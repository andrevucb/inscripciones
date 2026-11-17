# Usuarios de prueba para k6

El seeder crea estos usuarios base con `EmailConfirmed = true` y la misma
contraseña.

| Estudiante | Email | Contraseña | Materias habilitadas |
|---|---|---|---|
| Ana Torres | `ana.torres@inscripciones.local` | `Estudiante1!` | Cálculo I, Física Básica, Programación I |
| Bruno Díaz | `bruno.diaz@inscripciones.local` | `Estudiante1!` | Cálculo I, Programación I |
| Carla Ruiz | `carla.ruiz@inscripciones.local` | `Estudiante1!` | Física Básica |

Para las pruebas de carga de RA-01 no se usan solo estos tres usuarios: se genera
un dataset de **10.000 estudiantes** en una base dedicada. La guía completa está
en [`tests/k6/README.md`](../tests/k6/README.md).

## Dataset de 10.000 estudiantes

El seed `tests/k6/data/seed-10k.sql` crea:

- Usuarios `k6.00001@inscripciones.local` … `k6.10000@inscripciones.local`.
- Contraseña `Estudiante1!` (copian el `PasswordHash` de Ana Torres).
- `Id` deterministas `k6-00001` … `k6-10000`.
- 5 o 6 materias habilitadas por estudiante, distribuidas en 24 cohortes
  carrera/nivel.
- Catálogo y horarios tomados de los PDFs de `samples/`.

Se recomienda aplicarlo en una base separada para no mezclarlo con los datos de
desarrollo:

```bash
docker exec -it inscripciones-postgres \
  psql -U inscripciones -d postgres -c 'CREATE DATABASE inscripciones_k6;'
```

Después de migrar y arrancar la API una vez (para que exista Ana Torres):

```bash
docker exec -i inscripciones-postgres \
  psql -U inscripciones -d inscripciones_k6 < tests/k6/data/seed-10k.sql
```

## Obtener un token

```bash
API=http://localhost:5124

curl -s -X POST "$API/login?useCookies=false" \
  -H 'Content-Type: application/json' \
  -d '{"email":"ana.torres@inscripciones.local","password":"Estudiante1!"}'
```

La respuesta incluye `accessToken`. Se usa en los endpoints protegidos:

```bash
curl "$API/materias/habilitadas" -H "Authorization: Bearer <accessToken>"
```

## Tokens para todos los usuarios

El script de Node autentica los 10.000 usuarios con concurrencia, reintenta
fallos transitorios, verifica una muestra y escribe el archivo que k6 carga con
`SharedArray`:

```bash
caffeinate -dimsu node tests/k6/scripts/generar-tokens.mjs \
  --api http://localhost:5124 \
  --desde 1 \
  --hasta 10000 \
  --concurrencia 32 \
  --out tests/k6/data/estudiantes.json
```

En macOS conviene usar `caffeinate -dimsu`: si el equipo entra en reposo, los
10.000 logins se vuelven erráticos y pueden superar el tiempo de espera.

El archivo tiene la forma:

```json
[
  {
    "email": "k6.00001@inscripciones.local",
    "accessToken": "...",
    "expiresAt": 1760000000000
  }
]
```

Se escribe con modo `600` y está en `.gitignore`. Los tokens vencen (normalmente
en 1 hora): genéralos justo antes de la prueba y no reinicies la API después.

## Notas para k6

- Los tokens vencen; si la sesión se alarga, vuelve a ejecutar
  `generar-tokens.mjs`.
- El seeder solo corre si la tabla `Materias` está vacía; con la base ya poblada
  los usuarios existen.
- El seed de 10k es idempotente para su propio dataset: borra `k6-%` y las
  materias con `Id` entre 1000 y 1999.
- Para los escenarios del último cupo, cada materia base tiene un horario con
  `CuposTotales = 1`.
- Los cupos se modifican con las pruebas manuales. Para repetir un escenario
  desde cero, restaura `CuposDisponibles = CuposTotales` y elimina las filas de
  `Inscripciones`.
- Los scripts de k6 no son Node: usan `open()` y `SharedArray`, no `fs` ni npm.
