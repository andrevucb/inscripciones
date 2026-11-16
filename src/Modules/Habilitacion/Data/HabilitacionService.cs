using Inscripciones.Modules.Catalogo.Contracts;
using Inscripciones.Modules.Habilitacion.Contracts;
using Inscripciones.Modules.Habilitacion.Domain;
using Inscripciones.Shared.Data;
using Microsoft.EntityFrameworkCore;

namespace Inscripciones.Modules.Habilitacion.Data;

public sealed class HabilitacionService(AppDbContext db, ICatalogoService catalogoService)
    : IHabilitacionService
{
    public async Task<IReadOnlyList<MateriaHabilitadaResponse>> ObtenerMateriasHabilitadas(
        string estudianteId,
        CancellationToken cancellationToken = default)
    {
        var materiaIds = await db.Set<MateriaHabilitada>()
            .Where(materiaHabilitada => materiaHabilitada.EstudianteId == estudianteId)
            .Select(materiaHabilitada => materiaHabilitada.MateriaId)
            .ToListAsync(cancellationToken);

        if (materiaIds.Count == 0)
        {
            return [];
        }

        var materias = await catalogoService.ObtenerMateriasConHorarios(materiaIds, cancellationToken);

        return materias
            .Select(materia => new MateriaHabilitadaResponse(
                materia.Id,
                materia.Nombre,
                materia.Horarios
                    .Select(horario => new HorarioResponse(
                        horario.Id,
                        horario.Descripcion,
                        horario.CuposDisponibles))
                    .ToList()))
            .ToList();
    }
}
