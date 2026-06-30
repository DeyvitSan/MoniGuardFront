class DestinoCacao {
  final String nombre;
  final String region; // "Soconusco" o "Norte"
  final double lat;
  final double lng;

  const DestinoCacao({
    required this.nombre,
    required this.region,
    required this.lat,
    required this.lng,
  });
}

abstract final class DestinosCacao {
  static const List<DestinoCacao> lista = [
    DestinoCacao(nombre: 'Tapachula',    region: 'Soconusco', lat: 14.9046, lng: -92.2531),
    DestinoCacao(nombre: 'Cacahoatán',   region: 'Soconusco', lat: 14.9806, lng: -92.1714),
    DestinoCacao(nombre: 'Tuxtla Chico', region: 'Soconusco', lat: 14.9286, lng: -92.1538),
    DestinoCacao(nombre: 'Huixtla',      region: 'Soconusco', lat: 15.1389, lng: -92.4664),
    DestinoCacao(nombre: 'Mapastepec',   region: 'Soconusco', lat: 15.4333, lng: -92.9000),
    DestinoCacao(nombre: 'Escuintla',    region: 'Soconusco', lat: 15.3167, lng: -92.6667),
    DestinoCacao(nombre: 'Pichucalco',   region: 'Norte',     lat: 17.5167, lng: -93.1167),
    DestinoCacao(nombre: 'Ixtacomitán',  region: 'Norte',     lat: 17.5667, lng: -93.2833),
    DestinoCacao(nombre: 'Juárez',       region: 'Norte',     lat: 17.7333, lng: -93.1667),
  ];
}