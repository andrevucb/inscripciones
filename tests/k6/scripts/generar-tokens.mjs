import fs from 'node:fs/promises';
import path from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';

const aqui = path.dirname(fileURLToPath(import.meta.url));

const { values } = parseArgs({
  options: {
    api: { type: 'string', default: 'http://localhost:5124' },
    desde: { type: 'string', default: '1' },
    hasta: { type: 'string', default: '10000' },
    prefijo: { type: 'string', default: 'k6' },
    dominio: { type: 'string', default: 'inscripciones.local' },
    password: { type: 'string', default: 'Estudiante1!' },
    concurrencia: { type: 'string', default: '32' },
    reintentos: { type: 'string', default: '5' },
    timeout: { type: 'string', default: '30' },
    out: { type: 'string', default: path.join(aqui, '../data/estudiantes.json') },
  },
});

class ErrorNoReintentable extends Error {}

const api = values.api.replace(/\/+$/, '');
const desde = Number.parseInt(values.desde, 10);
const hasta = Number.parseInt(values.hasta, 10);
const concurrencia = Number.parseInt(values.concurrencia, 10);
const reintentos = Number.parseInt(values.reintentos, 10);
const timeoutMs = Number.parseInt(values.timeout, 10) * 1000;

if (!Number.isInteger(desde) || desde < 1) {
  throw new Error('--desde debe ser un entero >= 1');
}

if (!Number.isInteger(hasta) || hasta < desde) {
  throw new Error('--hasta debe ser un entero >= --desde');
}

if (!Number.isInteger(concurrencia) || concurrencia < 1) {
  throw new Error('--concurrencia debe ser un entero >= 1');
}

if (!Number.isInteger(reintentos) || reintentos < 0) {
  throw new Error('--reintentos debe ser un entero >= 0');
}

if (!Number.isInteger(timeoutMs) || timeoutMs <= 0) {
  throw new Error('--timeout debe ser un entero > 0 (segundos)');
}

const total = hasta - desde + 1;

function emailDe(indice) {
  return `${values.prefijo}.${String(indice).padStart(5, '0')}@${values.dominio}`;
}

async function leerCuerpo(respuesta) {
  try {
    return await respuesta.text();
  } catch {
    return '';
  }
}

async function iniciarSesion(indice, intento = 0) {
  const email = emailDe(indice);

  try {
    const respuesta = await fetch(`${api}/login?useCookies=false`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify({ email, password: values.password }),
      signal: AbortSignal.timeout(timeoutMs),
    });

    if (respuesta.status === 401 || respuesta.status === 403) {
      const cuerpo = await leerCuerpo(respuesta);
      throw new ErrorNoReintentable(
        `Credenciales rechazadas para ${email} (HTTP ${respuesta.status}). ` +
          `¿Ejecutaste el seed y usa la misma contraseña? ${cuerpo.slice(0, 200)}`
      );
    }

    if (!respuesta.ok) {
      const cuerpo = await leerCuerpo(respuesta);
      throw new Error(`HTTP ${respuesta.status} al autenticar ${email}: ${cuerpo.slice(0, 200)}`);
    }

    const datos = await respuesta.json();
    if (!datos?.accessToken) {
      throw new Error(`La respuesta de login de ${email} no contiene accessToken`);
    }

    const expiresIn = Number(datos.expiresIn) > 0 ? Number(datos.expiresIn) : 3600;

    return {
      email,
      accessToken: datos.accessToken,
      expiresAt: Date.now() + expiresIn * 1000,
    };
  } catch (error) {
    if (error instanceof ErrorNoReintentable || intento >= reintentos) {
      throw error instanceof ErrorNoReintentable
        ? error
        : new Error(
            `No se pudo autenticar ${email} tras ${reintentos + 1} intento(s): ${error.message}`
          );
    }

    const esperaMs = Math.min(5000, 250 * 2 ** intento) + Math.floor(Math.random() * 250);
    await delay(esperaMs);
    return iniciarSesion(indice, intento + 1);
  }
}

async function verificarToken(token) {
  const respuesta = await fetch(`${api}/materias/habilitadas`, {
    headers: {
      Authorization: `Bearer ${token.accessToken}`,
      Accept: 'application/json',
    },
    signal: AbortSignal.timeout(timeoutMs),
  });

  const cuerpo = await leerCuerpo(respuesta);

  if (respuesta.status !== 200) {
    throw new Error(
      `El token de ${token.email} no sirve para /materias/habilitadas: ` +
        `HTTP ${respuesta.status} ${cuerpo.slice(0, 200)}`
    );
  }

  let materias;
  try {
    materias = JSON.parse(cuerpo);
  } catch {
    throw new Error(`/materias/habilitadas no devolvió JSON para ${token.email}`);
  }

  if (!Array.isArray(materias) || (materias.length !== 5 && materias.length !== 6)) {
    throw new Error(
      `El estudiante ${token.email} tiene ${Array.isArray(materias) ? materias.length : '?'} ` +
        'materias; el dataset k6 espera 5 o 6'
    );
  }

  return materias.length;
}

const resultados = new Array(total);
let siguiente = 0;
let completados = 0;
let errorFatal = null;
const inicio = Date.now();

async function trabajador() {
  while (!errorFatal) {
    const posicion = siguiente;
    siguiente += 1;

    if (posicion >= total) {
      return;
    }

    const indice = desde + posicion;

    try {
      resultados[posicion] = await iniciarSesion(indice);
    } catch (error) {
      errorFatal = error;
      throw error;
    }

    completados += 1;
    if (completados % 250 === 0 || completados === total) {
      const transcurridos = Math.max(1, (Date.now() - inicio) / 1000);
      process.stderr.write(
        `  ${completados}/${total} tokens (${(completados / transcurridos).toFixed(1)}/s)\n`
      );
    }
  }
}

console.log(`Autenticando ${total} usuarios contra ${api} con concurrencia ${concurrencia}...`);

const trabajos = await Promise.allSettled(
  Array.from({ length: concurrencia }, () => trabajador())
);
const fallo = trabajos.find((trabajo) => trabajo.status === 'rejected');

if (fallo) {
  throw fallo.reason;
}

if (resultados.length !== total || resultados.some((resultado) => !resultado)) {
  throw new Error(`Se esperaban ${total} tokens y se generaron ${resultados.filter(Boolean).length}`);
}

const muestras = [
  resultados[0],
  resultados[Math.floor(resultados.length / 2)],
  resultados[resultados.length - 1],
];
const cantidades = await Promise.all(muestras.map((token) => verificarToken(token)));
const vigenciaMinimaMs = Math.min(...resultados.map((token) => token.expiresAt)) - Date.now();

await fs.mkdir(path.dirname(values.out), { recursive: true });
const temporal = `${values.out}.tmp-${process.pid}`;

await fs.writeFile(temporal, `${JSON.stringify(resultados)}\n`, {
  encoding: 'utf8',
  mode: 0o600,
});
await fs.rename(temporal, values.out);
await fs.chmod(values.out, 0o600);

console.log(`Tokens generados: ${resultados.length}`);
console.log(`Muestras verificadas: ${cantidades.join(', ')} materias`);
console.log(`Vigencia mínima: ${Math.max(0, Math.floor(vigenciaMinimaMs / 60000))} minutos`);
console.log(`Archivo escrito: ${values.out} (modo 600)`);
