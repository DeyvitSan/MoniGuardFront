import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/local_storage_service.dart';
import 'domain/interfaces/i_local_storage_service.dart';
import 'presentation/onboarding/screens/onboarding_screen.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'presentation/home/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  await initDependencies();

  final ILocalStorageService storageService = LocalStorageService();
  final bool hasSeenOnboarding = await storageService.getHasSeenOnboarding();

  runApp(MoniGuardApp(
    storageService: storageService,
    hasSeenOnboarding: hasSeenOnboarding,
  ));
}

class MoniGuardApp extends StatelessWidget {
  final ILocalStorageService storageService;
  final bool hasSeenOnboarding;

  const MoniGuardApp({
    super.key,
    required this.storageService,
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
      home: hasSeenOnboarding ? _loginPage() : _onboardingScreen(),
    );
  }

  Widget _onboardingScreen() => OnboardingScreen(
    storageService: storageService,
    onCompleted: (ctx) => _pushReplacement(ctx, _loginPage(), fade: true),
  );

  Widget _loginPage() => LoginPage(
    onLoginSuccess: (ctx) => _pushReplacement(ctx, const HomeScreen()),
    onGoToRegister: (ctx) => _pushReplacement(ctx, _registerPage()),
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