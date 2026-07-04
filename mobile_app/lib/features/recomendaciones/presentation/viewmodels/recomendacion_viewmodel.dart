import 'package:flutter/foundation.dart';
import '../../domain/entities/recomendacion_entity.dart';
import '../../domain/usecases/obtener_recomendaciones_usecase.dart';

class RecomendacionViewModel extends ChangeNotifier {
  final ObtenerRecomendacionesUseCase _obtenerRecomendacionesUseCase;
  RecomendacionViewModel({
    required ObtenerRecomendacionesUseCase obtenerRecomendacionesUseCase,
  }) : _obtenerRecomendacionesUseCase = obtenerRecomendacionesUseCase;

  List<RecomendacionEntity> recomendaciones = [];
  bool isLoading = false;

  Future<void> cargar(String claseId) async {
    isLoading = true;
    notifyListeners();
    try {
      recomendaciones = await _obtenerRecomendacionesUseCase(claseId);
    } catch (_) {
      recomendaciones = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
