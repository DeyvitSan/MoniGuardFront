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
  bool _hashVisible = false;

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

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await controller.logout();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _buildLoginPage()),
          (route) => false,
    );
  }

  // ── Header: avatar + nombre + correo ────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          child: Text(
            controller.initials,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          controller.name,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          controller.email,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Encabezado de sección estilo "Ajustes" ──────────────────────────
  Widget _sectionLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _infoTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        bool monospace = false,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: Icon(icon, size: 18, color: theme.colorScheme.onSecondaryContainer),
      ),
      title: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          value,
          style: monospace
              ? theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')
              : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildCuentaSection(BuildContext context) {
    return _sectionCard(children: [
      _infoTile(
        context,
        icon: Icons.badge_outlined,
        label: 'Nombre',
        value: controller.name,
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: 'Editar nombre',
          onPressed: _showEditNameDialog,
        ),
      ),
      const Divider(height: 1, indent: 68),
      _infoTile(
        context,
        icon: Icons.email_outlined,
        label: 'Correo',
        value: controller.email,
      ),
    ]);
  }

  Widget _buildSeguridadSection(BuildContext context) {
    final hash = controller.passwordHash;
    final displayValue = hash == null
        ? 'No disponible'
        : (_hashVisible ? hash : '•' * 24);

    return _sectionCard(children: [
      _infoTile(
        context,
        icon: Icons.lock_outline,
        label: 'Contraseña (hash almacenado)',
        value: displayValue,
        monospace: true,
        trailing: hash == null
            ? null
            : IconButton(
          icon: Icon(_hashVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
          tooltip: _hashVisible ? 'Ocultar' : 'Mostrar',
          onPressed: () => setState(() => _hashVisible = !_hashVisible),
        ),
      ),
      if (hash != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(68, 0, 16, 14),
          child: Text(
            'Este es el hash cifrado, no tu contraseña real — no se puede revertir a texto plano.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
    ]);
  }

  Widget _buildParcelaSection(BuildContext context) {
    final hectareas = controller.parcelaHectareas;
    return _sectionCard(children: [
      _infoTile(
        context,
        icon: Icons.landscape_outlined,
        label: 'Parcela',
        value: controller.parcelaNombre ?? 'Sin parcela registrada',
      ),
      const Divider(height: 1, indent: 68),
      _infoTile(
        context,
        icon: Icons.place_outlined,
        label: 'Ubicación',
        value: controller.parcelaUbicacion ?? 'No registrada',
      ),
      const Divider(height: 1, indent: 68),
      _infoTile(
        context,
        icon: Icons.crop_square_outlined,
        label: 'Tamaño',
        value: hectareas != null
            ? '${hectareas.toStringAsFixed(hectareas == hectareas.roundToDouble() ? 0 : 1)} ha'
            : 'No registrado',
      ),
    ]);
  }

  Widget _buildLoginPage() => LoginPage(
    onLoginSuccess: (ctx) => Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
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
    final theme = Theme.of(context);

    final content = controller.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        _buildHeader(context),
        if (controller.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            controller.errorMessage!,
            style: TextStyle(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: controller.loadProfile,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
            ),
          ),
        ],
        _sectionLabel(context, 'Cuenta'),
        _buildCuentaSection(context),
        _sectionLabel(context, 'Seguridad'),
        _buildSeguridadSection(context),
        _sectionLabel(context, 'Parcela'),
        _buildParcelaSection(context),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.4)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            onPressed: _confirmLogout,
          ),
        ),
      ],
    );

    if (!widget.showAppBar) {
      return SafeArea(child: content);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(child: content),
    );
  }
}