namespace Inscripciones.Modules.Auditoria.Contracts;

public interface IAuditoriaService
{
    Task RegistrarIntentoRechazado(
        string estudianteId,
        int? materiaId,
        string origen,
        string motivo,
        CancellationToken cancellationToken = default);
}
