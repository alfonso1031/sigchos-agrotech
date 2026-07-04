import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failure.dart';
import '../../../../services/location_service.dart';
import '../../domain/entities/parcela_entity.dart';
import '../../domain/usecases/crear_parcela_usecase.dart';
import '../../domain/usecases/obtener_parcelas_usecase.dart';

class ParcelaViewModel extends ChangeNotifier {
  final CrearParcelaUseCase _crearParcelaUseCase;
  final ActualizarParcelaUseCase _actualizarParcelaUseCase;
  final ObtenerParcelasPorFincaUseCase _obtenerParcelasPorFincaUseCase;
  final ObtenerParcelasPorUsuarioUseCase _obtenerParcelasPorUsuarioUseCase;
  final LocationService _locationService;

  ParcelaViewModel({
    required CrearParcelaUseCase crearParcelaUseCase,
    required ActualizarParcelaUseCase actualizarParcelaUseCase,
    required ObtenerParcelasPorFincaUseCase obtenerParcelasPorFincaUseCase,
    required ObtenerParcelasPorUsuarioUseCase
        obtenerParcelasPorUsuarioUseCase,
    LocationService? locationService,
  })  : _crearParcelaUseCase = crearParcelaUseCase,
        _actualizarParcelaUseCase = actualizarParcelaUseCase,
        _obtenerParcelasPorFincaUseCase = obtenerParcelasPorFincaUseCase,
        _obtenerParcelasPorUsuarioUseCase = obtenerParcelasPorUsuarioUseCase,
        _locationService = locationService ?? LocationService();

  List<ParcelaEntity> parcelas = [];
  bool isLoading = false;
  bool isGuardando = false;
  String? errorMessage;
  double? gpsLat;
  double? gpsLng;
  StreamSubscription<List<ParcelaEntity>>? _subscription;

  /// Última parcela creada — usada para encadenar Parcela -> Cultivo (paso 2/2).
  String? ultimaParcelaId;

  void escucharParcelasDeFinca(String fincaId) {
    isLoading = true;
    notifyListeners();
    _subscription?.cancel();
    _subscription =
        _obtenerParcelasPorFincaUseCase(fincaId).listen((lista) {
      parcelas = lista;
      isLoading = false;
      notifyListeners();
    });
  }

  void escucharParcelasDeUsuario(String usuarioId) {
    _subscription?.cancel();
    _subscription = _obtenerParcelasPorUsuarioUseCase(usuarioId).listen((lista) {
      parcelas = lista;
      notifyListeners();
    });
  }

  Future<void> capturarGps() async {
    try {
      final pos = await _locationService.obtenerPosicionActual();
      gpsLat = pos.latitude;
      gpsLng = pos.longitude;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<bool> crearParcela({
    required String fincaId,
    required String usuarioId,
    required String nombre,
    required double areaHectareas,
  }) async {
    if (gpsLat == null || gpsLng == null) {
      await capturarGps();
      if (gpsLat == null) return false;
    }
    isGuardando = true;
    notifyListeners();
    try {
      final id = await _crearParcelaUseCase(ParcelaEntity(
        id: '',
        fincaId: fincaId,
        usuarioId: usuarioId,
        nombre: nombre,
        areaHectareas: areaHectareas,
        lat: gpsLat!,
        lng: gpsLng!,
        fechaCreacion: DateTime.now(),
      ));
      ultimaParcelaId = id;
      return true;
    } on Failure catch (f) {
      errorMessage = f.message;
      return false;
    } finally {
      isGuardando = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarParcela({
    required ParcelaEntity original,
    required String nombre,
    required double areaHectareas,
  }) async {
    isGuardando = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _actualizarParcelaUseCase(ParcelaEntity(
        id: original.id,
        fincaId: original.fincaId,
        usuarioId: original.usuarioId,
        nombre: nombre,
        areaHectareas: areaHectareas,
        lat: gpsLat ?? original.lat,
        lng: gpsLng ?? original.lng,
        fechaCreacion: original.fechaCreacion,
      ));
      return true;
    } on Failure catch (f) {
      errorMessage = f.message;
      return false;
    } finally {
      isGuardando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
