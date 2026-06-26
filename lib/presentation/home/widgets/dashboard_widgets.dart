// lib/presentation/home/widgets/dashboard_widgets.dart
// Widgets atómicos del dashboard — todos Stateless, datos por constructor.
// SRP: cada widget sabe cómo renderizar UN concepto.

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/dashboard_summary.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HEADER DE BIENVENIDA
// ─────────────────────────────────────────────────────────────────────────────
class DashboardHeader extends StatelessWidget {
  final String nombreParcela;
  final String ubicacion;
  final int    alertasActivas;

  const DashboardHeader({
    super.key,
    required this.nombreParcela,
    required this.ubicacion,
    required this.alertasActivas,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buenos días 🌱',
                  style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(nombreParcela,
                  style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(ubicacion,
                      style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
        // Badge de alertas
        if (alertasActivas > 0)
          _AlertBadge(count: alertasActivas, colorScheme: cs, textTheme: tt),
      ],
    );
  }
}

class _AlertBadge extends StatelessWidget {
  final int count;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  const _AlertBadge(
      {required this.count,
        required this.colorScheme,
        required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_active_rounded,
              color: colorScheme.error, size: 22),
          const SizedBox(height: 2),
          Text('$count',
              style: textTheme.labelMedium
                  ?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w800)),
          Text('alertas',
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.error)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD DE INDICADOR CLIMÁTICO (temperatura, humedad, precipitación)
// ─────────────────────────────────────────────────────────────────────────────
class ClimaIndicatorCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final String   unit;
  final Color    accentColor;

  const ClimaIndicatorCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono con fondo de acento
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.12),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            // Valor + unidad en la misma línea
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTypography.playfair(
                      size: 28,
                      weight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: AppTypography.urbanist(
                      size: 13,
                      weight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD DE RIESGO DE MONILIASIS — el componente más importante del dashboard
// ─────────────────────────────────────────────────────────────────────────────
class RiesgoMoniliasisCard extends StatelessWidget {
  final RiesgoData riesgo;

  const RiesgoMoniliasisCard({super.key, required this.riesgo});

  // Colores semáforo según nivel
  Color _bgColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (riesgo.nivel) {
      case NivelRiesgo.bajo:  return AppColors.emeraldPale;
      case NivelRiesgo.medio: return const Color(0xFFFFF3E0); // amber 50
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
        border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Row(
            children: [
              Icon(_icon, color: accent, size: 24),
              const SizedBox(width: 10),
              Text('Riesgo de Moniliasis',
                  style: tt.titleMedium?.copyWith(
                      color: accent, fontWeight: FontWeight.w700)),
              const Spacer(),
              // Chip de nivel
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: accent.withOpacity(0.15),
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

          // Barra de progreso animada
          _RiesgoProgressBar(porcentaje: riesgo.porcentaje, color: accent),
          const SizedBox(height: 12),

          // Descripción
          Text(riesgo.descripcion,
              style: tt.bodySmall?.copyWith(
                  color: accent.withOpacity(0.85), height: 1.5)),
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
        Text('${porcentaje}%',
            style: AppTypography.playfair(
                size: 22, weight: FontWeight.w700, color: color)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:           porcentaje / 100,
            minHeight:       8,
            backgroundColor: color.withOpacity(0.15),
            valueColor:      AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD DE ÚLTIMA BITÁCORA
// ─────────────────────────────────────────────────────────────────────────────
class UltimaBitacoraCard extends StatelessWidget {
  final DateTime? fecha;

  const UltimaBitacoraCard({super.key, this.fecha});

  String get _fechaTexto {
    if (fecha == null) return 'Sin registros';
    final diff = DateTime.now().difference(fecha!);
    if (diff.inMinutes < 60)  return 'Hace ${diff.inMinutes} min';
    if (diff.inHours   < 24)  return 'Hace ${diff.inHours} h';
    if (diff.inDays    == 1)  return 'Ayer';
    return 'Hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.secondaryContainer,
          ),
          child: Icon(Icons.edit_note_rounded, color: cs.secondary, size: 22),
        ),
        title: Text('Última bitácora',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(_fechaTexto,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: cs.onSurfaceVariant),
        onTap: () {/* TODO: navegar a Bitácoras */},
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SKELETON LOADER — placeholder mientras carga el dashboard
// ─────────────────────────────────────────────────────────────────────────────
class DashboardSkeleton extends StatefulWidget {
  const DashboardSkeleton({super.key});

  @override
  State<DashboardSkeleton> createState() => _DashboardSkeletonState();
}

class _DashboardSkeletonState extends State<DashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final color = cs.onSurface.withOpacity(_anim.value * 0.12);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Box(w: 120, h: 14, color: color),
                    const SizedBox(height: 8),
                    _Box(w: 200, h: 22, color: color),
                    const SizedBox(height: 6),
                    _Box(w: 150, h: 12, color: color),
                  ],
                ),
              ),
              _Box(w: 68, h: 68, color: color, radius: 16),
            ]),
            const SizedBox(height: 24),
            // Tarjetas clima
            Row(children: [
              Expanded(child: _Box(h: 110, color: color, radius: 24)),
              const SizedBox(width: 12),
              Expanded(child: _Box(h: 110, color: color, radius: 24)),
              const SizedBox(width: 12),
              Expanded(child: _Box(h: 110, color: color, radius: 24)),
            ]),
            const SizedBox(height: 16),
            // Riesgo card
            _Box(h: 130, color: color, radius: 24),
            const SizedBox(height: 12),
            // Bitácora card
            _Box(h: 72, color: color, radius: 24),
          ],
        );
      },
    );
  }
}

class _Box extends StatelessWidget {
  final double? w;
  final double  h;
  final Color   color;
  final double  radius;
  const _Box({this.w, required this.h, required this.color, this.radius = 8});

  @override
  Widget build(BuildContext context) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}