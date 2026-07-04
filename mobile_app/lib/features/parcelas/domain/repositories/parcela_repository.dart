import '../entities/parcela_entity.dart';

abstract class ParcelaRepository {
  Future<String> crearParcela(ParcelaEntity parcela);
  Future<void> actualizarParcela(ParcelaEntity parcela);
  Stream<List<ParcelaEntity>> obtenerParcelasPorFinca(String fincaId);
  Stream<List<ParcelaEntity>> obtenerParcelasPorUsuario(String usuarioId);
}
