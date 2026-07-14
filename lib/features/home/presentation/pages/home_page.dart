// features/home/presentation/pages/home_page.dart
// Pantalla principal de MoniGuard — Dashboard.
// Presentación pura: delega toda la lógica a HomeProvider.
// BottomNavigationBar con 3 tabs: Inicio · Bitácoras · Perfil.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../bitacora/presentation/pages/bitacora_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../provider/home_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/clima_indicator_card.dart';
import '../widgets/riesgo_moniliasis_card.dart';
import '../widgets/ultima_bitacora_card.dart';
import '../widgets/dashboard_skeleton.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeProvider>(
      create: (_) => getIt<HomeProvider>()..loadSummary(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<HomeProvider>(
      builder: (context, ctrl, _) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: _buildAppBar(context, cs, ctrl),
          body: IndexedStack(
            index: ctrl.tabIndex,
            children: [
              _DashboardTab(ctrl: ctrl),
              BitacoraPage(
                onSessionExpired: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
              const ProfilePage(showAppBar: false),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: ctrl.tabIndex,
            onDestinationSelected: (i) {
              HapticFeedback.selectionClick();
              ctrl.setTab(i);
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

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ColorScheme cs, HomeProvider ctrl) {
    return AppBar(
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
        if (ctrl.tabIndex == 0)
          IconButton(
            icon: ctrl.isLoading
                ? SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: cs.secondary),
            )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar datos',
            onPressed: ctrl.isLoading ? null : () => ctrl.refresh(),
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// TAB 0 — Dashboard principal
class _DashboardTab extends StatelessWidget {
  final HomeProvider ctrl;
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
          DashboardStatus.idle || DashboardStatus.loading =>
          const DashboardSkeleton(),
          DashboardStatus.failure => _ErrorView(
            message: ctrl.errorMessage ?? 'Error desconocido',
            onRetry: ctrl.refresh,
          ),
          DashboardStatus.success => _DashboardContent(
            summary: ctrl.summary!,
          ),
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final dynamic summary;
  const _DashboardContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardHeader(
          nombreParcela:  summary.parcela.nombre,
          ubicacion:      summary.parcela.ubicacion,
          alertasActivas: summary.alertasActivas,
        ),
        const SizedBox(height: 28),

        _SectionLabel(label: 'CONDICIONES ACTUALES', textTheme: tt, colorScheme: cs),
        const SizedBox(height: 12),

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

        _SectionLabel(label: 'DIAGNÓSTICO DE RIESGO', textTheme: tt, colorScheme: cs),
        const SizedBox(height: 12),
        RiesgoMoniliasisCard(riesgo: summary.riesgo),
        const SizedBox(height: 16),

        _SectionLabel(label: 'REGISTRO DE CAMPO', textTheme: tt, colorScheme: cs),
        const SizedBox(height: 12),
        UltimaBitacoraCard(fecha: summary.ultimaBitacora),

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
                color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
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