namespace Inscripciones.Modules.Catalogo.Contracts;

public interface ICatalogoService
{
    Task<IReadOnlyList<MateriaConHorarios>> ObtenerMateriasConHorarios(
        IReadOnlyCollection<int> materiaIds,
        CancellationToken cancellationToken = default);

    Task<HorarioDetalle?> ObtenerHorario(
        int horarioId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<HorarioDisponible>> ObtenerHorariosDeMateria(
        int materiaId,
        CancellationToken cancellationToken = default);
}
