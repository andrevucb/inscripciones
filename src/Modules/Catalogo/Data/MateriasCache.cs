using Inscripciones.Modules.Catalogo.Domain;
using Inscripciones.Shared.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Inscripciones.Modules.Catalogo.Data;

/// <summary>
/// Catálogo de materias en memoria. Es inmutable después del seed, así que se
/// consulta una sola vez. Los horarios NO se cachean porque CuposDisponibles
/// cambia con cada reserva, expiración o liberación.
/// </summary>
public sealed class MateriasCache(IServiceScopeFactory scopeFactory)
{
    private readonly Lazy<Task<IReadOnlyDictionary<int, string>>> _materias =
        new(() => Cargar(scopeFactory));

    public Task<IReadOnlyDictionary<int, string>> ObtenerTodas() => _materias.Value;

    private static async Task<IReadOnlyDictionary<int, string>> Cargar(
        IServiceScopeFactory scopeFactory)
    {
        // DbContext es scoped y este servicio es singleton: se crea un scope propio.
        using var scope = scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        return await db.Set<Materia>()
            .AsNoTracking()
            .ToDictionaryAsync(materia => materia.Id, materia => materia.Nombre);
    }
}
