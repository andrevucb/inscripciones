namespace Inscripciones.Modules.Catalogo.Contracts;

public interface ICatalogoService
{
    Task<IReadOnlyList<MateriaConHorarios>> ObtenerMateriasConHorarios(
        IReadOnlyCollection<int> materiaIds,
        CancellationToken cancellationToken = default);
}
