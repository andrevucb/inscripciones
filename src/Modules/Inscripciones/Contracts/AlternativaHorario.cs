namespace Inscripciones.Modules.Inscripciones.Contracts;

public sealed record AlternativaHorario(
    int HorarioId,
    string Descripcion,
    int CuposDisponibles);
