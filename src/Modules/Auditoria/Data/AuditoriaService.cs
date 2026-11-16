using Inscripciones.Modules.Auditoria.Contracts;
using Inscripciones.Modules.Auditoria.Domain;
using Inscripciones.Shared.Data;

namespace Inscripciones.Modules.Auditoria.Data;

public sealed class AuditoriaService(AppDbContext db) : IAuditoriaService
{
    public async Task RegistrarIntentoRechazado(
        string estudianteId,
        int? materiaId,
        string origen,
        string motivo,
        CancellationToken cancellationToken = default)
    {
        db.Set<IntentoRechazado>().Add(new IntentoRechazado
        {
            EstudianteId = estudianteId,
            MateriaId = materiaId,
            FechaHora = DateTimeOffset.UtcNow,
            Origen = origen,
            Motivo = motivo
        });

        await db.SaveChangesAsync(cancellationToken);
    }
}
