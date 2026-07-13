import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/domain/local_storage_service.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/parcela/domain/parcela_repository.dart';
import 'features/parcela/presentation/pages/parcela_setup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  await initDependencies();

  final storageService = getIt<LocalStorageService>();
  final bool hasSeenOnboarding = await storageService.getHasSeenOnboarding();

  runApp(MoniGuardApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MoniGuardApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MoniGuardApp({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoniGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: hasSeenOnboarding ? _loginPage() : _onboardingPage(),
    );
  }

  Widget _onboardingPage() => OnboardingPage(
    onCompleted: (ctx) => _pushReplacement(ctx, _loginPage(), fade: true),
  );

  Widget _loginPage() => LoginPage(
    onLoginSuccess: (ctx) async {
      // Tras login, decide si manda a configurar parcela o directo a Home.
      final tieneParcela = await getIt<ParcelaRepository>().tieneParcela();
      if (!ctx.mounted) return;

      if (tieneParcela) {
        _pushReplacement(ctx, const HomePage());
      } else {
        _pushReplacement(ctx, _parcelaSetupPage());
      }
    },
    onGoToRegister: (ctx) => _pushReplacement(ctx, _registerPage()),
  );

  Widget _parcelaSetupPage() => ParcelaSetupPage(
    onCompleted: (ctx) => _pushReplacement(ctx, const HomePage()),
    onSessionExpired: (ctx) => _pushReplacement(ctx, _loginPage(), fade: true),
  );

  Widget _registerPage() => RegisterPage(
    onRegisterSuccess: (ctx) => _pushReplacement(ctx, _loginPage(), fade: true),
    onGoToLogin: (ctx) => _pushReplacement(ctx, _loginPage(), fade: true),
  );

  void _pushReplacement(BuildContext ctx, Widget page, {bool fade = false}) {
    Navigator.of(ctx).pushReplacement(
      fade
          ? PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 450),
      )
          : PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }
}