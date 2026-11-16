namespace Inscripciones.Modules.Catalogo.Contracts;

public sealed record MateriaConHorarios(
    int Id,
    string Nombre,
    IReadOnlyList<HorarioDisponible> Horarios);
