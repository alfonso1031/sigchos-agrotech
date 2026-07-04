import 'package:flutter/foundation.dart';
import '../../../../core/errors/failure.dart';
import '../../../../services/location_service.dart';
import '../../../diagnostico/domain/entities/clima_snapshot.dart';
import '../../domain/entities/clima_actual_entity.dart';
import '../../domain/entities/pronostico_dia_entity.dart';
import '../../domain/usecases/obtener_clima_actual_usecase.dart';
import '../../domain/usecases/obtener_pronostico_usecase.dart';

class ClimaViewModel extends ChangeNotifier {
  final ObtenerClimaActualUseCase _obtenerClimaActualUseCase;
  final ObtenerPronosticoUseCase _obtenerPronosticoUseCase;
  final LocationService _locationService;

  ClimaViewModel({
    required ObtenerClimaActualUseCase obtenerClimaActualUseCase,
    required ObtenerPronosticoUseCase obtenerPronosticoUseCase,
    LocationService? locationService,
  })  : _obtenerClimaActualUseCase = obtenerClimaActualUseCase,
        _obtenerPronosticoUseCase = obtenerPronosticoUseCase,
        _locationService = locationService ?? LocationService();

  ClimaActualEntity? actual;
  List<PronosticoDiaEntity> pronostico = [];
  bool isLoading = false;
  String? errorMessage;

  /// Usado por el flujo de diagnóstico para geoetiquetar el clima del momento.
  ClimaSnapshot? get snapshot => actual == null
      ? null
      : ClimaSnapshot(
          temperatura: actual!.temperatura,
          humedad: actual!.humedad,
          descripcion: actual!.descripcion,
        );

  Future<void> cargar() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final pos = await _locationService.obtenerPosicionActual();
      final resultados = await Future.wait([
        _obtenerClimaActualUseCase(lat: pos.latitude, lng: pos.longitude),
        _obtenerPronosticoUseCase(lat: pos.latitude, lng: pos.longitude),
      ]);
      actual = resultados[0] as ClimaActualEntity;
      pronostico = resultados[1] as List<PronosticoDiaEntity>;
    } on Failure catch (f) {
      errorMessage = f.message;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
