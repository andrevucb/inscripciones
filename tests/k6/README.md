# Pruebas de carga k6 — RA-01

Medición de lectura de `GET /materias/habilitadas` con **10.000 estudiantes
únicos** y **500 estudiantes concurrentes**.

- Sin reservas, sin bloqueos y sin escrituras: solo `GET`.
- Dataset derivado de los horarios reales de `samples/*.pdf`.
- Dos escenarios independientes:
  - `ra-01-dia.js`: 10.000 estudiantes distribuidos en un día de inscripciones
    comprimido, una lectura por estudiante.
  - `ra-01-capacidad.js`: 500 VUs sostenidos durante 8 minutos, rotando por los
    10.000 tokens.

> El escenario del día valida la latencia de una jornada normal. Su concurrencia
> máxima ronda las 24–30 peticiones en vuelo, no 500. El escenario de capacidad es
> el que valida el requisito de 500 estudiantes a la vez.

## Requisitos

- Docker con PostgreSQL (`docker compose up -d`).
- .NET SDK y `dotnet-ef` (`dotnet tool install --global dotnet-ef` si falta).
- Node 20+ para generar el catálogo, el seed y los tokens.
- k6. **No hace falta Brew**: usa el binario oficial o Docker.

### Instalar k6 sin Brew (binario oficial)

```bash
url=$(node -e "
  fetch('https://api.github.com/repos/grafana/k6/releases/latest', {
    headers: { 'User-Agent': 'k6-install' }
  })
    .then((r) => r.json())
    .then((j) => {
      const asset = j.assets.find((a) => /macos-amd64\.zip$/.test(a.name));
      if (!asset) process.exit(1);
      console.log(asset.browser_download_url);
    });
")

curl -L "$url" -o /tmp/k6.zip
rm -rf /tmp/k6 && unzip -q /tmp/k6.zip -d /tmp/k6
mkdir -p "$HOME/.local/bin"
find /tmp/k6 -type f -name k6 -exec install {} "$HOME/.local/bin/k6" \;
xattr -d com.apple.quarantine "$HOME/.local/bin/k6" 2>/dev/null || true
export PATH="$HOME/.local/bin:$PATH"
k6 version
```

Para mediciones oficiales se recomienda este binario nativo. Docker sirve como
alternativa sin instalación, pero agrega la red/VM de Docker.

## 1. Base de datos dedicada

Se usa `inscripciones_k6` para no mezclar los 10.000 usuarios con los datos de
desarrollo.

```bash
docker compose up -d

docker exec -it inscripciones-postgres \
  psql -U inscripciones -d postgres -c 'CREATE DATABASE inscripciones_k6;'

export ConnectionStrings__Inscripciones='Host=localhost;Port=5432;Database=inscripciones_k6;Username=inscripciones;Password=inscripciones'

dotnet ef database update \
  --project src/Shared \
  --startup-project src/Inscripciones.Api
```

Arranca la API una vez para que el seeder cree los usuarios base (Ana Torres y
compañía) y luego detenla:

```bash
dotnet run --project src/Inscripciones.Api
# esperar el log del seeder y cortar con Ctrl+C
```

## 2. Generar el dataset

El catálogo ya está versionado en `tests/k6/data/catalogo.json`. Solo necesitas
regenerarlo si cambian los PDFs de `samples/`.

```bash
cd tests/k6
npm install
npm run extraer-catalogo   # samples/*.pdf -> data/catalogo.json
npm run generar-seed       # data/catalogo.json -> data/seed-10k.sql
```

El seed genera, a partir de 6 carreras × 4 niveles:

| Elemento | Cantidad |
|---|---:|
| Cohortes carrera/nivel | 24 |
| Materias | 132 |
| Horarios (grupos) | 299 |
| Estudiantes `k6-00001` … `k6-10000` | 10.000 |
| Materias habilitadas | 55.000 |

