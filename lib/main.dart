import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/onboarding/domain/local_storage_service.dart';

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

  const MoniGuardApp({super.key, required this.hasSeenOnboarding});

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

  Widget _onboardingScreen() => OnboardingPage(
        onCompleted: (ctx) => _pushReplacement(ctx, _loginScreen(), fade: true),
      );

  Widget _loginScreen() => LoginPage(
        onLoginSuccess: (ctx) async => _pushReplacement(ctx, const HomeScreen(), fade: true),
        onGoToRegister: (ctx) => _pushReplacement(ctx, RegisterPage(
              onRegisterSuccess: (registerCtx) => _pushReplacement(registerCtx, _loginScreen(), fade: true),
              onGoToLogin: (loginCtx) => _pushReplacement(loginCtx, _loginScreen(), fade: true),
            )),
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