using System.Security.Claims;
using Microsoft.AspNetCore.Http;

namespace Inscripciones.Shared.Identity;

public sealed class EstudianteActual(IHttpContextAccessor httpContextAccessor) : IEstudianteActual
{
    public string? EstudianteId =>
        httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
}
