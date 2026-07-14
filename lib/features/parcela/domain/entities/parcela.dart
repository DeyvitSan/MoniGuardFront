class Parcela {
  final String   id;
  final String   nombre;
  final String   ubicacion;
  final double   hectareas;
  final String   cultivo;
  final double?  destinoLat;
  final double?  destinoLng;
  final DateTime createdAt;

  const Parcela({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.hectareas,
    required this.cultivo,
    this.destinoLat,
    this.destinoLng,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'nombre':     nombre,
    'ubicacion':  ubicacion,
    'hectareas':  hectareas,
    'cultivo':    cultivo,
    'destinoLat': destinoLat,
    'destinoLng': destinoLng,
  };

  factory Parcela.fromJson(Map<String, dynamic> j) => Parcela(
    id:         j['id'] as String,
    nombre:     j['nombre'] as String,
    ubicacion:  j['ubicacion'] as String,
    hectareas:  (j['hectareas'] as num).toDouble(),
    cultivo:    j['cultivo'] as String? ?? 'cacao',
    destinoLat: (j['destinoLat'] as num?)?.toDouble(),
    destinoLng: (j['destinoLng'] as num?)?.toDouble(),
    createdAt:  DateTime.parse(j['createdAt'] as String? ?? j['created_at'] as String),
  );
}