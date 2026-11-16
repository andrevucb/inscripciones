using Inscripciones.Modules.Inscripciones.Contracts;
using Inscripciones.Modules.Inscripciones.Data;
using Inscripciones.Modules.Inscripciones.Endpoints;
using Inscripciones.Shared.Data;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace Inscripciones.Modules.Inscripciones;

public static class InscripcionesModule
{
    public static IServiceCollection AddInscripcionesModule(this IServiceCollection services)
    {
        services.AddSingleton<IModuleModelConfiguration, InscripcionesModelConfiguration>();
        services.AddOptions<InscripcionesOptions>().BindConfiguration(InscripcionesOptions.SectionName);
        services.AddScoped<IInscripcionesService, InscripcionesService>();
        services.AddScoped<ExpiracionReservasService>();
        services.AddHostedService<ReservasExpiracionBackgroundService>();
        return services;
    }

    public static IEndpointRouteBuilder MapInscripcionesEndpoints(this IEndpointRouteBuilder endpoints)
    {
        InscripcionesEndpoints.Map(endpoints);
        return endpoints;
    }
}
