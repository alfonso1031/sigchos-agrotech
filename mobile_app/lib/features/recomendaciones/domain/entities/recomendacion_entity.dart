class RecomendacionEntity {
  final String id;
  final String enfermedad; // claseId
  final int orden;
  final String titulo;
  final String descripcion;

  const RecomendacionEntity({
    required this.id,
    required this.enfermedad,
    required this.orden,
    required this.titulo,
    required this.descripcion,
  });
}