Cada estudiante queda con 5 o 6 materias; cada materia con 2 o 3 grupos reales.
Los usuarios usan `k6.NNNNN@inscripciones.local` / `Estudiante1!` y copian el
`PasswordHash` de Ana Torres.

Aplica el seed:

```bash
cd ../..
docker exec -i inscripciones-postgres \
  psql -U inscripciones -d inscripciones_k6 < tests/k6/data/seed-10k.sql
```

El SQL es idempotente para el dataset k6: borra usuarios `k6-%` y materias con
`Id` entre 1000 y 1999 antes de recrearlos. No toca los datos base del seeder.

## 3. Arrancar la API para la prueba

La API debe escuchar en `0.0.0.0` para que un contenedor k6 pueda alcanzarla.
No reinicies la API entre la generación de tokens y las corridas.

```bash
export ConnectionStrings__Inscripciones='Host=localhost;Port=5432;Database=inscripciones_k6;Username=inscripciones;Password=inscripciones'
export ASPNETCORE_URLS='http://0.0.0.0:5124'
export Logging__LogLevel__Default='Warning'
export Logging__LogLevel__Microsoft.AspNetCore='Warning'
export Logging__LogLevel__Microsoft.EntityFrameworkCore='Warning'

dotnet run -c Release --no-launch-profile --project src/Inscripciones.Api
```

El nivel `Warning` evita que las ~10.000 peticiones por corrida llenen el disco
con logs de ASP.NET; igual quedan visibles los errores.

Verifica desde otra terminal:

```bash
curl -s http://localhost:5124/salud
```

## 4. Generar los 10.000 tokens

Los bearer tokens de Identity vencen (normalmente en 1 hora). Genera el archivo
justo antes de medir y mantén la sesión completa por debajo de ~45 minutos.

```bash
caffeinate -dimsu node tests/k6/scripts/generar-tokens.mjs \
  --api http://localhost:5124 \
  --desde 1 \
  --hasta 10000 \
  --concurrencia 32
```

Salida: `tests/k6/data/estudiantes.json` con `{ email, accessToken, expiresAt }`,
modo `600` y **gitignored**. El script verifica tres tokens contra
`/materias/habilitadas` antes de escribir el archivo.

Opciones útiles:

```text
--prefijo k6 --dominio inscripciones.local --password 'Estudiante1!'
--reintentos 5 --timeout 30 --out tests/k6/data/estudiantes.json
```

## 5. Ejecutar las pruebas

### Binario nativo

En macOS, envuelve la corrida con `caffeinate -dimsu` para que el equipo no
entre en reposo durante la medición:

```bash
caffeinate -dimsu k6 run tests/k6/ra-01-dia.js
caffeinate -dimsu k6 run tests/k6/ra-01-capacidad.js
```

Si el equipo duerme, k6 registra picos de varios minutos, algunas franjas
pierden estudiantes y la generación de tokens se vuelve errática. En Linux no
hace falta; solo asegúrate de que la máquina no suspenda.

### Docker

```bash
export API_BASE_URL=http://host.docker.internal:5124

docker run --rm -i \
  --add-host=host.docker.internal:host-gateway \
  -v "$PWD/tests/k6:/scripts" \
  -e API_BASE_URL \
  grafana/k6 run /scripts/ra-01-dia.js

docker run --rm -i \
  --add-host=host.docker.internal:host-gateway \
  -v "$PWD/tests/k6:/scripts" \
  -e API_BASE_URL \
  grafana/k6 run /scripts/ra-01-capacidad.js
```

Si `host.docker.internal` no resuelve (por ejemplo con Colima), usa la IP del
host:

```bash
export API_BASE_URL="http://$(ipconfig getifaddr en0):5124"
```

Variables de entorno:

