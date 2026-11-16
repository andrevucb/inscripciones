using Inscripciones.Modules.Catalogo.Contracts;
using Inscripciones.Modules.Inscripciones.Domain;
using Inscripciones.Shared.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Inscripciones.Modules.Inscripciones.Data;

public sealed class ReservasExpiracionService(
    IServiceScopeFactory scopeFactory,
    IOptions<InscripcionesOptions> options,
    ILogger<ReservasExpiracionService> logger) : BackgroundService
{
    private readonly TimeSpan _intervaloRevision =
        TimeSpan.FromSeconds(Math.Max(1, options.Value.IntervaloRevisionSegundos));

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var temporizador = new PeriodicTimer(_intervaloRevision);

        while (await EsperarSiguienteRevision(temporizador, stoppingToken))
        {
            try
            {
                await ExpirarReservasVencidas(stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception excepcion)
            {
                logger.LogError(excepcion, "Error al expirar reservas vencidas.");
            }
        }
    }

    private static async Task<bool> EsperarSiguienteRevision(
        PeriodicTimer temporizador,
        CancellationToken stoppingToken)
    {
        try
        {
            return await temporizador.WaitForNextTickAsync(stoppingToken);
        }
        catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
        {
            return false;
        }
    }

    private async Task ExpirarReservasVencidas(CancellationToken cancellationToken)
    {
        using var scope = scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var catalogoService = scope.ServiceProvider.GetRequiredService<ICatalogoService>();

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
    }
}
