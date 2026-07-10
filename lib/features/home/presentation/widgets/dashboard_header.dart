import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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