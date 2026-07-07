import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/views/cargando_view.dart';

class SigchosApp extends StatelessWidget {
  /// Destino tras la pantalla de carga, ya resuelto en `main()` (Inicio si hay
  /// sesión, Login si no), decidido bajo el splash nativo.
  final String rutaInicial;

  const SigchosApp({super.key, required this.rutaInicial});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sigchos Agrotech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: CargandoView(destino: rutaInicial),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
