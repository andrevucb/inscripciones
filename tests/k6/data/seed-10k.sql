-- Generado por tests/k6/scripts/generar-seed.mjs
-- Requiere que exista el usuario ana.torres@inscripciones.local (lo crea el seeder de la API).
\set ON_ERROR_STOP on

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM "AspNetUsers"
        WHERE "Email" = 'ana.torres@inscripciones.local'
          AND "PasswordHash" IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'Falta el usuario ana.torres@inscripciones.local; arranca la API una vez antes de ejecutar este seed.';
    END IF;
END $$;

-- Limpieza idempotente del dataset k6.
DELETE FROM "AspNetUsers" WHERE "Id" LIKE 'k6-%';
DELETE FROM "Materias" WHERE "Id" >= 1000 AND "Id" < 2000;

-- Usuarios de prueba.
INSERT INTO "AspNetUsers" (
    "Id", "UserName", "NormalizedUserName", "Email", "NormalizedEmail",
    "EmailConfirmed", "PasswordHash", "SecurityStamp", "ConcurrencyStamp",
    "PhoneNumber", "PhoneNumberConfirmed", "TwoFactorEnabled", "LockoutEnd",
    "LockoutEnabled", "AccessFailedCount"
)
SELECT
    'k6-' || lpad(i::text, 5, '0'),
    'k6.' || lpad(i::text, 5, '0') || '@inscripciones.local',
    upper('k6.' || lpad(i::text, 5, '0') || '@inscripciones.local'),
    'k6.' || lpad(i::text, 5, '0') || '@inscripciones.local',
    upper('k6.' || lpad(i::text, 5, '0') || '@inscripciones.local'),
    TRUE,
    (
        SELECT "PasswordHash"
        FROM "AspNetUsers"
        WHERE "Email" = 'ana.torres@inscripciones.local'
    ),
    'k6-security-' || i,
    gen_random_uuid()::text,
    NULL, FALSE, FALSE, NULL, FALSE, 0
FROM generate_series(1, 10000) AS i;

-- Catálogo derivado de los PDFs de samples/.

-- Cohorte: INGENIERIA ELECTRICA / nivel A
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1000, 'ALGEBRA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10000, 1000, 'G1 LU 18:45-20:15 622 | MA 08:15-09:45 612 | MI 08:15-09:45 693B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10001, 1000, 'G2 MA 08:15-09:45 693C | JU 08:15-09:45 617 | MI 12:45-14:15 642', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10002, 1000, 'G2A JU 14:15-15:45 691D | VI 15:45-17:15 692A', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1001, 'CALCULO I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10003, 1001, 'G3 MA 06:45-08:15 661 | JU 18:45-20:15 692A | SA 11:15-12:45 624', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10004, 1001, 'G4 LU 12:45-14:15 692C | MI 11:15-12:45 625C | VI 12:45-14:15 642', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10005, 1001, 'G4A MA 06:45-08:15 692A | SA 08:15-09:45 622', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1002, 'FISICA BASICA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10006, 1002, 'GE MI 12:45-14:15 691F | JU 12:45-14:15 691F | VI 11:15-12:45 691C', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10007, 1002, 'GE1 LU 09:45-11:15 618', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10008, 1002, 'GE2 JU 11:15-12:45 621', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1003, 'INTRODUCCION A LA PROGRAMACION');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10009, 1003, 'G1 LU 12:45-14:15 691A | JU 06:45-08:15 651 | SA 08:15-09:45 607', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10010, 1003, 'G2 LU 11:15-12:45 625D | MI 09:45-11:15 690B | SA 09:45-11:15 624', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10011, 1003, 'G3 LU 17:15-18:45 693D | MA 14:15-15:45 622 | JU 14:15-15:45 623', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1004, 'PROBABILIDAD Y ESTADISTICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10012, 1004, 'G4 LU 09:45-11:15 612 | MA 12:45-14:15 624 | VI 09:45-11:15 642', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10013, 1004, 'G5 LU 18:45-20:15 692F | JU 20:15-21:45 624 | VI 14:15-15:45 642', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10014, 1004, 'G6 MA 18:45-20:15 692E | JU 18:45-20:15 651 | VI 18:45-20:15 625D', 80, 80);

-- Cohorte: INGENIERIA ELECTRICA / nivel B
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1005, 'ALGEBRA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10015, 1005, 'G3 LU 14:15-15:45 607 | VI 09:45-11:15 692D | SA 09:45-11:15 693C', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10016, 1005, 'G3A MA 08:15-09:45 692F | MI 08:15-09:45 691B | JU 06:45-08:15 692G', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1006, 'CALCULO II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10017, 1006, 'G3A LU 17:15-18:45 617C | MI 20:15-21:45 622 | JU 09:45-11:15 691D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10018, 1006, 'G3B MA 12:45-14:15 692C | MI 08:15-09:45 692F | SA 11:15-12:45 622', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10019, 1006, 'G12 MA 06:45-08:15 693D | SA 08:15-09:45 692D | VI 12:45-14:15 617C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1007, 'CALCULO NUMERICO');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10020, 1007, 'G1 MA 09:45-11:15 AULVIR | JU 09:45-11:15 AULVIR | VI 08:15-09:45 AULVIR', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1008, 'CIRCUITOS ELECTRICOS I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10021, 1008, 'G1 LU 11:15-12:45 682L1 | VI 11:15-12:45 668 | MA 11:15-12:45 682B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10022, 1008, 'G2 LU 08:15-09:45 682L2 | MI 17:15-18:45 682L2 | JU 18:45-20:15 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10023, 1008, 'G3 LU 12:45-14:15 682B | MI 09:45-11:15 692F | VI 08:15-09:45 651', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1009, 'FISICA BASICA III');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10024, 1009, 'GC MA 08:15-09:45 692E | MI 08:15-09:45 692H | JU 11:15-12:45 693C', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10025, 1009, 'GC1 JU 14:15-15:45 684L8', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10026, 1009, 'GC2 MA 06:45-08:15 684L8', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1010, 'INGLES I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10027, 1010, 'G1 MA 17:15-18:45 690E | JU 17:15-18:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10028, 1010, 'G2 MA 11:15-12:45 692F | VI 09:45-11:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10029, 1010, 'G3 LU 06:45-08:15 691B | MI 06:45-08:15 692H', 80, 80);

