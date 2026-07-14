import 'entities/parcela.dart';

abstract interface class ParcelaRepository {
  Future<Parcela> crear({
    required String nombre,
    required String ubicacion,
    required double hectareas,
    String cultivo,
    double? destinoLat,
    double? destinoLng,
  });

  Future<List<Parcela>> listar();
  Future<bool> tieneParcela();
}

class ParcelaException implements Exception {
  final String message;
  final int?   statusCode;
  const ParcelaException({required this.message, this.statusCode});
}