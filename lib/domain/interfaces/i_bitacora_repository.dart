import '../models/bitacora.dart';

/// Resultado detallado de una sincronización, para que la UI pueda distinguir
/// entre "todo bien", "parcial", "falló la red" y "no autorizado" — en vez de
/// tragarse el error y mentir con "sin conexión".
enum SyncOutcome {
  allUploaded, // todas las pendientes subieron
  partial, // algunas subieron, otras se reintentarán
  allFailed, // ninguna subió (red o servidor caído); se conservan en cola
  nothingPending, // no había nada que sincronizar
}

class SyncResult {
  final SyncOutcome outcome;
  final int uploaded;
  final int failed;

  const SyncResult({
    required this.outcome,
    this.uploaded = 0,
    this.failed = 0,
  });
}

abstract interface class IBitacoraRepository {
  /// Consulta clima actual para un destino (requiere internet).
  Future<ClimaPrevio> getClimaDestino({
    required double lat,
    required double lng,
  });

  /// Guarda bitácora localmente (cifrada), sin requerir internet.
  Future<void> guardarLocal(Bitacora bitacora);

  /// Lista las bitácoras pendientes de sincronizar (guardadas local).
  Future<List<Bitacora>> listarPendientes();

  /// Sube las pendientes al backend. El token se lee de SessionService,
  /// ya NO se pasa por parámetro. Lanza [UnauthorizedException] si no hay
  /// token válido o el servidor responde 401/403.
  Future<SyncResult> sincronizar();

  /// Lista bitácoras ya sincronizadas (desde el backend).
  /// Lanza [UnauthorizedException] si el token es inválido/expiró.
  Future<List<Bitacora>> listarRemotas();
}

/// Error genérico de bitácora (mensaje mostrable al usuario).
class BitacoraException implements Exception {
  final String message;
  const BitacoraException(this.message);
}

/// Sesión inválida o expirada. Se maneja distinto a un error de red:
/// la UI debe pedir re-login, no decir "sin conexión".
class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(
      [this.message = 'Tu sesión expiró. Inicia sesión de nuevo.']);
}