-- Cohorte: INGENIERIA ELECTRICA / nivel C
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1011, 'CIRCUITOS ELECTRICOS II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10030, 1011, 'G1 LU 06:45-08:15 668 | VI 08:15-09:45 682L3 | LU 15:45-17:15 624', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10031, 1011, 'G2 LU 18:45-20:15 625D | MI 15:45-17:15 660 | MI 15:45-17:15 682L2', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1012, 'ECUACIONES DIFERENCIALES');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10032, 1012, 'G3 MI 06:45-08:15 642 | VI 06:45-08:15 693A | SA 06:45-08:15 692E', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10033, 1012, 'G5 LU 11:15-12:45 612 | MI 06:45-08:15 660 | JU 12:45-14:15 617', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1013, 'ELECTROMAGNETISMO');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10034, 1013, 'G1 MA 20:15-21:45 622 | JU 18:45-20:15 691A | VI 18:45-21:00 671C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1014, 'FISICA BASICA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10035, 1014, 'GD LU 17:15-18:45 692F | MI 17:15-18:45 622 | JU 12:45-14:15 622', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10036, 1014, 'GD1 MA 12:45-14:15 684L0', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10037, 1014, 'GD2 MI 18:45-20:15 684L0', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1015, 'VARIABLE COMPLEJA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10038, 1015, 'G1 LU 12:45-14:15 622 | MA 06:45-08:15 692B | JU 06:45-08:15 617C', 80, 80);

-- Cohorte: INGENIERIA ELECTRICA / nivel D
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1016, 'CIRCUITOS ELECTRICOS III');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10039, 1016, 'G1 LU 08:15-10:30 668 | MI 09:45-12:00 668 | LU 18:45-20:15 617C', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10040, 1016, 'G2 MI 06:45-09:00 668 | VI 20:15-21:45 691F | SA 09:45-11:15 693D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1017, 'ELECTRONICA ANALOGICA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10041, 1017, 'G1 LU 06:45-08:15 691F | MA 06:45-08:15 617B | JU 06:45-08:15 671A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10042, 1017, 'G2 LU 06:45-08:15 691D | MA 18:45-20:15 667A | MI 06:45-08:15 691F', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1018, 'HIDRAULICA APLICADA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10043, 1018, 'G1 JU 14:15-15:45 660 | VI 15:45-18:00 690D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1019, 'RESISTENCIA DE MATERIALES');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10044, 1019, 'G1 LU 12:45-15:00 617B | MI 11:15-12:45 607', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1020, 'TRANSFORMADAS INTEGRALES');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10045, 1020, 'G1 LU 14:15-15:45 693B | JU 17:15-18:45 624 | VI 14:15-15:45 612', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10046, 1020, 'G2 LU 17:15-18:45 652 | MA 15:45-17:15 642 | JU 14:15-15:45 693C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1021, 'INGLES I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10047, 1021, 'G1 MA 17:15-18:45 690E | JU 17:15-18:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10048, 1021, 'G2 MA 11:15-12:45 692F | VI 09:45-11:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10049, 1021, 'G3 LU 06:45-08:15 691B | MI 06:45-08:15 692H', 80, 80);

-- Cohorte: INGENIERIA INDUSTRIAL / nivel A
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1022, 'ALGEBRA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10050, 1022, 'G3 LU 17:15-18:45 693B | MA 09:45-11:15 623 | JU 09:45-11:15 612', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10051, 1022, 'G3A JU 12:45-14:15 692F | VI 08:15-09:45 661', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10052, 1022, 'G4 LU 18:45-20:15 660 | MA 11:15-12:45 661 | VI 14:15-15:45 624', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1023, 'CALCULO I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10053, 1023, 'G5 JU 08:15-09:45 612 | VI 11:15-12:45 617B | SA 08:15-09:45 617C', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10054, 1023, 'G5A LU 11:15-12:45 692G | MA 12:45-14:15 617 | MI 12:45-14:15 607', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10055, 1023, 'G6 MA 11:15-12:45 692A | MI 09:45-11:15 692D | JU 06:45-08:15 622', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1024, 'COMPUTACION I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10056, 1024, 'G1 LU 18:45-20:15 692B | MI 18:45-20:15 692B | SA 11:15-12:45 607', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10057, 1024, 'G2 MI 18:45-20:15 691C | VI 12:45-14:15 625C | SA 08:15-09:45 INFLAB', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10058, 1024, 'G4 LU 18:45-20:15 692A | MA 12:45-14:15 625C | MI 15:45-17:15 693B', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1025, 'FISICA BASICA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10059, 1025, 'GH LU 11:15-12:45 692B | MA 06:45-08:15 652 | MI 11:15-12:45 691D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10060, 1025, 'GH1 MA 12:45-14:15 618', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10061, 1025, 'GH2 LU 15:45-17:15 621', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1026, 'QUIMICA GENERAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10062, 1026, 'G1 MI 06:45-08:15 623 | JU 14:15-15:45 612 | VI 17:15-18:45 622', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10063, 1026, 'G2 LU 12:45-14:15 624 | MI 17:15-18:45 607 | VI 12:45-14:15 691D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10064, 1026, 'G7 MA 17:15-18:45 691C | MI 12:45-14:15 622 | JU 15:45-17:15 692A', 80, 80);

