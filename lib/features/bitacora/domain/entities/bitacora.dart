enum EstadoMazorca {
  sinSintomas,
  manchasLeves,
  manchasExtendidas,
  pudricionVisible;

  String get valorBackend => switch (this) {
    EstadoMazorca.sinSintomas => 'sin_sintomas',
    EstadoMazorca.manchasLeves => 'manchas_leves',
    EstadoMazorca.manchasExtendidas => 'manchas_extendidas',
    EstadoMazorca.pudricionVisible => 'pudricion_visible',
  };

  String get label => switch (this) {
    EstadoMazorca.sinSintomas => 'Sin síntomas',
    EstadoMazorca.manchasLeves => 'Manchas leves',
    EstadoMazorca.manchasExtendidas => 'Manchas extendidas',
    EstadoMazorca.pudricionVisible => 'Pudrición visible',
  };

  static EstadoMazorca? fromBackend(String? valor) {
    return switch (valor) {
      'sin_sintomas' => EstadoMazorca.sinSintomas,
      'manchas_leves' => EstadoMazorca.manchasLeves,
      'manchas_extendidas' => EstadoMazorca.manchasExtendidas,
      'pudricion_visible' => EstadoMazorca.pudricionVisible,
      _ => null,
    };
  }
}

class Bitacora {
  final String?         id;
  final String          destino;
  final double           destinoLat;
  final double           destinoLng;
  final String?          texto;
  final double?          temperatura;
  final double?          humedad;
  final double?          precipitacion;
  final DateTime?        fechaObservacion;
  final EstadoMazorca?   estadoMazorca;
  final bool             sincronizada;
  final DateTime         creadaEn;

  const Bitacora({
    this.id,
    required this.destino,
    required this.destinoLat,
    required this.destinoLng,
    this.texto,
    this.temperatura,
    this.humedad,
    this.precipitacion,
    this.fechaObservacion,
    this.estadoMazorca,
    this.sincronizada = false,
    required this.creadaEn,
  });

  Map<String, dynamic> toJson() => {
    'destino':          destino,
    'destinoLat':       destinoLat,
    'destinoLng':       destinoLng,
    'texto':            texto,
    'temperatura':      temperatura,
    'humedad':          humedad,
    'precipitacion':    precipitacion,
    'fechaObservacion': fechaObservacion?.toIso8601String(),
    'estadoMazorca':    estadoMazorca?.valorBackend,
  };

  factory Bitacora.fromJson(Map<String, dynamic> j) => Bitacora(
    id:               j['id'] as String?,
    destino:          j['destino'] as String,
    destinoLat:       (j['destinoLat'] as num).toDouble(),
    destinoLng:       (j['destinoLng'] as num).toDouble(),
    texto:            j['texto'] as String?,
    temperatura:      (j['temperatura'] as num?)?.toDouble(),
    humedad:          (j['humedad'] as num?)?.toDouble(),
    precipitacion:    (j['precipitacion'] as num?)?.toDouble(),
    fechaObservacion: j['fechaObservacion'] != null
        ? DateTime.parse(j['fechaObservacion'] as String)
        : null,
    estadoMazorca:    EstadoMazorca.fromBackend(j['estadoMazorca'] as String?),
    sincronizada:     j['sincronizada'] as bool? ?? true,
    creadaEn:         DateTime.parse(j['creadaEn'] as String? ?? j['creada_en'] as String),
  );

  Map<String, dynamic> toLocalJson() => {
    ...toJson(),
    'creadaEn': creadaEn.toIso8601String(),
  };

  factory Bitacora.fromLocalJson(Map<String, dynamic> j) => Bitacora(
    destino:          j['destino'] as String,
    destinoLat:       (j['destinoLat'] as num).toDouble(),
    destinoLng:       (j['destinoLng'] as num).toDouble(),
    texto:            j['texto'] as String?,
    temperatura:      (j['temperatura'] as num?)?.toDouble(),
    humedad:          (j['humedad'] as num?)?.toDouble(),
    precipitacion:    (j['precipitacion'] as num?)?.toDouble(),
    fechaObservacion: j['fechaObservacion'] != null
        ? DateTime.parse(j['fechaObservacion'] as String)
        : null,
    estadoMazorca:    EstadoMazorca.fromBackend(j['estadoMazorca'] as String?),
    sincronizada:     false,
    creadaEn:         DateTime.parse(j['creadaEn'] as String),
  );
}