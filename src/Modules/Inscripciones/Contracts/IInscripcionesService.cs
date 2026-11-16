namespace Inscripciones.Modules.Inscripciones.Contracts;

public interface IInscripcionesService
{
    Task<ReservaResult> Reservar(
        string estudianteId,
        int horarioId,
        string origen,
        CancellationToken cancellationToken = default);

    Task<OperacionResult> Confirmar(
        string estudianteId,
        int inscripcionId,
        CancellationToken cancellationToken = default);

    Task<OperacionResult> Cancelar(
        string estudianteId,
        int inscripcionId,
        CancellationToken cancellationToken = default);
}
