import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/interfaces/i_local_storage_service.dart';
import '../../../domain/models/onboarding_page_model.dart';
import '../widgets/onboarding_page_content.dart';
import '../widgets/onboarding_page_indicator.dart';

const List<OnboardingPageModel> _kOnboardingPages = [
  OnboardingPageModel(
    tag: '01 • ENTORNO',
    title: 'Monitoreo\nClimático',
    description:
    'Registra temperatura, humedad y condiciones del entorno de tu plantación en tiempo real. Detecta el clima ideal para el avance de la moniliasis antes de que sea tarde.',
    icon: Icons.thermostat_rounded,
    accentColor: AppColors.forestDeep,
  ),
  OnboardingPageModel(
    tag: '02 • BITÁCORAS',
    title: 'Control\nTécnico Pro',
    description:
    'Documenta cada intervención de campo con bitácoras técnicas estructuradas. Análisis NLP integrado extrae patrones de texto libre para diagnóstico asistido.',
    icon: Icons.analytics_rounded,
    accentColor: AppColors.cacaoMid,
  ),
  OnboardingPageModel(
    tag: '03 • OFFLINE-FIRST',
    title: 'Operatividad\nTotal',
    description:
    'Sin señal no hay problema. MoniGuard opera en modo offline-first: tus datos se sincronizan automáticamente en cuanto recuperas conectividad.',
    icon: Icons.cloud_sync_rounded,
    accentColor: AppColors.emeraldSoft,
  ),
];

//PANTALLA
class OnboardingScreen extends StatefulWidget {
  ///Servicio de storage inyectado — depende de la abstracción, no de la impl.
  final ILocalStorageService storageService;

  ///Callback invocado cuando el onboarding finaliza.
  ///Recibe el [BuildContext] activo para que el llamador pueda navegar.
  ///La navegación real ocurre en el widget padre (AppRouter), no aquí.
  final void Function(BuildContext context) onCompleted;

  const OnboardingScreen({
    super.key,
    required this.storageService,
    required this.onCompleted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == _kOnboardingPages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  //Navegación

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();   //micro-interacción táctil
    setState(() => _currentPage = index);
  }

  void _goToNext() {
    if (_isLastPage) {
      _finishOnboarding();
      return;
    }
    HapticFeedback.selectionClick();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  void _skip() {
    HapticFeedback.lightImpact();
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    await widget.storageService.setHasSeenOnboarding(value: true);
    if (!mounted) return;
    widget.onCompleted(context);
  }

  //Build

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            //Barra superior: logo + skip
            _TopBar(
              onSkip: _isLastPage ? null : _skip,
              textStyle: tt.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),

            //Contenido paginado
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _kOnboardingPages.length,
                itemBuilder: (_, index) => OnboardingPageContent(
                  model: _kOnboardingPages[index],
                ),
              ),
            ),

            //Footer: indicadores + botón
            _Footer(
              pageCount: _kOnboardingPages.length,
              currentIndex: _currentPage,
              isLastPage: _isLastPage,
              activeColor: cs.secondary,
              inactiveColor: cs.outlineVariant,
              onNext: _goToNext,
              primaryColor: cs.primary,
              onPrimaryColor: cs.onPrimary,
              secondaryColor: cs.secondary,
              onSecondaryColor: cs.onSecondary,
              textTheme: tt,
            ),

            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }
}

// Sub-widgets privados del orquestador
class _TopBar extends StatelessWidget {
  final VoidCallback? onSkip;
  final TextStyle? textStyle;

  const _TopBar({required this.onSkip, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          //Logotipo / wordmark
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Moni',
                  style: AppTypography.playfair(
                    size: 22,
                    weight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: 'Guard',
                  style: AppTypography.playfair(
                    size: 22,
                    weight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          //Botón "Omitir" — solo visible cuando no es la última página
          AnimatedOpacity(
            opacity: onSkip != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: const StadiumBorder(),
              ),
              child: Text('Omitir', style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final int pageCount;
  final int currentIndex;
  final bool isLastPage;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onNext;
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color secondaryColor;
  final Color onSecondaryColor;
  final TextTheme textTheme;

  const _Footer({
    required this.pageCount,
    required this.currentIndex,
    required this.isLastPage,
    required this.activeColor,
    required this.inactiveColor,
    required this.onNext,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.secondaryColor,
    required this.onSecondaryColor,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //Indicadores de página
          OnboardingPageIndicator(
            pageCount: pageCount,
            currentIndex: currentIndex,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),

          //Botón de avance — cambia label en la última página
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: isLastPage
                ? _PrimaryActionButton(
              key: const ValueKey('start'),
              label: 'Comenzar',
              icon: Icons.eco_rounded,
              backgroundColor: secondaryColor,
              foregroundColor: onSecondaryColor,
              textTheme: textTheme,
              onPressed: onNext,
            )
                : _PrimaryActionButton(
              key: const ValueKey('next'),
              label: 'Siguiente',
              icon: Icons.arrow_forward_rounded,
              backgroundColor: primaryColor,
              foregroundColor: onPrimaryColor,
              textTheme: textTheme,
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final TextTheme textTheme;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.textTheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const StadiumBorder(),
        elevation: 0,
        textStyle: AppTypography.urbanist(
          size: 15,
          weight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}