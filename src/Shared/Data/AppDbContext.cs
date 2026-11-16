using Inscripciones.Shared.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Inscripciones.Shared.Data;

public sealed class AppDbContext : IdentityDbContext<ApplicationUser>
{
    private readonly IEnumerable<IModuleModelConfiguration> _moduleConfigurations;

    public AppDbContext(
        DbContextOptions<AppDbContext> options,
        IEnumerable<IModuleModelConfiguration> moduleConfigurations)
        : base(options)
    {
        _moduleConfigurations = moduleConfigurations;
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        foreach (var moduleConfiguration in _moduleConfigurations)
        {
            moduleConfiguration.Configure(modelBuilder);
        }
    }
}
