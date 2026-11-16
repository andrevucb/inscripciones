using Inscripciones.Modules.Catalogo.Domain;
using Inscripciones.Modules.Inscripciones.Domain;
using Inscripciones.Shared.Data;
using Inscripciones.Shared.Identity;
using Microsoft.EntityFrameworkCore;

namespace Inscripciones.Modules.Inscripciones.Data;

public sealed class InscripcionesModelConfiguration : IModuleModelConfiguration
{
    public void Configure(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Inscripcion>(inscripcion =>
        {
            inscripcion.ToTable("Inscripciones");
            inscripcion.HasKey(i => i.Id);
            inscripcion.Property(i => i.Estado).HasConversion<string>().HasMaxLength(20).IsRequired();
            inscripcion
                .HasOne<ApplicationUser>()
                .WithMany()
                .HasForeignKey(i => i.EstudianteId)
                .OnDelete(DeleteBehavior.Cascade);
            inscripcion
                .HasOne<Horario>()
                .WithMany()
                .HasForeignKey(i => i.HorarioId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
