import '../entities/cultivo_entity.dart';

abstract class CultivoRepository {
  Future<String> crearCultivo(CultivoEntity cultivo);
  Stream<List<CultivoEntity>> obtenerCultivosPorParcela(String parcelaId);
  Stream<List<CultivoEntity>> obtenerCultivosPorUsuario(String usuarioId);
}
