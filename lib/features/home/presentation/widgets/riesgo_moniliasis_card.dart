import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/dashboard_summary.dart';

class RiesgoMoniliasisCard extends StatelessWidget {
  final RiesgoData riesgo;

  const RiesgoMoniliasisCard({super.key, required this.riesgo});

  Color _bgColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (riesgo.nivel) {
      case NivelRiesgo.bajo:  return AppColors.emeraldPale;
      case NivelRiesgo.medio: return const Color(0xFFFFF3E0);
      case NivelRiesgo.alto:  return cs.errorContainer;
      case NivelRiesgo.desconocido: return cs.surfaceContainerHighest;
    }
  }

  Color _accentColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (riesgo.nivel) {
      case NivelRiesgo.bajo:  return AppColors.forestDeep;
      case NivelRiesgo.medio: return AppColors.warning;
      case NivelRiesgo.alto:  return cs.error;
      case NivelRiesgo.desconocido: return cs.onSurfaceVariant;
    }
  }

  IconData get _icon {
    switch (riesgo.nivel) {
      case NivelRiesgo.bajo:  return Icons.check_circle_rounded;
      case NivelRiesgo.medio: return Icons.warning_amber_rounded;
      case NivelRiesgo.alto:  return Icons.dangerous_rounded;
      case NivelRiesgo.desconocido: return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt     = Theme.of(context).textTheme;
    final accent = _accentColor(context);
    final bg     = _bgColor(context);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, color: accent, size: 24),
              const SizedBox(width: 10),
              Text('Riesgo de Moniliasis',
                  style: tt.titleMedium?.copyWith(
                      color: accent, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: accent.withValues(alpha: 0.15),
                ),
                child: Text(
                  riesgo.nivel.label.toUpperCase(),
                  style: tt.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _RiesgoProgressBar(porcentaje: riesgo.porcentaje, color: accent),
          const SizedBox(height: 12),

          Text(riesgo.descripcion,
              style: tt.bodySmall?.copyWith(
                  color: accent.withValues(alpha: 0.85), height: 1.5)),
        ],
      ),
    );
  }
}

class _RiesgoProgressBar extends StatelessWidget {
  final int   porcentaje;
  final Color color;
  const _RiesgoProgressBar({required this.porcentaje, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$porcentaje%',
            style: AppTypography.playfair(
                size: 22, weight: FontWeight.w700, color: color)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:           porcentaje / 100,
            minHeight:       8,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor:      AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}