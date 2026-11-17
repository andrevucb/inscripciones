# Inscripciones (POC)

Sistema de inscripciones académicas construido como **monolito modular** con ASP.NET Core Minimal APIs (.NET 10) y PostgreSQL 18. Documento de referencia: [`poc_inscripciones_agente.md`](poc_inscripciones_agente.md).

**Estado:** Fases 1 a 5 completas y verificadas. La Fase 6 (pruebas de carga con k6) la ejecuta el usuario.

**Actualizado:** 2026-11-16.

## Índice

- [Estado actual](#estado-actual)
- [Stack](#stack)
- [Requisitos](#requisitos)
- [Estructura](#estructura)
- [Puesta en marcha](#puesta-en-marcha)
- [Base de datos](#base-de-datos)
- [Modelo de datos](#modelo-de-datos)
- [API](#api)
- [Datos de prueba](#datos-de-prueba)
- [Pruebas](#pruebas)
- [Decisiones](#decisiones)
- [Notas de entorno](#notas-de-entorno)
- [Pendiente](#pendiente)

## Estado actual

Está implementado:

- Solución `Inscripciones.slnx` con `Inscripciones.Api`, cuatro módulos (`Catalogo`, `Habilitacion`, `Inscripciones`, `Auditoria`), `Shared` y pruebas.
- PostgreSQL 18 en Docker con volumen persistente.
- EF Core con un `AppDbContext` único y la migración `20261116150150_Inicial` aplicada.
- ASP.NET Core Identity con tokens bearer (`MapIdentityApi<ApplicationUser>()`).
- `IEstudianteActual` para obtener el id del estudiante desde el token.
- Seeder idempotente con materias de la facultad de tecnología, horarios, estudiantes y habilitaciones.
- `GET /salud` anónimo.
- **Fase 2:** consulta de materias habilitadas por estudiante, control de acceso a listas ajenas y auditoría de rechazos.
- **Fase 3:** reservas con descuento atómico de cupo, alternativas cuando se agota, confirmación y cancelación con liberación inmediata.
- **Fase 4:** expiración automática de reservas con liberación idempotente del cupo.
- **Fase 5:** pruebas funcionales automatizadas contra PostgreSQL real, este README y [`docs/usuarios-k6.md`](docs/usuarios-k6.md).

| Verificación | Resultado |
|---|---|
| `dotnet build` | 0 warnings / 0 errores |
| `dotnet test` | 9/9 (2 unitarias + 7 de integración) |
| Migración aplicada | `20261116150150_Inicial` |
| Seeder | 3 materias, 8 horarios, 3 estudiantes, 6 habilitaciones (idempotente) |
| `GET /salud` | 200 anónimo |
| Endpoint protegido sin token | 401 |
| Registro + login + token | 200 / 200 / 200 |
| Materias habilitadas | Ana ve 3 materias; Carla ve 1 |
| Lista ajena | 403 con cuerpo vacío + fila en `IntentosRechazados` |
| Reserva | 201, cupo −1, vence a los 5 minutos |
| Materia no habilitada | 403, cupo sin cambios y auditoría con `MateriaId` |
| Último cupo | Primera reserva 201; segunda 409 `cupo_agotado` con alternativas; cupo final 0 |
| Confirmación | 200 `Confirmada` sin tocar el cupo; fuera de plazo 409 `reserva_expirada` |
| Cancelación | 200 `Cancelada` y cupo devuelto; segunda cancelación 409 sin liberar de nuevo |
| Expiración | Reserva vencida → `Expirada`, cupo liberado exactamente una vez |
| Inscripción ajena | 403 al confirmar o cancelar |

## Stack

| Aspecto | Decisión |
|---|---|
| Plataforma | .NET 10 (LTS), ASP.NET Core Minimal APIs |
| Autenticación | ASP.NET Core Identity, individual auth, tokens bearer |
| Acceso a datos | EF Core 10.0.15 (Npgsql 10.0.3) |
| Base de datos | PostgreSQL 18 en Docker |
| Pruebas | xUnit 2.9.3, `WebApplicationFactory` y `Microsoft.AspNetCore.Mvc.Testing` 10.0.15 |
| Pruebas de carga | k6 (Fase 6, fuera del alcance del agente) |

## Requisitos

- .NET SDK 10 o superior (probado con 10.0.404 y 11.0.100).
- `dotnet-ef` (probado con 11.0.0):
  ```bash
  dotnet tool install --global dotnet-ef
  ```
- Docker con la imagen `postgres:18`.
- Docker Compose v2 recomendado. Si solo hay Compose v1, ver [Notas de entorno](#notas-de-entorno).
- Para correr las pruebas: PostgreSQL levantado y el usuario `inscripciones` con permiso para crear bases. Las pruebas crean y recrean `inscripciones_tests`; **no tocan** la base `inscripciones`.

## Estructura

```
Inscripciones.slnx
docker-compose.yml
src/
  Inscripciones.Api/
    Program.cs                      -> composición: DbContext, Identity, módulos, endpoints
    Seeding/Seeder.cs               -> datos de prueba idempotentes
    appsettings.json                -> conexión y opciones de reservas
  Modules/
    Catalogo/
      Contracts/                    -> ICatalogoService, materias/horarios
      Domain/                       -> Materia, Horario
      Data/                         -> CatalogoModelConfiguration, CatalogoService
    Habilitacion/
      Contracts/                    -> IHabilitacionService, respuestas
      Domain/                       -> MateriaHabilitada
      Data/                         -> HabilitacionModelConfiguration, HabilitacionService
      Endpoints/                    -> HabilitacionEndpoints
    Inscripciones/
      Contracts/                    -> IInscripcionesService, requests/responses y resultados
      Domain/                       -> Inscripcion, EstadoInscripcion
      Data/                         -> configuraciones, servicios de reservas y expiración
      Endpoints/                    -> InscripcionesEndpoints
      InscripcionesOptions.cs       -> duración e intervalo de revisión
    Auditoria/
      Contracts/                    -> IAuditoriaService
      Domain/                       -> IntentoRechazado
      Data/                         -> AuditoriaModelConfiguration, AuditoriaService
  Shared/
    Data/AppDbContext.cs            -> único DbContext (incluye Identity)
    Data/IModuleModelConfiguration.cs
    Identity/ApplicationUser.cs
    Identity/IEstudianteActual.cs
    Identity/EstudianteActual.cs
    Migrations/                     -> migración inicial y snapshot
tests/
  Inscripciones.Tests/
    Shared/EstudianteActualTests.cs
    Integration/InscripcionesApiFactory.cs
    Integration/InscripcionesEndpointsTests.cs
    Integration/AssemblyInfo.cs
tests/k6/
  README.md                         -> dataset de 10k, tokens y escenarios RA-01
  ra-01-dia.js                      -> 10.000 estudiantes en un día comprimido
  ra-01-capacidad.js                -> 500 VUs sostenidos
docs/
  usuarios-k6.md                    -> usuarios y tokens para k6
  asr/requisitos-de-arquitectura.md -> requisitos de arquitectura (ASR)
```

Cada módulo expone `AddXModule(IServiceCollection)` y `MapXEndpoints(IEndpointRouteBuilder)`. `Program.cs` solo compone. Los módulos se comunican por interfaces públicas (`ICatalogoService`, `IHabilitacionService`, `IAuditoriaService`), nunca accediendo a tablas de otro módulo.

## Puesta en marcha

1. Levantar PostgreSQL:

   ```bash
   docker compose up -d
   ```

2. Aplicar migraciones:

   ```bash
   dotnet ef database update --project src/Shared --startup-project src/Inscripciones.Api
   ```

3. Arrancar la API:

   ```bash
   dotnet run --project src/Inscripciones.Api
   # http://localhost:5124
   ```

   Al arrancar, el seeder carga los datos de prueba si la tabla `Materias` está vacía.

4. Correr las pruebas (con PostgreSQL levantado):

   ```bash
   dotnet test
   ```

## Base de datos

| Parámetro | Valor |
|---|---|
| Host / puerto | `localhost:5432` |
| Base de desarrollo | `inscripciones` |
| Base de pruebas | `inscripciones_tests` (se recrea en cada ejecución) |
| Usuario | `inscripciones` |
| Contraseña | `inscripciones` |
| Imagen | `postgres:18` |
| Volumen | `inscripciones_postgres_data` → `/var/lib/postgresql` |

Cadena de conexión (`src/Inscripciones.Api/appsettings.json`):

```
Host=localhost;Port=5432;Database=inscripciones;Username=inscripciones;Password=inscripciones
```

Opciones de reservas:

```json
"Inscripciones": {
  "DuracionReservaMinutos": 5,
  "IntervaloRevisionSegundos": 3
}
```

- `DuracionReservaMinutos`: vigencia de una reserva. **5 minutos** por decisión del product owner para escenarios de alta concurrencia.
- `IntervaloRevisionSegundos`: frecuencia del expirador. `3` segundos por defecto (mínimo 1), dentro del límite de RA-12.

Tablas: `Materias`, `Horarios`, `MateriasHabilitadas`, `Inscripciones`, `IntentosRechazados`, las tablas de Identity y `__EFMigrationsHistory`.

## Modelo de datos

| Tabla | Campos principales |
|---|---|
| `Materias` | `Id` (int), `Nombre` |
| `Horarios` | `Id`, `MateriaId`, `Descripcion`, `CuposTotales`, `CuposDisponibles` + `CHECK (CuposDisponibles >= 0)` |
| `MateriasHabilitadas` | `EstudianteId` (text), `MateriaId`; PK compuesta |
| `Inscripciones` | `Id`, `EstudianteId`, `HorarioId`, `Estado` (`Reservada`/`Confirmada`/`Cancelada`/`Expirada`), `CreadaEn`, `ExpiraEn` |
| `IntentosRechazados` | `Id`, `EstudianteId`, `MateriaId` (opcional), `FechaHora`, `Origen`, `Motivo` |
| `AspNetUsers` | usuario de Identity (`ApplicationUser`); `Id` es `text` |

## API

Todas las rutas usan JSON. Los endpoints marcados con Bearer requieren `Authorization: Bearer <accessToken>`.

| Método | Ruta | Autenticación | Descripción |
|---|---|---|---|
| GET | `/salud` | Anónimo | `200 {"estado":"ok"}` sin consultar la base |
| GET | `/materias/habilitadas` | Bearer | Materias habilitadas del estudiante autenticado, con horarios y cupos |
| GET | `/estudiantes/{estudianteId}/materias-habilitadas` | Bearer | Igual que la anterior solo si el id es el propio; si no, 403 |
| POST | `/inscripciones/reservas` | Bearer | Reserva `{ "horarioId": N }` |
| POST | `/inscripciones/{id}/confirmar` | Bearer | Confirma una reserva propia vigente |
| DELETE | `/inscripciones/{id}` | Bearer | Cancela una inscripción propia y libera el cupo |
| POST | `/register` | Anónimo | Registro de usuario (Identity) |
| POST | `/login?useCookies=false` | Anónimo | Login; devuelve el token bearer |
| POST | `/refresh` | Anónimo | Renueva el token |
| GET | `/manage/info` | Bearer | Endpoint protegido de Identity |

### Códigos de error

| HTTP | `error` | Cuándo |
|---|---|---|
| 401 | — | Falta el token en un endpoint protegido |
| 403 | cuerpo vacío | Materia no habilitada o inscripción/lista de otro estudiante |
| 404 | `horario_no_encontrado` | `horarioId` inexistente |
| 404 | `inscripcion_no_encontrada` | Id de inscripción inexistente |
| 409 | `inscripcion_activa` | Ya hay una reserva o inscripción activa para la materia |
| 409 | `cupo_agotado` | No quedan cupos; incluye `alternativas` |
| 409 | `reserva_expirada` | Se intenta confirmar una reserva vencida |
| 409 | `estado_invalido` | La inscripción ya está cancelada, expirada o confirmada |

### Ejemplos de respuesta

Materias habilitadas:

```json
[
  {
    "materiaId": 1,
    "nombre": "Cálculo I",
    "horarios": [
      { "horarioId": 1, "descripcion": "Lunes y miércoles 09:00", "cuposDisponibles": 30 }
    ]
  }
]
```

Reserva exitosa (`201`):

```json
{
  "id": 1,
  "horarioId": 5,
  "estado": "Reservada",
  "creadaEn": "2026-11-16T16:32:11.742052+00:00",
  "expiraEn": "2026-11-16T16:37:11.742052+00:00"
}
```

Cupo agotado (`409`):

```json
{
  "error": "cupo_agotado",
  "alternativas": [
    { "horarioId": 4, "descripcion": "Lunes y miércoles 11:00", "cuposDisponibles": 25 }
  ]
}
```

### Flujo completo con curl

```bash
API=http://localhost:5124

# 1. Login (guardar el token)
TOKEN=$(curl -s -X POST "$API/login?useCookies=false" \
  -H 'Content-Type: application/json' \
  -d '{"email":"ana.torres@inscripciones.local","password":"Estudiante1!"}' |
  python3 -c 'import json,sys; print(json.load(sys.stdin)["accessToken"])')

# 2. Ver materias habilitadas y elegir un horarioId
curl "$API/materias/habilitadas" -H "Authorization: Bearer $TOKEN"

# 3. Reservar (201; 409 cupo_agotado/inscripcion_activa; 403 si no está habilitada)
curl -X POST "$API/inscripciones/reservas" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"horarioId": 5}'

# 4. Confirmar (200)
curl -X POST "$API/inscripciones/1/confirmar" \
  -H "Authorization: Bearer $TOKEN"

# 5. Cancelar y liberar el cupo (200)
curl -X DELETE "$API/inscripciones/1" \
  -H "Authorization: Bearer $TOKEN"

# Registro de un usuario nuevo
curl -X POST "$API/register" \
  -H 'Content-Type: application/json' \
  -d '{"email":"alumno@ejemplo.com","password":"Alumno123!"}'
```

## Datos de prueba

El seeder corre al arrancar y solo actúa si `Materias` está vacía. Los usuarios se crean con email confirmado y contraseña `Estudiante1!`.

| Estudiante | Email | Materias habilitadas |
|---|---|---|
| Ana Torres | `ana.torres@inscripciones.local` | Cálculo I, Física Básica, Programación I |
| Bruno Díaz | `bruno.diaz@inscripciones.local` | Cálculo I, Programación I |
| Carla Ruiz | `carla.ruiz@inscripciones.local` | Física Básica |

| Materia | Horarios | Horario con 1 cupo |
|---|---|---|
| Cálculo I | 3 | Viernes 18:00 |
| Física Básica | 2 | Martes y jueves 16:00 |
| Programación I | 3 | Viernes 15:00 |

Los demás horarios tienen 20, 25 o 30 cupos. Los usuarios, tokens y notas para k6 están en [`docs/usuarios-k6.md`](docs/usuarios-k6.md).

## Pruebas

```bash
dotnet test
```

Resultado actual: **9/9**.

**Unitarias (2)**

- `EstudianteActual` devuelve el id del usuario autenticado.
- `EstudianteActual` devuelve `null` sin contexto HTTP.

**Integración (7)**, con `WebApplicationFactory<Program>` contra PostgreSQL real y ejecución **secuencial** (`DisableTestParallelization`):

| Prueba | Qué verifica |
|---|---|
| `MateriaNoHabilitada_Devuelve403_SinCambiarCupo_YRegistraAuditoria` | 403, cupo intacto y fila de auditoría con estudiante, materia, origen y motivo |
| `ListaAjena_Devuelve403_SinDatos_YRegistraAuditoria` | La lista propia responde 200; la de otro estudiante 403 sin cuerpo y con auditoría |
| `UltimoCupo_PrimeraReservaFunciona_SegundaRecibe409ConAlternativas` | 201 y cupo 0; segunda reserva 409 `cupo_agotado` con alternativas |
| `Cancelacion_DevuelveCupoDeInmediato` | Cancelación 200, estado `Cancelada`, cupo restaurado; segunda cancelación 409 |
| `Expiracion_LiberaCupoUnaSolaVez` | Vencida → `Expirada`, cupo liberado una vez; segunda pasada no libera |
| `ConfirmacionFueraDePlazo_Falla` | 409 `reserva_expirada` sin confirmar |
| `ConfirmacionExitosa_CambiaEstadoSinTocarCupo` | 200 `Confirmada` y cupo sin cambios |

Cómo funcionan:

- La fixture recrea la base `inscripciones_tests`, aplica las migraciones y deja que el seeder cargue los datos.
- Cada prueba limpia `Inscripciones` e `IntentosRechazados` y restaura `CuposDisponibles = CuposTotales`, por lo que el orden no afecta.
- El expirador se configura con un intervalo de una hora para no interferir; la prueba de expiración invoca directamente `ExpiracionReservasService.ExpirarVencidasAsync`, que es la misma lógica que usa el `BackgroundService`.
- La base de desarrollo `inscripciones` no se modifica.

## Decisiones

**Arquitectura**

- **.NET 10**: versión LTS vigente; todos los proyectos apuntan a `net10.0`.
- **Monolito modular, un solo despliegue y una sola base de datos**: sin CQRS, microservicios, MediatR, repositorios genéricos, mensajería, caché, réplicas ni front-end.
- **Módulos como bibliotecas**: cada módulo es un proyecto en `src/Modules` que referencia `Shared`. `Program.cs` solo registra y mapea módulos.
- **Comunicación por interfaces públicas**: `Habilitacion` usa `ICatalogoService` e `IAuditoriaService`; `Inscripciones` usa `ICatalogoService`, `IHabilitacionService` e `IAuditoriaService`. Ningún módulo consulta las tablas de otro.
- **Un solo `AppDbContext` en `Shared`**: hereda de `IdentityDbContext<ApplicationUser>`. Cada módulo registra su `IModuleModelConfiguration` en su `AddXModule`.
- **`IntentosRechazados` sin claves foráneas**: debe conservarse aunque se elimine el estudiante o la materia.
- **Claves `int` identity** en `Materias`, `Horarios`, `Inscripciones` e `IntentosRechazados`; `text` solo donde lo exige Identity.
- **Migraciones manuales en `Shared/Migrations`**: es el ensamblado del `DbContext`. `Shared` referencia Npgsql porque el código generado lo necesita. El arranque no migra.
- **Credenciales de desarrollo en `appsettings.json`**: fijas para el POC; no usar en producción.
- **Sin caché**: cada consulta lee PostgreSQL, por lo que los cupos mostrados están frescos.

**Datos e integridad**

- **Fechas `DateTimeOffset` → `timestamptz`**; los vencimientos se calculan con la hora del servidor.
- **`Estado` como texto** (`varchar(20)`), legible directamente en SQL.
- **`CHECK (CuposDisponibles >= 0)`**: la base también protege la integridad del cupo.
- **Reserva con `UPDATE` atómico**: `CuposDisponibles - 1 WHERE Id = @id AND CuposDisponibles > 0` en la misma transacción que inserta la `Inscripcion`. Si afecta 0 filas, rollback y 409 con alternativas; dos reservas concurrentes nunca dejan el cupo negativo.
- **Alternativas** (RA-14): otros horarios de la misma materia con `CuposDisponibles > 0`, consultados en ese momento y devueltos en el mismo 409.
- **Duración de la reserva 5 minutos** (RA-11): decisión del product owner para alta concurrencia; el documento de referencia sugería 10. Configurable en `Inscripciones:DuracionReservaMinutos`.
- **Inscripción activa**: para el 409 cuentan `Reservada` y `Confirmada` de cualquier horario de la materia. Una `Reservada` vencida bloquea hasta que el expirador la marque `Expirada`.
- **Confirmación**: solo el dueño, solo `Reservada` y con `ExpiraEn` futuro; no vuelve a tocar el cupo. Una vencida responde 409 `reserva_expirada`.
- **Cancelación**: `UPDATE` condicional a `Estado IN ('Reservada','Confirmada')` y devolución del cupo en la misma transacción. Dos cancelaciones concurrentes no liberan dos veces; la segunda recibe 409.
- **Expiración idempotente** (RA-12): por cada reserva vencida, una transacción con `UPDATE ... SET Estado = 'Expirada' WHERE Id = @id AND Estado = 'Reservada'`; solo si afecta una fila llama a `ICatalogoService.LiberarCupo`. Dos instancias o dos ciclos no devuelven el cupo dos veces.
- **Liberación por interfaz**: `Inscripciones` no actualiza `Horarios` directamente; usa `ICatalogoService.LiberarCupo` dentro de su transacción.
- **Solo expira `Reservada`**: una `Confirmada` conserva el cupo aunque su `ExpiraEn` haya pasado.
- **Intervalo de revisión configurable**: `Inscripciones:IntervaloRevisionSegundos` (3 por defecto, mínimo 1).
- **Errores aislados en el expirador**: se registran en el log y el siguiente ciclo continúa.

**Seguridad y auditoría**

- **`ApplicationUser` en `Shared`** con clave `string` (`AspNetUsers.Id` es `text`); las FK de estudiante usan el mismo tipo.
- **`IEstudianteActual`** lee `ClaimTypes.NameIdentifier` del `ClaimsPrincipal` con `IHttpContextAccessor`. El id sale siempre del token, nunca del cuerpo ni de la URL.
- **Lista ajena**: se compara el id de la ruta con el del token (ordinal); si no coincide, 403 con cuerpo vacío, sin consultar datos y con auditoría.
- **Auditoría de rechazos (RA-05)**: `IntentosRechazados` guarda estudiante, materia (si aplica), `FechaHora` (`DateTimeOffset.UtcNow`), `Origen` (`RemoteIpAddress`; `"desconocido"` si falta) y motivo. Se escribe antes de responder el 403. No se usa `X-Forwarded-For` porque el POC no está detrás de un proxy.
- **Materia no habilitada al reservar**: 403, sin descontar cupo y con auditoría de la materia solicitada.
- **Inscripción ajena**: confirmar o cancelar responde 403 sin datos. No se audita porque RA-05 solo exige los rechazos por materia no habilitada.
- **Sin envío de correos**: no hay `IEmailSender` real; el registro no confirma el email y el login funciona igual. Los usuarios del seeder se crean con `EmailConfirmed = true`.
- **`/salud` anónimo y sin base de datos**: chequeo de vida, no de disponibilidad de PostgreSQL.

**Pruebas**

- **PostgreSQL real, no SQLite**: las pruebas cubren transacciones, `CHECK` y SQL atómico.
- **Ejecución secuencial**: `DisableTestParallelization` evita que las pruebas compartan estado y cupos.
- **Base `inscripciones_tests` aislada**: se elimina y recrea en cada ejecución, se migra antes de arrancar la API y el seeder la puebla. La base de desarrollo no se toca.
- **Reseteo por prueba**: se borran `Inscripciones` e `IntentosRechazados` y se restauran los cupos, para que el orden no importe.
- **Expirador con intervalo largo en pruebas**: evita interferencias; la prueba de expiración llama a `ExpiracionReservasService`, la misma lógica del `BackgroundService`.

**Datos de prueba**

- **Seeder idempotente**: solo corre si `Materias` está vacía; reiniciar la API no duplica datos.
- **Materias de la facultad de tecnología** y **un horario de 1 cupo por materia** para probar el último cupo.
- **Tres estudiantes con listas distintas** (3, 2 y 1 materias) para probar accesos permitidos y rechazados.

## Notas de entorno

- **Compose v1 no funciona localmente**: el `docker-compose` 1.29.2 instalado por MacPorts es incompatible con el SDK de Docker actual (`kwargs_from_env() got an unexpected keyword argument 'ssl_version'`). El `docker-compose.yml` está listo para Compose v2.
- Mientras no haya Compose v2, la base se levanta con el equivalente:

  ```bash
  docker run -d --name inscripciones-postgres \
    -e POSTGRES_DB=inscripciones \
    -e POSTGRES_USER=inscripciones \
    -e POSTGRES_PASSWORD=inscripciones \
    -p 5432:5432 \
    -v inscripciones_postgres_data:/var/lib/postgresql \
    postgres:18
  ```

- El contenedor `inscripciones-postgres` está levantado con esa variante. Si se instala Compose v2, conviene eliminarlo antes (`docker rm -f inscripciones-postgres`) para que Compose cree el suyo.
- La base `inscripciones_tests` queda creada después de correr las pruebas; en la siguiente ejecución se elimina y recrea.
- Las pruebas asumen PostgreSQL en `localhost:5432` con usuario y contraseña `inscripciones`. Si cambias esos valores, ajusta `tests/Inscripciones.Tests/Integration/InscripcionesApiFactory.cs`.

## Pendiente

- **Fase 6 (k6, la ejecuta el usuario)**: último cupo concurrente, latencia de lectura, latencia de escritura y reservas que vencen bajo carga. Usar [`docs/usuarios-k6.md`](docs/usuarios-k6.md) para los usuarios base y [`tests/k6/README.md`](tests/k6/README.md) para el dataset de 10.000 estudiantes, los tokens y los escenarios de RA-01.
