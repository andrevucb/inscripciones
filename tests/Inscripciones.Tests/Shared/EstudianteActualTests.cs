using System.Security.Claims;
using Inscripciones.Shared.Identity;
using Microsoft.AspNetCore.Http;

namespace Inscripciones.Tests.Shared;

public class EstudianteActualTests
{
    [Fact]
    public void DevuelveElIdDelEstudianteAutenticado()
    {
        var accessor = new HttpContextAccessorFake
        {
            HttpContext = new DefaultHttpContext
            {
                User = new ClaimsPrincipal(new ClaimsIdentity(
                    [new Claim(ClaimTypes.NameIdentifier, "estudiante-1")],
                    authenticationType: "Bearer"))
            }
        };

        var estudianteActual = new EstudianteActual(accessor);

        Assert.Equal("estudiante-1", estudianteActual.EstudianteId);
    }

    [Fact]
    public void DevuelveNullCuandoNoHayContextoHttp()
    {
        var estudianteActual = new EstudianteActual(new HttpContextAccessorFake());

        Assert.Null(estudianteActual.EstudianteId);
    }

    private sealed class HttpContextAccessorFake : IHttpContextAccessor
    {
        public HttpContext? HttpContext { get; set; }
    }
}
