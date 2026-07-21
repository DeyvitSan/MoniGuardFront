// Flujo: la parcela y el clima se cargan automático al abrir (ya no se
// pregunta destino). El usuario solo elige fecha + estado observado +
// texto opcional. Sincronización automática: al abrir, al recuperar
// conexión y al volver del background.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/bitacora.dart';
import '../provider/bitacora_provider.dart';

class BitacoraPage extends StatelessWidget {
  final VoidCallback? onSessionExpired;

  const BitacoraPage({super.key, this.onSessionExpired});

  @override
  Widget build(BuildContext context) {
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

    _ctrl = context.read<BitacoraProvider>();
    _ctrl.addListener(_onControllerChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.cargarParcela();
      _ctrl.cargarPendientes();
      _ctrl.syncIfPending();
    });

    _connSub = _connectivity.onConnectionChanged.listen((online) {
      if (online) {
        _ctrl.syncIfPending();
        _ctrl.consultarClima();
      }
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
    super.dispose();
  }

  Future<void> _elegirFecha(BuildContext context, BitacoraProvider ctrl) async {
    final ahora = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: ctrl.fechaObservacion,
      firstDate: ahora.subtract(const Duration(days: 30)),
      lastDate: ahora,
      locale: const Locale('es'),
    );
    if (elegida != null) ctrl.seleccionarFecha(elegida);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                'Registra lo que observas en tu parcela hoy.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 20),

              if (ctrl.sesionExpirada) _buildAuthErrorBanner(cs, ctrl),

              _buildParcelaSection(cs, ctrl),

              if (ctrl.parcelaCargaStatus == ParcelaCargaStatus.success) ...[
                const SizedBox(height: 16),
                _buildClimaSection(cs, ctrl),
                const SizedBox(height: 20),
                _buildFormulario(cs, ctrl),
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

  Widget _buildParcelaSection(ColorScheme cs, BitacoraProvider ctrl) {
    if (ctrl.parcelaCargaStatus == ParcelaCargaStatus.loading ||
        ctrl.parcelaCargaStatus == ParcelaCargaStatus.idle) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (ctrl.parcelaCargaStatus == ParcelaCargaStatus.failure) {
      return Card(
        color: cs.errorContainer,
        shape: AppShapes.cardShape,
        child: ListTile(
          leading: Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
          title: Text(ctrl.parcelaError ?? 'Error',
              style: TextStyle(color: cs.onErrorContainer)),
          trailing: IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.cargarParcela,
          ),
        ),
      );
    }

    final parcela = ctrl.parcela!;
    return Card(
      shape: AppShapes.cardShape,
      child: ListTile(
        leading: Icon(Icons.landscape_rounded, color: cs.secondary),
        title: Text(parcela.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(parcela.ubicacion),
      ),
    );
  }

  Widget _buildClimaSection(ColorScheme cs, BitacoraProvider ctrl) {
    if (ctrl.climaStatus == ClimaStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ctrl.climaStatus == ClimaStatus.failure) {
      return Card(
        color: cs.errorContainer,
        shape: AppShapes.cardShape,
        child: ListTile(
          leading: Icon(Icons.cloud_off_rounded, color: cs.onErrorContainer),
          title: Text(ctrl.climaError ?? 'Error',
              style: TextStyle(color: cs.onErrorContainer)),
          trailing: IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.consultarClima,
          ),
        ),
      );
    }

    final clima = ctrl.clima;
    if (clima == null) return const SizedBox.shrink();

    // Si el clima consultado ahora mismo trajo error pero teníamos uno
    // previo cacheado, se sigue mostrando marcado como "último conocido".
    final esUltimoConocido = ctrl.climaObtenidoEn != null &&
        DateTime.now().difference(ctrl.climaObtenidoEn!) > const Duration(minutes: 2);

    return Card(
      color: cs.secondaryContainer,
      shape: AppShapes.cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (esUltimoConocido)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded,
                        size: 16, color: cs.onSecondaryContainer),
                    const SizedBox(width: 6),
                    Text(
                      'Último clima conocido (sin conexión ahora)',
                      style: TextStyle(
                          fontSize: 11.5, color: cs.onSecondaryContainer),
                    ),
                  ],
                ),
              ),
            Row(
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
          ],
        ),
      ),
    );
  }

  Widget _buildFormulario(ColorScheme cs, BitacoraProvider ctrl) {
    final guardando = ctrl.guardadoStatus == GuardadoStatus.guardando;
    final guardado = ctrl.guardadoStatus == GuardadoStatus.guardado;
    final puedeGuardar = ctrl.estadoSeleccionado != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('¿Qué observaste hoy?',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: cs.onSurface, fontSize: 15)),
        const SizedBox(height: 10),

        // Selector de fecha
        Card(
          shape: AppShapes.cardShape,
          child: ListTile(
            leading: Icon(Icons.calendar_today_rounded, color: cs.secondary),
            title: const Text('Fecha de observación'),
            subtitle: Text(
              DateFormat('EEEE d MMMM yyyy', 'es').format(ctrl.fechaObservacion),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _elegirFecha(context, ctrl),
          ),
        ),
        const SizedBox(height: 14),

        // Chips de estado
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EstadoMazorca.values.map((estado) {
            final seleccionado = ctrl.estadoSeleccionado == estado;
            return ChoiceChip(
              label: Text(estado.label),
              selected: seleccionado,
              onSelected: (_) => ctrl.seleccionarEstado(estado),
              selectedColor: _colorEstado(estado, cs),
              labelStyle: TextStyle(
                color: seleccionado ? cs.onPrimary : cs.onSurface,
                fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _textoCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Notas adicionales (opcional)',
            hintText: 'Detalles extra que quieras registrar...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        FilledButton.icon(
          onPressed: (guardando || !puedeGuardar)
              ? null
              : () async {
            final ok = await ctrl.guardarBitacora(texto: _textoCtrl.text);
            if (ok && mounted) {
              _textoCtrl.clear();
              ctrl.resetFormulario();
              await ctrl.cargarPendientes();
              await ctrl.syncIfPending();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bitácora guardada localmente')),
                );
              }
            }
          },
          icon: guardando
              ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.lock_outline_rounded),
          label: Text(guardando ? 'Guardando...' : 'Guardar bitácora (cifrada local)'),
        ),
        if (!puedeGuardar)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Selecciona un estado para poder guardar.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ),
        if (guardado)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Guardada. Se sincronizará cuando haya conexión.'),
          ),
      ],
    );
  }

  Color _colorEstado(EstadoMazorca estado, ColorScheme cs) {
    switch (estado) {
      case EstadoMazorca.sinSintomas:
        return AppColors.forestDeep;
      case EstadoMazorca.manchasLeves:
        return AppColors.warning;
      case EstadoMazorca.manchasExtendidas:
        return const Color(0xFFE65100);
      case EstadoMazorca.pudricionVisible:
        return cs.error;
    }
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
                  width: 14, height: 14,
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
              subtitle: Text(
                b.estadoMazorca?.label ?? (b.texto ?? 'Sin detalle'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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