import exec from 'k6/execution';
import { estudiantes, estudiantePorIndice, verificarVigencia } from './lib/estudiantes.js';
import { verificarApiYToken, leerMateriasHabilitadas } from './lib/api.js';
import { validarRespuesta } from './lib/checks.js';
import { generarReporte } from './lib/reporte.js';

/**
 * RA-01 — capacidad sostenida de lectura.
 *
 * 500 VUs mantienen 500 lecturas concurrentes durante 8 minutos. Los tokens
 * rotan por los 10.000 estudiantes del dataset, de modo que se recorren todos
 * los catálogos y no siempre el mismo subconjunto en caché.
 *
 * Este es el escenario que valida "el servidor soporta 500 estudiantes a la vez".
 */

const VUS_CAPACIDAD = 500;
const DURACION_CAPACIDAD = '8m';
const CALENTAMIENTO_TASA = 20;

export const options = {
  scenarios: {
    calentamiento: {
      executor: 'constant-arrival-rate',
      exec: 'calentamiento',
      rate: CALENTAMIENTO_TASA,
      timeUnit: '1s',
      duration: '20s',
      preAllocatedVUs: 10,
      maxVUs: 30,
      gracefulStop: '1s',
      tags: { escenario: 'calentamiento' },
    },
    capacidad: {
      executor: 'constant-vus',
      exec: 'leerCapacidad',
      vus: VUS_CAPACIDAD,
      duration: DURACION_CAPACIDAD,
      gracefulStop: '10s',
      startTime: '30s',
      tags: { escenario: 'capacidad' },
    },
  },
  summaryTrendStats: ['avg', 'min', 'med', 'p(90)', 'p(95)', 'p(99)', 'max'],
  thresholds: {
    'http_req_duration{endpoint:materias_habilitadas,escenario:capacidad}': [
      'p(95)<300',
      'p(99)<600',
    ],
    'http_req_failed{endpoint:materias_habilitadas,escenario:capacidad}': ['rate<0.01'],
    'checks{endpoint:materias_habilitadas,escenario:capacidad}': ['rate>0.99'],
  },
};

export const handleSummary = generarReporte({
  archivo: 'ra-01-capacidad.md',
  titulo: 'Capacidad (500 VUs)',
  escenario: 'capacidad',
  descripcion:
    '500 VUs sostenidos durante 8 minutos, rotando por los 10.000 tokens del dataset. ' +
    'Este es el escenario que valida el requisito de 500 estudiantes concurrentes.',
});

export function setup() {
  verificarVigencia(estudiantes[0]);
  verificarVigencia(estudiantes[estudiantes.length - 1]);

  const materias = verificarApiYToken(estudiantes[0]);
  console.log(
    `RA-01 capacidad: ${VUS_CAPACIDAD} VUs durante ${DURACION_CAPACIDAD}, ` +
      `${estudiantes.length} tokens rotando, ${materias} materias en la verificación`
  );
}

export function calentamiento() {
  const indice = exec.scenario.iterationInInstance % estudiantes.length;
  const respuesta = leerMateriasHabilitadas(estudiantePorIndice(indice), {
    escenario: 'calentamiento',
  });

  validarRespuesta(respuesta, { escenario: 'calentamiento' });
}

export function leerCapacidad() {
  const indice = exec.scenario.iterationInInstance % estudiantes.length;
  const estudiante = estudiantePorIndice(indice);

  const respuesta = leerMateriasHabilitadas(estudiante, {
    escenario: 'capacidad',
  });

  validarRespuesta(respuesta, { escenario: 'capacidad' });
}
