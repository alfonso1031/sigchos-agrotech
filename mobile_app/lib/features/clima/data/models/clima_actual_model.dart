import '../../domain/entities/clima_actual_entity.dart';

class ClimaActualModel extends ClimaActualEntity {
  const ClimaActualModel({
    required super.ciudad,
    required super.temperatura,
    required super.humedad,
    required super.descripcion,
    required super.vientoKmh,
    required super.probabilidadLluvia,
  });

  /// Parsea la respuesta de `GET /data/2.5/weather` de OpenWeather.
  factory ClimaActualModel.fromJson(
    Map<String, dynamic> json, {
    int probabilidadLluvia = 0,
  }) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    return ClimaActualModel(
      ciudad: json['name'] as String? ?? '',
      temperatura: (main['temp'] as num).toDouble(),
      humedad: (main['humidity'] as num).toInt(),
      descripcion: _capitalizar(weather['description'] as String? ?? ''),
      vientoKmh: ((wind['speed'] as num?)?.toDouble() ?? 0) * 3.6,
      probabilidadLluvia: probabilidadLluvia,
    );
  }

  static String _capitalizar(String texto) =>
      texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
}
