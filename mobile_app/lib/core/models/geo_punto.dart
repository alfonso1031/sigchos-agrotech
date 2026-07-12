/// Coordenada simple (lat/lng) sin depender de paquetes de UI, para usarla
/// tanto en el dominio (entidades) como en los cálculos geográficos.
class GeoPunto {
  final double lat;
  final double lng;
  const GeoPunto(this.lat, this.lng);

  Map<String, double> toJson() => {'lat': lat, 'lng': lng};

  @override
  bool operator ==(Object other) =>
      other is GeoPunto && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);
}
