import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/login_controller.dart';
import '../widgets/moniguard_wordmark.dart';

class LoginScreen extends StatefulWidget {
  final void Function(BuildContext context) onLoginSuccess;
  final void Function(BuildContext context) onGoToRegister;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onGoToRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Estado local mínimo: form key + controllers de texto
  final _formKey        = GlobalKey<FormState>();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _loginCtrl      = LoginController(authRepository: AuthRepository());   // instancia local — swapeable por Provider/get_it

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _loginCtrl.dispose();
    super.dispose();
  }

  //Submit
  Future<void> _submit() async {
    //Cierra el teclado antes de proceder
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    await _loginCtrl.signIn(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (_loginCtrl.status == LoginStatus.success) {
      HapticFeedback.mediumImpact();
      widget.onLoginSuccess(context);
    } else if (_loginCtrl.status == LoginStatus.failure) {
      HapticFeedback.heavyImpact();
      _showErrorSnackbar(_loginCtrl.errorMessage ?? 'Error desconocido');
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

  //Build
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cs   = Theme.of(context).colorScheme;
    final tt   = Theme.of(context).textTheme;

    return Scaffold(
      //SafeArea para notch / barra de sistema
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height - 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //Header: Wordmark + subtítulo
                _Header(textTheme: tt, colorScheme: cs),
                const SizedBox(height: 40),

                //Card del formulario
                _LoginCard(
                  formKey:      _formKey,
                  emailCtrl:    _emailCtrl,
                  passwordCtrl: _passwordCtrl,
                  controller:   _loginCtrl,
                  onSubmit:     _submit,
                  textTheme:    tt,
                  colorScheme:  cs,
                ),
                const SizedBox(height: 24),

                //Pie: "¿Olvidaste tu contraseña?" + Ir a Registro
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

// WIDGETS PRIVADOS — SRP: cada uno tiene UNA responsabilidad visual
class _Header extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const _Header({required this.textTheme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Ícono de hoja — marca visual sin asset externo
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

///Card contenedora del formulario de login
class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final LoginController controller;
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
    //AnimatedBuilder escucha LoginController sin depender de Provider
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Card(
          //Card hereda automáticamente CardTheme de app_theme.dart
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //Título de sección
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

                  //Campo Email
                  _EmailField(
                    controller: emailCtrl,
                    enabled: !controller.isLoading,
                  ),
                  const SizedBox(height: 16),

                  //Campo Contraseña
                  _PasswordField(
                    controller: passwordCtrl,
                    obscure: !controller.passwordVisible,
                    enabled: !controller.isLoading,
                    onToggleVisibility: controller.togglePasswordVisibility,
                  ),
                  const SizedBox(height: 32),

                  //Botón de submit
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
      },
    );
  }
}

///Campo de correo electrónico con validación de formato
class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _EmailField({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    //Hereda InputDecorationTheme completo de app_theme.dart
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      //Seguridad: no permite autocompletar credenciales de terceros
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

///Campo de contraseña con toggle de visibilidad seguro
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
      //Seguridad: deshabilita sugerencias y corrección en campo de password
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: const [AutofillHints.password],
      //Validación: mínimo 8 caracteres (OWASP)
      validator: AppValidators.password,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        //Toggle de visibilidad — accesible con semanticsLabel
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

///Botón de submit con estado de carga integrado
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
        //Hereda ElevatedButtonTheme de app_theme.dart
        //null desactiva el botón automáticamente durante carga
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

///Enlace de ¿Olvidaste tu contraseña?
class _ForgotPassword extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ForgotPassword({required this.colorScheme, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        //TODO: navegar a RecoverPasswordScreen cuando la implementes
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

//Botón ¿No tienes cuenta? Regístrate navega a RegisterScreen
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