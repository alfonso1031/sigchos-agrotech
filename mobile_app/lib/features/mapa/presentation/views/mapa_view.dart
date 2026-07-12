import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/enfermedades.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_tab_bar.dart';
import '../../../../services/location_service.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/mapa_viewmodel.dart';

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

enum _FiltroMapa { todos, conDano, sinDano, soloFinca }

/// Centro del cantón Sigchos: se usa como respaldo cuando no hay ningún punto
/// que mostrar en el mapa.
const LatLng _sigchos = LatLng(-0.7166, -78.8833);

class _MapaViewState extends State<MapaView> {
  Position? _miPosicion;
  GoogleMapController? _mapController;
  _FiltroMapa _filtro = _FiltroMapa.todos;

  // Marcadores actualmente pintados y firma de sus posiciones, para reajustar
  // la cámara solo cuando el conjunto de puntos cambia (datos nuevos o filtro).
  Set<Marker> _markersActuales = {};
  String? _firmaFit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = context.read<AuthViewModel>().usuario?.uid;
      if (uid != null) context.read<MapaViewModel>().escuchar(uid);
      try {
        _miPosicion = await LocationService().obtenerPosicionActual();
        if (mounted) setState(() {});
      } catch (_) {
        // Sin GPS disponible: el mapa igual muestra fincas/diagnósticos.
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  double _hueDe(String claseId) {
    switch (claseId) {
      case 'hoja_sana':
        return BitmapDescriptor.hueGreen;
      case 'mancha_foliar':
      case 'mildiu':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueOrange;
    }
  }

  Future<void> _irA(LatLng destino, {double zoom = 17}) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: destino, zoom: zoom),
      ),
    );
  }

  /// Encuadra la cámara para que se vean todos los puntos (fincas +
  /// diagnósticos). Si no hay ninguno, centra en Sigchos. Con un solo punto
  /// (o varios casi coincidentes) hace zoom directo para no acercar de más.
  Future<void> _ajustarCamara(Set<Marker> markers) async {
    final controller = _mapController;
    if (controller == null) return;
    final puntos = markers.map((m) => m.position).toList();

    if (puntos.isEmpty) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(target: _sigchos, zoom: 13),
        ),
      );
      return;
    }

    var minLat = puntos.first.latitude, maxLat = puntos.first.latitude;
    var minLng = puntos.first.longitude, maxLng = puntos.first.longitude;
    for (final p in puntos) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    // Un solo punto o puntos casi encimados: bounds degenerado, mejor zoom fijo.
    const eps = 0.0009; // ~100 m
    if (maxLat - minLat < eps && maxLng - minLng < eps) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
            zoom: 16,
          ),
        ),
      );
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        56, // padding en px para que ningún marcador quede pegado al borde
      ),
    );
  }

  Future<void> _irAMiUbicacion() async {
    try {
      final pos = await LocationService().obtenerPosicionActual();
      _miPosicion = pos;
      if (mounted) setState(() {});
      await _irA(LatLng(pos.latitude, pos.longitude), zoom: 16);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener tu ubicación.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapaViewModel>();
    final geolocalizados = vm.diagnosticosGeolocalizados;

    // Diagnósticos visibles según el filtro seleccionado.
    final visibles = geolocalizados.where((d) {
      switch (_filtro) {
        case _FiltroMapa.conDano:
          return d.enfermedad != 'hoja_sana';
        case _FiltroMapa.sinDano:
          return d.enfermedad == 'hoja_sana';
        case _FiltroMapa.soloFinca:
          return false; // Solo fincas: se ocultan los diagnósticos.
        case _FiltroMapa.todos:
          return true;
      }
    }).toList();

    // Contorno de cada finca que tenga polígono dibujado.
    final polygons = <Polygon>{
      for (final f in vm.fincas)
        if (f.tienePoligono)
          Polygon(
            polygonId: PolygonId('finca_${f.id}'),
            points: [for (final p in f.limite) LatLng(p.lat, p.lng)],
            strokeColor: const Color(0xFF00A6FF),
            strokeWidth: 2,
            fillColor: const Color(0xFF00A6FF).withValues(alpha: 0.18),
          ),
    };

    final markers = <Marker>{
      for (final f in vm.fincas)
        Marker(
          markerId: MarkerId('finca_${f.id}'),
          position: LatLng(f.lat, f.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
              title: f.nombre,
              snippet: f.tienePoligono
                  ? 'Finca · ${f.areaHectareas.toStringAsFixed(2)} ha'
                  : 'Finca'),
        ),
      for (final d in visibles)
        Marker(
          markerId: MarkerId('dx_${d.id}'),
          position: LatLng(d.lat!, d.lng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(_hueDe(d.enfermedad)),
          infoWindow: InfoWindow(
            title: infoDe(d.enfermedad).nombre,
            snippet: '${(d.confianza * 100).round()}% confianza',
          ),
        ),
    };

    _markersActuales = markers;

    // Reajusta el encuadre solo cuando cambian los puntos (llegan datos o se
    // cambia de filtro), no en cada rebuild.
    final firma = (markers.map((m) =>
            '${m.position.latitude.toStringAsFixed(6)},${m.position.longitude.toStringAsFixed(6)}')
        .toList()
      ..sort())
        .join('|');
    if (firma != _firmaFit) {
      _firmaFit = firma;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _ajustarCamara(markers));
    }

    // Punto inicial mientras el mapa se crea; el encuadre real lo hace
    // _ajustarCamara en cuanto el controlador está listo.
    final centro = vm.fincas.isNotEmpty
        ? LatLng(vm.fincas.first.lat, vm.fincas.first.lng)
        : _miPosicion != null
            ? LatLng(_miPosicion!.latitude, _miPosicion!.longitude)
            : _sigchos;

    // Lista de la parte inferior: respeta el filtro.
    final listaInferior = [...visibles]
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    return Scaffold(
      bottomNavigationBar: const MainTabBar(current: TabItem.mapa),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Zonas afectadas',
                      style: AppTheme.displayFont(
                          fontSize: 24, fontWeight: FontWeight.w700)),
                  Text('Mapa de incidencia · cantón Sigchos',
                      style: AppTheme.bodyFont(
                          fontSize: 13, color: AppColors.textoSecundario)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 96),
                children: [
                  // Chips de filtro
                  SizedBox(
                    height: 38,
                    child: Row(
                      children: [
                        _chipFiltro('Todos', _FiltroMapa.todos),
                        const SizedBox(width: 8),
                        _chipFiltro('Con daño', _FiltroMapa.conDano),
                        const SizedBox(width: 8),
                        _chipFiltro('Sin daño', _FiltroMapa.sinDano),
                        const SizedBox(width: 8),
                        _chipFiltro('Solo finca', _FiltroMapa.soloFinca),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 320,
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition:
                                CameraPosition(target: centro, zoom: 13),
                            markers: markers,
                            polygons: polygons,
                            // El mapa vive dentro de un ListView; sin esto el
                            // scroll se traga los gestos de zoom/arrastre.
                            gestureRecognizers: {
                              Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer()),
                            },
                            mapType: MapType.hybrid,
                            myLocationEnabled: _miPosicion != null,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            onMapCreated: (c) {
                              _mapController = c;
                              // El mapa ya tiene tamaño: encuadra los puntos.
                              WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => _ajustarCamara(_markersActuales));
                            },
                          ),
                          // Botón mi ubicación
                          Positioned(
                            right: 10,
                            top: 10,
                            child: _botonRedondo(
                              icono: Icons.my_location,
                              onTap: _irAMiUbicacion,
                            ),
                          ),
                          // Leyenda flotante
                          Positioned(
                            left: 10,
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _leyendaItem(const Color(0xFF00A6FF), 'Ubicación de la finca'),
                                  const SizedBox(height: 5),
                                  _leyendaItem(AppColors.severidadAlta, 'Severidad alta'),
                                  const SizedBox(height: 5),
                                  _leyendaItem(AppColors.severidadMedia, 'Severidad media'),
                                  const SizedBox(height: 5),
                                  _leyendaItem(AppColors.sano, 'Hoja sana'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icono: Icons.warning_amber_rounded,
                          valor: '${vm.conDano}',
                          label: 'Con daño',
                          color: AppColors.severidadAlta,
                          fondo: AppColors.severidadAltaBg,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icono: Icons.eco_outlined,
                          valor: '${vm.sanas}',
                          label: 'Sin daño',
                          color: AppColors.sano,
                          fondo: AppColors.sanoBg,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 20, 4, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('DIAGNÓSTICOS EN EL MAPA',
                            style: AppTheme.monoFont(fontSize: 11)
                                .copyWith(letterSpacing: 1)),
                        Text('${listaInferior.length}',
                            style: AppTheme.monoFont(fontSize: 11)
                                .copyWith(letterSpacing: 1)),
                      ],
                    ),
                  ),
                  if (listaInferior.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.map_outlined,
                              color: AppColors.textoDeshabilitado, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No hay diagnósticos geolocalizados para este filtro.',
                              style: AppTheme.bodyFont(
                                  fontSize: 13, color: AppColors.textoSecundario),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    for (final d in listaInferior.take(10))
                      InkWell(
                        onTap: () => _irA(LatLng(d.lat!, d.lng!)),
                        onLongPress: () => Navigator.of(context).pushNamed(
                          AppRoutes.diagnostico,
                          arguments: d,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: d.imagenUrl.isNotEmpty
                                      ? Image.network(
                                          d.imagenUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (context, child, progress) =>
                                                  progress == null
                                                      ? child
                                                      : _thumbHoja(d.enfermedad),
                                          errorBuilder: (_, _, _) =>
                                              _thumbHoja(d.enfermedad),
                                        )
                                      : _thumbHoja(d.enfermedad),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(infoDe(d.enfermedad).nombre,
                                        style: AppTheme.bodyFont(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                      '${(d.confianza * 100).round()}% confianza · toca para ver en el mapa · mantén presionado para el diagnóstico',
                                      style: AppTheme.bodyFont(
                                          fontSize: 12,
                                          color: AppColors.textoSecundario),
                                    ),
                                  ],
                                ),
                              ),
                              if (_miPosicion != null && d.lat != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${(Geolocator.distanceBetween(_miPosicion!.latitude, _miPosicion!.longitude, d.lat!, d.lng!) / 1000).toStringAsFixed(1)} km',
                                    style: AppTheme.monoFont(
                                        fontSize: 12,
                                        color: AppColors.textoSecundario),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipFiltro(String label, _FiltroMapa filtro) {
    final activo = _filtro == filtro;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filtro = filtro),
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: activo ? AppColors.verdeOscuro : AppColors.card,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                color: activo ? AppColors.verdeOscuro : AppColors.cardBorder),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label,
                maxLines: 1,
                style: AppTheme.bodyFont(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: activo ? Colors.white : AppColors.textoSecundario,
                )),
          ),
        ),
      ),
    );
  }

  Widget _botonRedondo({required IconData icono, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icono, color: AppColors.verdeMedio, size: 20),
      ),
    );
  }

  /// Respaldo cuando la foto de la hoja no está disponible: caja con el color
  /// de la enfermedad y un ícono de hoja.
  Widget _thumbHoja(String enfermedad) {
    return Container(
      color: AppColors.fondoEnfermedad(enfermedad),
      alignment: Alignment.center,
      child: Icon(Icons.eco,
          color: AppColors.colorEnfermedad(enfermedad), size: 22),
    );
  }

  Widget _leyendaItem(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(texto,
            style: AppTheme.bodyFont(
                fontSize: 11, color: AppColors.textoPrimario)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String label;
  final Color color;
  final Color fondo;
  const _StatCard({
    required this.icono,
    required this.valor,
    required this.label,
    required this.color,
    required this.fondo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(valor,
                  style: AppTheme.displayFont(
                      fontSize: 22, fontWeight: FontWeight.w700, color: color)),
              Text(label,
                  style: AppTheme.bodyFont(
                      fontSize: 12, color: AppColors.textoSecundario)),
            ],
          ),
        ],
      ),
    );
  }
}
