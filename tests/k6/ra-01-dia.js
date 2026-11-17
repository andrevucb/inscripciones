import exec from 'k6/execution';
import { estudiantes, estudiantePorIndice, verificarVigencia } from './lib/estudiantes.js';
import { verificarApiYToken, leerMateriasHabilitadas } from './lib/api.js';
import { validarRespuesta } from './lib/checks.js';
import { generarReporte } from './lib/reporte.js';

/**
 * RA-01 — lectura de /materias/habilitadas en un día normal de inscripciones.
 *
 * Modelo:
 *   - 10.000 estudiantes únicos, al menos una lectura cada uno.
 *   - El día (08:00–20:00) se comprime a 240 s: 20 s por hora simulada.
 *   - Cada franja dura 21 s: 20 s de la hora simulada + 1 s de margen para que
 *     ningún estudiante del tramo quede sin leer si el executor omite algún tick.
 *   - La concurrencia máxima la fija la tasa de llegada, no el total de estudiantes.
 *     Por eso este escenario mide la latencia de un día normal; el pico sostenido
 *     de 500 estudiantes se mide aparte en ra-01-capacidad.js.
 */

const SEGUNDOS_POR_FRANJA = 20;
const MARGEN_POR_FRANJA = 1;
const CALENTAMIENTO_SEGUNDOS = 20;
const CALENTAMIENTO_TASA = 20;
const ESPERA_ENTRE_CALENTAMIENTO_Y_DIA = 10;

const FRANJAS = [
  { nombre: 'dia_08', hora: '08-09', estudiantes: 1600, tasa: 80 },
  { nombre: 'dia_09', hora: '09-10', estudiantes: 1000, tasa: 50 },
  { nombre: 'dia_10', hora: '10-11', estudiantes: 800, tasa: 40 },
  { nombre: 'dia_11', hora: '11-12', estudiantes: 700, tasa: 35 },
  { nombre: 'dia_12', hora: '12-13', estudiantes: 900, tasa: 45 },
  { nombre: 'dia_13', hora: '13-14', estudiantes: 1100, tasa: 55 },
  { nombre: 'dia_14', hora: '14-15', estudiantes: 700, tasa: 35 },
  { nombre: 'dia_15', hora: '15-16', estudiantes: 600, tasa: 30 },
  { nombre: 'dia_16', hora: '16-17', estudiantes: 700, tasa: 35 },
  { nombre: 'dia_17', hora: '17-18', estudiantes: 800, tasa: 40 },
  { nombre: 'dia_18', hora: '18-19', estudiantes: 900, tasa: 45 },
  { nombre: 'dia_19', hora: '19-20', estudiantes: 200, tasa: 10 },
];

const TOTAL_ESTUDIANTES_DIA = FRANJAS.reduce((total, franja) => total + franja.estudiantes, 0);
const FRANJAS_POR_NOMBRE = new Map();
const ESCENARIOS = {
  calentamiento: {
    executor: 'constant-arrival-rate',
    exec: 'calentamiento',
    rate: CALENTAMIENTO_TASA,
    timeUnit: '1s',
    duration: `${CALENTAMIENTO_SEGUNDOS}s`,
    preAllocatedVUs: 10,
    maxVUs: 30,
    gracefulStop: '1s',
    tags: { escenario: 'calentamiento' },
  },
};

let inicioEnSegundos = CALENTAMIENTO_SEGUNDOS + ESPERA_ENTRE_CALENTAMIENTO_Y_DIA;
let estudianteInicial = 0;

for (const franja of FRANJAS) {
  FRANJAS_POR_NOMBRE.set(franja.nombre, { ...franja, desde: estudianteInicial });
  ESCENARIOS[franja.nombre] = {
    executor: 'constant-arrival-rate',
    exec: 'leerDia',
    rate: franja.tasa,
    timeUnit: '1s',
    duration: `${SEGUNDOS_POR_FRANJA + MARGEN_POR_FRANJA}s`,
    preAllocatedVUs: 30,
    maxVUs: 60,
    gracefulStop: '2s',
    startTime: `${inicioEnSegundos}s`,
    tags: { escenario: 'dia', franja: franja.hora },
  };

  inicioEnSegundos += SEGUNDOS_POR_FRANJA;
  estudianteInicial += franja.estudiantes;
}

export const options = {
  scenarios: ESCENARIOS,
  summaryTrendStats: ['avg', 'min', 'med', 'p(90)', 'p(95)', 'p(99)', 'max'],
  thresholds: {
    // Solo el día medido; el calentamiento queda fuera.
    'http_req_duration{endpoint:materias_habilitadas,escenario:dia}': [
      'p(95)<300',
      'p(99)<600',
    ],
    'http_req_failed{endpoint:materias_habilitadas,escenario:dia}': ['rate<0.01'],
    'checks{endpoint:materias_habilitadas,escenario:dia}': ['rate>0.99'],
    'http_reqs{endpoint:materias_habilitadas,escenario:dia}': ['count>=10000'],
    'dropped_iterations{escenario:dia}': ['count<1'],
  },
};

export const handleSummary = generarReporte({
  archivo: 'ra-01-dia.md',
  titulo: 'Día (10.000 estudiantes)',
  escenario: 'dia',
  descripcion:
    'Jornada comprimida de 08:00 a 20:00: 12 franjas de 21 s con tasa de llegada constante. ' +
    'Cada estudiante del dataset se lee al menos una vez; el pico de concurrencia ronda las 30 peticiones en vuelo.',
});

export function setup() {
  verificarVigencia(estudiantes[0]);
  verificarVigencia(estudiantes[estudiantes.length - 1]);

  const materias = verificarApiYToken(estudiantes[0]);
  console.log(
    `RA-01 día: ${estudiantes.length} tokens cargados, ${FRANJAS.length} franjas, ` +
      `${TOTAL_ESTUDIANTES_DIA} lecturas previstas, ${materias} materias en la verificación`
  );
}

export function calentamiento() {
  const indice = exec.scenario.iterationInInstance % estudiantes.length;
  const respuesta = leerMateriasHabilitadas(estudiantePorIndice(indice), {
    escenario: 'calentamiento',
  });

  validarRespuesta(respuesta, { escenario: 'calentamiento' });
}

export function leerDia() {
  const franja = FRANJAS_POR_NOMBRE.get(exec.scenario.name);

  if (!franja) {
    throw new Error(`Escenario de día desconocido: ${exec.scenario.name}`);
  }

  // Cada estudiante del tramo se usa una sola vez. El módulo protege contra
  // una iteración extra si el executor llegara a generar más de las previstas.
  const indice = franja.desde + (exec.scenario.iterationInInstance % franja.estudiantes);
  const estudiante = estudiantePorIndice(indice);

  const respuesta = leerMateriasHabilitadas(estudiante, {
    escenario: 'dia',
    franja: franja.hora,
  });

  validarRespuesta(respuesta, { escenario: 'dia', franja: franja.hora });
}
