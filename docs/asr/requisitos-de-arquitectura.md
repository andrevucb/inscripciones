# Requisitos de arquitectura (ASR)

| ID | Categoría | Escenario | Medida | Alcance |
|---|---|---|---|---|
| RA-03 | Seguridad | Cuando un estudiante envía una solicitud de inscripción con una materia que no está en su lista de materias habilitadas, el sistema rechaza la solicitud con error 403 y no la procesa. | 403, sin procesamiento | Fase 3 |
| RA-04 | Seguridad | Cuando un estudiante solicita la lista de materias habilitadas de otro estudiante, el sistema responde con error 403 y no devuelve información. | 403, sin datos expuestos | Fase 2 |
| RA-05 | Seguridad | Cuando se rechaza una solicitud por intento no habilitado, el sistema registra en el log el identificador del estudiante, la materia solicitada, la fecha y hora, y el origen de la petición. | Registro en menos de 1 s | Fases 2 y 3 |
| RA-08 | Mantenibilidad | Agregar una nueva regla de habilitación requiere modificar como máximo un módulo y no requiere desplegar otros servicios. | Módulos modificados ≤ 1 | Estructura modular |
| RA-10 | Integridad | Cuando 50 estudiantes intentan inscribirse de forma concurrente en el último cupo, exactamente 1 inscripción es confirmada y las 49 restantes reciben error de cupo agotado con alternativas (RA-14), sin que el cupo quede negativo. | Confirmadas = 1; cupo final ≥ 0 | Diseño en Fase 3; validación en Fase 6 (k6) |
| RA-11 | Reserva | Cuando un estudiante selecciona un horario con cupo disponible, el sistema retiene ese cupo para él durante 10 minutos. | Reserva = 10 min | Fase 3 |
| RA-12 | Reserva | Cuando vence una reserva sin confirmación, el cupo vuelve a estar disponible y ningún otro estudiante puede confirmarlo antes de esa liberación. | Liberación en menos de 5 s | Fase 4 |
| RA-13 | Liberación | Cuando un estudiante cancela una inscripción confirmada, el cupo queda disponible para otros estudiantes. | Liberación en menos de 1 s | Fase 3 |
| RA-14 | Alternativas | Cuando una inscripción falla por cupo agotado, la misma respuesta incluye las alternativas con cupo de la misma materia. | Alternativas en la misma respuesta | Fase 3 |
| RA-15 | Integridad | Una inscripción confirmada nunca excede la capacidad del horario, incluso si la vista de cupos está desactualizada. | Inscripciones ≤ capacidad | Fase 3 (`UPDATE` atómico + `CHECK`) |
| RA-01 | Rendimiento | Con 10,000 estudiantes únicos a lo largo de una jornada (máximo 500 concurrentes) y con 500 estudiantes concurrentes sostenidos, obtener la lista de materias habilitadas toma menos de 300 ms. | Percentil 95 | Fase 6 (k6) |
| RA-02 | Rendimiento | Con 10,000 estudiantes concurrentes, guardar el plan académico toma menos de 250 ms. | Percentil 90 | Fase 6 (k6) |
| RA-06 | Disponibilidad | Durante el periodo de inscripciones, el sistema está disponible al menos el 99% del tiempo. | Mensual ≥ 99% | Fuera del POC |
| RA-07 | Resiliencia | Si el servidor principal falla, el tráfico se dirige al servidor auxiliar sin pérdida de transacciones confirmadas. | Failover en menos de 1 min | Fuera del POC |
| RA-09 | Frescura | Cuando un cupo cambia de estado, la cantidad mostrada se actualiza. | Menos de 5 s | Fuera del POC (sin caché, la lectura es siempre fresca) |

## Decisiones de arquitectura que justifican el diseño

- **Monolito modular:** transacción local para descontar el cupo e inscribir, lo que evita inconsistencias entre servicios (RA-10, RA-15).
- **Sin CQRS ni caché en esta etapa:** lo más simple primero; se agregan solo si una medición lo exige.
- **La decisión de inscribir siempre se toma contra la base de datos principal**, nunca contra datos en caché o réplicas (RA-15).
