using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Inscripciones.Modules.Auditoria.Domain;
using Inscripciones.Modules.Catalogo.Domain;
using Inscripciones.Modules.Inscripciones.Data;
using Inscripciones.Modules.Inscripciones.Domain;
using Inscripciones.Shared.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Inscripciones.Tests.Integration;

public class InscripcionesEndpointsTests(InscripcionesApiFactory factory)
    : IClassFixture<InscripcionesApiFactory>, IAsyncLifetime
{
    private const string Clave = "Estudiante1!";
    private const string Ana = "ana.torres@inscripciones.local";
    private const string Carla = "carla.ruiz@inscripciones.local";

    public async Task InitializeAsync()
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        await db.Database.ExecuteSqlRawAsync(
            """
            DELETE FROM "Inscripciones";
            DELETE FROM "IntentosRechazados";
            UPDATE "Horarios" SET "CuposDisponibles" = "CuposTotales";
            """);
    }

    public Task DisposeAsync() => Task.CompletedTask;

    [Fact]
    public async Task MateriaNoHabilitada_Devuelve403_SinCambiarCupo_YRegistraAuditoria()
    {
        var datos = await ObtenerDatosAsync();
        using var cliente = await ClienteAutenticadoAsync(Carla);
        var cupoAntes = await CupoAsync(datos.CalculoLunesId);

        var respuesta = await ReservarAsync(cliente, datos.CalculoLunesId);

        Assert.Equal(HttpStatusCode.Forbidden, respuesta.StatusCode);
        Assert.Equal(cupoAntes, await CupoAsync(datos.CalculoLunesId));

        var intento = await ConDbAsync(db => db.Set<IntentoRechazado>().AsNoTracking().SingleAsync());
        Assert.Equal(datos.CarlaId, intento.EstudianteId);
        Assert.Equal(datos.CalculoId, intento.MateriaId);
        Assert.False(string.IsNullOrWhiteSpace(intento.Origen));
        Assert.Equal("Materia no habilitada para el estudiante", intento.Motivo);
        Assert.Equal(0, await ConDbAsync(db => db.Set<Inscripcion>().CountAsync()));
    }

    [Fact]
    public async Task ListaAjena_Devuelve403_SinDatos_YRegistraAuditoria()
    {
        var datos = await ObtenerDatosAsync();
        using var cliente = await ClienteAutenticadoAsync(Carla);

        var propia = await cliente.GetAsync("/materias/habilitadas");
        Assert.Equal(HttpStatusCode.OK, propia.StatusCode);
        using (var jsonPropia = JsonDocument.Parse(await propia.Content.ReadAsStringAsync()))
        {
            Assert.Equal(1, jsonPropia.RootElement.GetArrayLength());
        }

        var respuesta = await cliente.GetAsync($"/estudiantes/{datos.AnaId}/materias-habilitadas");

        Assert.Equal(HttpStatusCode.Forbidden, respuesta.StatusCode);
        Assert.Equal(string.Empty, await respuesta.Content.ReadAsStringAsync());

        var intento = await ConDbAsync(db => db.Set<IntentoRechazado>().AsNoTracking().SingleAsync());
        Assert.Equal(datos.CarlaId, intento.EstudianteId);
        Assert.Null(intento.MateriaId);
        Assert.Equal("Consulta de materias habilitadas de otro estudiante", intento.Motivo);
    }

    [Fact]
    public async Task UltimoCupo_PrimeraReservaFunciona_SegundaRecibe409ConAlternativas()
    {
        var datos = await ObtenerDatosAsync();
        using var ana = await ClienteAutenticadoAsync(Ana);
        using var carla = await ClienteAutenticadoAsync(Carla);

        var primera = await ReservarAsync(ana, datos.FisicaUnoId);
        Assert.Equal(HttpStatusCode.Created, primera.StatusCode);
        var inscripcionId = await LeerIdAsync(primera);
        Assert.Equal(0, await CupoAsync(datos.FisicaUnoId));

        var segunda = await ReservarAsync(carla, datos.FisicaUnoId);
        Assert.Equal(HttpStatusCode.Conflict, segunda.StatusCode);

        using var json = JsonDocument.Parse(await segunda.Content.ReadAsStringAsync());
        Assert.Equal("cupo_agotado", json.RootElement.GetProperty("error").GetString());
        Assert.Contains(
            json.RootElement.GetProperty("alternativas").EnumerateArray(),
            alternativa =>
                alternativa.GetProperty("horarioId").GetInt32() == datos.FisicaVeinticincoId &&
                alternativa.GetProperty("cuposDisponibles").GetInt32() > 0);

        Assert.Equal(0, await CupoAsync(datos.FisicaUnoId));
        Assert.Equal("Reservada", await EstadoAsync(inscripcionId));
    }

    [Fact]
    public async Task Cancelacion_DevuelveCupoDeInmediato()
    {
        var datos = await ObtenerDatosAsync();
        using var ana = await ClienteAutenticadoAsync(Ana);
        var capacidad = await CapacidadAsync(datos.CalculoLunesId);

        var reserva = await ReservarAsync(ana, datos.CalculoLunesId);
        var inscripcionId = await LeerIdAsync(reserva);
        Assert.Equal(capacidad - 1, await CupoAsync(datos.CalculoLunesId));

        var cancelacion = await ana.DeleteAsync($"/inscripciones/{inscripcionId}");

        Assert.Equal(HttpStatusCode.OK, cancelacion.StatusCode);
        Assert.Equal("Cancelada", await EstadoAsync(inscripcionId));
        Assert.Equal(capacidad, await CupoAsync(datos.CalculoLunesId));

        var segundaCancelacion = await ana.DeleteAsync($"/inscripciones/{inscripcionId}");
        Assert.Equal(HttpStatusCode.Conflict, segundaCancelacion.StatusCode);
        Assert.Equal(capacidad, await CupoAsync(datos.CalculoLunesId));
    }

    [Fact]
    public async Task Expiracion_LiberaCupoUnaSolaVez()
    {
        var datos = await ObtenerDatosAsync();
        using var ana = await ClienteAutenticadoAsync(Ana);

        var reserva = await ReservarAsync(ana, datos.FisicaUnoId);
        var inscripcionId = await LeerIdAsync(reserva);
        Assert.Equal(0, await CupoAsync(datos.FisicaUnoId));

        await EjecutarSqlAsync(
            $"""UPDATE "Inscripciones" SET "ExpiraEn" = now() - interval '1 minute' WHERE "Id" = {inscripcionId}""");

        await using var scope = factory.Services.CreateAsyncScope();
        var expiracion = scope.ServiceProvider.GetRequiredService<ExpiracionReservasService>();

        Assert.Equal(1, await expiracion.ExpirarVencidasAsync());
        Assert.Equal("Expirada", await EstadoAsync(inscripcionId));
        Assert.Equal(1, await CupoAsync(datos.FisicaUnoId));

        Assert.Equal(0, await expiracion.ExpirarVencidasAsync());
        Assert.Equal(1, await CupoAsync(datos.FisicaUnoId));
    }

    [Fact]
    public async Task ConfirmacionFueraDePlazo_Falla()
    {
        var datos = await ObtenerDatosAsync();
        using var ana = await ClienteAutenticadoAsync(Ana);

        var reserva = await ReservarAsync(ana, datos.CalculoLunesId);
        var inscripcionId = await LeerIdAsync(reserva);

        await EjecutarSqlAsync(
            $"""UPDATE "Inscripciones" SET "ExpiraEn" = now() - interval '1 minute' WHERE "Id" = {inscripcionId}""");

        var confirmacion = await ana.PostAsync($"/inscripciones/{inscripcionId}/confirmar", content: null);

        Assert.Equal(HttpStatusCode.Conflict, confirmacion.StatusCode);
        using var json = JsonDocument.Parse(await confirmacion.Content.ReadAsStringAsync());
        Assert.Equal("reserva_expirada", json.RootElement.GetProperty("error").GetString());
        Assert.Equal("Reservada", await EstadoAsync(inscripcionId));
    }

    [Fact]
    public async Task ConfirmacionExitosa_CambiaEstadoSinTocarCupo()
    {
        var datos = await ObtenerDatosAsync();
        using var ana = await ClienteAutenticadoAsync(Ana);

        var reserva = await ReservarAsync(ana, datos.CalculoLunesId);
        var inscripcionId = await LeerIdAsync(reserva);
        var cupoTrasReservar = await CupoAsync(datos.CalculoLunesId);

        var confirmacion = await ana.PostAsync($"/inscripciones/{inscripcionId}/confirmar", content: null);

        Assert.Equal(HttpStatusCode.OK, confirmacion.StatusCode);
        Assert.Equal("Confirmada", await EstadoAsync(inscripcionId));
        Assert.Equal(cupoTrasReservar, await CupoAsync(datos.CalculoLunesId));
    }

    private async Task<HttpClient> ClienteAutenticadoAsync(string email)
    {
        var cliente = factory.CreateClient();
        var respuesta = await cliente.PostAsJsonAsync(
            "/login?useCookies=false",
            new { email, password = Clave });

        respuesta.EnsureSuccessStatusCode();
        var sesion = await respuesta.Content.ReadFromJsonAsync<Sesion>();
        cliente.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", sesion!.AccessToken);
        return cliente;
    }

    private static Task<HttpResponseMessage> ReservarAsync(HttpClient cliente, int horarioId) =>
        cliente.PostAsJsonAsync("/inscripciones/reservas", new { horarioId });

    private static async Task<int> LeerIdAsync(HttpResponseMessage respuesta)
    {
        using var json = JsonDocument.Parse(await respuesta.Content.ReadAsStringAsync());
        return json.RootElement.GetProperty("id").GetInt32();
    }

    private async Task<DatosPrueba> ObtenerDatosAsync()
    {
        return await ConDbAsync(async db =>
        {
            var ana = await db.Users.AsNoTracking().SingleAsync(usuario => usuario.Email == Ana);
            var carla = await db.Users.AsNoTracking().SingleAsync(usuario => usuario.Email == Carla);
            var calculo = await db.Set<Materia>().AsNoTracking().SingleAsync(materia => materia.Nombre == "Cálculo I");
            var calculoLunes = await db.Set<Horario>().AsNoTracking()
                .SingleAsync(horario => horario.Descripcion == "Lunes y miércoles 09:00");
            var fisicaUno = await db.Set<Horario>().AsNoTracking()
                .SingleAsync(horario => horario.Descripcion == "Martes y jueves 16:00");
            var fisicaVeinticinco = await db.Set<Horario>().AsNoTracking()
                .SingleAsync(horario => horario.Descripcion == "Lunes y miércoles 11:00");

            return new DatosPrueba(
                ana.Id,
                carla.Id,
                calculo.Id,
                calculoLunes.Id,
                fisicaUno.Id,
                fisicaVeinticinco.Id);
        });
    }

    private Task<int> CupoAsync(int horarioId) =>
        ConDbAsync(db => db.Set<Horario>()
            .Where(horario => horario.Id == horarioId)
            .Select(horario => horario.CuposDisponibles)
            .SingleAsync());

    private Task<int> CapacidadAsync(int horarioId) =>
        ConDbAsync(db => db.Set<Horario>()
            .Where(horario => horario.Id == horarioId)
            .Select(horario => horario.CuposTotales)
            .SingleAsync());

    private async Task<string> EstadoAsync(int inscripcionId)
    {
        var estado = await ConDbAsync(db => db.Set<Inscripcion>()
            .Where(inscripcion => inscripcion.Id == inscripcionId)
            .Select(inscripcion => inscripcion.Estado)
            .SingleAsync());

        return estado.ToString();
    }

    private async Task EjecutarSqlAsync(FormattableString sql)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.ExecuteSqlInterpolatedAsync(sql);
    }

    private async Task<T> ConDbAsync<T>(Func<AppDbContext, Task<T>> operacion)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        return await operacion(db);
    }

    private sealed record DatosPrueba(
        string AnaId,
        string CarlaId,
        int CalculoId,
        int CalculoLunesId,
        int FisicaUnoId,
        int FisicaVeinticincoId);

    private sealed record Sesion([property: JsonPropertyName("accessToken")] string AccessToken);
}