-- Cohorte: INGENIERIA INDUSTRIAL / nivel B
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1027, 'ALGEBRA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10065, 1027, 'G4 LU 06:45-08:15 692D | MA 06:45-08:15 623 | VI 06:45-08:15 690D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10066, 1027, 'G4A LU 15:45-17:15 693D | MI 17:15-18:45 692F | VI 14:15-15:45 623', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1028, 'CALCULO II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10067, 1028, 'G4 MA 18:45-20:15 692D | SA 08:15-09:45 624 | MI 15:45-17:15 691C', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10068, 1028, 'G5 LU 08:15-09:45 612 | MI 15:45-17:15 622 | VI 17:15-18:45 660', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10069, 1028, 'G13 MA 15:45-17:15 693A | VI 15:45-17:15 693C | JU 14:15-15:00 692F', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1029, 'DIBUJO TECNICO COMPUTARIZADO');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10070, 1029, 'G1 LU 17:15-18:45 692E | JU 17:15-19:30 625C', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10071, 1029, 'G2 MA 17:15-18:45 691A | VI 12:45-15:00 692H', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1030, 'ESTADISTICA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10072, 1030, 'G1 LU 14:15-15:45 692H | MI 18:45-20:15 607 | VI 18:45-20:15 624', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10073, 1030, 'G2 MA 14:15-15:45 691F | SA 11:15-12:45 623 | MI 11:15-12:45 692G', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1031, 'FISICA BASICA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10074, 1031, 'GF LU 11:15-12:45 623 | MA 11:15-12:45 691C | VI 11:15-12:45 692B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10075, 1031, 'GF1 LU 15:45-17:15 684L0', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10076, 1031, 'GF2 VI 09:45-11:15 684L0', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1032, 'INGLES I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10077, 1032, 'G1 MA 17:15-18:45 690E | JU 17:15-18:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10078, 1032, 'G2 MA 11:15-12:45 692F | VI 09:45-11:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10079, 1032, 'G3 LU 06:45-08:15 691B | MI 06:45-08:15 692H', 80, 80);

-- Cohorte: INGENIERIA INDUSTRIAL / nivel C
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1033, 'CALCULO COMPUTARIZADO');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10080, 1033, 'G1 MA 12:45-14:15 691E | JU 09:45-11:15 642 | VI 11:15-12:45 692E', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10081, 1033, 'G2 MA 14:15-15:45 612 | MI 14:15-15:45 692B | VI 12:45-14:15 691E', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1034, 'ECUACIONES DIFERENCIALES');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10082, 1034, 'G2 LU 17:15-18:45 607 | MI 17:15-18:45 624 | MA 11:15-12:45 692G', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10083, 1034, 'G2A MA 08:15-09:45 623 | JU 08:15-09:45 624 | VI 09:45-11:15 624', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1035, 'ESTADISTICA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10084, 1035, 'G1 MA 17:15-18:45 692D | JU 14:15-15:45 622 | SA 09:45-11:15 623', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10085, 1035, 'G4 LU 14:15-15:45 692E | MI 15:45-17:15 624 | VI 17:15-18:45 612', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1036, 'FISICA BASICA III');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10086, 1036, 'GC1 JU 14:15-15:45 684L8', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10087, 1036, 'GC3 LU 06:45-08:15 684L8', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10088, 1036, 'GD2 MA 14:15-15:45 684L8', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1037, 'FISICOQUIMICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10089, 1037, 'G1 JU 06:45-08:15 623 | SA 08:15-09:45 691F | JU 15:45-17:15 691B', 80, 80);

-- Cohorte: INGENIERIA INDUSTRIAL / nivel D
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1038, 'ECONOMIA INDUSTRIAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10090, 1038, 'G1 LU 11:15-12:45 661 | MI 11:15-12:45 661 | VI 11:15-12:45 691D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10091, 1038, 'G2 MA 08:15-09:45 690D | MI 08:15-09:45 690D | JU 12:45-14:15 617C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1039, 'ELECTROTECNIA INDUSTRIAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10092, 1039, 'G1 LU 09:00-11:15 682L3 | LU 17:15-18:45 692H | MI 18:45-20:15 642', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10093, 1039, 'G5 LU 06:45-08:15 692E | MA 06:45-09:00 682L3 | MA 12:45-14:15 693A', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1040, 'ORGANIZACION INDUSTRIAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10094, 1040, 'G1 MA 08:15-09:45 692H | JU 09:45-11:15 692D | VI 11:15-12:45 652', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1041, 'RESISTENCIA DE MATERIALES');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10095, 1041, 'G1 LU 18:45-20:15 692C | JU 17:15-18:45 651 | VI 12:45-14:15 693C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1042, 'TERMODINAMICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10096, 1042, 'G1 MA 12:45-14:15 691A | MI 18:45-20:15 693B | JU 06:45-08:15 691D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1043, 'INGLES I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10097, 1043, 'G1 MA 17:15-18:45 690E | JU 17:15-18:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10098, 1043, 'G2 MA 11:15-12:45 692F | VI 09:45-11:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10099, 1043, 'G3 LU 06:45-08:15 691B | MI 06:45-08:15 692H', 80, 80);

-- Cohorte: INGENIERIA MECANICA / nivel A
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1044, 'ALGEBRA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10100, 1044, 'G7 LU 12:45-14:15 660 | MA 12:45-14:15 623', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10101, 1044, 'G11 MA 09:45-11:15 691F | MI 09:45-11:15 642 | JU 09:45-11:15 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10102, 1044, 'G13 LU 06:45-08:15 642 | SA 09:45-11:15 693A | LU 12:45-14:15 617C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1045, 'CALCULO I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10103, 1045, 'G13 LU 09:45-11:15 652 | MA 18:45-20:15 692C | VI 17:15-18:45 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10104, 1045, 'G15 JU 06:45-08:15 692B | VI 06:45-08:15 607 | SA 08:15-09:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10105, 1045, 'G19 MA 17:15-18:45 661 | MI 17:15-18:45 612 | SA 09:45-11:15 617B', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1046, 'DIBUJO TECNICO COMPUTARIZADO');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10106, 1046, 'G1 LU 15:45-17:15 692B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10107, 1046, 'G2 MA 12:45-14:15 691D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10108, 1046, 'G3 MI 15:45-17:15 625C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1047, 'FISICA BASICA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10109, 1047, 'GM LU 09:45-11:15 624 | MA 09:45-11:15 692B | JU 06:45-08:15 692H', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10110, 1047, 'GM1 LU 14:15-15:45 621', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10111, 1047, 'GM2 LU 11:15-12:45 618', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1048, 'QUIMICA GENERAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10112, 1048, 'G3 MI 09:45-11:15 622 | VI 15:45-17:15 691B | SA 08:15-09:45 612', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10113, 1048, 'G3A MA 08:15-09:45 607 | MI 12:45-14:15 692B | JU 08:15-09:45 607', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10114, 1048, 'G3B MI 08:15-09:45 612 | JU 15:45-17:15 607 | VI 15:45-17:15 612', 80, 80);