| Variable | Default | Uso |
|---|---|---|
| `API_BASE_URL` | `http://localhost:5124` | URL base de la API |
| `DATA_FILE` | `../data/estudiantes.json` | Ruta al archivo de tokens, relativa a `lib/estudiantes.js` |
| `ESTUDIANTES_ESPERADOS` | `10000` | Mínimo de tokens a cargar |
| `MARGEN_EXPIRACION_MINUTOS` | `10` | Falla si un token vence dentro de ese margen |
| `HTTP_TIMEOUT` | `10s` | Timeout por petición HTTP de k6 |

## 6. Escenario del día (`ra-01-dia.js`)

Día 08:00–20:00 comprimido a 240 s (20 s por hora simulada). Calentamiento de
20 s a 20 llegadas/s, 10 s de pausa y 12 escenarios `constant-arrival-rate`
consecutivos. Cada franja dura **21 s**: 20 s de la hora simulada más 1 s de
margen para que ningún estudiante del tramo quede sin leer.

| Hora | Estudiantes | Tasa |
|---|---:|---:|
| 08–09 | 1.600 | 80/s |
| 09–10 | 1.000 | 50/s |
| 10–11 | 800 | 40/s |
| 11–12 | 700 | 35/s |
| 12–13 | 900 | 45/s |
| 13–14 | 1.100 | 55/s |
| 14–15 | 700 | 35/s |
| 15–16 | 600 | 30/s |
| 16–17 | 700 | 35/s |
| 17–18 | 800 | 40/s |
| 18–19 | 900 | 45/s |
| 19–20 | 200 | 10/s |
| **Total** | **10.000** | |

Cada franja usa un rango disjunto de índices de estudiantes, así que no hay
lecturas repetidas entre horas. Las franjas se solapan durante el segundo de
margen, pero siguen usando estudiantes distintos. `preAllocatedVUs = 30` y
`maxVUs = 60` por franja; solo hay una franja activa a la vez, muy por debajo de
500 VUs.

Umbrales medidos solo en `escenario:dia`:

```text
http_req_duration p95 < 300 ms
http_req_duration p99 < 600 ms
http_req_failed   < 1 %
checks            > 99 %
http_reqs         >= 10.000
dropped_iterations = 0
```

El calentamiento se etiqueta `escenario:calentamiento` y no entra en los umbrales
del día.

## 7. Escenario de capacidad (`ra-01-capacidad.js`)

- Calentamiento: 20 s a 20 llegadas/s.
- Capacidad: desde el segundo 30, **500 VUs durante 8 minutos**, sin pausa entre
  iteraciones, para mantener 500 lecturas en vuelo.
- Cada iteración toma el siguiente token del pool de 10.000, así que se recorren
  todos los catálogos.

Umbrales en `escenario:capacidad`:

```text
http_req_duration p95 < 300 ms
http_req_duration p99 < 600 ms
http_req_failed   < 1 %
checks            > 99 %
```

Este escenario es el que puede exponer límites de Npgsql (pool por defecto de
100 conexiones), tres consultas secuenciales por request, validación de tokens y
saturación de Kestrel/PostgreSQL. Si falla el p95, ese es el hallazgo a reportar
antes de optimizar.

## 8. Qué valida cada respuesta

Además de `200` y `Content-Type: application/json`:

- El cuerpo es un arreglo.
- Tiene exactamente 5 o 6 materias (según el seed).
- No hay `materiaId` duplicados.
- Cada materia tiene nombre y al menos un horario.
- Cada horario tiene `horarioId`, `descripcion` no vacía y
  `cuposDisponibles >= 0`.

## 9. Repetir y reportar

Cada corrida genera automáticamente un reporte Markdown en
`tests/k6/results/ra-01-dia.md` o `tests/k6/results/ra-01-capacidad.md`, con
métricas del escenario, latencias y resultado de cada umbral. La carpeta está
gitignored; créala si no existe:

```bash
mkdir -p tests/k6/results
```

