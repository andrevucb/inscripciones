using Microsoft.EntityFrameworkCore;

namespace Inscripciones.Shared.Data;

public interface IModuleModelConfiguration
{
    void Configure(ModelBuilder modelBuilder);
}
