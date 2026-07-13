import 'entities/parcela.dart';

abstract interface class ParcelaRepository {
  // Crea una parcela nueva para el usuario autenticado.
  Future<Parcela> crear({
    required String nombre,
    required String ubicacion,
    required double hectareas,
    String cultivo,
  });

  // Lista las parcelas del usuario (puede tener más de una a futuro).
  Future<List<Parcela>> listar();

  // Consulta rápida: ¿el usuario ya tiene al menos una parcela?
  // Se usa justo después del login para decidir a dónde navegar.
  Future<bool> tieneParcela();
}

class ParcelaException implements Exception {
  final String message;
  final int?   statusCode;
  const ParcelaException({required this.message, this.statusCode});
}