La consola muestra un resumen corto con el mismo resultado (PASS/FAIL) y la
ruta del reporte. Para guardar también la salida de consola, redirígela:

```bash
caffeinate -dimsu k6 run tests/k6/ra-01-dia.js > tests/k6/results/dia.log 2>&1
```

- Corre el escenario del día 3 veces y reporta mediana y peor p95.
- No reinicies la API ni regeneres la base entre corridas: las lecturas son
  idempotentes.
- Si la sesión supera la vigencia de los tokens, vuelve a generarlos.
- Reporta p50/p90/p95/p99, RPS, VUs máximos, requests totales y errores.
  El resumen de k6 ya incluye esos valores.

### Resultados de referencia

Corrida local del 2026-11-17 sobre macOS x86-64 (16 vCPU lógicas), API .NET 10
en Release y PostgreSQL 18 en Docker, todo en la misma máquina, con el catálogo
de materias cacheado en memoria (`MateriasCache`) y los horarios leídos de la
base en cada petición para no servir `CuposDisponibles` desactualizados:

| Escenario | Requests | p95 | p99 | Errores | Duración |
|---|---:|---:|---:|---:|---:|
| Día (10.000 estudiantes) | 10.510 | 5,99 ms | 6,35 ms | 0 | 4m31s |
| Capacidad (500 VUs) | 1.305.923 | 222,82 ms | 248,14 ms | 0 | 8m30s |

El escenario de capacidad sostuvo ~2.560 req/s con 500 VUs y 0% de fallos. Sin
la caché de materias la misma corrida daba p95 ~323 ms y superaba el umbral de
300 ms; el cambio eliminó una consulta por petición sin cachear los cupos. El
escenario del día es holgado porque su concurrencia máxima ronda las 30
peticiones en vuelo.

## 10. Archivos

```text
tests/k6/
  ra-01-dia.js                  escenario de día completo
  ra-01-capacidad.js            escenario sostenido de 500 VUs
  lib/api.js                    request helper y verificación de humo
  lib/checks.js                 validación de estado y forma del JSON
  lib/estudiantes.js            SharedArray de tokens + control de vigencia
  lib/reporte.js                handleSummary -> reporte Markdown en results/
  scripts/extraer-catalogo.mjs  PDFs de samples/ -> catalogo.json
  scripts/generar-seed.mjs      catalogo.json -> seed-10k.sql
  scripts/generar-tokens.mjs    10.000 logins -> estudiantes.json
  data/catalogo.json            catálogo versionado
  data/seed-10k.sql             seed generado y versionado
  data/estudiantes.json         tokens generados (gitignored)
  results/                      reportes Markdown generados (gitignored)
```

## 11. Problemas frecuentes

| Síntoma | Causa probable |
|---|---|
| `401` en la verificación inicial | Tokens vencidos, o el seed se aplicó en otra base |
| `0` materias o checks de forma fallando | No se ejecutó `seed-10k.sql` |
| `dropped_iterations > 0` en el día | Latencia alta para los VUs reservados en esa franja |
| Picos de varios minutos o franjas incompletas | El equipo entró en reposo: usa `caffeinate -dimsu` en macOS |
| Generación de tokens mucho más lenta de lo normal | El equipo entró en reposo: usa `caffeinate -dimsu` |
| `host.docker.internal` no resuelve | Usa la IP del host (`ipconfig getifaddr en0`) |
| p95 alto solo en capacidad | Consultas secuenciales por petición, pool de conexiones o CPU/IO de PostgreSQL |
| k6 no encuentra `estudiantes.json` | Ejecuta desde la raíz del repo y revisa `DATA_FILE` |
| Error de sintaxis al importar `fs` | k6 no es Node: usa `open()`/`SharedArray`, no módulos de Node |

Los scripts k6 no deben importar paquetes npm ni usar `fs`. La generación de
datos y tokens vive en los `.mjs` de Node; k6 solo lee el JSON con `open()`.
