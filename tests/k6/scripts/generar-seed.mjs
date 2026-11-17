import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';

const aqui = path.dirname(fileURLToPath(import.meta.url));
const raizRepositorio = path.resolve(aqui, '../../..');

const { values } = parseArgs({
  options: {
    catalogo: { type: 'string', default: path.join(aqui, '../data/catalogo.json') },
    out: { type: 'string', default: path.join(aqui, '../data/seed-10k.sql') },
    estudiantes: { type: 'string', default: '10000' },
    grupos: { type: 'string', default: '3' },
    cohortes: { type: 'string', default: '6x4' }
  }
});

const totalEstudiantes = Number.parseInt(values.estudiantes, 10);
const gruposPorMateria = Number.parseInt(values.grupos, 10);
const [cantidadCarreras, cantidadNiveles] = values.cohortes.split('x').map(Number);
const NIVELES = 'ABCDEFGHIJ'.slice(0, cantidadNiveles).split('');
const MATERIA_ID_INICIAL = 1000;
const HORARIO_ID_INICIAL = 10000;

if (!Number.isInteger(totalEstudiantes) || totalEstudiantes <= 0) {
  throw new Error('--estudiantes debe ser un entero positivo');
}

if (!Number.isInteger(gruposPorMateria) || gruposPorMateria <= 0) {
  throw new Error('--grupos debe ser un entero positivo');
}

const catalogo = JSON.parse(await fs.readFile(values.catalogo, 'utf8'));
const carreras = catalogo.carreras.slice(0, cantidadCarreras);

function escaparSql(texto) {
  return `'${String(texto).replaceAll("'", "''")}'`;
}

function descripcionGrupo(grupo) {
  const sesiones = grupo.sesiones.map(
    (sesion) => `${sesion.dia} ${sesion.inicio}-${sesion.fin} ${sesion.aula}`
  );

  for (const cantidad of [3, 2, 1]) {
    const texto = `G${grupo.grupo} ${sesiones.slice(0, cantidad).join(' | ')}`;
    if (texto.length <= 100) {
      return texto;
    }
  }

  return `G${grupo.grupo} ${sesiones.join(' | ')}`.slice(0, 97) + '...';
}

function materiaConGrupos(nombre) {
  const normalizado = nombre.trim().toUpperCase();
  for (const carrera of catalogo.carreras) {
    for (const nivel of carrera.niveles) {
      const materia = nivel.materias.find(
        (candidata) =>
          candidata.nombre.trim().toUpperCase() === normalizado && candidata.grupos.length > 0
      );
      if (materia) {
        return materia;
      }
    }
  }
  return null;
}

const electivas = [
  'INGLES I',
  'METODOLOGIA INVESTIGACION Y TEC COMUNICACION',
  'COMPUTACION I',
  'INGLES TECNICO'
]
  .map((nombre) => ({ nombre, materia: materiaConGrupos(nombre) }))
  .filter((electiva) => electiva.materia);

if (electivas.length === 0) {
  throw new Error('No se encontraron materias electivas en el catálogo');
}

const cohortes = [];
let siguienteMateriaId = MATERIA_ID_INICIAL;
let siguienteHorarioId = HORARIO_ID_INICIAL;