-- Cohorte: INGENIERIA MECANICA / nivel B
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1049, 'ALGEBRA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10115, 1049, 'G7 LU 06:45-08:15 693D | JU 18:45-20:15 693A | VI 18:45-20:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10116, 1049, 'G7A LU 09:45-11:15 693A | JU 14:15-15:45 692G | VI 15:45-17:15 692B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10117, 1049, 'G9 LU 15:45-17:15 660 | JU 15:45-17:15 692E | VI 14:15-15:45 607', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1050, 'CALCULO II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10118, 1050, 'G3 MA 09:45-11:15 622 | MI 14:15-15:45 623 | JU 12:45-14:15 660', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10119, 1050, 'G8 LU 06:45-08:15 623 | MI 06:45-08:15 622 | VI 06:45-08:15 691E', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10120, 1050, 'G10 LU 06:45-08:15 691A | MA 06:45-08:15 692D | MI 06:45-08:15 692B', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1051, 'DIBUJO MECANICO');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10121, 1051, 'G1 LU 09:45-11:15 617B | MA 09:45-12:00 CAE | JU 11:15-12:45 690C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1052, 'ESTADISTICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10122, 1052, 'G1 MA 15:45-17:15 617B | MI 14:15-15:45 682L8IN | JU 15:45-17:15 692D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10123, 1052, 'G2 LU 20:15-21:45 690C | MA 18:45-20:15 624 | MI 18:45-20:15 625D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10124, 1052, 'G3 LU 18:45-20:15 692F | JU 20:15-21:45 624', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1053, 'FISICA BASICA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10125, 1053, 'GI LU 12:45-14:15 693C | MI 14:15-15:45 617C | VI 12:45-14:15 692E', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10126, 1053, 'GI1 LU 18:45-20:15 684L0', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10127, 1053, 'GI2 MA 11:15-12:45 684L0', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1054, 'INGLES TECNICO');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10128, 1054, 'G1 JU 18:45-20:15 692G | VI 18:45-20:15 692H', 80, 80);

-- Cohorte: INGENIERIA MECANICA / nivel C
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1055, 'ANALISIS VECTORIAL Y TENSORIAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10129, 1055, 'G2 LU 08:15-09:45 690B | MA 09:45-11:15 682B | MI 15:45-17:15 690B', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1056, 'COMPUTACION I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10130, 1056, 'G3 MA 11:15-12:45 690C | MI 12:45-14:15 625C | VI 18:45-20:15 691B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10131, 1056, 'G5 MA 12:45-14:15 691F | JU 12:45-14:15 692B | SA 09:45-11:15 607', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1057, 'ECUACIONES DIFERENCIALES');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10132, 1057, 'G3 MI 06:45-08:15 642 | VI 06:45-08:15 693A | SA 06:45-08:15 692E', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10133, 1057, 'G5 LU 11:15-12:45 612 | MI 06:45-08:15 660 | JU 12:45-14:15 617', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10134, 1057, 'G5A MA 17:15-18:45 642 | MI 17:15-18:45 617B | JU 18:45-20:15 690C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1058, 'ESTATICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10135, 1058, 'G1 MA 11:15-12:45 607 | JU 08:15-10:30 661', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10136, 1058, 'G2 MI 20:15-21:45 691C | VI 19:30-21:45 692G', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1059, 'FISICA BASICA III');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10137, 1059, 'GG MA 11:15-12:45 691A | MI 08:15-09:45 693C | JU 09:45-11:15 691F', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10138, 1059, 'GG1 MA 11:15-12:45 684L8', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10139, 1059, 'GG2 MI 06:45-08:15 684L8', 80, 80);

-- Cohorte: INGENIERIA MECANICA / nivel D
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1060, 'CALCULO NUMERICO');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10140, 1060, 'G2 LU 15:45-17:15 692E | MA 14:15-15:45 691A | VI 17:15-18:45 624', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1061, 'CIENCIA DE LOS MATERIALES');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10141, 1061, 'G2 LU 18:45-20:15 652 | MA 18:45-20:15 690C | MI 06:45-08:15 690B', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1062, 'DINAMICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10142, 1062, 'G1 LU 06:45-08:15 624 | MA 08:15-09:45 661 | JU 06:45-08:15 693B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10143, 1062, 'G2 LU 08:15-09:45 651 | MI 08:15-09:45 681B | JU 08:15-09:45 651', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1063, 'RESISTENCIA DE MATERIALES');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10144, 1063, 'G1 LU 20:15-21:45 692A | MA 20:15-21:45 MAGCIV | MI 20:15-21:45 692F', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10145, 1063, 'G2 MI 08:15-09:45 AUDCIV | MI 14:15-15:45 652 | JU 09:45-11:15 660', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10146, 1063, 'G3 MI 14:15-15:45 692E | JU 09:45-11:15 693A | VI 08:15-09:45 625C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1064, 'TERMODINAMICA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10147, 1064, 'G1 LU 17:15-18:45 660 | MA 15:45-17:15 652 | MI 14:15-15:45 690B', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1065, 'TRANSFORMADAS INTEGRALES');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10148, 1065, 'G1 LU 14:15-15:45 693B | JU 17:15-18:45 624 | VI 14:15-15:45 612', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10149, 1065, 'G2 LU 17:15-18:45 652 | MA 15:45-17:15 642 | JU 14:15-15:45 693C', 80, 80);

-- Cohorte: INGENIERIA QUIMICA / nivel A
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1066, 'ALGEBRA LINEAL Y TEORIA MATRICIAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10150, 1066, 'G1 JU 08:15-09:45 623 | VI 08:15-09:45 622 | SA 08:15-09:45 691A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10151, 1066, 'G2 LU 14:15-15:45 612 | MA 09:45-11:15 661 | JU 14:15-15:45 691F', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10152, 1066, 'G3 MA 08:15-09:45 617B | JU 17:15-18:45 612', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1067, 'CALCULO I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10153, 1067, 'G14 LU 06:45-08:15 607 | JU 06:45-08:15 607 | SA 11:15-12:45 691F', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10154, 1067, 'G18 LU 14:15-15:45 692D | MA 14:15-15:45 692A | VI 15:45-17:15 617B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10155, 1067, 'G22 LU 14:15-15:45 691D | MA 14:15-15:45 692B', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1068, 'FISICA BASICA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10156, 1068, 'GA LU 11:15-12:45 622 | MA 09:45-11:15 691A | MI 11:15-12:45 624', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10157, 1068, 'GA1 LU 15:45-17:15 618', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10158, 1068, 'GA2 LU 17:15-18:45 621', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1069, 'LABORATORIO DE QUIMICA GENERAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10159, 1069, 'G1 MI 12:45-17:15 616 | MI 12:45-16:30 616', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10160, 1069, 'G2 MA 08:15-12:45 613 | MA 08:15-12:00 613', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10161, 1069, 'G3 LU 15:00-19:30 613 | LU 15:00-18:45 613', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1070, 'QUIMICA GENERAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10162, 1070, 'G1 LU 14:15-15:45 693D | MA 11:15-12:45 623 | JU 11:15-12:45 624', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10163, 1070, 'G2 MA 15:45-17:15 691A | MI 14:15-15:45 692G | VI 14:15-15:45 691A', 80, 80);

