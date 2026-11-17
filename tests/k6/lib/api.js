import http from 'k6/http';

const baseUrl = (__ENV.API_BASE_URL || 'http://localhost:5124').replace(/\/+$/, '');
const timeout = __ENV.HTTP_TIMEOUT || '10s';

export const apiBaseUrl = baseUrl;

function cabeceras(estudiante) {
  if (!estudiante?.accessToken) {
    throw new Error(`El estudiante ${estudiante?.email ?? '(sin email)'} no tiene accessToken`);
  }

  return {
    Authorization: `Bearer ${estudiante.accessToken}`,
    Accept: 'application/json',
  };
}

/**
 * GET /materias/habilitadas con el token del estudiante indicado.
 * Las etiquetas pasadas se combinan con endpoint=materias_habilitadas,
 * de modo que las thresholds puedan filtrar por escenario/franja.
 */
export function leerMateriasHabilitadas(estudiante, etiquetas = {}) {
  return http.get(`${apiBaseUrl}/materias/habilitadas`, {
    headers: cabeceras(estudiante),
    timeout,
    tags: {
      endpoint: 'materias_habilitadas',
      ...etiquetas,
    },
  });
}

/**
 * Verificación de humo antes de arrancar los escenarios medidos.
 * Falla rápido si la API no responde o si los tokens del archivo no sirven.
 */
export function verificarApiYToken(estudiante) {
  const salud = http.get(`${apiBaseUrl}/salud`, {
    timeout,
    tags: { endpoint: 'salud_verificacion' },
  });

  if (salud.status !== 200) {
    throw new Error(`/salud respondió ${salud.status}: ${String(salud.body).slice(0, 200)}`);
  }

  const respuesta = http.get(`${apiBaseUrl}/materias/habilitadas`, {
    headers: cabeceras(estudiante),
    timeout,
    tags: { endpoint: 'materias_habilitadas_verificacion' },
  });

  if (respuesta.status !== 200) {
    throw new Error(
      `/materias/habilitadas respondió ${respuesta.status}: ${String(respuesta.body).slice(0, 200)}`
    );
  }

  let materias;
  try {
    materias = respuesta.json();
  } catch {
    throw new Error('La respuesta de verificación de /materias/habilitadas no es JSON');
  }

  if (!Array.isArray(materias)) {
    throw new Error('La respuesta de verificación de /materias/habilitadas no es un arreglo');
  }

  if (materias.length !== 5 && materias.length !== 6) {
    throw new Error(
      `El estudiante ${estudiante.email} tiene ${materias.length} materias; el dataset k6 espera 5 o 6`
    );
  }

  return materias.length;
}
