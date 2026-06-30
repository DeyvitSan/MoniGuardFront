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

class Bitacora {
  final String?  id;
  final String   destino;
  final double   destinoLat;
  final double   destinoLng;
  final String   texto;
  final double?  temperatura;
  final double?  humedad;
  final double?  precipitacion;
  final bool     sincronizada;
  final DateTime creadaEn;

  const Bitacora({
    this.id,
    required this.destino,
    required this.destinoLat,
    required this.destinoLng,
    required this.texto,
    this.temperatura,
    this.humedad,
    this.precipitacion,
    this.sincronizada = false,
    required this.creadaEn,
  });

  Map<String, dynamic> toJson() => {
    'destino':       destino,
    'destinoLat':    destinoLat,
    'destinoLng':    destinoLng,
    'texto':         texto,
    'temperatura':   temperatura,
    'humedad':       humedad,
    'precipitacion': precipitacion,
  };

  factory Bitacora.fromJson(Map<String, dynamic> j) => Bitacora(
    id:            j['id'] as String?,
    destino:       j['destino'] as String,
    destinoLat:    (j['destinoLat'] as num).toDouble(),
    destinoLng:    (j['destinoLng'] as num).toDouble(),
    texto:         j['texto'] as String,
    temperatura:   (j['temperatura'] as num?)?.toDouble(),
    humedad:       (j['humedad'] as num?)?.toDouble(),
    precipitacion: (j['precipitacion'] as num?)?.toDouble(),
    sincronizada:  j['sincronizada'] as bool? ?? true,
    creadaEn:      DateTime.parse(j['creadaEn'] as String? ?? j['creada_en'] as String),
  );

  //Para guardar local (cifrado) antes de sincronizar
  Map<String, dynamic> toLocalJson() => {
    ...toJson(),
    'creadaEn': creadaEn.toIso8601String(),
  };

  factory Bitacora.fromLocalJson(Map<String, dynamic> j) => Bitacora(
    destino:       j['destino'] as String,
    destinoLat:    (j['destinoLat'] as num).toDouble(),
    destinoLng:    (j['destinoLng'] as num).toDouble(),
    texto:         j['texto'] as String,
    temperatura:   (j['temperatura'] as num?)?.toDouble(),
    humedad:       (j['humedad'] as num?)?.toDouble(),
    precipitacion: (j['precipitacion'] as num?)?.toDouble(),
    sincronizada:  false,
    creadaEn:      DateTime.parse(j['creadaEn'] as String),
  );
}