enum EtapaCultivo { germinacion, crecimiento, floracion, cosecha }

class CultivoEntity {
  final String id;
  final String parcelaId;
  final String usuarioId;
  final String variedad;
  final DateTime fechaSiembra;
  final int plantasEstimadas;
  final EtapaCultivo etapa;
  final bool activo;

  const CultivoEntity({
    required this.id,
    required this.parcelaId,
    required this.usuarioId,
    required this.variedad,
    required this.fechaSiembra,
    required this.plantasEstimadas,
    this.etapa = EtapaCultivo.germinacion,
    this.activo = true,
  });
}
