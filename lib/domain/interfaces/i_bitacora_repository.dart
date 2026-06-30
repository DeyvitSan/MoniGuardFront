import '../models/bitacora.dart';

abstract interface class IBitacoraRepository {
  //Consulta clima actual para un destino (requiere internet)
  Future<ClimaPrevio> getClimaDestino({
    required double lat,
    required double lng,
  });

  // Guarda bitácora localmente (cifrada), sin requerir internet
  Future<void> guardarLocal(Bitacora bitacora);

  // Lista las bitácoras pendientes de sincronizar (guardadas local)
  Future<List<Bitacora>> listarPendientes();

  //Sube las bitácoras pendientes al backend (requiere internet + token)
  Future<int> sincronizar({required String accessToken});

  //Lista bitácoras ya sincronizadas (desde el backend)
  Future<List<Bitacora>> listarRemotas({required String accessToken});
}

class BitacoraException implements Exception {
  final String message;
  const BitacoraException(this.message);
}