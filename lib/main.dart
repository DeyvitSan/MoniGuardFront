import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/local_storage_service.dart';
import 'domain/interfaces/i_local_storage_service.dart';
import 'presentation/onboarding/screens/onboarding_screen.dart';
import 'presentation/login/screens/login_screen.dart';
import 'presentation/register/screens/register_screen.dart';
import 'presentation/home/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

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
      home: hasSeenOnboarding ? _loginScreen() : _onboardingScreen(),
    );
  }

  Widget _onboardingScreen() => OnboardingScreen(
    storageService: storageService,
    onCompleted: (ctx) => _pushReplacement(ctx, _loginScreen(), fade: true),
  );

  Widget _loginScreen() => LoginScreen(
    onLoginSuccess: (ctx) => _pushReplacement(ctx, const HomeScreen()),
    onGoToRegister: (ctx) => _pushReplacement(ctx, _registerScreen()),
  );

  Widget _registerScreen() => RegisterScreen(
    onRegisterSuccess: (ctx) => _pushReplacement(ctx, const HomeScreen()),
    onGoToLogin: (ctx) => _pushReplacement(ctx, _loginScreen(), fade: true),
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