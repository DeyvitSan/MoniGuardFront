import 'package:flutter/foundation.dart';

import '../../../core/constants/destinos_cacao.dart';
import '../../../domain/interfaces/i_bitacora_repository.dart';
import '../../../domain/models/bitacora.dart';

enum ClimaStatus { idle, loading, success, failure }
enum GuardadoStatus { idle, guardando, guardado, failure }
enum SyncStatus { idle, syncing, success, failure }

class BitacoraController extends ChangeNotifier {
  final IBitacoraRepository _repo;

  BitacoraController({required IBitacoraRepository repository})
      : _repo = repository;

  //Destino seleccionado
  DestinoCacao? _destino;
  DestinoCacao? get destino => _destino;

  void seleccionarDestino(DestinoCacao d) {
    _destino = d;
    _clima = null;
    _climaStatus = ClimaStatus.idle;
    notifyListeners();
  }

  //Clima previo
  ClimaStatus  _climaStatus = ClimaStatus.idle;
  ClimaPrevio? _clima;
  String?      _climaError;

  ClimaStatus  get climaStatus  => _climaStatus;
  ClimaPrevio? get clima        => _clima;
  String?      get climaError   => _climaError;
  bool         get climaListo   => _climaStatus == ClimaStatus.success;

  Future<void> consultarClima() async {
    if (_destino == null) return;
    _climaStatus = ClimaStatus.loading;
    _climaError  = null;
    notifyListeners();

    try {
      _clima = await _repo.getClimaDestino(lat: _destino!.lat, lng: _destino!.lng);
      _climaStatus = ClimaStatus.success;
    } on BitacoraException catch (e) {
      _climaStatus = ClimaStatus.failure;
      _climaError  = e.message;
    } catch (_) {
      _climaStatus = ClimaStatus.failure;
      _climaError  = 'No se pudo obtener el clima. Intenta de nuevo';
    } finally {
      notifyListeners();
    }
  }

  //Texto de la bitácora
  GuardadoStatus _guardadoStatus = GuardadoStatus.idle;
  GuardadoStatus get guardadoStatus => _guardadoStatus;

  Future<bool> guardarBitacora(String texto) async {
    if (_destino == null || texto.trim().length < 5) return false;

    _guardadoStatus = GuardadoStatus.guardando;
    notifyListeners();

    try {
      final bitacora = Bitacora(
        destino:       _destino!.nombre,
        destinoLat:    _destino!.lat,
        destinoLng:    _destino!.lng,
        texto:         texto.trim(),
        temperatura:   _clima?.temperatura,
        humedad:       _clima?.humedad,
        precipitacion: _clima?.precipitacion,
        creadaEn:      DateTime.now(),
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
    _destino        = null;
    _clima          = null;
    _climaStatus    = ClimaStatus.idle;
    _guardadoStatus = GuardadoStatus.idle;
    notifyListeners();
  }

  //Pendientes + Sincronización
  List<Bitacora> _pendientes = [];
  List<Bitacora> get pendientes => _pendientes;

  SyncStatus _syncStatus = SyncStatus.idle;
  SyncStatus get syncStatus => _syncStatus;
  String?    _syncMessage;
  String?    get syncMessage => _syncMessage;

  Future<void> cargarPendientes() async {
    _pendientes = await _repo.listarPendientes();
    notifyListeners();
  }

  Future<void> sincronizar({required String accessToken}) async {
    if (_pendientes.isEmpty) return;
    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    try {
      final subidas = await _repo.sincronizar(accessToken: accessToken);
      _syncStatus  = SyncStatus.success;
      _syncMessage = subidas > 0
          ? '$subidas bitácora(s) sincronizada(s)'
          : 'Sin conexión. Se guardó para sincronizar después';
      await cargarPendientes();
    } catch (_) {
      _syncStatus  = SyncStatus.failure;
      _syncMessage = 'No se pudo sincronizar. Intenta más tarde';
    } finally {
      notifyListeners();
    }
  }
}