for (const carrera of carreras) {
  for (const nivel of NIVELES) {
    const nivelCatalogo = carrera.niveles.find((candidato) => candidato.nivel === nivel);
    if (!nivelCatalogo) {
      continue;
    }

    const disponibles = nivelCatalogo.materias.filter((materia) => materia.grupos.length > 0);
    const deseadas = 5 + (cohortes.length % 2);
    const seleccionadas = disponibles.slice(0, deseadas);
    const nombres = new Set(seleccionadas.map((materia) => materia.nombre.trim().toUpperCase()));

    for (const electiva of electivas) {
      if (seleccionadas.length >= deseadas) {
        break;
      }
      if (!nombres.has(electiva.nombre)) {
        seleccionadas.push(electiva.materia);
        nombres.add(electiva.nombre);
      }
    }

    if (seleccionadas.length < 5) {
      throw new Error(
        `${carrera.nombre} nivel ${nivel} solo tiene ${seleccionadas.length} materias; no se pueden generar 5-6`
      );
    }

    const materias = seleccionadas.map((materia) => {
      const grupos = materia.grupos
        .filter((grupo) => grupo.sesiones.length > 0)
        .slice(0, gruposPorMateria);

      if (grupos.length === 0) {
        throw new Error(`La materia ${materia.nombre} no tiene grupos`);
      }

      return {
        id: siguienteMateriaId++,
        nombre: materia.nombre,
        horarios: grupos.map((grupo) => ({
          id: siguienteHorarioId++,
          descripcion: descripcionGrupo(grupo)
        }))
      };
    });

    cohortes.push({
      carrera: carrera.nombre,
      nivel,
      materias
    });
  }
}

if (cohortes.length === 0) {
  throw new Error('No se generaron cohortes');
}

const lineas = [];
lineas.push('-- Generado por tests/k6/scripts/generar-seed.mjs');
lineas.push('-- Requiere que exista el usuario ana.torres@inscripciones.local (lo crea el seeder de la API).');
lineas.push('\\set ON_ERROR_STOP on');
lineas.push('');
lineas.push('BEGIN;');
lineas.push('');
lineas.push('DO $$');
lineas.push('BEGIN');
lineas.push('    IF NOT EXISTS (');
lineas.push('        SELECT 1');
lineas.push('        FROM "AspNetUsers"');
lineas.push('        WHERE "Email" = \'ana.torres@inscripciones.local\'');
lineas.push('          AND "PasswordHash" IS NOT NULL');
lineas.push('    ) THEN');
lineas.push(
  "        RAISE EXCEPTION 'Falta el usuario ana.torres@inscripciones.local; arranca la API una vez antes de ejecutar este seed.';"
);
lineas.push('    END IF;');
lineas.push('END $$;');
lineas.push('');
lineas.push('-- Limpieza idempotente del dataset k6.');
lineas.push('DELETE FROM "AspNetUsers" WHERE "Id" LIKE \'k6-%\';');
lineas.push(`DELETE FROM "Materias" WHERE "Id" >= ${MATERIA_ID_INICIAL} AND "Id" < 2000;`);
lineas.push('');
lineas.push('-- Usuarios de prueba.');
lineas.push('INSERT INTO "AspNetUsers" (');
lineas.push('    "Id", "UserName", "NormalizedUserName", "Email", "NormalizedEmail",');
lineas.push('    "EmailConfirmed", "PasswordHash", "SecurityStamp", "ConcurrencyStamp",');
lineas.push('    "PhoneNumber", "PhoneNumberConfirmed", "TwoFactorEnabled", "LockoutEnd",');
lineas.push('    "LockoutEnabled", "AccessFailedCount"');
lineas.push(')');
lineas.push('SELECT');
lineas.push("    'k6-' || lpad(i::text, 5, '0'),");
lineas.push("    'k6.' || lpad(i::text, 5, '0') || '@inscripciones.local',");
lineas.push("    upper('k6.' || lpad(i::text, 5, '0') || '@inscripciones.local'),");
lineas.push("    'k6.' || lpad(i::text, 5, '0') || '@inscripciones.local',");
lineas.push("    upper('k6.' || lpad(i::text, 5, '0') || '@inscripciones.local'),");
lineas.push('    TRUE,');
lineas.push('    (');
lineas.push('        SELECT "PasswordHash"');
lineas.push('        FROM "AspNetUsers"');
lineas.push("        WHERE \"Email\" = 'ana.torres@inscripciones.local'");
lineas.push('    ),');
lineas.push("    'k6-security-' || i,");
lineas.push('    gen_random_uuid()::text,');
lineas.push('    NULL, FALSE, FALSE, NULL, FALSE, 0');
lineas.push(`FROM generate_series(1, ${totalEstudiantes}) AS i;`);
lineas.push('');

