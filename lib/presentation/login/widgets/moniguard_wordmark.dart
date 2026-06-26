import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MoniGuardWordmark extends StatelessWidget {
  final double fontSize;

  const MoniGuardWordmark({super.key, this.fontSize = 32});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Moni',
            style: AppTypography.playfair(
              size: fontSize,
              weight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          TextSpan(
            text: 'Guard',
            style: AppTypography.playfair(
              size: fontSize,
              weight: FontWeight.w700,
              color: cs.secondary,
            ),
          ),
        ],
      ),
    );
  }
}