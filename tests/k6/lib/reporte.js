/**
 * Genera un reporte Markdown al terminar cada corrida de k6.
 *
 * k6 llama a handleSummary(data) con todas las métricas ya agregadas. Al
 * devolver una entrada 'stdout' reemplazamos el resumen por defecto de la
 * consola por una versión corta; el detalle queda en tests/k6/results/.
 */

const DIRECTORIO_RESULTADOS = 'tests/k6/results';

function claveMetrica(data, nombre, escenario) {
  const conEtiqueta = Object.keys(data.metrics).find(
    (clave) => clave.startsWith(`${nombre}{`) && clave.includes(`escenario:${escenario}`)
  );

  return conEtiqueta ?? nombre;
}

function valores(data, nombre, escenario) {
  return data.metrics[claveMetrica(data, nombre, escenario)]?.values ?? null;
}

function numero(valor) {
  return typeof valor === 'number' && Number.isFinite(valor) ? valor : null;
}

function ms(valor) {
  const n = numero(valor);
  return n === null ? '—' : `${n.toFixed(2).replace('.', ',')} ms`;
}

function porcentaje(valor) {
  const n = numero(valor);
  return n === null ? '—' : `${(n * 100).toFixed(2).replace('.', ',')}%`;
}

function entero(valor) {
  const n = numero(valor);
  return n === null ? '—' : Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

function decimal(valor) {
  const n = numero(valor);
  return n === null ? '—' : n.toFixed(2).replace('.', ',');
}

function listaUmbrales(data) {
  const filas = [];

  for (const [metrica, detalle] of Object.entries(data.metrics)) {
    for (const [umbral, resultado] of Object.entries(detalle.thresholds ?? {})) {
      filas.push({ metrica, umbral, ok: resultado.ok === true });
    }
  }

  return filas;
}

function markdown(data, config) {
  const duracion = valores(data, 'http_req_duration', config.escenario);
  const requests = valores(data, 'http_reqs', config.escenario);
  const fallos = valores(data, 'http_req_failed', config.escenario);
  const checks = valores(data, 'checks', config.escenario);
  const descartadas = valores(data, 'dropped_iterations', config.escenario);
  const vusMax = data.metrics.vus_max?.values?.max;
  const umbrales = listaUmbrales(data);
  const paso = umbrales.length > 0 && umbrales.every((fila) => fila.ok);
  const fecha = new Date().toISOString();

  const lineas = [
    `# RA-01 — ${config.titulo}`,
    '',
    `- Generado: ${fecha}`,
    `- Resultado: ${paso ? '✅ PASS' : '❌ FAIL'}`,
    `- Duración de la corrida: ${decimal((data.state?.testRunDurationMs ?? 0) / 1000)} s`,
    '',
    config.descripcion,
    '',
    `## Métricas del escenario (\`escenario:${config.escenario}\`)`,
    '',
    '| Métrica | Valor |',
    '|---|---:|',
    `| Requests | ${entero(requests?.count)} |`,
    `| RPS | ${decimal(requests?.rate)} |`,
    `| Checks correctos | ${porcentaje(checks?.rate)} |`,
    `| Fallos HTTP | ${porcentaje(fallos?.rate)} |`,
    `| Iteraciones descartadas | ${entero(descartadas?.count)} |`,
    `| VUs máximos | ${entero(vusMax)} |`,
    '',
    `## Latencia — \`http_req_duration{escenario:${config.escenario}}\``,
    '',
    '| avg | med | p(90) | p(95) | p(99) | max |',
    '|---:|---:|---:|---:|---:|---:|',
    `| ${ms(duracion?.avg)} | ${ms(duracion?.med)} | ${ms(duracion?.['p(90)'])} | ` +
      `${ms(duracion?.['p(95)'])} | ${ms(duracion?.['p(99)'])} | ${ms(duracion?.max)} |`,
    '',
    '## Umbrales',
    '',
    '| Métrica | Umbral | Resultado |',
    '|---|---|---|',
  ];

  if (umbrales.length === 0) {
    lineas.push('| — | — | Sin umbrales |');
  } else {
    for (const fila of umbrales) {
      lineas.push(`| \`${fila.metrica}\` | ${fila.umbral} | ${fila.ok ? '✅' : '❌'} |`);
    }
  }

  lineas.push('', `Reporte generado por \`lib/reporte.js\` en \`${DIRECTORIO_RESULTADOS}/${config.archivo}\`.`, '');

  return lineas.join('\n');
}

function textoConsola(data, config) {
  const duracion = valores(data, 'http_req_duration', config.escenario);
  const requests = valores(data, 'http_reqs', config.escenario);
  const fallos = valores(data, 'http_req_failed', config.escenario);
  const checks = valores(data, 'checks', config.escenario);
  const descartadas = valores(data, 'dropped_iterations', config.escenario);
  const umbrales = listaUmbrales(data);
  const paso = umbrales.length > 0 && umbrales.every((fila) => fila.ok);
  const fallidos = umbrales.filter((fila) => !fila.ok);

  const lineas = [
    `RA-01 ${config.titulo} — ${paso ? '✅ PASS' : '❌ FAIL'}`,
    `requests=${entero(requests?.count)} rps=${decimal(requests?.rate)} ` +
      `checks=${porcentaje(checks?.rate)} fallos=${porcentaje(fallos?.rate)} ` +
      `dropped=${entero(descartadas?.count)}`,
    `http_req_duration med=${ms(duracion?.med)} p95=${ms(duracion?.['p(95)'])} ` +
      `p99=${ms(duracion?.['p(99)'])} max=${ms(duracion?.max)}`,
    `Reporte: ${DIRECTORIO_RESULTADOS}/${config.archivo}`,
  ];

  if (fallidos.length > 0) {
    lineas.push(
      `UMBRALES FALLIDOS: ${fallidos.map((fila) => `${fila.metrica}:${fila.umbral}`).join(', ')}`
    );
  }

  return `${lineas.join('\n')}\n`;
}

export function generarReporte(config) {
  return function handleSummary(data) {
    return {
      stdout: textoConsola(data, config),
      [`${DIRECTORIO_RESULTADOS}/${config.archivo}`]: markdown(data, config),
    };
  };
}
