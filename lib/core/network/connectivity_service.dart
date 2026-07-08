// Wrapper de connectivity_plus (v6+, que retorna List<ConnectivityResult>).
// IMPORTANTE: connectivity_plus indica si hay una INTERFAZ de red activa,
// NO si hay internet real. No pasa nada: cada POST está protegido con timeout,
// así que un "conectado" falso solo produce un intento que falla y se re-encola.
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// true si hay al menos una interfaz de red activa.
  Future<bool> get hasConnection async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Emite true cuando se recupera conexión, false cuando se pierde.
  Stream<bool> get onConnectionChanged =>
      _connectivity.onConnectivityChanged.map(
            (results) => results.any((r) => r != ConnectivityResult.none),
      );
}