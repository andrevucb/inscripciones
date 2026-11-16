namespace Inscripciones.Modules.Inscripciones;

public sealed class InscripcionesOptions
{
    public const string SectionName = "Inscripciones";

    public int DuracionReservaMinutos { get; set; } = 5;

    public int IntervaloRevisionSegundos { get; set; } = 3;
}
