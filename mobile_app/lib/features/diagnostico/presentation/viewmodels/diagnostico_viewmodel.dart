import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/enfermedades.dart';
import '../../../../core/errors/failure.dart';
import '../../../../services/notification_service.dart';
import '../../domain/entities/clima_snapshot.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/usecases/clasificar_hoja_usecase.dart';
import '../../domain/usecases/crear_diagnostico_usecase.dart';

enum DiagnosticoEstado { esperandoFoto, analizando, listo }

/// Confianza mínima del top-1 para aceptar un diagnóstico. El modelo es un
/// softmax cerrado de 5 clases: cualquier foto (incluso una que no sea hoja) se
/// fuerza a una clase. Si ni la clase ganadora supera este umbral, tratamos la
/// imagen como no válida ("no parece una hoja") en vez de mostrar un resultado
/// engañoso. Ajustable según la matriz de confusión del modelo.
const double _umbralConfianzaMinima = 0.60;

/// Margen mínimo entre top-1 y top-2. Si el modelo duda entre dos clases (fotos
/// fuera de dominio suelen repartir la probabilidad), también se rechaza.
const double _margenMinimoTop1Top2 = 0.15;

/// ViewModel del flujo Captura -> Analizando -> Resultado (pantallas centrales
/// del prototipo). Orquesta cámara, TFLite y persistencia en Firestore.
/// La ubicación (lat/lng) la captura la vista con permiso previo y la pasa a
/// [analizarYGuardar]; el ViewModel no pide permisos por su cuenta.
class DiagnosticoViewModel extends ChangeNotifier {
  final ClasificarHojaUseCase _clasificarHojaUseCase;
  final CrearDiagnosticoUseCase _crearDiagnosticoUseCase;
  final ImagePicker _picker;
  final NotificationService? _notificationService;

  DiagnosticoViewModel({
    required ClasificarHojaUseCase clasificarHojaUseCase,
    required CrearDiagnosticoUseCase crearDiagnosticoUseCase,
    ImagePicker? picker,
    NotificationService? notificationService,
  })  : _clasificarHojaUseCase = clasificarHojaUseCase,
        _crearDiagnosticoUseCase = crearDiagnosticoUseCase,
        _picker = picker ?? ImagePicker(),
        _notificationService = notificationService;

  DiagnosticoEstado estado = DiagnosticoEstado.esperandoFoto;
  File? imagen;
  DiagnosticoEntity? resultado;
  String? errorMessage;

  Future<bool> capturarDesdeGaleria() async {
    try {
      final archivo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (archivo == null) return false;
      imagen = File(archivo.path);
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'No se pudo acceder a la galería.';
      notifyListeners();
      return false;
    }
  }

  /// Usado por CapturaView tras tomar la foto con la cámara en vivo
  /// (CameraController), en vez de abrir la app de cámara del sistema.
  void usarImagenCapturada(File archivo) {
    imagen = archivo;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> analizarYGuardar({
    required String usuarioId,
    required String cultivoId,
    ClimaSnapshot? clima,
    double? lat,
    double? lng,
  }) async {
    if (imagen == null) return false;
    estado = DiagnosticoEstado.analizando;
    errorMessage = null;
    notifyListeners();

    try {
      final probabilidades = await _clasificarHojaUseCase(imagen!);
      final ganadora = probabilidades.first;
      final otras = probabilidades.skip(1).take(3).toList();

      // Rechazo de imágenes fuera de dominio (no-hoja / demasiado ambiguas):
      // el softmax cerrado nunca dice "no es hoja", así que lo inferimos por
      // baja confianza o poca separación entre las dos clases más probables.
      final margen = probabilidades.length > 1
          ? ganadora.probabilidad - probabilidades[1].probabilidad
          : ganadora.probabilidad;
      if (ganadora.claseId == 'no_hoja' ||
          ganadora.probabilidad < _umbralConfianzaMinima ||
          margen < _margenMinimoTop1Top2) {
        errorMessage =
            'La imagen no parece una hoja o no se ve con claridad. '
            'Acerca la cámara a una sola hoja, con buena luz y fondo simple.';
        estado = DiagnosticoEstado.esperandoFoto;
        return false;
      }

      final entidad = DiagnosticoEntity(
        id: '',
        usuarioId: usuarioId,
        cultivoId: cultivoId,
        imagenUrl: '',
        enfermedad: ganadora.claseId,
        confianza: ganadora.probabilidad,
        top3: otras,
        fecha: DateTime.now(),
        lat: lat,
        lng: lng,
        clima: clima,
      );

      resultado = await _crearDiagnosticoUseCase(
        diagnostico: entidad,
        imagen: imagen!,
      );
      estado = DiagnosticoEstado.listo;
      if (ganadora.claseId != 'hoja_sana') {
        await _notificationService?.resultadoDiagnostico(
          enfermedad: infoDe(ganadora.claseId).nombre,
          confianzaPorcentaje: (ganadora.probabilidad * 100).round(),
        );
      }
      return true;
    } on Failure catch (f) {
      errorMessage = f.message;
      estado = DiagnosticoEstado.esperandoFoto;
      return false;
    } catch (e) {
      errorMessage = 'No se pudo analizar la hoja. Intenta de nuevo.';
      estado = DiagnosticoEstado.esperandoFoto;
      return false;
    } finally {
      notifyListeners();
    }
  }

  void reiniciar() {
    estado = DiagnosticoEstado.esperandoFoto;
    imagen = null;
    resultado = null;
    errorMessage = null;
    notifyListeners();
  }
}
