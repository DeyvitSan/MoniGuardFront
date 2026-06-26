import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../register/register_controller.dart';
import '../../login/widgets/moniguard_wordmark.dart';

class RegisterScreen extends StatefulWidget {
  /// Callback cuando el registro es exitoso → el padre navega al Home.
  final void Function(BuildContext context) onRegisterSuccess;

  /// Callback para volver al Login (botón "¿Ya tienes cuenta?").
  final void Function(BuildContext context) onGoToLogin;

  const RegisterScreen({
    super.key,
    required this.onRegisterSuccess,
    required this.onGoToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _nombreCtrl     = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _confirmCtrl    = TextEditingController();
  final _registerCtrl   = RegisterController(authRepository: AuthRepository());

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _registerCtrl.dispose();
    super.dispose();
  }

  //Submit
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await _registerCtrl.register(
      nombre:   _nombreCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (_registerCtrl.status == RegisterStatus.success) {
      HapticFeedback.mediumImpact();
      widget.onRegisterSuccess(context);
    } else if (_registerCtrl.status == RegisterStatus.failure) {
      HapticFeedback.heavyImpact();
      _showErrorSnackbar(_registerCtrl.errorMessage ?? 'Error desconocido');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  color: Theme.of(context).colorScheme.onError, size: 18),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height - 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //Header
                _RegisterHeader(textTheme: tt, colorScheme: cs),
                const SizedBox(height: 32),

                //Card del formulario
                _RegisterCard(
                  formKey:      _formKey,
                  nombreCtrl:   _nombreCtrl,
                  emailCtrl:    _emailCtrl,
                  passwordCtrl: _passwordCtrl,
                  confirmCtrl:  _confirmCtrl,
                  controller:   _registerCtrl,
                  onSubmit:     _submit,
                  textTheme:    tt,
                  colorScheme:  cs,
                ),
                const SizedBox(height: 20),

                //Ir al Login
                _GoToLoginButton(
                  colorScheme: cs,
                  textTheme:   tt,
                  onTap: () => widget.onGoToLogin(context),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//WIDGETS PRIVADOS
class _RegisterHeader extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const _RegisterHeader({required this.textTheme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primaryContainer,
          ),
          child: Icon(Icons.person_add_rounded,
              size: 36, color: colorScheme.primary),
        ),
        const SizedBox(height: 20),
        const MoniGuardWordmark(fontSize: 32),
        const SizedBox(height: 8),
        Text(
          'Crea tu cuenta de productor',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RegisterCard extends StatelessWidget {
  final GlobalKey<FormState>    formKey;
  final TextEditingController   nombreCtrl;
  final TextEditingController   emailCtrl;
  final TextEditingController   passwordCtrl;
  final TextEditingController   confirmCtrl;
  final RegisterController      controller;
  final VoidCallback            onSubmit;
  final TextTheme               textTheme;
  final ColorScheme             colorScheme;

  const _RegisterCard({
    required this.formKey,
    required this.nombreCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.controller,
    required this.onSubmit,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Crear cuenta',
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Llena los datos para registrarte',
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 28),

                  //Nombre completo
                  TextFormField(
                    controller: nombreCtrl,
                    enabled: !controller.isLoading,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: AppValidators.fullName,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      hintText: 'Juan Pérez',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  //Email
                  TextFormField(
                    controller: emailCtrl,
                    enabled: !controller.isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    validator: AppValidators.email,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'usuario@ejemplo.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  //Contraseña
                  TextFormField(
                    controller: passwordCtrl,
                    enabled: !controller.isLoading,
                    obscureText: !controller.passwordVisible,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    validator: AppValidators.password,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(controller.passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        tooltip: controller.passwordVisible
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  //Confirmar contraseña
                  TextFormField(
                    controller: confirmCtrl,
                    enabled: !controller.isLoading,
                    obscureText: !controller.confirmVisible,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    enableSuggestions: false,
                    //Validación cruzada — compara con el campo password
                    validator: (v) =>
                        AppValidators.confirmPassword(v, passwordCtrl.text),
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_person_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(controller.confirmVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        tooltip: controller.confirmVisible
                            ? 'Ocultar'
                            : 'Mostrar',
                        onPressed: controller.toggleConfirmVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  //botón registrar
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isLoading ? null : onSubmit,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: controller.isLoading
                            ? SizedBox(
                          key: const ValueKey('loader'),
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.onPrimary,
                          ),
                        )
                            : Text(
                          key: const ValueKey('label'),
                          'Crear cuenta',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
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

class _GoToLoginButton extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme   textTheme;
  final VoidCallback onTap;

  const _GoToLoginButton({
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
          '¿Ya tienes cuenta?',
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
            'Inicia sesión',
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