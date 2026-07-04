import 'package:geolocator/geolocator.dart';

/// Wrapper sobre Geolocator: pide permisos y entrega la posición actual.
/// Usado por fincas (ubicación), parcelas (GPS), diagnóstico (geoetiquetado)
/// y clima (coordenadas para OpenWeather).
class LocationService {
  Future<Position> obtenerPosicionActual() async {
    final servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      throw Exception('Activa el GPS del dispositivo para continuar.');
    }

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado.');
      }
    }
    if (permiso == LocationPermission.deniedForever) {
      throw Exception(
        'Permiso de ubicación denegado permanentemente. Actívalo en ajustes.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
