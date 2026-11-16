using Inscripciones.Modules.Inscripciones.Contracts;
using Inscripciones.Shared.Identity;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace Inscripciones.Modules.Inscripciones.Endpoints;

internal static class InscripcionesEndpoints
{
    public static void Map(IEndpointRouteBuilder endpoints)
    {
        endpoints
            .MapPost("/inscripciones/reservas", Reservar)
            .RequireAuthorization();

        endpoints
            .MapPost("/inscripciones/{id:int}/confirmar", Confirmar)
            .RequireAuthorization();

        endpoints
            .MapDelete("/inscripciones/{id:int}", Cancelar)
            .RequireAuthorization();
    }

    private static async Task<IResult> Reservar(
        ReservaRequest request,
        HttpContext httpContext,
        IEstudianteActual estudianteActual,
        IInscripcionesService inscripcionesService,
        CancellationToken cancellationToken)
    {
        var estudianteId = estudianteActual.EstudianteId;
        if (estudianteId is null)
        {
            return Results.Unauthorized();
        }

        var resultado = await inscripcionesService.Reservar(
            estudianteId,
            request.HorarioId,
            httpContext.Connection.RemoteIpAddress?.ToString() ?? "desconocido",
            cancellationToken);

        return resultado.Resultado switch
        {
            ReservaResultado.Creada =>
                Results.Created($"/inscripciones/{resultado.Inscripcion!.Id}", resultado.Inscripcion),
            ReservaResultado.HorarioNoEncontrado =>
                Results.NotFound(new { error = "horario_no_encontrado" }),
            ReservaResultado.MateriaNoHabilitada =>
                Results.Forbid(),
            ReservaResultado.InscripcionActiva =>
                Results.Conflict(new { error = "inscripcion_activa" }),
            ReservaResultado.CupoAgotado =>
                Results.Conflict(new { error = "cupo_agotado", alternativas = resultado.Alternativas }),
            _ => Results.Problem()
        };
    }

    private static async Task<IResult> Confirmar(
        int id,
        IEstudianteActual estudianteActual,
        IInscripcionesService inscripcionesService,
        CancellationToken cancellationToken)
    {
        var estudianteId = estudianteActual.EstudianteId;
        if (estudianteId is null)
        {
            return Results.Unauthorized();
        }

        var resultado = await inscripcionesService.Confirmar(estudianteId, id, cancellationToken);
        return MapearOperacion(resultado, "reserva_expirada");
    }

    private static async Task<IResult> Cancelar(
        int id,
        IEstudianteActual estudianteActual,
        IInscripcionesService inscripcionesService,
        CancellationToken cancellationToken)
    {
        var estudianteId = estudianteActual.EstudianteId;
        if (estudianteId is null)
        {
            return Results.Unauthorized();
        }

        var resultado = await inscripcionesService.Cancelar(estudianteId, id, cancellationToken);
        return MapearOperacion(resultado, "estado_invalido");
    }

    private static IResult MapearOperacion(OperacionResult resultado, string errorConflicto)
    {
        return resultado.Resultado switch
        {
            OperacionResultado.Ok => Results.Ok(resultado.Inscripcion),
            OperacionResultado.NoEncontrada =>
                Results.NotFound(new { error = "inscripcion_no_encontrada" }),
            OperacionResultado.Prohibida => Results.Forbid(),
            OperacionResultado.Expirada =>
                Results.Conflict(new { error = "reserva_expirada" }),
            OperacionResultado.EstadoInvalido =>
                Results.Conflict(new { error = errorConflicto }),
            _ => Results.Problem()
        };
    }
}
