namespace Inscripciones.Modules.Catalogo.Domain;

public sealed class Horario
{
    public int Id { get; set; }

    public int MateriaId { get; set; }

    public string Descripcion { get; set; } = string.Empty;

    public int CuposTotales { get; set; }

    public int CuposDisponibles { get; set; }
}
