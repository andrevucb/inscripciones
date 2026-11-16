namespace Inscripciones.Modules.Catalogo.Contracts;

public sealed record HorarioDisponible(
    int HorarioId,
    string Descripcion,
    int CuposDisponibles);
