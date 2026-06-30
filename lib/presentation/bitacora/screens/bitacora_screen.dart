// Flujo: seleccionar destino → consultar clima → redactar → guardar local → sincronizar.
import 'package:flutter/material.dart';

import '../../../core/constants/destinos_cacao.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/bitacora_repository.dart';
import '../controller/bitacora_controller.dart';

class BitacoraScreen extends StatefulWidget {
  final String accessToken;

  const BitacoraScreen({super.key, this.accessToken = ''});

  @override
  State<BitacoraScreen> createState() => _BitacoraScreenState();
}

class _BitacoraScreenState extends State<BitacoraScreen> {
  late final BitacoraController _ctrl;
  final _textoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = BitacoraController(repository: BitacoraRepository());
    _ctrl.cargarPendientes();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _textoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
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

              _buildSelectorDestino(cs),
              const SizedBox(height: 16),

              if (_ctrl.destino != null) _buildClimaSection(cs),

              if (_ctrl.climaListo) ...[
                const SizedBox(height: 20),
                _buildFormularioTexto(cs),
              ],

              const SizedBox(height: 32),
              _buildPendientesSection(cs),
            ],
          ),
        );
      },
    );
  }

  //Selector de destino
  Widget _buildSelectorDestino(ColorScheme cs) {
    return Card(
      shape: AppShapes.cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<DestinoCacao>(
          initialValue: _ctrl.destino,
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
            if (d != null) _ctrl.seleccionarDestino(d);
          },
        ),
      ),
    );
  }

  //Sección de clima
  Widget _buildClimaSection(ColorScheme cs) {
    if (_ctrl.climaStatus == ClimaStatus.idle) {
      return FilledButton.icon(
        onPressed: _ctrl.consultarClima,
        icon: const Icon(Icons.cloud_download_outlined),
        label: const Text('Consultar clima antes de salir'),
      );
    }

    if (_ctrl.climaStatus == ClimaStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_ctrl.climaStatus == ClimaStatus.failure) {
      return Card(
        color: cs.errorContainer,
        shape: AppShapes.cardShape,
        child: ListTile(
          leading: Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
          title: Text(_ctrl.climaError ?? 'Error', style: TextStyle(color: cs.onErrorContainer)),
          trailing: IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _ctrl.consultarClima,
          ),
        ),
      );
    }

    final clima = _ctrl.clima!;
    return Card(
      color: cs.secondaryContainer,
      shape: AppShapes.cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ClimaChip(icon: Icons.thermostat_rounded, label: '${clima.temperatura.toStringAsFixed(1)}°C'),
            _ClimaChip(icon: Icons.water_drop_outlined, label: '${clima.humedad.toStringAsFixed(0)}%'),
            _ClimaChip(icon: Icons.umbrella_outlined, label: '${clima.precipitacion.toStringAsFixed(1)}mm'),
          ],
        ),
      ),
    );
  }

  //Formulario de texto
  Widget _buildFormularioTexto(ColorScheme cs) {
    final guardando = _ctrl.guardadoStatus == GuardadoStatus.guardando;
    final guardado  = _ctrl.guardadoStatus == GuardadoStatus.guardado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textoCtrl,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Observaciones de campo',
            hintText: 'Describe el estado de la parcela, frutos, hojas, humedad visible...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: guardando
              ? null
              : () async {
            final ok = await _ctrl.guardarBitacora(_textoCtrl.text);
            if (ok && mounted) {
              _textoCtrl.clear();
              _ctrl.resetFormulario();
              await _ctrl.cargarPendientes();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bitácora guardada localmente')),
              );
            }
          },
          icon: guardando
              ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.lock_outline_rounded),
          label: Text(guardando ? 'Guardando...' : 'Guardar bitácora (cifrada local)'),
        ),
        if (guardado)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Guardada. Se sincronizará cuando haya conexión.'),
          ),
      ],
    );
  }

  //Pendientes de sincronizar
  Widget _buildPendientesSection(ColorScheme cs) {
    final pendientes = _ctrl.pendientes;
    final syncing    = _ctrl.syncStatus == SyncStatus.syncing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pendientes de sincronizar (${pendientes.length})',
                style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
            TextButton.icon(
              onPressed: (pendientes.isEmpty || syncing)
                  ? null
                  : () => _ctrl.sincronizar(accessToken: widget.accessToken),
              icon: syncing
                  ? const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync_rounded, size: 18),
              label: Text(syncing ? 'Sincronizando...' : 'Sincronizar'),
            ),
          ],
        ),
        if (_ctrl.syncMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_ctrl.syncMessage!,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
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
              subtitle: Text(b.texto, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )),
      ],
    );
  }
}

class _ClimaChip extends StatelessWidget {
  final IconData icon;
  final String   label;

  const _ClimaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: cs.onSecondaryContainer),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: cs.onSecondaryContainer, fontWeight: FontWeight.w600)),
      ],
    );
  }
}