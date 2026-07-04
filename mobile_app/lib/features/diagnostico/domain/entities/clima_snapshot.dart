/// Foto del clima en el momento del diagnóstico (se guarda embebida en el
/// documento de `diagnosticos_hojas` para no depender de un join posterior).
class ClimaSnapshot {
  final double temperatura;
  final int humedad;
  final String descripcion;

  const ClimaSnapshot({
    required this.temperatura,
    required this.humedad,
    required this.descripcion,
  });
}
