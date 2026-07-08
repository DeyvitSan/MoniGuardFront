// Flujo: seleccionar destino → consultar clima → redactar → guardar local → sincronizar.
// Sincronización automática: al abrir, al recuperar conexión y al volver del background.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/destinos_cacao.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../provider/bitacora_provider.dart';

class BitacoraPage extends StatelessWidget {
  final VoidCallback? onSessionExpired;

  const BitacoraPage({super.key, this.onSessionExpired});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider crea el provider UNA vez y se encarga de
    // llamar dispose() automáticamente cuando este widget sale del árbol.
    // Antes eso lo hacías a mano en dispose().
    return ChangeNotifierProvider<BitacoraProvider>(
      create: (_) => getIt<BitacoraProvider>(),
      child: _BitacoraView(onSessionExpired: onSessionExpired),
    );
  }
}

class _BitacoraView extends StatefulWidget {
  final VoidCallback? onSessionExpired;

  const _BitacoraView({this.onSessionExpired});

  @override
  State<_BitacoraView> createState() => _BitacoraViewState();
}

class _BitacoraViewState extends State<_BitacoraView>
    with WidgetsBindingObserver {
  final _textoCtrl = TextEditingController();
  final _connectivity = ConnectivityService();
  StreamSubscription<bool>? _connSub;
  bool _sessionExpiredHandled = false;
  late BitacoraProvider _ctrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // context.read() (no watch) porque solo necesitamos la referencia,
    // no queremos que initState se re-ejecute en cada notifyListeners().
    _ctrl = context.read<BitacoraProvider>();
    _ctrl.addListener(_onControllerChanged);

    _ctrl.cargarPendientes();
    _ctrl.syncIfPending();

    _connSub = _connectivity.onConnectionChanged.listen((online) {
      if (online) _ctrl.syncIfPending();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ctrl.syncIfPending();
    }
  }

  void _onControllerChanged() {
    if (_ctrl.sesionExpirada && !_sessionExpiredHandled) {
      _sessionExpiredHandled = true;
      widget.onSessionExpired?.call();
    } else if (!_ctrl.sesionExpirada) {
      _sessionExpiredHandled = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connSub?.cancel();
    _ctrl.removeListener(_onControllerChanged);
    _textoCtrl.dispose();
    // Ya NO llamamos _ctrl.dispose() — ChangeNotifierProvider lo hace solo.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Consumer reemplaza AnimatedBuilder: escucha automáticamente y
    // solo repinta este subárbol cuando BitacoraProvider notifica.
    return Consumer<BitacoraProvider>(
      builder: (context, ctrl, _) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Nueva bitácora',
                  style: AppTypography.playfair(size: 24, color: cs.onSurface)),
              const SizedBox(height: 4),
              Text(
                'Selecciona el destino antes de salir para registrar el clima de referencia.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 20),

              if (ctrl.sesionExpirada) _buildAuthErrorBanner(cs, ctrl),

              _buildSelectorDestino(cs, ctrl),
              const SizedBox(height: 16),

              if (ctrl.destino != null) _buildClimaSection(cs, ctrl),

              if (ctrl.climaListo) ...[
                const SizedBox(height: 20),
                _buildFormularioTexto(cs, ctrl),
              ],

              const SizedBox(height: 32),
              _buildPendientesSection(cs, ctrl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuthErrorBanner(ColorScheme cs, BitacoraProvider ctrl) {
    return Card(
      color: cs.errorContainer,
      shape: AppShapes.cardShape,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.lock_person_rounded, color: cs.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ctrl.syncMessage ?? 'Tu sesión expiró. Inicia sesión de nuevo.',
                style: TextStyle(color: cs.onErrorContainer),
              ),
            ),
            if (widget.onSessionExpired != null)
              TextButton(
                onPressed: widget.onSessionExpired,
                child: const Text('Iniciar sesión'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorDestino(ColorScheme cs, BitacoraProvider ctrl) {
    return Card(
      shape: AppShapes.cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<DestinoCacao>(
          initialValue: ctrl.destino,
          decoration: const InputDecoration(
            labelText: 'Destino de evaluación',
            border: InputBorder.none,
          ),
          items: DestinosCacao.lista.map((d) {
            return DropdownMenuItem(
              value: d,
              child: Text('${d.nombre} · ${d.region}'),
            );
          }).toList(),
          onChanged: (d) {
            if (d != null) ctrl.seleccionarDestino(d);
          },
        ),
      ),
    );
  }

  Widget _buildClimaSection(ColorScheme cs, BitacoraProvider ctrl) {
    if (ctrl.climaStatus == ClimaStatus.idle) {
      return FilledButton.icon(
        onPressed: ctrl.consultarClima,
        icon: const Icon(Icons.cloud_download_outlined),
        label: const Text('Consultar clima antes de salir'),
      );
    }

    if (ctrl.climaStatus == ClimaStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ctrl.climaStatus == ClimaStatus.failure) {
      return Card(
        color: cs.errorContainer,
        shape: AppShapes.cardShape,
        child: ListTile(
          leading:
          Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
          title: Text(ctrl.climaError ?? 'Error',
              style: TextStyle(color: cs.onErrorContainer)),
          trailing: IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.consultarClima,
          ),
        ),
      );
    }

    final clima = ctrl.clima!;
    return Card(
      color: cs.secondaryContainer,
      shape: AppShapes.cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ClimaChip(
                icon: Icons.thermostat_rounded,
                label: '${clima.temperatura.toStringAsFixed(1)}°C'),
            _ClimaChip(
                icon: Icons.water_drop_outlined,
                label: '${clima.humedad.toStringAsFixed(0)}%'),
            _ClimaChip(
                icon: Icons.umbrella_outlined,
                label: '${clima.precipitacion.toStringAsFixed(1)}mm'),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioTexto(ColorScheme cs, BitacoraProvider ctrl) {
    final guardando = ctrl.guardadoStatus == GuardadoStatus.guardando;
    final guardado = ctrl.guardadoStatus == GuardadoStatus.guardado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textoCtrl,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Observaciones de campo',
            hintText:
            'Describe el estado de la parcela, frutos, hojas, humedad visible...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: guardando
              ? null
              : () async {
            final ok = await ctrl.guardarBitacora(_textoCtrl.text);
            if (ok && mounted) {
              _textoCtrl.clear();
              ctrl.resetFormulario();
              await ctrl.cargarPendientes();
              await ctrl.syncIfPending();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Bitácora guardada localmente')),
                );
              }
            }
          },
          icon: guardando
              ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.lock_outline_rounded),
          label: Text(
              guardando ? 'Guardando...' : 'Guardar bitácora (cifrada local)'),
        ),
        if (guardado)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Guardada. Se sincronizará cuando haya conexión.'),
          ),
      ],
    );
  }

  Widget _buildPendientesSection(ColorScheme cs, BitacoraProvider ctrl) {
    final pendientes = ctrl.pendientes;
    final syncing = ctrl.syncStatus == SyncStatus.syncing;

    Color msgColor() {
      switch (ctrl.syncStatus) {
        case SyncStatus.unauthorized:
        case SyncStatus.failure:
          return cs.error;
        case SyncStatus.partial:
          return cs.tertiary;
        default:
          return cs.onSurfaceVariant;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pendientes de sincronizar (${pendientes.length})',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: cs.onSurface)),
            TextButton.icon(
              onPressed: (pendientes.isEmpty || syncing)
                  ? null
                  : () => ctrl.sincronizar(),
              icon: syncing
                  ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync_rounded, size: 18),
              label: Text(syncing ? 'Sincronizando...' : 'Sincronizar'),
            ),
          ],
        ),
        if (ctrl.syncMessage != null && !ctrl.sesionExpirada)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(ctrl.syncMessage!,
                style: TextStyle(color: msgColor(), fontSize: 12)),
          ),
        if (pendientes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('No hay bitácoras pendientes.',
                style: TextStyle(color: cs.onSurfaceVariant)),
          )
        else
          ...pendientes.map((b) => Card(
            shape: AppShapes.cardShape,
            child: ListTile(
              leading: const Icon(Icons.lock_clock_outlined),
              title: Text(b.destino),
              subtitle: Text(b.texto,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )),
      ],
    );
  }
}

class _ClimaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ClimaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: cs.onSecondaryContainer),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: cs.onSecondaryContainer, fontWeight: FontWeight.w600)),
      ],
    );
  }
}