class ClimaActualEntity {
  final String ciudad;
  final double temperatura;
  final int humedad;
  final String descripcion;
  final double vientoKmh;
  final int probabilidadLluvia;

  const ClimaActualEntity({
    required this.ciudad,
    required this.temperatura,
    required this.humedad,
    required this.descripcion,
    required this.vientoKmh,
    required this.probabilidadLluvia,
  });

  /// Riesgo fúngico alto: humedad >= 80% y temperatura entre 15-25°C
  /// (condiciones que favorecen mildiú y mancha foliar — ver PLAN.md sección 9).
  bool get riesgoFungicoAlto =>
      humedad >= 80 && temperatura >= 15 && temperatura <= 25;
}
