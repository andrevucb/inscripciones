using Inscripciones.Modules.Auditoria.Data;
using Inscripciones.Modules.Catalogo.Data;
using Inscripciones.Modules.Habilitacion.Data;
using Inscripciones.Modules.Inscripciones.Data;
using Inscripciones.Shared.Data;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Npgsql;

namespace Inscripciones.Tests.Integration;

public sealed class InscripcionesApiFactory : WebApplicationFactory<Program>
{
    public const string NombreBaseDeDatos = "inscripciones_tests";

    public const string CadenaConexion =
        $"Host=localhost;Port=5432;Database={NombreBaseDeDatos};Username=inscripciones;Password=inscripciones";

    private const string CadenaAdministracion =
        "Host=localhost;Port=5432;Database=postgres;Username=inscripciones;Password=inscripciones";

    public InscripcionesApiFactory()
    {
        PrepararBaseDeDatosAsync().GetAwaiter().GetResult();
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureAppConfiguration((_, configuration) =>
        {
            configuration.AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["ConnectionStrings:Inscripciones"] = CadenaConexion,
                // Evita que el expirador interfiera con las pruebas que controlan el vencimiento.
                ["Inscripciones:IntervaloRevisionSegundos"] = "3600"
            });
        });
    }

    private static async Task PrepararBaseDeDatosAsync()
    {
        NpgsqlConnection.ClearAllPools();

        await using (var conexion = new NpgsqlConnection(CadenaAdministracion))
        {
            await conexion.OpenAsync();

            await using (var eliminar = new NpgsqlCommand(
                $"DROP DATABASE IF EXISTS \"{NombreBaseDeDatos}\" WITH (FORCE)",
                conexion))
            {
                await eliminar.ExecuteNonQueryAsync();
            }

            await using var crear = new NpgsqlCommand(
                $"CREATE DATABASE \"{NombreBaseDeDatos}\"",
                conexion);

            await crear.ExecuteNonQueryAsync();
        }

        var opciones = new DbContextOptionsBuilder<AppDbContext>()
            .UseNpgsql(CadenaConexion)
            .Options;

        await using var db = new AppDbContext(
            opciones,
            [
                new CatalogoModelConfiguration(),
                new HabilitacionModelConfiguration(),
                new InscripcionesModelConfiguration(),
                new AuditoriaModelConfiguration()
            ]);

        await db.Database.MigrateAsync();
    }
}
