import { SharedArray } from 'k6/data';

const ruta = __ENV.DATA_FILE || '../data/estudiantes.json';
const esperados = Number.parseInt(__ENV.ESTUDIANTES_ESPERADOS || '10000', 10);

export const estudiantes = new SharedArray('estudiantes', () => {
  const datos = JSON.parse(open(ruta));

  if (!Array.isArray(datos) || datos.length === 0) {
    throw new Error(`El archivo ${ruta} no contiene estudiantes`);
  }

  if (datos.length < esperados) {
    throw new Error(
      `El archivo ${ruta} contiene ${datos.length} estudiantes; se esperaban al menos ${esperados}`
    );
  }

  for (const [indice, estudiante] of datos.entries()) {
    if (!estudiante?.email || !estudiante?.accessToken) {
      throw new Error(`El estudiante en la posición ${indice} no tiene email/token`);
    }
  }

  return datos;
});

export function verificarVigencia(estudiante) {
  if (!estudiante?.expiresAt) {
    return;
  }

  const margenMinutos = Number.parseInt(__ENV.MARGEN_EXPIRACION_MINUTOS || '10', 10);
  const margenMs = margenMinutos * 60 * 1000;

  if (Date.now() + margenMs >= estudiante.expiresAt) {
    throw new Error(
      `El token de ${estudiante.email} vence en menos de ${margenMinutos} minutos. ` +
        'Genera los tokens de nuevo antes de correr la prueba.'
    );
  }
}

export function estudiantePorIndice(indice) {
  if (!Number.isInteger(indice) || indice < 0 || indice >= estudiantes.length) {
    throw new Error(`Índice de estudiante inválido: ${indice}`);
  }

  return estudiantes[indice];
}