lineas.push('-- Catálogo derivado de los PDFs de samples/.');
for (const cohorte of cohortes) {
  lineas.push('');
  lineas.push(`-- Cohorte: ${cohorte.carrera} / nivel ${cohorte.nivel}`);
  for (const materia of cohorte.materias) {
    lineas.push(
      `INSERT INTO "Materias" ("Id", "Nombre") VALUES (${materia.id}, ${escaparSql(materia.nombre)});`
    );
    for (const horario of materia.horarios) {
      lineas.push(
        `INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") ` +
          `VALUES (${horario.id}, ${materia.id}, ${escaparSql(horario.descripcion)}, 80, 80);`
      );
    }
  }
}

lineas.push('');
lineas.push('-- Relación cohorte -> materias habilitadas.');
lineas.push('CREATE TEMP TABLE k6_cohorte_materias (cohorte integer NOT NULL, materia_id integer NOT NULL) ON COMMIT DROP;');
lineas.push('INSERT INTO k6_cohorte_materias (cohorte, materia_id) VALUES');
const valoresCohortes = [];
cohortes.forEach((cohorte, indiceCohorte) => {
  for (const materia of cohorte.materias) {
    valoresCohortes.push(`    (${indiceCohorte}, ${materia.id})`);
  }
});
lineas.push(valoresCohortes.join(',\n') + ';');
lineas.push('');
lineas.push('-- Habilitaciones de los 10k estudiantes, distribuidas por cohorte.');
lineas.push('INSERT INTO "MateriasHabilitadas" ("EstudianteId", "MateriaId")');
lineas.push("SELECT 'k6-' || lpad(i::text, 5, '0'), cm.materia_id");
lineas.push(`FROM generate_series(1, ${totalEstudiantes}) AS i`);
lineas.push(`JOIN k6_cohorte_materias cm ON cm.cohorte = ((i - 1) % ${cohortes.length})`);
lineas.push('ORDER BY i, cm.materia_id;');
lineas.push('');
lineas.push('-- Mantener las secuencias por delante de los IDs explícitos del seed.');
lineas.push(
  `SELECT setval(pg_get_serial_sequence('"Materias"', 'Id'), GREATEST((SELECT COALESCE(MAX("Id"), 0) FROM "Materias"), 1), TRUE);`
);
lineas.push(
  `SELECT setval(pg_get_serial_sequence('"Horarios"', 'Id'), GREATEST((SELECT COALESCE(MAX("Id"), 0) FROM "Horarios"), 1), TRUE);`
);
lineas.push('');
lineas.push('ANALYZE "AspNetUsers";');
lineas.push('ANALYZE "Materias";');
lineas.push('ANALYZE "Horarios";');
lineas.push('ANALYZE "MateriasHabilitadas";');
lineas.push('');
lineas.push('COMMIT;');
lineas.push('');

await fs.mkdir(path.dirname(values.out), { recursive: true });
await fs.writeFile(values.out, `${lineas.join('\n')}\n`, 'utf8');

const totalMaterias = cohortes.reduce((total, cohorte) => total + cohorte.materias.length, 0);
const totalHorarios = cohortes.reduce(
  (total, cohorte) => total + cohorte.materias.reduce((suma, materia) => suma + materia.horarios.length, 0),
  0
);
const estudiantesBase = Math.floor(totalEstudiantes / cohortes.length);
const estudiantesExtra = totalEstudiantes % cohortes.length;
const totalHabilitaciones = cohortes.reduce(
  (total, cohorte, indice) =>
    total + (estudiantesBase + (indice < estudiantesExtra ? 1 : 0)) * cohorte.materias.length,
  0
);

console.log(`Cohortes: ${cohortes.length}`);
console.log(`Materias: ${totalMaterias}`);
console.log(`Horarios: ${totalHorarios}`);
console.log(`Estudiantes: ${totalEstudiantes}`);
console.log(`Habilitaciones: ${totalHabilitaciones}`);
console.log(`SQL escrito en ${values.out}`);