-- Cohorte: INGENIERIA QUIMICA / nivel B
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1071, 'CALCULO II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10164, 1071, 'G9 VI 12:45-14:15 692A | SA 06:45-08:15 691D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10165, 1071, 'G9A LU 14:15-15:45 693C | MI 15:45-17:15 691A | JU 17:15-18:45 617', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10166, 1071, 'G11 MI 14:15-15:45 691C | VI 09:45-11:15 692G', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1072, 'EQUILIBRIOS EN DISOLUCION');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10167, 1072, 'G1 LU 12:45-14:15 690D | MA 12:45-14:15 692E | MI 12:45-14:15 692E', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10168, 1072, 'G2 MI 15:45-17:15 691D | JU 15:45-17:15 691D | VI 08:15-09:45 692C', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10169, 1072, 'G3 LU 08:15-09:45 683B | JU 11:15-12:45 683B | VI 11:15-12:45 617C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1073, 'ESTADISTICA APLICADA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10170, 1073, 'G1 MA 14:15-15:45 AULVIR | MI 09:45-11:15 AULVIR | VI 11:15-12:45 660', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1074, 'FISICA BASICA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10171, 1074, 'GA LU 06:45-08:15 691E | MI 09:45-11:15 690D | JU 08:15-09:45 691A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10172, 1074, 'GA1 LU 08:15-09:45 684L0', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10173, 1074, 'GA2 MI 11:15-12:45 684L0', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1075, 'QUIMICA INORGANICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10174, 1075, 'G1 LU 11:15-12:45 693B | MI 17:15-18:45 691E', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10175, 1075, 'G2 JU 18:45-20:15 691C | VI 18:45-20:15 692A', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1076, 'INGLES I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10176, 1076, 'G1 MA 17:15-18:45 690E | JU 17:15-18:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10177, 1076, 'G2 MA 11:15-12:45 692F | VI 09:45-11:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10178, 1076, 'G3 LU 06:45-08:15 691B | MI 06:45-08:15 692H', 80, 80);

-- Cohorte: INGENIERIA QUIMICA / nivel C
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1077, 'CALCULO III');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10179, 1077, 'G2 MA 08:15-09:45 623 | JU 08:15-09:45 624 | VI 09:45-11:15 624', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10180, 1077, 'G4A LU 17:15-18:45 625D | MI 18:45-20:15 693D | JU 17:15-18:45 692D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1078, 'FISICA BASICA III');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10181, 1078, 'GA MA 08:15-09:45 691C | MI 08:15-09:45 617 | JU 06:45-08:15 692E', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10182, 1078, 'GA1 LU 15:45-17:15 684L8', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10183, 1078, 'GA2 MI 12:45-14:15 684L8', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1079, 'FISICOQUIMICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10184, 1079, 'G2 LU 12:45-14:15 617 | MA 12:45-14:15 692F | VI 09:45-11:15 692B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10185, 1079, 'G3 MI 12:45-14:15 693B | JU 12:45-14:15 623 | VI 12:45-14:15 623', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1080, 'LABORATORIO DE FISICOQUIMICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10186, 1080, 'G1 MA 14:15-18:45 616 | MA 14:15-18:00 616', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10187, 1080, 'G2 MI 08:15-12:45 616 | MI 08:15-12:00 616', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10188, 1080, 'G3 MA 09:45-14:15 616 | MA 09:45-13:30 616', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1081, 'INGLES I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10189, 1081, 'G1 MA 17:15-18:45 690E | JU 17:15-18:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10190, 1081, 'G2 MA 11:15-12:45 692F | VI 09:45-11:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10191, 1081, 'G3 LU 06:45-08:15 691B | MI 06:45-08:15 692H', 80, 80);

-- Cohorte: INGENIERIA QUIMICA / nivel D
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1082, 'DIBUJO TECNICO');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10192, 1082, 'G1 MA 14:15-15:45 625D | MI 14:15-15:45 CAE', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10193, 1082, 'G2 MI 18:45-20:15 617B | VI 11:15-12:45 CAE', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1083, 'ECONOMIA Y ADMINISTRACION INDUSTRIAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10194, 1083, 'G1 MA 11:15-12:45 691B | MI 12:45-14:15 691D | JU 11:15-12:45 690B', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1084, 'INTRODUCCION A LOS PROCESOS QUIMICOS');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10195, 1084, 'G1 LU 09:45-11:15 623 | MA 06:45-08:15 691E | MI 06:45-08:15 691E', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1085, 'LABORATORIO DE QUIMICA ORGANICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10196, 1085, 'G1 LU 14:15-18:45 615 | LU 14:15-18:00 615', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10197, 1085, 'G2 MA 14:15-18:45 615 | MA 14:15-18:00 615', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10198, 1085, 'G3 MI 08:15-12:45 615 | MI 08:15-12:00 615', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1086, 'QUIMICA ORGANICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10199, 1086, 'G1 JU 06:45-08:15 693C | VI 06:45-08:15 692E | SA 06:45-08:15 693C', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10200, 1086, 'G2 LU 11:15-12:45 691D | JU 11:15-12:45 691C | VI 09:45-11:15 660', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1087, 'TERMODINAMICA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10201, 1087, 'G1 MA 12:45-14:15 651 | JU 12:45-14:15 691D | VI 17:15-18:45 607', 80, 80);

