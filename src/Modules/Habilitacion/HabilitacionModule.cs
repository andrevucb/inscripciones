using Inscripciones.Modules.Habilitacion.Data;
using Inscripciones.Shared.Data;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace Inscripciones.Modules.Habilitacion;

public static class HabilitacionModule
{
    public static IServiceCollection AddHabilitacionModule(this IServiceCollection services)
    {
        services.AddSingleton<IModuleModelConfiguration, HabilitacionModelConfiguration>();
        return services;
    }

    public static IEndpointRouteBuilder MapHabilitacionEndpoints(this IEndpointRouteBuilder endpoints)
    {
        return endpoints;
    }
}
