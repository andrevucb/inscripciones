# RA-01 — Capacidad (500 VUs)

- Generado: 2026-11-17T21:20:35.891Z
- Resultado: ❌ FAIL
- Duración de la corrida: 510,35 s

500 VUs sostenidos durante 8 minutos, rotando por los 10.000 tokens del dataset. Este es el escenario que valida el requisito de 500 estudiantes concurrentes.

## Métricas del escenario (`escenario:capacidad`)

| Métrica | Valor |
|---|---:|
| Requests | 874.445 |
| RPS | 1713,41 |
| Checks correctos | 100,00% |
| Fallos HTTP | 0,00% |
| Iteraciones descartadas | — |
| VUs máximos | 500 |

## Latencia — `http_req_duration{escenario:capacidad}`

| avg | med | p(90) | p(95) | p(99) | max |
|---:|---:|---:|---:|---:|---:|
| 274,16 ms | 271,65 ms | 310,04 ms | 322,70 ms | 352,66 ms | 1229,87 ms |

## Umbrales

| Métrica | Umbral | Resultado |
|---|---|---|
| `checks{endpoint:materias_habilitadas,escenario:capacidad}` | rate>0.99 | ✅ |
| `http_req_failed{endpoint:materias_habilitadas,escenario:capacidad}` | rate<0.01 | ✅ |
| `http_req_duration{endpoint:materias_habilitadas,escenario:capacidad}` | p(95)<300 | ❌ |
| `http_req_duration{endpoint:materias_habilitadas,escenario:capacidad}` | p(99)<600 | ✅ |

Reporte generado por `lib/reporte.js` en `tests/k6/results/ra-01-capacidad.md`.