-- Cohorte: FISICA / nivel A
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1088, 'ALGEBRA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10202, 1088, 'G5 LU 17:15-18:45 642 | MA 15:45-17:15 617 | MI 14:15-15:45 607', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1089, 'CALCULO I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10203, 1089, 'G3 MA 06:45-08:15 661 | JU 18:45-20:15 692A | SA 11:15-12:45 624', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1090, 'FISICA BASICA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10204, 1090, 'GR LU 09:45-11:15 624 | MA 09:45-11:15 692B | JU 06:45-08:15 692H', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10205, 1090, 'GR1 VI 14:15-15:45 620', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10206, 1090, 'GR2 LU 15:45-17:15 621', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1091, 'GEOMETRIA ANALITICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10207, 1091, 'G1 LU 06:45-08:15 AULVIR | MI 08:15-09:45 AULVIR | JU 08:15-09:45 AULVIR', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1092, 'QUIMICA GENERAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10208, 1092, 'G3 MI 09:45-11:15 622 | VI 15:45-17:15 691B | SA 08:15-09:45 612', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10209, 1092, 'G5 LU 15:45-17:15 690C | MA 15:45-17:15 690B | JU 15:45-17:15 651', 80, 80);

-- Cohorte: FISICA / nivel B
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1093, 'ALGEBRA LINEAL Y MATRICIAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10210, 1093, 'G1 LU 17:15-18:45 691C | MA 17:15-18:45 692A | JU 18:45-20:15 690MAT', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1094, 'CALCULO II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10211, 1094, 'G9 VI 12:45-14:15 692A | SA 06:45-08:15 691D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1095, 'FISICA BASICA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10212, 1095, 'GL LU 06:45-08:15 691E | MI 09:45-11:15 690D | JU 08:15-09:45 691A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10213, 1095, 'GL1 VI 12:45-14:15 684L0', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10214, 1095, 'GL2 MI 12:45-14:15 684L0', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1096, 'PROBABILIDAD Y ESTADISTICA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10215, 1096, 'G1 LU 11:15-12:45 617C | MA 15:45-17:15 AULVIR | VI 09:45-11:15 AULVIR', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1097, 'INGLES I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10216, 1097, 'G1 MA 17:15-18:45 690E | JU 17:15-18:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10217, 1097, 'G2 MA 11:15-12:45 692F | VI 09:45-11:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10218, 1097, 'G3 LU 06:45-08:15 691B | MI 06:45-08:15 692H', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1098, 'METODOLOGIA INVESTIGACION Y TEC COMUNICACION');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10219, 1098, 'G1 LU 08:15-09:45 691C | MI 09:45-11:15 691B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10220, 1098, 'G2 LU 08:15-09:45 691D | MI 09:45-11:15 617B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10221, 1098, 'G3 JU 18:45-20:15 691F | VI 18:45-20:15 623', 80, 80);

-- Cohorte: FISICA / nivel C
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1099, 'ANALISIS VECTORIAL Y TENSORIAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10222, 1099, 'G1 JU 06:45-08:15 642 | VI 12:45-14:15 622 | SA 08:15-09:45 692E', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10223, 1099, 'G3 LU 09:45-11:15 625C | MA 11:15-12:45 690D | JU 06:45-08:15 691B', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1100, 'ECUACIONES DIFERENCIALES');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10224, 1100, 'G1 LU 09:45-11:15 607 | MI 09:45-11:15 607 | MA 09:45-11:15 625D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1101, 'FISICA BASICA III');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10225, 1101, 'GI MA 14:15-15:45 625C | MI 14:15-15:45 617B | VI 14:15-15:45 625C', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10226, 1101, 'GI1 JU 08:15-09:45 684L8', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10227, 1101, 'GI2 LU 15:45-17:15 684L8', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1102, 'PROBABILIDAD Y ESTADISTICA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10228, 1102, 'G1 LU 09:45-11:15 AULVIR | JU 15:45-17:15 AULVIR', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1103, 'INGLES I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10229, 1103, 'G1 MA 17:15-18:45 690E | JU 17:15-18:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10230, 1103, 'G2 MA 11:15-12:45 692F | VI 09:45-11:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10231, 1103, 'G3 LU 06:45-08:15 691B | MI 06:45-08:15 692H', 80, 80);

-- Cohorte: FISICA / nivel D
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1104, 'CALCULO COMPLEJO');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10232, 1104, 'G1 LU 12:45-14:15 622 | MA 06:45-08:15 692B | JU 06:45-08:15 617C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1105, 'FISICA BASICA IV');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10233, 1105, 'GA LU 09:45-11:15 684B | MI 09:45-11:15 684B | JU 09:45-11:15 684B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10234, 1105, 'GA1 LU 08:15-09:45 684L7', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1106, 'FISICA COMPUTACIONAL I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10235, 1106, 'G1 MA 08:15-09:45 684L6 | JU 06:45-08:15 684L6', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1107, 'INGLES III');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10236, 1107, 'G1 MA 14:15-15:45 693A | JU 15:45-17:15 692C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1108, 'INGLES I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10237, 1108, 'G1 MA 17:15-18:45 690E | JU 17:15-18:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10238, 1108, 'G2 MA 11:15-12:45 692F | VI 09:45-11:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10239, 1108, 'G3 LU 06:45-08:15 691B | MI 06:45-08:15 692H', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1109, 'METODOLOGIA INVESTIGACION Y TEC COMUNICACION');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10240, 1109, 'G1 LU 08:15-09:45 691C | MI 09:45-11:15 691B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10241, 1109, 'G2 LU 08:15-09:45 691D | MI 09:45-11:15 617B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10242, 1109, 'G3 JU 18:45-20:15 691F | VI 18:45-20:15 623', 80, 80);

