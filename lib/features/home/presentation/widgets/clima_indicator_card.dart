import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 16,
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  style: tt.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                maxLines: 1,
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
            ),
          ],
        ),
      ),
    );
  }
}