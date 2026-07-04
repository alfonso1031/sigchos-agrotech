import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/permission_helper.dart';
import '../../../../services/location_service.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../clima/presentation/viewmodels/clima_viewmodel.dart';
import '../viewmodels/diagnostico_viewmodel.dart';

/// Combina las pantallas "Captura" y "Analizando" del prototipo en una sola
/// vista (mismo patrón sc-if del diseño original). La cámara se muestra en
/// vivo dentro de la propia UI (CameraController + CameraPreview), no se abre
/// la app de cámara del sistema.
class CapturaView extends StatefulWidget {
  final String? cultivoId;
  const CapturaView({super.key, this.cultivoId});

  @override
  State<CapturaView> createState() => _CapturaViewState();
}

enum _EstadoPermiso { pendiente, concedido, denegado }

class _CapturaViewState extends State<CapturaView> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _inicializacion;
  _EstadoPermiso _permiso = _EstadoPermiso.pendiente;
  bool _tomandoFoto = false;

  bool _inicializando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pedirPermisoEIniciar());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // Libera la cámara al ir a segundo plano (ej. abrir la galería) y limpia
      // la UI para no dejar un preview congelado.
      final controller = _controller;
      if (controller != null) {
        controller.dispose();
        if (mounted) setState(() => _controller = null);
      }
    } else if (state == AppLifecycleState.resumed) {
      // Al volver, reactiva la cámara sin volver a pedir el permiso.
      if (_permiso == _EstadoPermiso.concedido) _crearControlador();
    }
  }

  /// Primera vez: muestra el aviso y pide el permiso; si lo conceden, arranca.
  Future<void> _pedirPermisoEIniciar() async {
    final concedido = await solicitarPermisoConAviso(
      context,
      permiso: Permission.camera,
      icono: Icons.camera_alt_outlined,
      titulo: 'Usar la cámara',
      mensaje:
          'Sigchos Agrotech necesita la cámara para fotografiar la hoja y '
          'detectar enfermedades con inteligencia artificial. Solo se activa '
          'mientras estás en esta pantalla.',
    );
    if (!mounted) return;
    if (!concedido) {
      setState(() => _permiso = _EstadoPermiso.denegado);
      return;
    }
    setState(() => _permiso = _EstadoPermiso.concedido);
    await _crearControlador();
  }

  /// Crea (o recrea) el CameraController. Idempotente: evita dobles arranques
  /// cuando el lifecycle y el retorno de la galería coinciden.
  Future<void> _crearControlador() async {
    if (_inicializando) return;
    if (_controller != null && _controller!.value.isInitialized) return;
    _inicializando = true;
    try {
      final camaras = await availableCameras();
      final trasera = camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => camaras.first,
      );
      final controller = CameraController(
        trasera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      final inicializacion = controller.initialize();
      await inicializacion;
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _inicializacion = inicializacion;
      });
    } catch (_) {
      if (mounted) setState(() => _permiso = _EstadoPermiso.denegado);
    } finally {
      _inicializando = false;
    }
  }

  Future<void> _capturarYAnalizar() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _tomandoFoto) {
      return;
    }
    setState(() => _tomandoFoto = true);
    try {
      final foto = await controller.takePicture();
      await _procesarImagen(File(foto.path));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo tomar la foto. Intenta de nuevo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _tomandoFoto = false);
    }
  }

  Future<void> _elegirDeGaleria() async {
    final vm = context.read<DiagnosticoViewModel>();
    final elegido = await vm.capturarDesdeGaleria();
    if (!mounted) return;
    if (!elegido || vm.imagen == null) {
      // Canceló la galería: reactiva la cámara (por si el lifecycle no la
      // reinició al volver).
      if (_permiso == _EstadoPermiso.concedido) _crearControlador();
      return;
    }
    await _procesarImagen(vm.imagen!);
  }

  Future<void> _procesarImagen(File archivo) async {
    final vm = context.read<DiagnosticoViewModel>();
    vm.usarImagenCapturada(archivo);

    // Geoetiquetado opcional: pide GPS con aviso previo. Si lo deniega, el
    // diagnóstico igual se guarda, solo que sin ubicación en el mapa.
    double? lat;
    double? lng;
    final permitirGps = await solicitarPermisoConAviso(
      context,
      permiso: Permission.location,
      icono: Icons.location_on_outlined,
      titulo: 'Ubicar el diagnóstico',
      mensaje:
          'Sigchos Agrotech puede geoetiquetar este diagnóstico con tu '
          'ubicación GPS para mostrarlo en el mapa de zonas afectadas.',
    );
    if (permitirGps) {
      try {
        final pos = await LocationService().obtenerPosicionActual();
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {
        // GPS no disponible en este momento: se guarda sin ubicación.
      }
    }
    if (!mounted) return;

    final uid = context.read<AuthViewModel>().usuario!.uid;
    final ok = await vm.analizarYGuardar(
      usuarioId: uid,
      cultivoId: widget.cultivoId ?? '',
      clima: context.read<ClimaViewModel>().snapshot,
      lat: lat,
      lng: lng,
    );
    if (ok && mounted) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.diagnostico,
        arguments: vm.resultado,
      );
    } else if (mounted && vm.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiagnosticoViewModel>();
    final analizando = vm.estado == DiagnosticoEstado.analizando;

    return Scaffold(
      backgroundColor: AppColors.fondoCamara,
      body: SafeArea(
        child: analizando ? _vistaAnalizando() : _vistaCaptura(context),
      ),
    );
  }

  Widget _vistaCaptura(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circulo(
                child: const Text('‹', style: TextStyle(fontSize: 20, color: Colors.white)),
                onTap: () => Navigator.of(context).pop(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.naranja.withValues(alpha: 0.18),
                  border: Border.all(color: AppColors.naranja.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('Diagnóstico de hoja',
                    style: AppTheme.bodyFont(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.naranjaClaro)),
              ),
              const SizedBox(width: 38),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF1C241F),
              borderRadius: BorderRadius.circular(22),
            ),
            child: _contenidoCamara(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
          child: Text(
            'Encuadra la hoja dentro del marco con buena luz',
            textAlign: TextAlign.center,
            style: AppTheme.bodyFont(fontSize: 13, color: Colors.white60),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(44, 18, 44, 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circulo(
                child: const Icon(Icons.photo_library_outlined, color: Colors.white54),
                onTap: _elegirDeGaleria,
                size: 48,
              ),
              GestureDetector(
                onTap: _capturarYAnalizar,
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 4),
                  ),
                  padding: const EdgeInsets.all(9),
                  child: _tomandoFoto
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : Container(
                          decoration:
                              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                ),
              ),
              _circulo(
                child: const Icon(Icons.flip_camera_android_outlined, color: Colors.white),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contenidoCamara() {
    if (_permiso == _EstadoPermiso.denegado) {
      return _vistaSinPermiso();
    }
    if (_permiso == _EstadoPermiso.pendiente || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.naranja),
      );
    }
    return FutureBuilder<void>(
      future: _inicializacion,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.naranja),
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            Center(child: CameraPreview(_controller!)),
            IgnorePointer(
              child: Center(
                child: SizedBox(
                  width: 210,
                  height: 210,
                  child: CustomPaint(painter: _MarcoEsquinasPainter()),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'vista de cámara · hoja de zapallo',
                    style: AppTheme.monoFont(fontSize: 11, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _vistaSinPermiso() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white38, size: 40),
            const SizedBox(height: 14),
            Text(
              'Sin acceso a la cámara',
              style: AppTheme.displayFont(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Puedes elegir una foto de la galería, o activa el permiso de cámara para tomarla en vivo.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyFont(fontSize: 13, color: Colors.white60),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _pedirPermisoEIniciar,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vistaAnalizando() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation(AppColors.naranja),
                    ),
                  ),
                  const Icon(Icons.eco_outlined, color: AppColors.naranja, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 34),
            Text('Analizando con IA',
                style: AppTheme.displayFont(
                    fontSize: 21, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'Modelo TensorFlow Lite procesando la imagen de la hoja…',
              textAlign: TextAlign.center,
              style: AppTheme.bodyFont(fontSize: 14, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circulo({required Widget child, required VoidCallback onTap, double size = 38}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _MarcoEsquinasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.naranja
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const l = 34.0;
    canvas.drawPath(
      Path()
        ..moveTo(0, l)
        ..lineTo(0, 0)
        ..lineTo(l, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - l, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, l),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - l)
        ..lineTo(0, size.height)
        ..lineTo(l, size.height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - l, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - l),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
