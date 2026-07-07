import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_logo.dart';

/// Pantalla de marca que se muestra al abrir la app: logo, nombre y una barra
/// de progreso. La sesión ya se resolvió en `main()` bajo el splash nativo, así
/// que aquí solo se hace una pausa breve de branding antes de ir a [destino].
class CargandoView extends StatefulWidget {
  /// Ruta a la que se navega al terminar (Inicio si hay sesión, Login si no).
  final String destino;

  const CargandoView({super.key, required this.destino});

  @override
  State<CargandoView> createState() => _CargandoViewState();
}

class _CargandoViewState extends State<CargandoView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ya hay un frame real dibujado a pantalla completa: retira el splash
      // nativo y programa la navegación tras la pausa de branding.
      FlutterNativeSplash.remove();
      _irADestino();
    });
  }

  Future<void> _irADestino() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(widget.destino);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.gradienteLogin),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    children: [
                      const AppLogo(size: 104),
                      const SizedBox(height: 24),
                      Text(
                        'Sigchos Agrotech',
                        style: AppTheme.displayFont(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Detección de enfermedades foliares',
                        style: AppTheme.bodyFont(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    SizedBox(
                      width: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.naranja),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Cargando…',
                      style: AppTheme.monoFont(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
