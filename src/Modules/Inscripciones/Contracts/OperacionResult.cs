namespace Inscripciones.Modules.Inscripciones.Contracts;

public enum OperacionResultado
{
    Ok,
    NoEncontrada,
    Prohibida,
    EstadoInvalido,
    Expirada
}

public sealed record OperacionResult(
    OperacionResultado Resultado,
    InscripcionResponse? Inscripcion = null);
