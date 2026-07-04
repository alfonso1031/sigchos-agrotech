import 'clima_snapshot.dart';
import 'probabilidad_clase.dart';

class DiagnosticoEntity {
  final String id;
  final String usuarioId;
  final String cultivoId;
  final String imagenUrl;
  final String enfermedad; // claseId ganador
  final double confianza; // 0..1
  final List<ProbabilidadClase> top3;
  final double? lat;
  final double? lng;
  final ClimaSnapshot? clima;
  final DateTime fecha;

  const DiagnosticoEntity({
    required this.id,
    required this.usuarioId,
    required this.cultivoId,
    required this.imagenUrl,
    required this.enfermedad,
    required this.confianza,
    required this.top3,
    required this.fecha,
    this.lat,
    this.lng,
    this.clima,
  });
}
