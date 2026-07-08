import 'package:flutter/foundation.dart';

import '../../../../core/constants/destinos_cacao.dart';
import '../../domain/bitacora_repository.dart';
import '../../domain/entities/bitacora.dart';
import '../../domain/entities/clima_previo.dart';

enum ClimaStatus { idle, loading, success, failure }

enum GuardadoStatus { idle, guardando, guardado, failure }

// 'unauthorized' es un estado propio: NO es lo mismo que 'failure' de red.
enum SyncStatus { idle, syncing, success, partial, failure, unauthorized }

class BitacoraProvider extends ChangeNotifier {
  final BitacoraRepository _repo;

  BitacoraProvider({required BitacoraRepository repository})
      : _repo = repository;

  // ---- Destino seleccionado ----
  DestinoCacao? _destino;
  DestinoCacao? get destino => _destino;

  void seleccionarDestino(DestinoCacao d) {
    _destino = d;
    _clima = null;
    _climaStatus = ClimaStatus.idle;
    notifyListeners();
  }

  // ---- Clima previo ----
  ClimaStatus _climaStatus = ClimaStatus.idle;
  ClimaPrevio? _clima;
  String? _climaError;

  ClimaStatus get climaStatus => _climaStatus;
  ClimaPrevio? get clima => _clima;
  String? get climaError => _climaError;
  bool get climaListo => _climaStatus == ClimaStatus.success;

  Future<void> consultarClima() async {
    if (_destino == null) return;
    _climaStatus = ClimaStatus.loading;
    _climaError = null;
    notifyListeners();

    try {
      _clima =
      await _repo.getClimaDestino(lat: _destino!.lat, lng: _destino!.lng);
      _climaStatus = ClimaStatus.success;
    } on BitacoraException catch (e) {
      _climaStatus = ClimaStatus.failure;
      _climaError = e.message;
    } catch (_) {
      _climaStatus = ClimaStatus.failure;
      _climaError = 'No se pudo obtener el clima. Intenta de nuevo';
    } finally {
      notifyListeners();
    }
  }

  // ---- Texto de la bitácora ----
  GuardadoStatus _guardadoStatus = GuardadoStatus.idle;
  GuardadoStatus get guardadoStatus => _guardadoStatus;

  Future<bool> guardarBitacora(String texto) async {
    if (_destino == null || texto.trim().length < 5) return false;

    _guardadoStatus = GuardadoStatus.guardando;
    notifyListeners();

    try {
      final bitacora = Bitacora(
        destino: _destino!.nombre,
        destinoLat: _destino!.lat,
        destinoLng: _destino!.lng,
        texto: texto.trim(),
        temperatura: _clima?.temperatura,
        humedad: _clima?.humedad,
        precipitacion: _clima?.precipitacion,
        creadaEn: DateTime.now(),
      );
      await _repo.guardarLocal(bitacora);
      _guardadoStatus = GuardadoStatus.guardado;
      notifyListeners();
      return true;
    } catch (_) {
      _guardadoStatus = GuardadoStatus.failure;
      notifyListeners();
      return false;
    }
  }

  void resetFormulario() {
    _destino = null;
    _clima = null;
    _climaStatus = ClimaStatus.idle;
    _guardadoStatus = GuardadoStatus.idle;
    notifyListeners();
  }

  // ---- Pendientes + Sincronización ----
  List<Bitacora> _pendientes = [];
  List<Bitacora> get pendientes => _pendientes;

  SyncStatus _syncStatus = SyncStatus.idle;
  SyncStatus get syncStatus => _syncStatus;
  String? _syncMessage;
  String? get syncMessage => _syncMessage;

  bool get sesionExpirada => _syncStatus == SyncStatus.unauthorized;

  Future<void> cargarPendientes() async {
    _pendientes = await _repo.listarPendientes();
    notifyListeners();
  }

  Future<void> sincronizar() async {
    if (_syncStatus == SyncStatus.syncing) return;
    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    try {
      final result = await _repo.sincronizar();
      switch (result.outcome) {
        case SyncOutcome.allUploaded:
          _syncStatus = SyncStatus.success;
          _syncMessage = '${result.uploaded} bitácora(s) sincronizada(s)';
          break;
        case SyncOutcome.partial:
          _syncStatus = SyncStatus.partial;
          _syncMessage =
          '${result.uploaded} subida(s), ${result.failed} pendiente(s). Se reintentará.';
          break;
        case SyncOutcome.allFailed:
          _syncStatus = SyncStatus.failure;
          _syncMessage =
          'No se pudo conectar con el servidor. Se reintentará al recuperar conexión.';
          break;
        case SyncOutcome.nothingPending:
          _syncStatus = SyncStatus.idle;
          _syncMessage = null;
          break;
      }
    } on UnauthorizedException catch (e) {
      _syncStatus = SyncStatus.unauthorized;
      _syncMessage = e.message;
    } catch (_) {
      _syncStatus = SyncStatus.failure;
      _syncMessage = 'No se pudo sincronizar. Intenta más tarde.';
    } finally {
      await cargarPendientes();
      notifyListeners();
    }
  }

  Future<void> syncIfPending() async {
    await cargarPendientes();
    if (_pendientes.isEmpty) return;
    await sincronizar();
  }
}