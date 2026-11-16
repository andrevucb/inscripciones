namespace Inscripciones.Modules.Catalogo.Contracts;

public sealed record HorarioDisponible(
    int Id,
    string Descripcion,
    int CuposDisponibles);
