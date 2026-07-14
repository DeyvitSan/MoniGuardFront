// Se muestra tras el login cuando el usuario aún no tiene ninguna parcela
// registrada. Sin esto, el dashboard no tiene a qué ubicación real pedir
// clima ni de qué parcela mostrar datos.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/destinos_cacao.dart';
import '../../../../core/di/injection_container.dart';
import '../provider/parcela_provider.dart';

class ParcelaSetupPage extends StatelessWidget {
  final void Function(BuildContext context) onCompleted;
  final void Function(BuildContext context)? onSessionExpired;


  const ParcelaSetupPage({
    super.key,
    required this.onCompleted,
    this.onSessionExpired,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ParcelaProvider>(
      create: (_) => getIt<ParcelaProvider>(),
      child: _ParcelaSetupView(
        onCompleted: onCompleted,
        onSessionExpired: onSessionExpired,
      ),
    );
  }
}

class _ParcelaSetupView extends StatefulWidget {
  final void Function(BuildContext context) onCompleted;
  final void Function(BuildContext context)? onSessionExpired;

  const _ParcelaSetupView({
    required this.onCompleted,
    this.onSessionExpired,
  });

  @override
  State<_ParcelaSetupView> createState() => _ParcelaSetupViewState();
}

class _ParcelaSetupViewState extends State<_ParcelaSetupView> {
  final _formKey        = GlobalKey<FormState>();
  final _nombreCtrl     = TextEditingController();
  final _hectareasCtrl  = TextEditingController();
  DestinoCacao? _destino;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _hectareasCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(ParcelaProvider ctrl) async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_destino == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la ubicación de tu parcela')),
      );
      return;
    }

    final ok = await ctrl.crearParcela(
      nombre:    _nombreCtrl.text.trim(),
      ubicacion: _destino!.nombre,
      hectareas: double.parse(_hectareasCtrl.text.trim()),
      destinoLat: _destino!.lat,
      destinoLng: _destino!.lng,
    );

    if (!mounted) return;

    if (ok) {
      HapticFeedback.mediumImpact();
      widget.onCompleted(context);
    } else if (ctrl.status == ParcelaSetupStatus.unauthorized) {
      widget.onSessionExpired?.call(context);
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(ctrl.errorMessage ?? 'Error desconocido')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Icon(Icons.agriculture_rounded, size: 56, color: cs.secondary),
              const SizedBox(height: 16),
              Text('Configura tu parcela',
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Necesitamos saber dónde está tu cultivo para darte el clima '
                    'y el riesgo de moniliasis correctos.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              Consumer<ParcelaProvider>(
                builder: (context, ctrl, _) => Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nombreCtrl,
                        enabled: !ctrl.isSaving,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de tu parcela',
                          hintText: 'Ej. El Zapotal',
                          prefixIcon: Icon(Icons.landscape_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().length < 3)
                            ? 'Ponle un nombre a tu parcela'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<DestinoCacao>(
                        initialValue: _destino,
                        decoration: const InputDecoration(
                          labelText: 'Ubicación (municipio)',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        items: DestinosCacao.lista.map((d) {
                          return DropdownMenuItem(
                            value: d,
                            child: Text('${d.nombre} · ${d.region}'),
                          );
                        }).toList(),
                        onChanged: ctrl.isSaving
                            ? null
                            : (d) => setState(() => _destino = d),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _hectareasCtrl,
                        enabled: !ctrl.isSaving,
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Hectáreas',
                          hintText: 'Ej. 2.5',
                          prefixIcon: Icon(Icons.square_foot_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Indica el tamaño aproximado';
                          }
                          final parsed = double.tryParse(v.trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Ingresa un número válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: ctrl.isSaving ? null : () => _submit(ctrl),
                          child: ctrl.isSaving
                              ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5))
                              : const Text('Guardar y continuar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}