class FincaEntity {
  final String id;
  final String usuarioId;
  final String nombre;
  final double lat;
  final double lng;
  final String direccion;
  final double areaHectareas;
  final DateTime fechaCreacion;

  const FincaEntity({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.lat,
    required this.lng,
    required this.direccion,
    required this.areaHectareas,
    required this.fechaCreacion,
  });
}
