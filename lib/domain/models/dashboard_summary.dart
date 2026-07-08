import 'package:flutter/foundation.dart';
enum NivelRiesgo { bajo, medio, alto, desconocido }

extension NivelRiesgoX on NivelRiesgo {
  static NivelRiesgo fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bajo':  return NivelRiesgo.bajo;
      case 'medio': return NivelRiesgo.medio;
      case 'alto':  return NivelRiesgo.alto;
      default:      return NivelRiesgo.desconocido;
    }
  }

  String get label {
    switch (this) {
      case NivelRiesgo.bajo:        return 'Bajo';
      case NivelRiesgo.medio:       return 'Medio';
      case NivelRiesgo.alto:        return 'Alto';
      case NivelRiesgo.desconocido: return 'Sin datos';
    }
  }
}

// Sub-modelos
@immutable
class ParcelaInfo {
  final String id;
  final String nombre;
  final String ubicacion;

  const ParcelaInfo({
    required this.id,
    required this.nombre,
    required this.ubicacion,
  });

  factory ParcelaInfo.fromJson(Map<String, dynamic> j) => ParcelaInfo(
    id:        j['id']        as String,
    nombre:    j['nombre']    as String,
    ubicacion: j['ubicacion'] as String,
  );
}

@immutable
class ClimaData {
  final double   temperatura;   // °C
  final double   humedad;       // %
  final double   precipitacion; // mm
  final DateTime actualizadoEn;

  const ClimaData({
    required this.temperatura,
    required this.humedad,
    required this.precipitacion,
    required this.actualizadoEn,
  });

  factory ClimaData.fromJson(Map<String, dynamic> j) => ClimaData(
    temperatura:    (j['temperatura']    as num).toDouble(),
    humedad:        (j['humedad']        as num).toDouble(),
    precipitacion:  (j['precipitacion']  as num).toDouble(),
    actualizadoEn:  DateTime.parse(j['actualizadoEn'] as String),
  );
}

@immutable
class RiesgoData {
  final NivelRiesgo nivel;
  final int         porcentaje; // 0-100
  final String      descripcion;

  const RiesgoData({
    required this.nivel,
    required this.porcentaje,
    required this.descripcion,
  });

  factory RiesgoData.fromJson(Map<String, dynamic> j) => RiesgoData(
    nivel:       NivelRiesgoX.fromString(j['nivel'] as String),
    porcentaje:  j['porcentaje'] as int,
    descripcion: j['descripcion'] as String,
  );
}


// Modelo raíz
@immutable
class DashboardSummary {
  final ParcelaInfo parcela;
  final ClimaData   clima;
  final RiesgoData  riesgo;
  final int         alertasActivas;
  final DateTime?   ultimaBitacora;

  const DashboardSummary({
    required this.parcela,
    required this.clima,
    required this.riesgo,
    required this.alertasActivas,
    this.ultimaBitacora,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> j) => DashboardSummary(
    parcela:        ParcelaInfo.fromJson(j['parcela'] as Map<String, dynamic>),
    clima:          ClimaData.fromJson(j['clima']    as Map<String, dynamic>),
    riesgo:         RiesgoData.fromJson(j['riesgo']  as Map<String, dynamic>),
    alertasActivas: j['alertasActivas'] as int,
    ultimaBitacora: j['ultimaBitacora'] != null
        ? DateTime.parse(j['ultimaBitacora'] as String)
        : null,
  );
}