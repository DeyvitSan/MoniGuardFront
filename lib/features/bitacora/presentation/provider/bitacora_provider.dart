import 'package:flutter/foundation.dart';

import '../../../parcela/domain/entities/parcela.dart';
import '../../../parcela/domain/parcela_repository.dart';
import '../../domain/bitacora_repository.dart';
import '../../domain/entities/bitacora.dart';
import '../../domain/entities/clima_previo.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


enum ParcelaCargaStatus { idle, loading, success, failure }

enum ClimaStatus { idle, loading, success, failure }

enum GuardadoStatus { idle, guardando, guardado, failure }

enum SyncStatus { idle, syncing, success, partial, failure, unauthorized }

class BitacoraProvider extends ChangeNotifier {
  final BitacoraRepository _repo;
  final ParcelaRepository _parcelaRepo;

  BitacoraProvider({
    required BitacoraRepository repository,
    required ParcelaRepository parcelaRepository,
  })  : _repo = repository,
        _parcelaRepo = parcelaRepository;

  //Parcela del usuario (automática, ya no se pregunta)
  ParcelaCargaStatus _parcelaCargaStatus = ParcelaCargaStatus.idle;
  Parcela? _parcela;
  String? _parcelaError;

  ParcelaCargaStatus get parcelaCargaStatus => _parcelaCargaStatus;
  Parcela? get parcela => _parcela;
  String? get parcelaError => _parcelaError;

  Future<void> cargarParcela() async {
    _parcelaCargaStatus = ParcelaCargaStatus.loading;
    _parcelaError = null;
    notifyListeners();

    try {
      final parcelas = await _parcelaRepo.listar();
      if (parcelas.isEmpty) {
        _parcelaCargaStatus = ParcelaCargaStatus.failure;
        _parcelaError = 'No tienes una parcela registrada.';
      } else {
        _parcela = parcelas.first;
        _parcelaCargaStatus = ParcelaCargaStatus.success;
        // En cuanto se conoce la parcela, se consulta el clima automático.
        await consultarClima();
      }
    } catch (_) {
      _parcelaCargaStatus = ParcelaCargaStatus.failure;
      _parcelaError = 'No se pudo cargar tu parcela.';
    } finally {
      notifyListeners();
    }
  }

  // ---- Clima previo (usa las coordenadas de la parcela, no un dropdown) ----
  ClimaStatus _climaStatus = ClimaStatus.idle;
  ClimaPrevio? _clima;
  String? _climaError;
  DateTime? _climaObtenidoEn;

  ClimaStatus get climaStatus => _climaStatus;
  ClimaPrevio? get clima => _clima;
  String? get climaError => _climaError;
  bool get climaListo => _climaStatus == ClimaStatus.success;
  DateTime? get climaObtenidoEn => _climaObtenidoEn;

  Future<void> consultarClima() async {
    final lat = _parcela?.destinoLat;
    final lng = _parcela?.destinoLng;
    if (lat == null || lng == null) {
      _climaStatus = ClimaStatus.failure;
      _climaError = 'Tu parcela no tiene ubicación registrada.';
      notifyListeners();
      return;
    }

    _climaStatus = ClimaStatus.loading;
    _climaError = null;
    notifyListeners();

    try {
      _clima = await _repo.getClimaDestino(lat: lat, lng: lng);
      _climaObtenidoEn = DateTime.now();
      _climaStatus = ClimaStatus.success;
    } on BitacoraException catch (e) {
      // Sin internet: si ya teníamos un clima previo cacheado, lo dejamos
      // visible marcado como "último conocido" en vez de tapar todo con error.
      if (_clima != null) {
        _climaStatus = ClimaStatus.success;
      } else {
        _climaStatus = ClimaStatus.failure;
        _climaError = e.message;
      }
    } catch (_) {
      if (_clima != null) {
        _climaStatus = ClimaStatus.success;
      } else {
        _climaStatus = ClimaStatus.failure;
        _climaError = 'No se pudo obtener el clima. Intenta de nuevo';
      }
    } finally {
      notifyListeners();
    }
  }

  // ---- Formulario de observación ----
  GuardadoStatus _guardadoStatus = GuardadoStatus.idle;
  GuardadoStatus get guardadoStatus => _guardadoStatus;

  DateTime _fechaObservacion = DateTime.now();
  DateTime get fechaObservacion => _fechaObservacion;
  void seleccionarFecha(DateTime fecha) {
    _fechaObservacion = fecha;
    notifyListeners();
  }

  EstadoMazorca? _estadoSeleccionado;
  EstadoMazorca? get estadoSeleccionado => _estadoSeleccionado;
  void seleccionarEstado(EstadoMazorca estado) {
    _estadoSeleccionado = estado;
    notifyListeners();
  }

  Future<bool> guardarBitacora({String? texto}) async {
    if (_parcela == null || _estadoSeleccionado == null) return false;

    _guardadoStatus = GuardadoStatus.guardando;
    notifyListeners();

    try {
      final bitacora = Bitacora(
        destino: _parcela!.nombre,
        destinoLat: _parcela!.destinoLat!,
        destinoLng: _parcela!.destinoLng!,
        texto: (texto != null && texto.trim().isNotEmpty) ? texto.trim() : null,
        temperatura: _clima?.temperatura,
        humedad: _clima?.humedad,
        precipitacion: _clima?.precipitacion,
        fechaObservacion: _fechaObservacion,
        estadoMazorca: _estadoSeleccionado,
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
    _fechaObservacion = DateTime.now();
    _estadoSeleccionado = null;
    _guardadoStatus = GuardadoStatus.idle;
    notifyListeners();
  }

  // ---- Pendientes + Sincronización (sin cambios de lógica) ----
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

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _dictando = false;
  bool get dictando => _dictando;
  bool _speechDisponible = false;

  Future<bool> inicializarDictado() async {
    _speechDisponible = await _speech.initialize(
      onError: (error) {
        _dictando = false;
        notifyListeners();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _dictando = false;
          notifyListeners();
        }
      },
    );
    return _speechDisponible;
  }

  // [onResultado] recibe el texto reconocido para que la UI lo ponga en el TextField.
  Future<void> iniciarDictado(void Function(String texto) onResultado) async {
    if (!_speechDisponible) {
      final ok = await inicializarDictado();
      if (!ok) return;
    }

    _dictando = true;
    notifyListeners();

    await _speech.listen(
      onResult: (result) {
        onResultado(result.recognizedWords);
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: 'es_MX',
        listenMode: stt.ListenMode.confirmation,
      ),
    );
  }

  void detenerDictado() {
    _speech.stop();
    _dictando = false;
    notifyListeners();
  }
}