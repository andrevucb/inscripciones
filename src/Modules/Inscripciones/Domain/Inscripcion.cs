namespace Inscripciones.Modules.Inscripciones.Domain;

public sealed class Inscripcion
{
    public int Id { get; set; }

    public string EstudianteId { get; set; } = string.Empty;

    public int HorarioId { get; set; }

    public EstadoInscripcion Estado { get; set; }

    public DateTimeOffset CreadaEn { get; set; }

    public DateTimeOffset? ExpiraEn { get; set; }
}
