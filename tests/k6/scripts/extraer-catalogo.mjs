import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { getDocument } from 'pdfjs-dist/legacy/build/pdf.mjs';

const aqui = path.dirname(fileURLToPath(import.meta.url));
const raizRepositorio = path.resolve(aqui, '../../..');

const { values } = parseArgs({
  options: {
    samples: { type: 'string', default: path.join(raizRepositorio, 'samples') },
    out: { type: 'string', default: path.join(aqui, '../data/catalogo.json') }
  }
});

const DIAS = new Set(['LU', 'MA', 'MI', 'JU', 'VI', 'SA', 'DO']);
const RE_ENCABEZADO = /^([A-Z])\s+(\d{7})\s+(.+?)\s*$/;
const RE_SESION = /(?<dia>LU|MA|MI|JU|VI|SA|DO)\s+(?<inicio>\d{1,4})\s*-\s*(?<fin>\d{1,4})\s+(?<aula>\S+)\s*$/;
const RE_GRUPO = /^([0-9]{1,2}[A-Z]?|[A-Z][0-9]?)\s+(?:\[(?:TP|P)\]\s+)?/;
const RE_TIPO = /^([0-9]{1,2}[A-Z]?|[A-Z][0-9]?)\s+(\[(?:TP|P)\])\s+/;

function normalizarHora(valor) {
  const digitos = valor.padStart(4, '0');
  return `${digitos.slice(0, 2)}:${digitos.slice(2)}`;
}

function compararGrupos(a, b) {
  const na = Number.parseInt(a, 10);
  const nb = Number.parseInt(b, 10);
  if (Number.isFinite(na) && Number.isFinite(nb) && na !== nb) {
    return na - nb;
  }
  return a.localeCompare(b);
}

async function extraerTexto(archivo) {
  const datos = new Uint8Array(await fs.readFile(archivo));
  const documento = await getDocument({ data: datos, useSystemFonts: true }).promise;
  const lineas = [];

  for (let pagina = 1; pagina <= documento.numPages; pagina += 1) {
    const contenido = await (await documento.getPage(pagina)).getTextContent();
    const filas = [];

    for (const item of contenido.items) {
      if (!('str' in item) || !item.str.trim()) {
        continue;
      }

      const x = item.transform?.[4];
      const y = item.transform?.[5];
      if (!Number.isFinite(x) || !Number.isFinite(y)) {
        continue;
      }

      let fila = filas.find((candidata) => Math.abs(candidata.y - y) <= 1.5);
      if (!fila) {
        fila = { y, items: [] };
        filas.push(fila);
      }

      fila.items.push({ x, texto: item.str.trim() });
    }

    filas
      .sort((a, b) => b.y - a.y)
      .forEach((fila) => {
        lineas.push(
          fila.items
            .sort((a, b) => a.x - b.x)
            .map((item) => item.texto)
            .join(' ')
            .replace(/\s+/g, ' ')
            .trim()
        );
      });

    lineas.push('');
  }

  return lineas.join('\n');
}

function parsearHorario(texto, archivo) {
  const nombreCarrera = /LICENCIATURA EN ([^\n]+)/.exec(texto)?.[1]?.trim();
  if (!nombreCarrera) {
    throw new Error(`No se encontró la carrera en ${archivo}`);
  }

  const codigoCarrera = path.basename(archivo, path.extname(archivo));
  const niveles = new Map();
  let nivelActual = null;
  let materiaActual = null;
  let ultimoGrupo = null;

  for (const lineaCruda of texto.split('\n')) {
    const linea = lineaCruda.trim();
    if (!linea) {
      continue;
    }

    const encabezado = RE_ENCABEZADO.exec(linea);
    if (encabezado) {
      const [, nivel, codigo, nombre] = encabezado;
      if (!niveles.has(nivel)) {
        niveles.set(nivel, []);
      }

      nivelActual = nivel;
      materiaActual = {
        codigo,
        nombre: nombre.trim(),
        grupos: new Map()
      };
      niveles.get(nivel).push(materiaActual);
      ultimoGrupo = null;
      continue;
    }

    const inicioGrupo = RE_GRUPO.exec(linea);
    if (inicioGrupo && materiaActual) {
      ultimoGrupo = inicioGrupo[1];
    }

    const sesion = RE_SESION.exec(linea);
    if (!sesion || !materiaActual || !nivelActual) {
      continue;
    }

    const grupo = RE_TIPO.exec(linea)?.[1] ?? ultimoGrupo;
    if (!grupo) {
      continue;
    }

    if (!materiaActual.grupos.has(grupo)) {
      materiaActual.grupos.set(grupo, []);
    }

    const dia = sesion.groups.dia;
    if (!DIAS.has(dia)) {
      continue;
    }

    materiaActual.grupos.get(grupo).push({
      dia,
      inicio: normalizarHora(sesion.groups.inicio),
      fin: normalizarHora(sesion.groups.fin),
      aula: sesion.groups.aula
    });
  }

  return {
    codigo: codigoCarrera,
    nombre: nombreCarrera,
    niveles: [...niveles.entries()].map(([nivel, materias]) => ({
      nivel,
      materias: materias.map((materia) => ({
        codigo: materia.codigo,
        nombre: materia.nombre,
        grupos: [...materia.grupos.entries()]
          .map(([grupo, sesiones]) => {
            const unicas = new Map(
              sesiones.map((sesion) => [
                `${sesion.dia}-${sesion.inicio}-${sesion.fin}-${sesion.aula}`,
                sesion
              ])
            );

            return {
              grupo,
              sesiones: [...unicas.values()]
            };
          })
          .filter((grupo) => grupo.sesiones.length > 0)
          .sort((a, b) => compararGrupos(a.grupo, b.grupo))
      }))
    }))
  };
}

const archivos = (await fs.readdir(values.samples))
  .filter((archivo) => archivo.toLowerCase().endsWith('.pdf'))
  .sort()
  .map((archivo) => path.join(values.samples, archivo));

if (archivos.length === 0) {
  throw new Error(`No hay PDFs en ${values.samples}`);
}

const carreras = [];
for (const archivo of archivos) {
  const texto = await extraerTexto(archivo);
  const carrera = parsearHorario(texto, archivo);
  carreras.push(carrera);
  const materias = carrera.niveles.reduce((total, nivel) => total + nivel.materias.length, 0);
  const grupos = carrera.niveles.reduce(
    (total, nivel) => total + nivel.materias.reduce((suma, materia) => suma + materia.grupos.length, 0),
    0
  );
  console.log(
    `${path.basename(archivo)}: ${carrera.nombre} (${carrera.niveles.length} niveles, ${materias} materias, ${grupos} grupos)`
  );
}

const catalogo = {
  generadoDesde: archivos.map((archivo) => path.relative(raizRepositorio, archivo)),
  carreras
};

await fs.mkdir(path.dirname(values.out), { recursive: true });
await fs.writeFile(values.out, `${JSON.stringify(catalogo, null, 2)}\n`, 'utf8');
console.log(`Catálogo escrito en ${values.out}`);
