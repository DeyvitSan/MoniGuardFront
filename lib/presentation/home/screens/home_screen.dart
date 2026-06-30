// Pantalla principal de MoniGuard — Dashboard.
// Presentación pura: delega toda la lógica al HomeController.
// BottomNavigationBar con 3 tabs: Inicio · Bitácoras · Perfil.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../controller/home_controller.dart';
import '../widgets/dashboard_widgets.dart';
import '../../bitacora/screens/bitacora_screen.dart';

class HomeScreen extends StatefulWidget {
  //Token de sesión — en la siguiente iteración vendrá de flutter_secure_storage.
  final String accessToken;

  const HomeScreen({super.key, this.accessToken = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = HomeController(repository: DashboardRepository());
    // Carga inicial al montar la pantalla
    _ctrl.loadSummary(accessToken: widget.accessToken);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Build
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: cs.surface,

          // ── AppBar
          appBar: _buildAppBar(context, cs),

          // ── Cuerpo según tab activo
          body: IndexedStack(
            index: _ctrl.tabIndex,
            children: [
              _DashboardTab(ctrl: _ctrl),
              BitacoraScreen(accessToken: widget.accessToken),
              const _PlaceholderTab(
                icon: Icons.person_outline_rounded,
                label: 'Perfil',
                subtitle: 'Módulo en construcción',
              ),
            ],
          ),

          // ── BottomNavigationBar
          bottomNavigationBar: NavigationBar(
            selectedIndex: _ctrl.tabIndex,
            onDestinationSelected: (i) {
              HapticFeedback.selectionClick();
              _ctrl.setTab(i);
            },
            destinations: const [
              NavigationDestination(
                icon:          Icon(Icons.dashboard_outlined),
                selectedIcon:  Icon(Icons.dashboard_rounded),
                label:         'Inicio',
              ),
              NavigationDestination(
                icon:          Icon(Icons.edit_note_outlined),
                selectedIcon:  Icon(Icons.edit_note_rounded),
                label:         'Bitácoras',
              ),
              NavigationDestination(
                icon:          Icon(Icons.person_outline_rounded),
                selectedIcon:  Icon(Icons.person_rounded),
                label:         'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme cs) {
    return AppBar(
      // Wordmark como título
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Moni',
              style: AppTypography.playfair(
                  size: 20, weight: FontWeight.w700, color: cs.onSurface),
            ),
            TextSpan(
              text: 'Guard',
              style: AppTypography.playfair(
                  size: 20, weight: FontWeight.w700, color: cs.secondary),
            ),
          ],
        ),
      ),
      actions: [
        // Botón de refresh manual
        if (_ctrl.tabIndex == 0)
          IconButton(
            icon: _ctrl.isLoading
                ? SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: cs.secondary),
            )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar datos',
            onPressed: _ctrl.isLoading
                ? null
                : () => _ctrl.refresh(accessToken: widget.accessToken),
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// TAB 0 — Dashboard principal

class _DashboardTab extends StatelessWidget {
  final HomeController ctrl;
  const _DashboardTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      color: cs.secondary,
      onRefresh: () => ctrl.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: switch (ctrl.status) {
        // ── Cargando
          DashboardStatus.idle || DashboardStatus.loading =>
          const DashboardSkeleton(),

        // ── Error ────────────────────────────────────────────────────────
          DashboardStatus.failure => _ErrorView(
            message: ctrl.errorMessage ?? 'Error desconocido',
            onRetry: ctrl.refresh,
          ),

        // ── Datos cargados ───────────────────────────────────────────────
          DashboardStatus.success => _DashboardContent(
            summary: ctrl.summary!,
          ),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contenido del dashboard cuando los datos están disponibles
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardContent extends StatelessWidget {
  final dynamic summary; // DashboardSummary
  const _DashboardContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header parcela ────────────────────────────────────────────────
        DashboardHeader(
          nombreParcela:  summary.parcela.nombre,
          ubicacion:      summary.parcela.ubicacion,
          alertasActivas: summary.alertasActivas,
        ),
        const SizedBox(height: 28),

        // ── Sección clima ─────────────────────────────────────────────────
        _SectionLabel(label: 'CONDICIONES ACTUALES', textTheme: tt, colorScheme: cs),
        const SizedBox(height: 12),

        // 3 tarjetas en fila
        Row(
          children: [
            Expanded(
              child: ClimaIndicatorCard(
                icon:        Icons.thermostat_rounded,
                label:       'Temperatura',
                value:       summary.clima.temperatura.toStringAsFixed(1),
                unit:        '°C',
                accentColor: AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClimaIndicatorCard(
                icon:        Icons.water_drop_rounded,
                label:       'Humedad',
                value:       summary.clima.humedad.toStringAsFixed(0),
                unit:        '%',
                accentColor: AppColors.forestDeep,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClimaIndicatorCard(
                icon:        Icons.grain_rounded,
                label:       'Precip.',
                value:       summary.clima.precipitacion.toStringAsFixed(1),
                unit:        'mm',
                accentColor: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Riesgo Moniliasis ─────────────────────────────────────────────
        _SectionLabel(label: 'DIAGNÓSTICO DE RIESGO', textTheme: tt, colorScheme: cs),
        const SizedBox(height: 12),
        RiesgoMoniliasisCard(riesgo: summary.riesgo),
        const SizedBox(height: 16),

        // ── Última bitácora ───────────────────────────────────────────────
        _SectionLabel(label: 'REGISTRO DE CAMPO', textTheme: tt, colorScheme: cs),
        const SizedBox(height: 12),
        UltimaBitacoraCard(fecha: summary.ultimaBitacora),

        // ── Timestamp de actualización ────────────────────────────────────
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Actualizado: ${_formatTime(summary.clima.actualizadoEn)}',
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets de apoyo
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const _SectionLabel(
      {required this.label,
        required this.textTheme,
        required this.colorScheme});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      letterSpacing: 1.8,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, size: 64,
                color: cs.onSurfaceVariant.withOpacity(0.4)),
            const SizedBox(height: 20),
            Text(message,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab placeholder para Bitácoras y Perfil mientras se implementan
class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   subtitle;
  const _PlaceholderTab(
      {required this.icon, required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: cs.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(label, style: tt.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}