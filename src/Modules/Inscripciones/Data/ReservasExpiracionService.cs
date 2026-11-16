using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Inscripciones.Modules.Inscripciones.Data;

public sealed class ReservasExpiracionBackgroundService(
    IServiceScopeFactory scopeFactory,
    IOptions<InscripcionesOptions> options,
    ILogger<ReservasExpiracionBackgroundService> logger) : BackgroundService
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
                using var scope = scopeFactory.CreateScope();
                var expiracion = scope.ServiceProvider.GetRequiredService<ExpiracionReservasService>();
                await expiracion.ExpirarVencidasAsync(stoppingToken);
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
}
