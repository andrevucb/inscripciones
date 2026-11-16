using Inscripciones.Modules.Auditoria.Domain;
using Inscripciones.Shared.Data;
using Microsoft.EntityFrameworkCore;

namespace Inscripciones.Modules.Auditoria.Data;

public sealed class AuditoriaModelConfiguration : IModuleModelConfiguration
{
    public void Configure(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<IntentoRechazado>(intento =>
        {
            intento.ToTable("IntentosRechazados");
            intento.HasKey(i => i.Id);
            intento.Property(i => i.EstudianteId).IsRequired();
            intento.Property(i => i.Origen).HasMaxLength(45).IsRequired();
            intento.Property(i => i.Motivo).HasMaxLength(200).IsRequired();
        });
    }
}
