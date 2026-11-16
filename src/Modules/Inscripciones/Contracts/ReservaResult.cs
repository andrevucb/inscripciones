namespace Inscripciones.Modules.Inscripciones.Contracts;

public enum ReservaResultado
{
    Creada,
    HorarioNoEncontrado,
    MateriaNoHabilitada,
    InscripcionActiva,
    CupoAgotado
}

public sealed record ReservaResult(
    ReservaResultado Resultado,
    InscripcionResponse? Inscripcion = null,
    IReadOnlyList<AlternativaHorario>? Alternativas = null);
