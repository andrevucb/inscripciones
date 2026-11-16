using Inscripciones.Modules.Habilitacion.Contracts;
using Inscripciones.Modules.Habilitacion.Data;
using Inscripciones.Modules.Habilitacion.Endpoints;
using Inscripciones.Shared.Data;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace Inscripciones.Modules.Habilitacion;

public static class HabilitacionModule
{
    public static IServiceCollection AddHabilitacionModule(this IServiceCollection services)
    {
        services.AddSingleton<IModuleModelConfiguration, HabilitacionModelConfiguration>();
        services.AddScoped<IHabilitacionService, HabilitacionService>();
        return services;
    }

    public static IEndpointRouteBuilder MapHabilitacionEndpoints(this IEndpointRouteBuilder endpoints)
    {
        HabilitacionEndpoints.Map(endpoints);
        return endpoints;
    }
}
