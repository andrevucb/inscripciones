using Inscripciones.Modules.Catalogo.Domain;
using Inscripciones.Modules.Habilitacion.Domain;
using Inscripciones.Shared.Data;
using Inscripciones.Shared.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Inscripciones.Api.Seeding;

public static class Seeder
{
    public static async Task SeedAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("Seeder");

        if (await db.Set<Materia>().AnyAsync())
        {
            logger.LogInformation("Seeder: los datos de prueba ya existen; no se hace nada.");
            return;
        }

        var calculo = new Materia { Nombre = "Cálculo I" };
        var fisica = new Materia { Nombre = "Física Básica" };
        var programacion = new Materia { Nombre = "Programación I" };

        db.Set<Materia>().AddRange(calculo, fisica, programacion);
        await db.SaveChangesAsync();

        db.Set<Horario>().AddRange(
            new Horario { MateriaId = calculo.Id, Descripcion = "Lunes y miércoles 09:00", CuposTotales = 30, CuposDisponibles = 30 },
            new Horario { MateriaId = calculo.Id, Descripcion = "Martes y jueves 14:00", CuposTotales = 20, CuposDisponibles = 20 },
            new Horario { MateriaId = calculo.Id, Descripcion = "Viernes 18:00", CuposTotales = 1, CuposDisponibles = 1 },
            new Horario { MateriaId = fisica.Id, Descripcion = "Lunes y miércoles 11:00", CuposTotales = 25, CuposDisponibles = 25 },
            new Horario { MateriaId = fisica.Id, Descripcion = "Martes y jueves 16:00", CuposTotales = 1, CuposDisponibles = 1 },
            new Horario { MateriaId = programacion.Id, Descripcion = "Lunes y miércoles 08:00", CuposTotales = 30, CuposDisponibles = 30 },
            new Horario { MateriaId = programacion.Id, Descripcion = "Martes y jueves 10:00", CuposTotales = 20, CuposDisponibles = 20 },
            new Horario { MateriaId = programacion.Id, Descripcion = "Viernes 15:00", CuposTotales = 1, CuposDisponibles = 1 });
        await db.SaveChangesAsync();

        var estudiantes = new[]
        {
            (Email: "ana.torres@inscripciones.local", Materias: new[] { calculo, fisica, programacion }),
            (Email: "bruno.diaz@inscripciones.local", Materias: new[] { calculo, programacion }),
            (Email: "carla.ruiz@inscripciones.local", Materias: new[] { fisica })
        };

        foreach (var (email, materias) in estudiantes)
        {
            var usuario = await userManager.FindByEmailAsync(email);
            if (usuario is null)
            {
                usuario = new ApplicationUser { UserName = email, Email = email, EmailConfirmed = true };
                var resultado = await userManager.CreateAsync(usuario, "Estudiante1!");
                if (!resultado.Succeeded)
                {
                    throw new InvalidOperationException(
                        $"No se pudo crear el estudiante {email}: " +
                        string.Join(", ", resultado.Errors.Select(error => error.Description)));
                }
            }

            db.Set<MateriaHabilitada>().AddRange(materias.Select(materia => new MateriaHabilitada
            {
                EstudianteId = usuario.Id,
                MateriaId = materia.Id
            }));
        }

        await db.SaveChangesAsync();
        logger.LogInformation("Seeder: 3 materias, 8 horarios y 3 estudiantes creados.");
    }
}
