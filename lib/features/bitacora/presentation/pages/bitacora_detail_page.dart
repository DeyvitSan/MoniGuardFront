// Pantalla de detalle de una bitácora — muestra absolutamente todo lo
// registrado en esa observación: datos de entrada, clima capturado en ese
// momento, y el resultado del análisis de texto por IA (si lo hubo).
// Se usa tanto desde "Última bitácora" en el Dashboard como desde el
// historial de bitácoras en Diagnóstico — mismo widget, mismo detalle.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/dashboard_summary.dart';
import '../../../home/presentation/widgets/clima_indicator_card.dart';
import '../../domain/entities/bitacora.dart';

class BitacoraDetailPage extends StatelessWidget {
  final Bitacora bitacora;

  // Opcional: el diagnóstico ACTUAL de la parcela (clima + riesgo de hoy),
  // para dar contexto junto a esta bitácora puntual. Ojo: esto es el
  // diagnóstico de HOY, no un histórico — MoniGuard no guarda un
  // "veredicto de riesgo" congelado por cada bitácora, solo el clima que
  // se capturó en ese momento (eso sí se muestra abajo como snapshot).
  final DashboardSummary? contextoActual;

  const BitacoraDetailPage({
    super.key,
    required this.bitacora,
    this.contextoActual,
  });

  String _fechaLarga(DateTime d) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    final hora = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.day} de ${meses[d.month - 1]} de ${d.year} · $hora:$min';
  }

  Color _colorEstado(BuildContext context, EstadoMazorca? estado) {
    final cs = Theme.of(context).colorScheme;
    switch (estado) {
      case EstadoMazorca.sinSintomas:
        return AppColors.forestDeep;
      case EstadoMazorca.manchasLeves:
        return AppColors.warning;
      case EstadoMazorca.manchasExtendidas:
      case EstadoMazorca.pudricionVisible:
        return cs.error;
      case null:
        return cs.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fecha = bitacora.fechaObservacion ?? bitacora.creadaEn;
    final tieneClimaSnapshot = bitacora.temperatura != null ||
        bitacora.humedad != null ||
        bitacora.precipitacion != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de bitácora')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Encabezado: fecha + estado de sincronización ──────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _fechaLarga(fecha),
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (!bitacora.sincronizada)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(AppShapes.radiusSm),
                  ),
                  child: Text('Pendiente de subir',
                      style: tt.labelSmall?.copyWith(color: cs.onTertiaryContainer)),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Estado de la mazorca (dato manual) ────────────────────
          _SectionTitle('Estado de la mazorca'),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _colorEstado(context, bitacora.estadoMazorca).withValues(alpha: 0.15),
                child: Icon(Icons.eco_outlined, color: _colorEstado(context, bitacora.estadoMazorca)),
              ),
              title: Text(bitacora.estadoMazorca?.label ?? 'No registrado'),
            ),
          ),
          const SizedBox(height: 24),

          // ── Notas de campo (texto libre) ──────────────────────────
          _SectionTitle('Notas de campo'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                (bitacora.texto?.trim().isNotEmpty ?? false)
                    ? bitacora.texto!.trim()
                    : 'No se escribió ninguna nota en esta observación.',
                style: tt.bodyMedium?.copyWith(
                  color: (bitacora.texto?.trim().isNotEmpty ?? false)
                      ? cs.onSurface
                      : cs.onSurfaceVariant,
                  fontStyle: (bitacora.texto?.trim().isNotEmpty ?? false)
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Análisis de texto por IA (si hubo) ────────────────────
          _SectionTitle('Análisis de la nota (IA)'),
          const SizedBox(height: 10),
          if (bitacora.analisisTextoEtiqueta != null)
            Card(
              child: ListTile(
                leading: Icon(Icons.psychology_alt_outlined, color: cs.secondary),
                title: Text(_capitalizar(bitacora.analisisTextoEtiqueta!)),
                subtitle: bitacora.analisisTextoConfianza != null
                    ? Text('Confianza: ${(bitacora.analisisTextoConfianza! * 100).toStringAsFixed(0)}%')
                    : null,
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Esta nota no generó un análisis de texto (sin nota escrita, o aún no se sincroniza con el servidor).',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // ── Clima capturado en el momento de la observación ───────
          _SectionTitle('Clima registrado en ese momento'),
          const SizedBox(height: 10),
          if (tieneClimaSnapshot)
            Row(
              children: [
                Expanded(
                  child: ClimaIndicatorCard(
                    icon: Icons.thermostat_rounded,
                    label: 'Temperatura',
                    value: bitacora.temperatura?.toStringAsFixed(1) ?? '—',
                    unit: '°C',
                    accentColor: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClimaIndicatorCard(
                    icon: Icons.water_drop_rounded,
                    label: 'Humedad',
                    value: bitacora.humedad?.toStringAsFixed(0) ?? '—',
                    unit: '%',
                    accentColor: AppColors.forestDeep,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClimaIndicatorCard(
                    icon: Icons.grain_rounded,
                    label: 'Precip.',
                    value: bitacora.precipitacion?.toStringAsFixed(1) ?? '—',
                    unit: 'mm',
                    accentColor: AppColors.info,
                  ),
                ),
              ],
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No se capturó el clima en el momento de esta observación.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
                ),
              ),
            ),

          // ── Contexto actual de la parcela (hoy, no histórico) ─────
          if (contextoActual != null) ...[
            const SizedBox(height: 28),
            _SectionTitle('Diagnóstico de la parcela hoy'),
            const SizedBox(height: 4),
            Text(
              'Este es el riesgo calculado con el clima y las bitácoras de HOY — no el de la fecha de esta nota.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(Icons.warning_amber_rounded,
                    color: _colorRiesgo(context, contextoActual!.riesgo.nivel)),
                title: Text('Riesgo de moniliasis: ${contextoActual!.riesgo.nivel.label}'),
                subtitle: Text('${contextoActual!.riesgo.porcentaje}% — ${contextoActual!.riesgo.descripcion}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _capitalizar(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  Color _colorRiesgo(BuildContext context, NivelRiesgo nivel) {
    final cs = Theme.of(context).colorScheme;
    switch (nivel) {
      case NivelRiesgo.bajo: return AppColors.forestDeep;
      case NivelRiesgo.medio: return AppColors.warning;
      case NivelRiesgo.alto: return cs.error;
      case NivelRiesgo.desconocido: return cs.onSurfaceVariant;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: cs.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}