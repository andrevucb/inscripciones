namespace Inscripciones.Modules.Auditoria.Domain;

public sealed class IntentoRechazado
{
    public int Id { get; set; }

    public string EstudianteId { get; set; } = string.Empty;

    public int? MateriaId { get; set; }

    public DateTimeOffset FechaHora { get; set; }

    public string Origen { get; set; } = string.Empty;

    public string Motivo { get; set; } = string.Empty;
}
