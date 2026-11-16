using Inscripciones.Modules.Auditoria.Data;
using Inscripciones.Shared.Data;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace Inscripciones.Modules.Auditoria;

public static class AuditoriaModule
{
    public static IServiceCollection AddAuditoriaModule(this IServiceCollection services)
    {
        services.AddSingleton<IModuleModelConfiguration, AuditoriaModelConfiguration>();
        return services;
    }

    public static IEndpointRouteBuilder MapAuditoriaEndpoints(this IEndpointRouteBuilder endpoints)
    {
        return endpoints;
    }
}
