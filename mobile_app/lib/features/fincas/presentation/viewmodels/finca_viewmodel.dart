import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/models/geo_punto.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../services/location_service.dart';
import '../../domain/entities/finca_entity.dart';
import '../../domain/usecases/crear_finca_usecase.dart';
import '../../domain/usecases/obtener_fincas_usecase.dart';

class FincaViewModel extends ChangeNotifier {
  final CrearFincaUseCase _crearFincaUseCase;
  final ActualizarFincaUseCase _actualizarFincaUseCase;
  final ObtenerFincasUseCase _obtenerFincasUseCase;
  final LocationService _locationService;

  FincaViewModel({
    required CrearFincaUseCase crearFincaUseCase,
    required ActualizarFincaUseCase actualizarFincaUseCase,
    required ObtenerFincasUseCase obtenerFincasUseCase,
    LocationService? locationService,
  })  : _crearFincaUseCase = crearFincaUseCase,
        _actualizarFincaUseCase = actualizarFincaUseCase,
        _obtenerFincasUseCase = obtenerFincasUseCase,
        _locationService = locationService ?? LocationService();

  List<FincaEntity> fincas = [];
  bool isLoading = false;
  bool isGuardando = false;
  bool isCapturandoGps = false;
  String? errorMessage;
  double? gpsLat;
  double? gpsLng;
  StreamSubscription<List<FincaEntity>>? _subscription;

  /// Vértices del contorno que el usuario va tocando en el mapa.
  final List<GeoPunto> puntosLimite = [];

  bool get tienePoligono => puntosLimite.length >= 3;

  /// Área en hectáreas calculada a partir del polígono dibujado.
  double get areaCalculada => GeoUtils.areaHectareas(puntosLimite);

  void agregarPunto(double lat, double lng) {
    puntosLimite.add(GeoPunto(lat, lng));
    notifyListeners();
  }

  void deshacerPunto() {
    if (puntosLimite.isNotEmpty) {
      puntosLimite.removeLast();
      notifyListeners();
    }
  }

  void limpiarLimite() {
    puntosLimite.clear();
    notifyListeners();
  }

  /// Precarga el contorno de una finca existente (modo edición).
  void cargarLimite(List<GeoPunto> puntos) {
    puntosLimite
      ..clear()
      ..addAll(puntos);
    notifyListeners();
  }

  Future<void> capturarGps() async {
    isCapturandoGps = true;
    errorMessage = null;
    notifyListeners();
    try {
      final pos = await _locationService.obtenerPosicionActual();
      gpsLat = pos.latitude;
      gpsLng = pos.longitude;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isCapturandoGps = false;
      notifyListeners();
    }
  }

  void escucharFincas(String usuarioId) {
    isLoading = true;
    notifyListeners();
    _subscription?.cancel();
    _subscription = _obtenerFincasUseCase(usuarioId).listen((lista) {
      fincas = lista;
      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      errorMessage = 'No se pudieron cargar las fincas.';
      isLoading = false;
      notifyListeners();
    });
  }

  FincaEntity? get fincaPrincipal => fincas.isNotEmpty ? fincas.first : null;

  Future<bool> crearFinca({
    required String usuarioId,
    required String nombre,
    required double areaHectareas,
    required String direccion,
  }) async {
    // Con polígono dibujado la ubicación es su centro; sin él se usa el GPS.
    final centro = GeoUtils.centroide(puntosLimite);
    if (centro == null && (gpsLat == null || gpsLng == null)) {
      await capturarGps();
      if (gpsLat == null) return false;
    }
    isGuardando = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _crearFincaUseCase(FincaEntity(
        id: '',
        usuarioId: usuarioId,
        nombre: nombre,
        lat: centro?.lat ?? gpsLat!,
        lng: centro?.lng ?? gpsLng!,
        direccion: direccion,
        areaHectareas: tienePoligono ? areaCalculada : areaHectareas,
        fechaCreacion: DateTime.now(),
        limite: List.of(puntosLimite),
      ));
      return true;
    } on Failure catch (f) {
      errorMessage = f.message;
      return false;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isGuardando = false;
      notifyListeners();
    }
  }

  /// Actualiza una finca existente. Si [nuevaUbicacion] es true, usa el GPS
  /// recién capturado; si no, conserva la ubicación previa.
  Future<bool> actualizarFinca({
    required FincaEntity original,
    required String nombre,
    required double areaHectareas,
    required String direccion,
    bool nuevaUbicacion = false,
  }) async {
    isGuardando = true;
    errorMessage = null;
    notifyListeners();
    try {
      // El polígono editado manda: su centro fija la ubicación y su forma el
      // área. Si no hay polígono se respeta la lógica previa de GPS.
      final centro = GeoUtils.centroide(puntosLimite);
      await _actualizarFincaUseCase(FincaEntity(
        id: original.id,
        usuarioId: original.usuarioId,
        nombre: nombre,
        lat: centro?.lat ??
            (nuevaUbicacion && gpsLat != null ? gpsLat! : original.lat),
        lng: centro?.lng ??
            (nuevaUbicacion && gpsLng != null ? gpsLng! : original.lng),
        direccion: direccion,
        areaHectareas: tienePoligono ? areaCalculada : areaHectareas,
        fechaCreacion: original.fechaCreacion,
        limite: List.of(puntosLimite),
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

  /// Limpia el GPS capturado (al abrir el form en modo edición para no
  /// arrastrar coordenadas de un registro anterior).
  void limpiarGps() {
    gpsLat = null;
    gpsLng = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
