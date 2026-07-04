import '../entities/finca_entity.dart';

abstract class FincaRepository {
  Future<String> crearFinca(FincaEntity finca);
  Future<void> actualizarFinca(FincaEntity finca);
  Stream<List<FincaEntity>> obtenerFincasPorUsuario(String usuarioId);
}
