import 'package:flutter/material.dart';
import '../../features/auth/presentation/views/editar_perfil_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/profile_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/views/splash_view.dart';
import '../../features/clima/presentation/views/clima_view.dart';
import '../../features/cultivos/presentation/views/registrar_cultivo_view.dart';
import '../../features/diagnostico/domain/entities/diagnostico_entity.dart';
import '../../features/diagnostico/presentation/views/captura_view.dart';
import '../../features/diagnostico/presentation/views/resultado_diagnostico_view.dart';
import '../../features/fincas/presentation/views/fincas_view.dart';
import '../../features/fincas/presentation/views/registrar_finca_view.dart';
import '../../features/historial/presentation/views/historial_view.dart';
import '../../features/inicio/presentation/views/inicio_view.dart';
import '../../features/mapa/presentation/views/mapa_view.dart';
import '../../features/parcelas/presentation/views/registrar_parcela_view.dart';
import '../../features/recomendaciones/presentation/views/recomendaciones_view.dart';
import 'app_routes.dart';

/// Resuelve cada nombre de ruta a su vista. Centralizar la navegación aquí
/// evita repetir `MaterialPageRoute` por toda la app.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashView());
      case AppRoutes.login:
        return _page(const LoginView());
      case AppRoutes.registro:
        return _page(const RegisterView());
      case AppRoutes.inicio:
        return _page(const InicioView());
      case AppRoutes.captura:
        return _page(CapturaView(cultivoId: settings.arguments as String?));
      case AppRoutes.diagnostico:
        return _page(
          ResultadoDiagnosticoView(
            diagnostico: settings.arguments as DiagnosticoEntity,
          ),
        );
      case AppRoutes.recomendaciones:
        return _page(
          RecomendacionesView(
            diagnostico: settings.arguments as DiagnosticoEntity,
          ),
        );
      case AppRoutes.historial:
        return _page(const HistorialView());
      case AppRoutes.mapa:
        return _page(const MapaView());
      case AppRoutes.clima:
        return _page(const ClimaView());
      case AppRoutes.fincas:
        return _page(const FincasView());
      case AppRoutes.registrarFinca:
        return _page(const RegistrarFincaView());
      case AppRoutes.registrarParcela:
        return _page(
          RegistrarParcelaView(fincaId: settings.arguments as String),
        );
      case AppRoutes.registrarCultivo:
        return _page(
          RegistrarCultivoView(parcelaId: settings.arguments as String),
        );
      case AppRoutes.perfil:
        return _page(const ProfileView());
      case AppRoutes.editarPerfil:
        return _page(const EditarPerfilView());
      default:
        return _page(const LoginView());
    }
  }

  /// Transición fade + slide suave (220ms) para todas las rutas nombradas,
  /// en vez del corte abrupto de una `MaterialPageRoute` sin animación propia.
  static PageRouteBuilder<dynamic> _page(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (_, _, _) => child,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curva = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curva,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curva),
            child: child,
          ),
        );
      },
    );
  }
}
