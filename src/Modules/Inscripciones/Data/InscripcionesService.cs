using Inscripciones.Modules.Auditoria.Contracts;
using Inscripciones.Modules.Catalogo.Contracts;
using Inscripciones.Modules.Habilitacion.Contracts;
using Inscripciones.Modules.Inscripciones.Contracts;
using Inscripciones.Modules.Inscripciones.Domain;
using Inscripciones.Shared.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace Inscripciones.Modules.Inscripciones.Data;

public sealed class InscripcionesService(
    AppDbContext db,
    ICatalogoService catalogoService,
    IHabilitacionService habilitacionService,
    IAuditoriaService auditoriaService,
    IOptions<InscripcionesOptions> options) : IInscripcionesService
{
    private const string MotivoMateriaNoHabilitada = "Materia no habilitada para el estudiante";

    private readonly TimeSpan _duracionReserva = TimeSpan.FromMinutes(options.Value.DuracionReservaMinutos);

    public async Task<ReservaResult> Reservar(
        string estudianteId,
        int horarioId,
        string origen,
        CancellationToken cancellationToken = default)
    {
        var horario = await catalogoService.ObtenerHorario(horarioId, cancellationToken);
        if (horario is null)
        {
            return new ReservaResult(ReservaResultado.HorarioNoEncontrado);
        }

        if (!await habilitacionService.EstaHabilitada(estudianteId, horario.MateriaId, cancellationToken))
        {
            await auditoriaService.RegistrarIntentoRechazado(
                estudianteId,
                horario.MateriaId,
                origen,
                MotivoMateriaNoHabilitada,
                cancellationToken);

            return new ReservaResult(ReservaResultado.MateriaNoHabilitada);
        }

        if (await TieneInscripcionActiva(estudianteId, horario.MateriaId, cancellationToken))
        {
            return new ReservaResult(ReservaResultado.InscripcionActiva);
        }

        await using var transaccion = await db.Database.BeginTransactionAsync(cancellationToken);

        var filasAfectadas = await db.Database.ExecuteSqlInterpolatedAsync(
            $"""
             UPDATE "Horarios"
             SET "CuposDisponibles" = "CuposDisponibles" - 1
             WHERE "Id" = {horarioId} AND "CuposDisponibles" > 0
             """,
            cancellationToken);

        if (filasAfectadas == 0)
        {
            await transaccion.RollbackAsync(cancellationToken);

            var alternativas = (await catalogoService.ObtenerHorariosDeMateria(horario.MateriaId, cancellationToken))
                .Where(alternativa => alternativa.HorarioId != horarioId && alternativa.CuposDisponibles > 0)
                .Select(alternativa => new AlternativaHorario(
                    alternativa.HorarioId,
                    alternativa.Descripcion,
                    alternativa.CuposDisponibles))
                .ToList();

            return new ReservaResult(ReservaResultado.CupoAgotado, Alternativas: alternativas);
        }

        var ahora = DateTimeOffset.UtcNow;
        var inscripcion = new Inscripcion
        {
            EstudianteId = estudianteId,
            HorarioId = horarioId,
            Estado = EstadoInscripcion.Reservada,
            CreadaEn = ahora,
            ExpiraEn = ahora.Add(_duracionReserva)
        };

        db.Set<Inscripcion>().Add(inscripcion);
        await db.SaveChangesAsync(cancellationToken);
        await transaccion.CommitAsync(cancellationToken);

        return new ReservaResult(ReservaResultado.Creada, ARespuesta(inscripcion));
    }

    public async Task<OperacionResult> Confirmar(
        string estudianteId,
        int inscripcionId,
        CancellationToken cancellationToken = default)
    {
        var inscripcion = await db.Set<Inscripcion>()
            .AsNoTracking()
            .FirstOrDefaultAsync(inscripcion => inscripcion.Id == inscripcionId, cancellationToken);

        if (inscripcion is null)
        {
            return new OperacionResult(OperacionResultado.NoEncontrada);
        }

        if (!EsDuenio(inscripcion, estudianteId))
        {
            return new OperacionResult(OperacionResultado.Prohibida);
        }

        if (inscripcion.Estado != EstadoInscripcion.Reservada)
        {
            return new OperacionResult(OperacionResultado.EstadoInvalido, ARespuesta(inscripcion));
        }

        if (inscripcion.ExpiraEn is null || inscripcion.ExpiraEn <= DateTimeOffset.UtcNow)
        {
            return new OperacionResult(OperacionResultado.Expirada, ARespuesta(inscripcion));
        }

        var filasAfectadas = await db.Database.ExecuteSqlInterpolatedAsync(
            $"""
             UPDATE "Inscripciones"
             SET "Estado" = 'Confirmada'
             WHERE "Id" = {inscripcionId} AND "Estado" = 'Reservada'
             """,
            cancellationToken);

        if (filasAfectadas == 0)
        {
            return new OperacionResult(OperacionResultado.EstadoInvalido);
        }

        return new OperacionResult(
            OperacionResultado.Ok,
            ARespuesta(inscripcion) with { Estado = EstadoInscripcion.Confirmada.ToString() });
    }

    public async Task<OperacionResult> Cancelar(
        string estudianteId,
        int inscripcionId,
        CancellationToken cancellationToken = default)
    {
        var inscripcion = await db.Set<Inscripcion>()
            .AsNoTracking()
            .FirstOrDefaultAsync(inscripcion => inscripcion.Id == inscripcionId, cancellationToken);

        if (inscripcion is null)
        {
            return new OperacionResult(OperacionResultado.NoEncontrada);
        }

        if (!EsDuenio(inscripcion, estudianteId))
        {
            return new OperacionResult(OperacionResultado.Prohibida);
        }

        if (inscripcion.Estado is not (EstadoInscripcion.Reservada or EstadoInscripcion.Confirmada))
        {
            return new OperacionResult(OperacionResultado.EstadoInvalido, ARespuesta(inscripcion));
        }

        await using var transaccion = await db.Database.BeginTransactionAsync(cancellationToken);

        var filasAfectadas = await db.Database.ExecuteSqlInterpolatedAsync(
            $"""
             UPDATE "Inscripciones"
             SET "Estado" = 'Cancelada'
             WHERE "Id" = {inscripcionId} AND "Estado" IN ('Reservada', 'Confirmada')
             """,
            cancellationToken);

        if (filasAfectadas == 0)
        {
            await transaccion.RollbackAsync(cancellationToken);
            return new OperacionResult(OperacionResultado.EstadoInvalido);
        }

        await db.Database.ExecuteSqlInterpolatedAsync(
            $"""
             UPDATE "Horarios"
             SET "CuposDisponibles" = "CuposDisponibles" + 1
             WHERE "Id" = {inscripcion.HorarioId}
             """,
            cancellationToken);

        await transaccion.CommitAsync(cancellationToken);

        return new OperacionResult(
            OperacionResultado.Ok,
            ARespuesta(inscripcion) with { Estado = EstadoInscripcion.Cancelada.ToString() });
    }

    private async Task<bool> TieneInscripcionActiva(
        string estudianteId,
        int materiaId,
        CancellationToken cancellationToken)
    {
        var horarios = await catalogoService.ObtenerHorariosDeMateria(materiaId, cancellationToken);
        var horarioIds = horarios.Select(horario => horario.HorarioId).ToList();

        return await db.Set<Inscripcion>().AnyAsync(
            inscripcion =>
                inscripcion.EstudianteId == estudianteId &&
                horarioIds.Contains(inscripcion.HorarioId) &&
                (inscripcion.Estado == EstadoInscripcion.Reservada ||
                 inscripcion.Estado == EstadoInscripcion.Confirmada),
            cancellationToken);
    }

    private static bool EsDuenio(Inscripcion inscripcion, string estudianteId) =>
        string.Equals(inscripcion.EstudianteId, estudianteId, StringComparison.Ordinal);

    private static InscripcionResponse ARespuesta(Inscripcion inscripcion) =>
        new(
            inscripcion.Id,
            inscripcion.HorarioId,
            inscripcion.Estado.ToString(),
            inscripcion.CreadaEn,
            inscripcion.ExpiraEn);
}