-- Cohorte: INGENIERIA DE SISTEMAS / nivel A
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1110, 'ALGEBRA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10243, 1110, 'G5 MA 12:45-14:15 660 | SA 11:15-12:45 692B | VI 08:15-09:45 623', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10244, 1110, 'G6 MI 12:45-14:15 624 | JU 12:45-14:15 612 | VI 12:45-14:15 607', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10245, 1110, 'G8 MI 11:15-12:45 692F | VI 06:45-08:15 692F | JU 06:45-08:15 625D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1111, 'CALCULO I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10246, 1111, 'G7 LU 12:45-14:15 612 | MI 12:45-14:15 661 | JU 09:45-11:15 692B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10247, 1111, 'G8 MA 18:45-20:15 612 | MI 06:45-08:15 617C | SA 11:15-12:45 692E', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10248, 1111, 'G9 LU 12:45-14:15 651 | MI 12:45-14:15 690D | JU 11:15-12:45 622', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1112, 'FISICA GENERAL');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10249, 1112, 'GC LU 14:15-15:45 617 | JU 17:15-18:45 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10250, 1112, 'GC1 MA 11:15-12:45 620', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10251, 1112, 'GC2 VI 08:15-09:45 620', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1113, 'INGLES I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10252, 1113, 'G1 MA 17:15-18:45 690E | JU 17:15-18:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10253, 1113, 'G2 MA 11:15-12:45 692F | VI 09:45-11:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10254, 1113, 'G3 LU 06:45-08:15 691B | MI 06:45-08:15 692H', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1114, 'INTRODUCCION A LA PROGRAMACION');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10255, 1114, 'G1 JU 11:15-12:45 691A | VI 11:15-12:45 691E | VI 17:15-18:45 623', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10256, 1114, 'G2 MA 17:15-18:45 617 | JU 15:45-17:15 624 | MI 17:15-18:45 691B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10257, 1114, 'G3 LU 12:45-14:15 607 | MI 12:45-14:15 612 | VI 12:45-14:15 624', 80, 80);

-- Cohorte: INGENIERIA DE SISTEMAS / nivel B
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1115, 'ALGEBRA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10258, 1115, 'G5 JU 08:15-09:45 622 | VI 08:15-09:45 660 | SA 09:45-11:15 692B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10259, 1115, 'G6 JU 11:15-12:45 691B | VI 12:45-14:15 691A | SA 08:15-09:45 692A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10260, 1115, 'G8 LU 11:15-12:45 624 | JU 14:15-15:45 692B | MA 14:15-15:45 692D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1116, 'ARQUITECTURA DE COMPUTADORAS I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10261, 1116, 'G1 LU 15:45-17:15 692C | MA 17:15-18:45 691D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10262, 1116, 'G2 LU 14:15-15:45 691B | JU 14:15-15:45 624', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10263, 1116, 'G3 LU 11:15-12:45 692A | MI 12:45-14:15 617', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1117, 'CALCULO II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10264, 1117, 'G6 MI 09:45-11:15 691D | JU 11:15-12:45 693D | VI 14:15-15:45 692B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10265, 1117, 'G6A LU 12:45-14:15 693D | MA 09:45-11:15 692D | JU 08:15-09:45 691B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10266, 1117, 'G7 LU 08:15-09:45 622 | MA 09:45-11:15 607 | MI 09:45-11:15 693B', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1118, 'ELEM. DE PROGRAMACION Y ESTRUC. DE DATOS');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10267, 1118, 'G1 MA 08:15-09:45 617 | VI 08:15-09:45 690C | MI 11:15-12:45 691F', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10268, 1118, 'G2 LU 12:45-14:15 623 | JU 12:45-14:15 624 | MI 15:45-17:15 623', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10269, 1118, 'G3 MA 18:45-20:15 622 | MI 06:45-08:15 691C | JU 12:45-14:15 690C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1119, 'MATEMATICA DISCRETA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10270, 1119, 'G1 MI 17:15-18:45 623 | JU 17:15-18:45 622 | VI 17:15-18:45 691A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10271, 1119, 'G2 LU 12:45-14:15 691D | MA 11:15-12:45 692E | MI 20:15-21:45 624', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1120, 'INGLES I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10272, 1120, 'G1 MA 17:15-18:45 690E | JU 17:15-18:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10273, 1120, 'G2 MA 11:15-12:45 692F | VI 09:45-11:15 693A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10274, 1120, 'G3 LU 06:45-08:15 691B | MI 06:45-08:15 692H', 80, 80);

-- Cohorte: INGENIERIA DE SISTEMAS / nivel C
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1121, 'BASE DE DATOS I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10275, 1121, 'G1 MA 12:45-14:15 691B | MI 12:45-14:15 691B | JU 12:45-14:15 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10276, 1121, 'G2 LU 06:45-08:15 692H | MA 06:45-08:15 693B | VI 06:45-08:15 692D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1122, 'CALCULO NUMERICO');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10277, 1122, 'G2 LU 14:15-15:45 622 | MA 11:15-12:45 693A | JU 06:45-08:15 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10278, 1122, 'G3 LU 08:15-09:45 617 | MA 15:45-17:15 692H | MI 15:45-17:15 690D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1123, 'CIRCUITOS ELECTRONICOS');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10279, 1123, 'G2 VI 15:45-17:15 622 | SA 11:15-12:45 692A', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1124, 'ECUACIONES DIFERENCIALES');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10280, 1124, 'G3A MI 12:45-14:15 693C | VI 09:45-11:15 623 | SA 09:45-11:15 691A', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10281, 1124, 'G4 LU 09:45-11:15 651 | MA 08:15-09:45 692C | VI 18:45-20:15 691A', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1125, 'ESTADISTICA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10282, 1125, 'G3 MA 09:45-11:15 692G | JU 14:15-15:45 690C | SA 08:15-09:45 660', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10283, 1125, 'G4 LU 11:15-12:45 642 | MA 15:45-17:15 AULVIR | VI 09:45-11:15 AULVIR', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10284, 1125, 'G5 LU 20:15-21:45 624 | MA 17:15-18:45 692C | JU 08:15-09:45 690B', 80, 80);

