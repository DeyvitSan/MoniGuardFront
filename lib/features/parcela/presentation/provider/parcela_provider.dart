import 'package:flutter/foundation.dart';
import '../../domain/parcela_repository.dart';

enum ParcelaSetupStatus { idle, guardando, guardado, failure, unauthorized, yaExiste }

class ParcelaProvider extends ChangeNotifier {
  final ParcelaRepository _repo;

  ParcelaProvider({required ParcelaRepository repository})
      : _repo = repository;

  ParcelaSetupStatus _status = ParcelaSetupStatus.idle;
  String? _errorMessage;

  ParcelaSetupStatus get status       => _status;
  String?            get errorMessage => _errorMessage;
  bool               get isSaving     => _status == ParcelaSetupStatus.guardando;

  Future<bool> crearParcela({
    required String nombre,
    required String ubicacion,
    required double hectareas,
    String cultivo = 'cacao',
    double? destinoLat,
    double? destinoLng,
  }) async {
    _status = ParcelaSetupStatus.guardando;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.crear(
        nombre: nombre,
        ubicacion: ubicacion,
        hectareas: hectareas,
        cultivo: cultivo,
        destinoLat: destinoLat,
        destinoLng: destinoLng,
      );
      _status = ParcelaSetupStatus.guardado;
      notifyListeners();
      return true;

    } on ParcelaException catch (e) {
      if (e.statusCode == 409) {
        // Ya tenía una parcela — no es una falla, solo puede continuar.
        _status = ParcelaSetupStatus.yaExiste;
        notifyListeners();
        return true;
      }
      _status = e.statusCode == 401
          ? ParcelaSetupStatus.unauthorized
          : ParcelaSetupStatus.failure;
      _errorMessage = e.message;
      notifyListeners();
      return false;

    } catch (_) {
      _status = ParcelaSetupStatus.failure;
      _errorMessage = 'Ocurrió un error inesperado. Intenta más tarde.';
      notifyListeners();
      return false;
    }
  }
}