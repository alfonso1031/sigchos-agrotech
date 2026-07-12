import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../services/location_service.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../domain/entities/finca_entity.dart';
import '../viewmodels/finca_viewmodel.dart';

/// Centro del cantón Sigchos: respaldo para centrar el mapa cuando no hay GPS
/// ni finca previa.
const LatLng _sigchos = LatLng(-0.7166, -78.8833);

/// Crea una finca nueva, o edita una existente si se pasa [fincaEditar].
class RegistrarFincaView extends StatefulWidget {
  final FincaEntity? fincaEditar;
  const RegistrarFincaView({super.key, this.fincaEditar});

  @override
  State<RegistrarFincaView> createState() => _RegistrarFincaViewState();
}

class _RegistrarFincaViewState extends State<RegistrarFincaView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _areaController = TextEditingController();

  GoogleMapController? _mapController;

  bool get _esEdicion => widget.fincaEditar != null;

  @override
  void initState() {
    super.initState();
    final vm = context.read<FincaViewModel>();
    // Limpia GPS/contorno del ViewModel para no arrastrar datos de un registro
    // anterior, luego precarga el contorno si estamos editando.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.limpiarGps();
      final f = widget.fincaEditar;
      if (f != null && f.limite.isNotEmpty) {
        vm.cargarLimite(f.limite);
      } else {
        vm.limpiarLimite();
      }
    });
    final f = widget.fincaEditar;
    if (f != null) {
      _nombreController.text = f.nombre;
      _direccionController.text = f.direccion;
      _areaController.text = f.areaHectareas.toString();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  LatLng get _centroInicial {
    final f = widget.fincaEditar;
    if (f != null && (f.lat != 0 || f.lng != 0)) return LatLng(f.lat, f.lng);
    return _sigchos;
  }

  Future<void> _irAMiUbicacion() async {
    try {
      final pos = await LocationService().obtenerPosicionActual();
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(pos.latitude, pos.longitude), zoom: 17),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener tu ubicación.')),
        );
      }
    }
  }

  Future<void> _guardar() async {
    final vm = context.read<FincaViewModel>();
    if (!_formKey.currentState!.validate()) return;
    // Sin polígono válido ni área manual no hay nada que guardar.
    if (!vm.tienePoligono && _areaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Dibuja el contorno en el mapa o ingresa el área.'),
      ));
      return;
    }
    final area = vm.tienePoligono
        ? vm.areaCalculada
        : double.tryParse(_areaController.text.trim()) ?? 0;
    bool ok;
    if (_esEdicion) {
      ok = await vm.actualizarFinca(
        original: widget.fincaEditar!,
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        areaHectareas: area,
      );
    } else {
      final uid = context.read<AuthViewModel>().usuario!.uid;
      ok = await vm.crearFinca(
        usuarioId: uid,
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        areaHectareas: area,
      );
    }
    if (ok && mounted) {
      Navigator.of(context).pop();
    } else if (mounted && vm.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FincaViewModel>();
    final puntos =
        vm.puntosLimite.map((p) => LatLng(p.lat, p.lng)).toList();

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    AppBackButton(onPressed: () => Navigator.of(context).pop()),
                    const SizedBox(width: 14),
                    Text(_esEdicion ? 'Editar finca' : 'Registrar finca',
                        style: AppTheme.displayFont(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    AppTextField(
                      label: 'Nombre de la finca',
                      controller: _nombreController,
                      validator: (v) =>
                          Validators.requerido(v, campo: 'El nombre'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Sector / dirección',
                      controller: _direccionController,
                      validator: (v) =>
                          Validators.requerido(v, campo: 'La dirección'),
                    ),
                    const SizedBox(height: 20),
                    Text('CONTORNO DE LA FINCA',
                        style: AppTheme.monoFont(fontSize: 11)
                            .copyWith(letterSpacing: 1.1)),
                    const SizedBox(height: 7),
                    Text(
                      'Toca el mapa para marcar las esquinas del terreno. '
                      'Con 3 o más puntos se calcula el área automáticamente.',
                      style: AppTheme.bodyFont(
                          fontSize: 12, color: AppColors.textoSecundario),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 300,
                        child: Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                  target: puntos.isNotEmpty
                                      ? puntos.first
                                      : _centroInicial,
                                  zoom: 16),
                              mapType: MapType.hybrid,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              gestureRecognizers: {
                                Factory<OneSequenceGestureRecognizer>(
                                    () => EagerGestureRecognizer()),
                              },
                              onMapCreated: (c) => _mapController = c,
                              onTap: (latLng) => vm.agregarPunto(
                                  latLng.latitude, latLng.longitude),
                              markers: {
                                for (var i = 0; i < puntos.length; i++)
                                  Marker(
                                    markerId: MarkerId('v$i'),
                                    position: puntos[i],
                                    icon:
                                        BitmapDescriptor.defaultMarkerWithHue(
                                            BitmapDescriptor.hueAzure),
                                  ),
                              },
                              polygons: puntos.length >= 3
                                  ? {
                                      Polygon(
                                        polygonId: const PolygonId('finca'),
                                        points: puntos,
                                        strokeColor: AppColors.verdeMedio,
                                        strokeWidth: 2,
                                        fillColor: AppColors.verdeMedio
                                            .withValues(alpha: 0.25),
                                      ),
                                    }
                                  : {},
                              polylines: puntos.length == 2
                                  ? {
                                      Polyline(
                                        polylineId: const PolylineId('linea'),
                                        points: puntos,
                                        color: AppColors.verdeMedio,
                                        width: 2,
                                      ),
                                    }
                                  : {},
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: _botonRedondo(
                                icono: Icons.my_location,
                                onTap: _irAMiUbicacion,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vm.tienePoligono
                                ? '${vm.puntosLimite.length} puntos · ${vm.areaCalculada.toStringAsFixed(2)} ha'
                                : '${vm.puntosLimite.length} punto(s) · faltan ${(3 - vm.puntosLimite.length).clamp(0, 3)} para cerrar el área',
                            style: AppTheme.bodyFont(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: vm.tienePoligono
                                    ? AppColors.verdeMedio
                                    : AppColors.textoSecundario),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: vm.puntosLimite.isEmpty
                              ? null
                              : vm.deshacerPunto,
                          icon: const Icon(Icons.undo, size: 18),
                          label: const Text('Deshacer'),
                        ),
                        TextButton.icon(
                          onPressed: vm.puntosLimite.isEmpty
                              ? null
                              : vm.limpiarLimite,
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Limpiar'),
                        ),
                      ],
                    ),
                    if (!vm.tienePoligono) ...[
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Área (hectáreas)',
                        controller: _areaController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) => vm.tienePoligono
                            ? null
                            : Validators.numeroPositivo(v, campo: 'El área'),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: AppPrimaryButton(
                  label: _esEdicion ? 'Guardar cambios' : 'Guardar finca',
                  loading: vm.isGuardando,
                  onPressed: _guardar,
                ),
              ),
            ],
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
}
