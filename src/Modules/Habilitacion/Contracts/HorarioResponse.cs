namespace Inscripciones.Modules.Habilitacion.Contracts;

public sealed record HorarioResponse(
    int HorarioId,
    string Descripcion,
    int CuposDisponibles);
