// features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/validators.dart';
import '../provider/login_provider.dart';
import '../widgets/moniguard_wordmark.dart';

class LoginPage extends StatelessWidget {
  final Future<void> Function(BuildContext context) onLoginSuccess;
  final void Function(BuildContext context) onGoToRegister;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
    required this.onGoToRegister,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginProvider>(
      create: (_) => getIt<LoginProvider>(),
      child: _LoginView(
        onLoginSuccess: onLoginSuccess,
        onGoToRegister: onGoToRegister,
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  final Future<void> Function(BuildContext context) onLoginSuccess;
  final void Function(BuildContext context) onGoToRegister;

  const _LoginView({
    required this.onLoginSuccess,
    required this.onGoToRegister,
  });

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    // Ya NO se llama dispose() del provider — ChangeNotifierProvider lo hace solo.
    super.dispose();
  }

  Future<void> _submit(LoginProvider ctrl) async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ctrl.signIn(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (ctrl.status == LoginStatus.success) {
      HapticFeedback.mediumImpact();
      await widget.onLoginSuccess(context);
    } else if (ctrl.status == LoginStatus.failure) {
      HapticFeedback.heavyImpact();
      _showErrorSnackbar(ctrl.errorMessage ?? 'Error desconocido');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.onInverseSurface,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cs   = Theme.of(context).colorScheme;
    final tt   = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height - 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(textTheme: tt, colorScheme: cs),
                const SizedBox(height: 40),

                Consumer<LoginProvider>(
                  builder: (context, ctrl, _) => _LoginCard(
                    formKey:      _formKey,
                    emailCtrl:    _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    controller:   ctrl,
                    onSubmit:     () => _submit(ctrl),
                    textTheme:    tt,
                    colorScheme:  cs,
                  ),
                ),
                const SizedBox(height: 24),

                _ForgotPassword(colorScheme: cs, textTheme: tt),
                _GoToRegisterButton(
                  colorScheme: cs,
                  textTheme: tt,
                  onTap: () => widget.onGoToRegister(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const _Header({required this.textTheme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.secondaryContainer,
          ),
          child: Icon(
            Icons.eco_rounded,
            size: 36,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 20),
        const MoniGuardWordmark(fontSize: 36),
        const SizedBox(height: 8),
        Text(
          'Gestión inteligente de cacao',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final LoginProvider controller;
  final VoidCallback onSubmit;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _LoginCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.controller,
    required this.onSubmit,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Iniciar sesión',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Accede a tu cuenta de productor',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),

              _EmailField(
                controller: emailCtrl,
                enabled: !controller.isLoading,
              ),
              const SizedBox(height: 16),

              _PasswordField(
                controller: passwordCtrl,
                obscure: !controller.passwordVisible,
                enabled: !controller.isLoading,
                onToggleVisibility: controller.togglePasswordVisibility,
              ),
              const SizedBox(height: 32),

              _SubmitButton(
                isLoading: controller.isLoading,
                onPressed: onSubmit,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _EmailField({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: const [AutofillHints.username, AutofillHints.email],
      validator: AppValidators.email,
      decoration: const InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'usuario@ejemplo.com',
        prefixIcon: Icon(Icons.mail_outline_rounded),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final bool enabled;
  final VoidCallback onToggleVisibility;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.enabled,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: const [AutofillHints.password],
      validator: AppValidators.loginPassword,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          tooltip: obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SubmitButton({
    required this.isLoading,
    required this.onPressed,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
            key: const ValueKey('loader'),
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.onPrimary,
            ),
          )
              : Text(
            key: const ValueKey('label'),
            'Entrar',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPassword extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ForgotPassword({required this.colorScheme, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recuperación de contraseña próximamente'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.secondary,
        shape: const StadiumBorder(),
      ),
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GoToRegisterButton extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme   textTheme;
  final VoidCallback onTap;

  const _GoToRegisterButton({
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta?',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.secondary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: Text(
            'Regístrate',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}