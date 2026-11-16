using Inscripciones.Modules.Catalogo.Contracts;
using Inscripciones.Modules.Catalogo.Domain;
using Inscripciones.Shared.Data;
using Microsoft.EntityFrameworkCore;

namespace Inscripciones.Modules.Catalogo.Data;

public sealed class CatalogoService(AppDbContext db) : ICatalogoService
{
    public async Task<IReadOnlyList<MateriaConHorarios>> ObtenerMateriasConHorarios(
        IReadOnlyCollection<int> materiaIds,
        CancellationToken cancellationToken = default)
    {
        if (materiaIds.Count == 0)
        {
            return [];
        }

        var materias = await db.Set<Materia>()
            .Where(materia => materiaIds.Contains(materia.Id))
            .OrderBy(materia => materia.Nombre)
            .Select(materia => new { materia.Id, materia.Nombre })
            .ToListAsync(cancellationToken);

        var horarios = await db.Set<Horario>()
            .Where(horario => materiaIds.Contains(horario.MateriaId))
            .OrderBy(horario => horario.Descripcion)
            .Select(horario => new
            {
                horario.Id,
                horario.MateriaId,
                horario.Descripcion,
                horario.CuposDisponibles
            })
            .ToListAsync(cancellationToken);

        return materias
            .Select(materia => new MateriaConHorarios(
                materia.Id,
                materia.Nombre,
                horarios
                    .Where(horario => horario.MateriaId == materia.Id)
                    .Select(horario => new HorarioDisponible(
                        horario.Id,
                        horario.Descripcion,
                        horario.CuposDisponibles))
                    .ToList()))
            .ToList();
    }
}
