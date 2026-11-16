namespace Inscripciones.Modules.Habilitacion.Contracts;

public interface IHabilitacionService
{
    Task<IReadOnlyList<MateriaHabilitadaResponse>> ObtenerMateriasHabilitadas(
        string estudianteId,
        CancellationToken cancellationToken = default);
}
