using Inscripciones.Modules.Catalogo.Domain;
using Inscripciones.Modules.Habilitacion.Domain;
using Inscripciones.Shared.Data;
using Inscripciones.Shared.Identity;
using Microsoft.EntityFrameworkCore;

namespace Inscripciones.Modules.Habilitacion.Data;

public sealed class HabilitacionModelConfiguration : IModuleModelConfiguration
{
    public void Configure(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<MateriaHabilitada>(materiaHabilitada =>
        {
            materiaHabilitada.ToTable("MateriasHabilitadas");
            materiaHabilitada.HasKey(m => new { m.EstudianteId, m.MateriaId });
            materiaHabilitada
                .HasOne<ApplicationUser>()
                .WithMany()
                .HasForeignKey(m => m.EstudianteId)
                .OnDelete(DeleteBehavior.Cascade);
            materiaHabilitada
                .HasOne<Materia>()
                .WithMany()
                .HasForeignKey(m => m.MateriaId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
