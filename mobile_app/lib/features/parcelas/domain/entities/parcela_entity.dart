class ParcelaEntity {
  final String id;
  final String fincaId;
  final String usuarioId;
  final String nombre;
  final double areaHectareas;
  final double lat;
  final double lng;
  final DateTime fechaCreacion;

  const ParcelaEntity({
    required this.id,
    required this.fincaId,
    required this.usuarioId,
    required this.nombre,
    required this.areaHectareas,
    required this.lat,
    required this.lng,
    required this.fechaCreacion,
  });
}
