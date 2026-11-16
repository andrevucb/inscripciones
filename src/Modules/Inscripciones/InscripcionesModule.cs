using Inscripciones.Modules.Inscripciones.Data;
using Inscripciones.Shared.Data;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace Inscripciones.Modules.Inscripciones;

public static class InscripcionesModule
{
    public static IServiceCollection AddInscripcionesModule(this IServiceCollection services)
    {
        services.AddSingleton<IModuleModelConfiguration, InscripcionesModelConfiguration>();
        return services;
    }

    public static IEndpointRouteBuilder MapInscripcionesEndpoints(this IEndpointRouteBuilder endpoints)
    {
        return endpoints;
    }
}
