// features/onboarding/presentation/widgets/onboarding_page_content.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/onboarding_page_model.dart';

class OnboardingPageContent extends StatelessWidget {
  final OnboardingPageModel model;

  const OnboardingPageContent({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconDisplay(model: model),
          const SizedBox(height: 48),

          _TagChip(tag: model.tag, accent: model.accentColor),
          const SizedBox(height: 16),

          Text(
            model.title,
            style: tt.displaySmall?.copyWith(
              color: cs.onSurface,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            model.description,
            style: tt.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconDisplay extends StatelessWidget {
  final OnboardingPageModel model;
  const _IconDisplay({required this.model});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: model.accentColor.withValues(alpha: 0.06),
            ),
          ),
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: model.accentColor.withValues(alpha: 0.18),
                width: 1.5,
              ),
              color: model.accentColor.withValues(alpha: 0.10),
            ),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  color: model.accentColor.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              model.icon,
              size: 40,
              color: model.accentColor,
            ),
          ),
          Positioned(
            top: 24,
            right: 36,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: model.accentColor.withValues(alpha: 0.55),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 28,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.forestDeep.withValues(alpha: 0.40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  final Color accent;
  const _TagChip({required this.tag, required this.accent});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: accent.withValues(alpha: 0.12),
      ),
      child: Text(
        tag,
        style: tt.labelMedium?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}