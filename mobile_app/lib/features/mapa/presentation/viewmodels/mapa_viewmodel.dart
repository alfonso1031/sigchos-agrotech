import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../diagnostico/domain/entities/diagnostico_entity.dart';
import '../../../diagnostico/domain/usecases/obtener_historial_usecase.dart';
import '../../../fincas/domain/entities/finca_entity.dart';
import '../../../fincas/domain/usecases/obtener_fincas_usecase.dart';

/// Combina fincas + diagnósticos geolocalizados para el mapa de incidencia.
/// No tiene repositorio propio: orquesta casos de uso ya existentes de
/// `fincas` y `diagnostico` (evita duplicar acceso a datos).
class MapaViewModel extends ChangeNotifier {
  final ObtenerFincasUseCase _obtenerFincasUseCase;
  final ObtenerHistorialUseCase _obtenerHistorialUseCase;

  MapaViewModel({
    required ObtenerFincasUseCase obtenerFincasUseCase,
    required ObtenerHistorialUseCase obtenerHistorialUseCase,
  })  : _obtenerFincasUseCase = obtenerFincasUseCase,
        _obtenerHistorialUseCase = obtenerHistorialUseCase;

  List<FincaEntity> fincas = [];
  List<DiagnosticoEntity> diagnosticos = [];
  StreamSubscription? _fincasSub;
  StreamSubscription? _diagSub;

  List<DiagnosticoEntity> get diagnosticosGeolocalizados =>
      diagnosticos.where((d) => d.lat != null && d.lng != null).toList();

  int get conDano =>
      diagnosticosGeolocalizados.where((d) => d.enfermedad != 'hoja_sana').length;

  int get sanas =>
      diagnosticosGeolocalizados.where((d) => d.enfermedad == 'hoja_sana').length;

  void escuchar(String usuarioId) {
    _fincasSub?.cancel();
    _diagSub?.cancel();
    _fincasSub = _obtenerFincasUseCase(usuarioId).listen((lista) {
      fincas = lista;
      notifyListeners();
    });
    _diagSub = _obtenerHistorialUseCase(usuarioId).listen((lista) {
      diagnosticos = lista;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _fincasSub?.cancel();
    _diagSub?.cancel();
    super.dispose();
  }
}
