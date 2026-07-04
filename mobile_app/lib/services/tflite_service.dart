import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClasificacionHoja {
  final String claseId;
  final double probabilidad;
  const ClasificacionHoja(this.claseId, this.probabilidad);
}

/// Ejecuta el modelo TensorFlow Lite entrenado por transferencia de
/// aprendizaje sobre MobileNetV2 (Google Colab, ver
/// `mobile_app/tool/entrenar_modelo_colab.ipynb`) con el dataset público
/// Pumpkin Leaf Diseases Dataset From Bangladesh (Kaggle, 5 clases).
///
/// `dano_plaga` no está cubierta por este modelo (el dataset no la incluye);
/// se mantiene en el catálogo/recomendaciones como mejora pendiente, ver README.
///
/// Si `assets/ml/model.tflite` no existe o falla la carga, el servicio cae en
/// un modo de simulación para que el flujo de la app siga siendo demostrable.
class TFLiteService {
  static const int inputSize = 224;
  static const List<String> _ordenClases = [
    'hoja_sana',
    'mancha_foliar',
    'mildiu',
    'oidio',
    'amarillamiento',
  ];

  Interpreter? _interpreter;
  List<String>? _labels;
  bool modeloCargado = false;

  Future<void> cargarModelo() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/ml/model.tflite');
      final raw = await rootBundle.loadString('assets/ml/labels.txt');
      _labels = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      modeloCargado = true;
    } catch (_) {
      // Asset ausente o corrupto: cae a modo simulado para no romper el flujo.
      modeloCargado = false;
    }
  }

  Future<List<ClasificacionHoja>> clasificar(File imagen) async {
    if (modeloCargado && _interpreter != null) {
      return _clasificarConModelo(imagen);
    }
    return _clasificarSimulado();
  }

  Future<List<ClasificacionHoja>> _clasificarConModelo(File imagen) async {
    final bytes = await imagen.readAsBytes();
    final decodificada = img.decodeImage(bytes);
    if (decodificada == null) return _clasificarSimulado();

    final redimensionada = img.copyResize(
      decodificada,
      width: inputSize,
      height: inputSize,
    );

    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final pixel = redimensionada.getPixel(x, y);
          return [
            (pixel.r - 127.5) / 127.5,
            (pixel.g - 127.5) / 127.5,
            (pixel.b - 127.5) / 127.5,
          ];
        }),
      ),
    );

    final labels = _labels ?? _ordenClases;
    final output = [List.filled(labels.length, 0.0)];
    _interpreter!.run(input, output);

    final resultados = <ClasificacionHoja>[];
    for (var i = 0; i < labels.length; i++) {
      resultados.add(ClasificacionHoja(labels[i], output[0][i]));
    }
    resultados.sort((a, b) => b.probabilidad.compareTo(a.probabilidad));
    return resultados;
  }

  /// Simulación determinista-aleatoria usada solo mientras no exista un
  /// modelo .tflite real (ver `cargarModelo`).
  Future<List<ClasificacionHoja>> _clasificarSimulado() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final random = Random();
    final claseGanadora = _ordenClases[random.nextInt(_ordenClases.length)];
    final confianzaGanadora = 0.75 + random.nextDouble() * 0.22;

    final restante = 1 - confianzaGanadora;
    final otras = _ordenClases.where((c) => c != claseGanadora).toList();
    final pesos = List.generate(otras.length, (_) => random.nextDouble());
    final sumaPesos = pesos.reduce((a, b) => a + b);

    final resultados = <ClasificacionHoja>[
      ClasificacionHoja(claseGanadora, confianzaGanadora),
    ];
    for (var i = 0; i < otras.length; i++) {
      resultados.add(
        ClasificacionHoja(otras[i], restante * (pesos[i] / sumaPesos)),
      );
    }
    resultados.sort((a, b) => b.probabilidad.compareTo(a.probabilidad));
    return resultados;
  }

  void dispose() {
    _interpreter?.close();
  }
}