-- Cohorte: INGENIERIA DE SISTEMAS / nivel D
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1126, 'BASE DE DATOS II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10285, 1126, 'G1 LU 06:45-08:15 617B | MA 06:45-08:15 691F | MI 08:15-09:45 617B', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10286, 1126, 'G2 LU 12:45-14:15 692B | MA 08:15-09:45 INFLAB | MI 09:45-11:15 612', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1127, 'CONTABILIDAD BASICA');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10287, 1127, 'G2 JU 09:45-11:15 625C | VI 09:45-11:15 622', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10288, 1127, 'G3 MA 11:15-12:45 692H | MI 18:45-20:15 692A | VI 11:15-12:45 692C', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1128, 'ESTADISTICA II');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10289, 1128, 'G2 LU 09:45-11:15 AULVIR | JU 15:45-17:15 AULVIR | VI 14:15-15:45 693D', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10290, 1128, 'G3 LU 08:15-09:45 692B | VI 14:15-15:45 691E | JU 18:45-20:15 660', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1129, 'INVESTIGACION OPERATIVA I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10291, 1129, 'G1 LU 11:15-12:45 682L8IN | MA 06:45-08:15 682L8IN | MI 08:15-09:45 682L7IN', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10292, 1129, 'G3 MA 11:15-12:45 AULVIR | MI 09:45-11:15 AULVIR | JU 12:45-14:15 AULVIR', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10293, 1129, 'G4 MA 14:15-15:45 682L6IN | MI 09:45-11:15 617C | JU 09:45-11:15 625D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1130, 'SISTEMAS DE INFORMACION I');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10294, 1130, 'G1 MI 15:45-17:15 692B | JU 09:45-11:15 607 | VI 09:45-11:15 691E', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10295, 1130, 'G2 LU 18:45-20:15 693D | MA 17:15-18:45 693D | MI 17:15-18:45 692D', 80, 80);
INSERT INTO "Materias" ("Id", "Nombre") VALUES (1131, 'TALLER DE SISTEMAS OPERATIVOS');
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10296, 1131, 'G1 MI 08:15-09:45 693A | JU 08:15-09:45 691F | VI 14:15-15:45 691C', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10297, 1131, 'G2 LU 08:15-09:45 623 | MI 14:15-15:45 691A | VI 08:15-09:45 624', 80, 80);
INSERT INTO "Horarios" ("Id", "MateriaId", "Descripcion", "CuposTotales", "CuposDisponibles") VALUES (10298, 1131, 'G3 LU 18:45-20:15 INFLAB | MA 18:45-20:15 691E | JU 20:15-21:45 691A', 80, 80);

-- Relación cohorte -> materias habilitadas.
CREATE TEMP TABLE k6_cohorte_materias (cohorte integer NOT NULL, materia_id integer NOT NULL) ON COMMIT DROP;
INSERT INTO k6_cohorte_materias (cohorte, materia_id) VALUES
    (0, 1000),
    (0, 1001),
    (0, 1002),
    (0, 1003),
    (0, 1004),
    (1, 1005),
    (1, 1006),
    (1, 1007),
    (1, 1008),
    (1, 1009),
    (1, 1010),
    (2, 1011),
    (2, 1012),
    (2, 1013),
    (2, 1014),
    (2, 1015),
    (3, 1016),
    (3, 1017),
    (3, 1018),
    (3, 1019),
    (3, 1020),
    (3, 1021),
    (4, 1022),
    (4, 1023),
    (4, 1024),
    (4, 1025),
    (4, 1026),
    (5, 1027),
    (5, 1028),
    (5, 1029),
    (5, 1030),
    (5, 1031),
    (5, 1032),
    (6, 1033),
    (6, 1034),
    (6, 1035),
    (6, 1036),
    (6, 1037),
    (7, 1038),
    (7, 1039),
    (7, 1040),
    (7, 1041),
    (7, 1042),
    (7, 1043),
    (8, 1044),
    (8, 1045),
    (8, 1046),
    (8, 1047),
    (8, 1048),
    (9, 1049),
    (9, 1050),
    (9, 1051),
    (9, 1052),
    (9, 1053),
    (9, 1054),
    (10, 1055),
    (10, 1056),
    (10, 1057),
    (10, 1058),
    (10, 1059),
    (11, 1060),
    (11, 1061),
    (11, 1062),
    (11, 1063),
    (11, 1064),
    (11, 1065),
    (12, 1066),
    (12, 1067),
    (12, 1068),
    (12, 1069),
    (12, 1070),
    (13, 1071),
    (13, 1072),
    (13, 1073),
    (13, 1074),
    (13, 1075),
    (13, 1076),
    (14, 1077),
    (14, 1078),
    (14, 1079),
    (14, 1080),
    (14, 1081),
    (15, 1082),
    (15, 1083),
    (15, 1084),
    (15, 1085),
    (15, 1086),
    (15, 1087),
    (16, 1088),
    (16, 1089),
    (16, 1090),
    (16, 1091),
    (16, 1092),
    (17, 1093),
    (17, 1094),
    (17, 1095),
    (17, 1096),
    (17, 1097),
    (17, 1098),
    (18, 1099),
    (18, 1100),
    (18, 1101),
    (18, 1102),
    (18, 1103),
    (19, 1104),
    (19, 1105),
    (19, 1106),
    (19, 1107),
    (19, 1108),
    (19, 1109),
    (20, 1110),
    (20, 1111),
    (20, 1112),
    (20, 1113),
    (20, 1114),
    (21, 1115),
    (21, 1116),
    (21, 1117),
    (21, 1118),
    (21, 1119),
    (21, 1120),
    (22, 1121),
    (22, 1122),
    (22, 1123),
    (22, 1124),
    (22, 1125),
    (23, 1126),
    (23, 1127),
    (23, 1128),
    (23, 1129),
    (23, 1130),
    (23, 1131);

-- Habilitaciones de los 10k estudiantes, distribuidas por cohorte.
INSERT INTO "MateriasHabilitadas" ("EstudianteId", "MateriaId")
SELECT 'k6-' || lpad(i::text, 5, '0'), cm.materia_id
FROM generate_series(1, 10000) AS i
JOIN k6_cohorte_materias cm ON cm.cohorte = ((i - 1) % 24)
ORDER BY i, cm.materia_id;

-- Mantener las secuencias por delante de los IDs explícitos del seed.
SELECT setval(pg_get_serial_sequence('"Materias"', 'Id'), GREATEST((SELECT COALESCE(MAX("Id"), 0) FROM "Materias"), 1), TRUE);
SELECT setval(pg_get_serial_sequence('"Horarios"', 'Id'), GREATEST((SELECT COALESCE(MAX("Id"), 0) FROM "Horarios"), 1), TRUE);

ANALYZE "AspNetUsers";
ANALYZE "Materias";
ANALYZE "Horarios";
ANALYZE "MateriasHabilitadas";

COMMIT;

