class ClimaPrevio {
  final double temperatura;
  final double humedad;
  final double precipitacion;

  const ClimaPrevio({
    required this.temperatura,
    required this.humedad,
    required this.precipitacion,
  });

  factory ClimaPrevio.fromOpenMeteo(Map<String, dynamic> j) {
    final current = j['current'] as Map<String, dynamic>;
    return ClimaPrevio(
      temperatura:   (current['temperature_2m']        as num).toDouble(),
      humedad:       (current['relative_humidity_2m']  as num).toDouble(),
      precipitacion: (current['precipitation']          as num).toDouble(),
    );
  }
}