# RA-01 — Día (10.000 estudiantes)

- Generado: 2026-11-17T21:50:40.573Z
- Resultado: ✅ PASS
- Duración de la corrida: 271,02 s

Jornada comprimida de 08:00 a 20:00: 12 franjas de 21 s con tasa de llegada constante. Cada estudiante del dataset se lee al menos una vez; el pico de concurrencia ronda las 30 peticiones en vuelo.

## Métricas del escenario (`escenario:dia`)

| Métrica | Valor |
|---|---:|
| Requests | 10.510 |
| RPS | 38,78 |
| Checks correctos | 100,00% |
| Fallos HTTP | 0,00% |
| Iteraciones descartadas | 0 |
| VUs máximos | 60 |

## Latencia — `http_req_duration{escenario:dia}`

| avg | med | p(90) | p(95) | p(99) | max |
|---:|---:|---:|---:|---:|---:|
| 5,06 ms | 5,14 ms | 5,82 ms | 5,99 ms | 6,35 ms | 12,06 ms |

## Umbrales

| Métrica | Umbral | Resultado |
|---|---|---|
| `http_req_failed{endpoint:materias_habilitadas,escenario:dia}` | rate<0.01 | ✅ |
| `http_reqs{endpoint:materias_habilitadas,escenario:dia}` | count>=10000 | ✅ |
| `dropped_iterations{escenario:dia}` | count<1 | ✅ |
| `http_req_duration{endpoint:materias_habilitadas,escenario:dia}` | p(99)<600 | ✅ |
| `http_req_duration{endpoint:materias_habilitadas,escenario:dia}` | p(95)<300 | ✅ |
| `checks{endpoint:materias_habilitadas,escenario:dia}` | rate>0.99 | ✅ |

Reporte generado por `lib/reporte.js` en `tests/k6/results/ra-01-dia.md`.
