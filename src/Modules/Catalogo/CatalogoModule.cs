using Inscripciones.Modules.Catalogo.Contracts;
using Inscripciones.Modules.Catalogo.Data;
using Inscripciones.Shared.Data;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace Inscripciones.Modules.Catalogo;

public static class CatalogoModule
{
    public static IServiceCollection AddCatalogoModule(this IServiceCollection services)
    {
        services.AddSingleton<IModuleModelConfiguration, CatalogoModelConfiguration>();
        services.AddScoped<ICatalogoService, CatalogoService>();
        return services;
    }

    public static IEndpointRouteBuilder MapCatalogoEndpoints(this IEndpointRouteBuilder endpoints)
    {
        return endpoints;
    }
}
