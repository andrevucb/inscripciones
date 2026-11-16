using Inscripciones.Modules.Catalogo.Contracts;
using Inscripciones.Modules.Inscripciones.Domain;
using Inscripciones.Shared.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Inscripciones.Modules.Inscripciones.Data;

public sealed class ExpiracionReservasService(
    AppDbContext db,
    ICatalogoService catalogoService,
    ILogger<ExpiracionReservasService> logger)
{
    public async Task<int> ExpirarVencidasAsync(CancellationToken cancellationToken = default)
    {
        var ahora = DateTimeOffset.UtcNow;
        var vencidas = await db.Set<Inscripcion>()
            .AsNoTracking()
            .Where(inscripcion =>
                inscripcion.Estado == EstadoInscripcion.Reservada &&
                inscripcion.ExpiraEn != null &&
                inscripcion.ExpiraEn < ahora)
            .Select(inscripcion => new { inscripcion.Id, inscripcion.HorarioId })
            .ToListAsync(cancellationToken);

        var expiradas = 0;

        foreach (var reserva in vencidas)
        {
            await using var transaccion = await db.Database.BeginTransactionAsync(cancellationToken);

            var filasAfectadas = await db.Database.ExecuteSqlInterpolatedAsync(
                $"""
                 UPDATE "Inscripciones"
                 SET "Estado" = 'Expirada'
                 WHERE "Id" = {reserva.Id} AND "Estado" = 'Reservada'
                 """,
                cancellationToken);

            if (filasAfectadas == 0)
            {
                await transaccion.RollbackAsync(cancellationToken);
                continue;
            }

            await catalogoService.LiberarCupo(reserva.HorarioId, cancellationToken);
            await transaccion.CommitAsync(cancellationToken);
            expiradas++;
        }

        if (expiradas > 0)
        {
            logger.LogInformation(
                "Se expiraron {Cantidad} reservas vencidas y se liberaron sus cupos.",
                expiradas);
        }

        return expiradas;
    }
}
