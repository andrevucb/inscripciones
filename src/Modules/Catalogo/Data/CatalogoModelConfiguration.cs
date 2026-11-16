using Inscripciones.Modules.Catalogo.Domain;
using Inscripciones.Shared.Data;
using Microsoft.EntityFrameworkCore;

namespace Inscripciones.Modules.Catalogo.Data;

public sealed class CatalogoModelConfiguration : IModuleModelConfiguration
{
    public void Configure(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Materia>(materia =>
        {
            materia.ToTable("Materias");
            materia.HasKey(m => m.Id);
            materia.Property(m => m.Nombre).HasMaxLength(200).IsRequired();
        });

        modelBuilder.Entity<Horario>(horario =>
        {
            horario.ToTable("Horarios", tabla =>
                tabla.HasCheckConstraint("CK_Horarios_CuposDisponibles", "\"CuposDisponibles\" >= 0"));

            horario.HasKey(h => h.Id);
            horario.Property(h => h.Descripcion).HasMaxLength(100).IsRequired();
            horario.HasOne<Materia>()
                .WithMany()
                .HasForeignKey(h => h.MateriaId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
