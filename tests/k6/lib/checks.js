import { check } from 'k6';
import { Trend } from 'k6/metrics';

export const materiasPorRespuesta = new Trend('materias_por_respuesta');

function tipoDeContenido(response) {
  return String(
    response.headers['Content-Type'] ?? response.headers['content-type'] ?? ''
  ).toLowerCase();
}

/**
 * Valida estado, tipo de contenido y forma del cuerpo de /materias/habilitadas.
 *
 * El dataset k6 crea estudiantes con 5 o 6 materias habilitadas, cada una con
 * al menos un horario. Si el seed queda incompleto, estas comprobaciones fallan.
 *
 * Devuelve true solo si la respuesta es válida desde el punto de vista funcional.
 */
export function validarRespuesta(response, etiquetas = {}) {
  const tags = {
    endpoint: 'materias_habilitadas',
    ...etiquetas,
  };

  const esJson = tipoDeContenido(response).includes('application/json');

  check(
    response,
    {
      'status es 200': (r) => r.status === 200,
      'content-type es JSON': () => esJson,
    },
    tags
  );

  if (response.status !== 200 || !esJson) {
    return false;
  }

  let materias;
  try {
    materias = response.json();
  } catch {
    check(response, { 'body JSON parseable': () => false }, tags);
    return false;
  }

  const esArreglo = Array.isArray(materias);
  const ids = esArreglo ? materias.map((materia) => materia?.materiaId) : [];
  const sinDuplicados = esArreglo && new Set(ids).size === ids.length;
  const cantidadValida = esArreglo && (materias.length === 5 || materias.length === 6);
  const nombresValidos =
    esArreglo &&
    materias.every(
      (materia) => typeof materia?.nombre === 'string' && materia.nombre.trim().length > 0
    );
  const todasConHorarios =
    esArreglo &&
    materias.every(
      (materia) => Array.isArray(materia?.horarios) && materia.horarios.length > 0
    );
  const horariosValidos =
    esArreglo &&
    materias.every(
      (materia) =>
        Array.isArray(materia?.horarios) &&
        materia.horarios.every(
          (horario) =>
            Number.isInteger(horario?.horarioId) &&
            typeof horario?.descripcion === 'string' &&
            horario.descripcion.trim().length > 0 &&
            Number.isFinite(horario?.cuposDisponibles) &&
            horario.cuposDisponibles >= 0
        )
    );

  check(
    materias,
    {
      'body es un arreglo': () => esArreglo,
      'tiene 5 o 6 materias': () => cantidadValida,
      'sin materias duplicadas': () => sinDuplicados,
      'cada materia tiene nombre': () => nombresValidos,
      'cada materia tiene horarios': () => todasConHorarios,
      'horarios bien formados': () => horariosValidos,
    },
    tags
  );

  if (esArreglo) {
    materiasPorRespuesta.add(materias.length, tags);
  }

  return (
    esArreglo &&
    cantidadValida &&
    sinDuplicados &&
    nombresValidos &&
    todasConHorarios &&
    horariosValidos
  );
}
