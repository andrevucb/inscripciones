using Inscripciones.Api.Seeding;
using Inscripciones.Modules.Auditoria;
using Inscripciones.Modules.Catalogo;
using Inscripciones.Modules.Habilitacion;
using Inscripciones.Modules.Inscripciones;
using Inscripciones.Shared.Data;
using Inscripciones.Shared.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Inscripciones")));

builder.Services.AddAuthorization();
builder.Services
    .AddIdentityApiEndpoints<ApplicationUser>()
    .AddEntityFrameworkStores<AppDbContext>();

builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IEstudianteActual, EstudianteActual>();

builder.Services.AddCatalogoModule();
builder.Services.AddHabilitacionModule();
builder.Services.AddInscripcionesModule();
builder.Services.AddAuditoriaModule();

var app = builder.Build();

await Seeder.SeedAsync(app.Services);

app.MapGet("/salud", () => Results.Ok(new { estado = "ok" })).AllowAnonymous();
app.MapIdentityApi<ApplicationUser>();
app.MapCatalogoEndpoints();
app.MapHabilitacionEndpoints();
app.MapInscripcionesEndpoints();
app.MapAuditoriaEndpoints();

app.Run();

public partial class Program
{
}
