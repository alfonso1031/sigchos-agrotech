import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_keys.dart';
import '../models/clima_actual_model.dart';
import '../models/pronostico_dia_model.dart';

const _diasSemana = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

/// Cliente REST de OpenWeather (https://openweathermap.org/api).
/// Ver PLAN.md sección 9 para cómo obtener la API key.
class OpenWeatherDataSource {
  static const _base = 'https://api.openweathermap.org/data/2.5';

  Future<ClimaActualModel> obtenerClimaActual(double lat, double lng) async {
    final respActual = await http.get(Uri.parse(
      '$_base/weather?lat=$lat&lon=$lng&appid=${ApiKeys.openWeatherApiKey}&units=metric&lang=es',
    ));
    if (respActual.statusCode != 200) {
      throw Exception('No se pudo obtener el clima (${respActual.statusCode}).');
    }
    final json = jsonDecode(respActual.body) as Map<String, dynamic>;

    var popActual = 0;
    try {
      final lista = await _obtenerListaForecast(lat, lng);
      if (lista.isNotEmpty) {
        popActual = (((lista.first['pop'] as num?) ?? 0) * 100).round();
      }
    } catch (_) {
      // La probabilidad de lluvia es un extra; si falla, se muestra 0.
    }

    return ClimaActualModel.fromJson(json, probabilidadLluvia: popActual);
  }

  Future<List<PronosticoDiaModel>> obtenerPronostico(double lat, double lng) async {
    final lista = await _obtenerListaForecast(lat, lng);

    final porDia = <String, List<Map<String, dynamic>>>{};
    for (final item in lista) {
      final fecha = (item['dt_txt'] as String).split(' ').first;
      porDia.putIfAbsent(fecha, () => []).add(item);
    }

    final dias = porDia.keys.toList()..sort();
    final resultado = <PronosticoDiaModel>[];
    for (var i = 0; i < dias.length && i < 5; i++) {
      final entradas = porDia[dias[i]]!;
      final temps = entradas.map((e) => e['main']['temp'] as num).toList();
      final pops = entradas.map((e) => (e['pop'] as num?) ?? 0).toList();
      final fecha = DateTime.parse(dias[i]);
      resultado.add(PronosticoDiaModel(
        dia: i == 0 ? 'Hoy' : _diasSemana[fecha.weekday % 7],
        tempMax: temps.reduce((a, b) => a > b ? a : b).toDouble(),
        tempMin: temps.reduce((a, b) => a < b ? a : b).toDouble(),
        probabilidadLluvia:
            (pops.reduce((a, b) => a > b ? a : b) * 100).round(),
      ));
    }
    return resultado;
  }

  Future<List<Map<String, dynamic>>> _obtenerListaForecast(
    double lat,
    double lng,
  ) async {
    final resp = await http.get(Uri.parse(
      '$_base/forecast?lat=$lat&lon=$lng&appid=${ApiKeys.openWeatherApiKey}&units=metric&lang=es',
    ));
    if (resp.statusCode != 200) {
      throw Exception('No se pudo obtener el pronóstico (${resp.statusCode}).');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return (json['list'] as List).cast<Map<String, dynamic>>();
  }
}
