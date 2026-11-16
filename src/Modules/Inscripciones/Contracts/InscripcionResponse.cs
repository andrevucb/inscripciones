namespace Inscripciones.Modules.Inscripciones.Contracts;

public sealed record InscripcionResponse(
    int Id,
    int HorarioId,
    string Estado,
    DateTimeOffset CreadaEn,
    DateTimeOffset? ExpiraEn);
