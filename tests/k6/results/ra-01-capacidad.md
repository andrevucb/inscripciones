# RA-01 — Capacidad (500 VUs)

- Generado: 2026-11-17T21:45:56.886Z
- Resultado: ✅ PASS
- Duración de la corrida: 510,20 s

500 VUs sostenidos durante 8 minutos, rotando por los 10.000 tokens del dataset. Este es el escenario que valida el requisito de 500 estudiantes concurrentes.

## Métricas del escenario (`escenario:capacidad`)

| Métrica | Valor |
|---|---:|
| Requests | 1.305.923 |
| RPS | 2559,62 |
| Checks correctos | 100,00% |
| Fallos HTTP | 0,00% |
| Iteraciones descartadas | — |
| VUs máximos | 500 |

## Latencia — `http_req_duration{escenario:capacidad}`

| avg | med | p(90) | p(95) | p(99) | max |
|---:|---:|---:|---:|---:|---:|
| 183,40 ms | 181,73 ms | 212,36 ms | 222,82 ms | 248,14 ms | 1020,35 ms |

## Umbrales

| Métrica | Umbral | Resultado |
|---|---|---|
| `checks{endpoint:materias_habilitadas,escenario:capacidad}` | rate>0.99 | ✅ |
| `http_req_duration{endpoint:materias_habilitadas,escenario:capacidad}` | p(95)<300 | ✅ |
| `http_req_duration{endpoint:materias_habilitadas,escenario:capacidad}` | p(99)<600 | ✅ |
| `http_req_failed{endpoint:materias_habilitadas,escenario:capacidad}` | rate<0.01 | ✅ |

Reporte generado por `lib/reporte.js` en `tests/k6/results/ra-01-capacidad.md`.
