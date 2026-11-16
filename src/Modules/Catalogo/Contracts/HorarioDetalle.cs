namespace Inscripciones.Modules.Catalogo.Contracts;

public sealed record HorarioDetalle(
    int HorarioId,
    int MateriaId,
    string Descripcion,
    int CuposTotales,
    int CuposDisponibles);
