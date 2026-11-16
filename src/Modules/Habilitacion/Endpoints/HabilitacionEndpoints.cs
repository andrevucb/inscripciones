using Inscripciones.Modules.Auditoria.Contracts;
using Inscripciones.Modules.Habilitacion.Contracts;
using Inscripciones.Shared.Identity;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace Inscripciones.Modules.Habilitacion.Endpoints;

internal static class HabilitacionEndpoints
{
    private const string MotivoConsultaAjena = "Consulta de materias habilitadas de otro estudiante";

    public static void Map(IEndpointRouteBuilder endpoints)
    {
        endpoints
            .MapGet("/materias/habilitadas", ObtenerMateriasHabilitadas)
            .RequireAuthorization();

        endpoints
            .MapGet("/estudiantes/{estudianteId}/materias-habilitadas", ObtenerMateriasHabilitadasDeEstudiante)
            .RequireAuthorization();
    }

    private static async Task<IResult> ObtenerMateriasHabilitadas(
        IEstudianteActual estudianteActual,
        IHabilitacionService habilitacionService,
        CancellationToken cancellationToken)
    {
        var estudianteId = estudianteActual.EstudianteId;
        if (estudianteId is null)
        {
            return Results.Unauthorized();
        }

        var materias = await habilitacionService.ObtenerMateriasHabilitadas(estudianteId, cancellationToken);
        return Results.Ok(materias);
    }

    private static async Task<IResult> ObtenerMateriasHabilitadasDeEstudiante(
        string estudianteId,
        HttpContext httpContext,
        IEstudianteActual estudianteActual,
        IHabilitacionService habilitacionService,
        IAuditoriaService auditoriaService,
        CancellationToken cancellationToken)
    {
        var estudianteAutenticadoId = estudianteActual.EstudianteId;
        if (estudianteAutenticadoId is null)
        {
            return Results.Unauthorized();
        }

        if (!string.Equals(estudianteId, estudianteAutenticadoId, StringComparison.Ordinal))
        {
            await auditoriaService.RegistrarIntentoRechazado(
                estudianteAutenticadoId,
                materiaId: null,
                origen: httpContext.Connection.RemoteIpAddress?.ToString() ?? "desconocido",
                motivo: MotivoConsultaAjena,
                cancellationToken);

            return Results.Forbid();
        }

        var materias = await habilitacionService.ObtenerMateriasHabilitadas(estudianteAutenticadoId, cancellationToken);
        return Results.Ok(materias);
    }
}
