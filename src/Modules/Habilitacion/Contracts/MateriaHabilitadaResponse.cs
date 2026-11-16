namespace Inscripciones.Modules.Habilitacion.Contracts;

public sealed record MateriaHabilitadaResponse(
    int MateriaId,
    string Nombre,
    IReadOnlyList<HorarioResponse> Horarios);
