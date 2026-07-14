import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/register_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../provider/profile_provider.dart';

class ProfilePage extends StatefulWidget {
  final bool showAppBar;

  const ProfilePage({super.key, this.showAppBar = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileProvider controller;

  @override
  void initState() {
    super.initState();
    controller = GetIt.instance<ProfileProvider>();
    controller.addListener(_onChanged);
    controller.loadProfile();
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _showEditNameDialog() async {
    final nameController = TextEditingController(text: controller.name);
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar nombre'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nombre completo'),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Escribe tu nombre';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (saved == true) {
      final updated = await controller.updateName(nameController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated ? 'Nombre actualizado' : (controller.errorMessage ?? 'No se pudo actualizar el nombre'),
          ),
        ),
      );
    }

    nameController.dispose();
  }

  Widget _buildLoginPage() => LoginPage(
        onLoginSuccess: (ctx) => Navigator.of(ctx).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        ),
        onGoToRegister: (ctx) => Navigator.of(ctx).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => _buildRegisterPage()),
          (route) => false,
        ),
      );

  Widget _buildRegisterPage() => RegisterPage(
        onRegisterSuccess: (ctx) => Navigator.of(ctx).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => _buildLoginPage()),
          (route) => false,
        ),
        onGoToLogin: (ctx) => Navigator.of(ctx).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => _buildLoginPage()),
          (route) => false,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 54,
                child: Text(
                  controller.initials,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 20),
              if (controller.isLoading)
                const CircularProgressIndicator()
              else ...[
                Text(
                  controller.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  onPressed: () async {
                    await controller.logout();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => _buildLoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!widget.showAppBar) {
      return SafeArea(child: content);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(onPressed: _showEditNameDialog, icon: const Icon(Icons.edit)),
        ],
      ),
      body: SafeArea(child: content),
    );
  }
}
