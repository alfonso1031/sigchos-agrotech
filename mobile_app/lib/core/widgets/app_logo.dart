import 'package:flutter/material.dart';

/// Logo oficial de Sigchos Agrotech (hoja + marco de escaneo).
/// Fuente: assets/images/logo.png — mismo archivo usado como ícono de la app.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
    );
  }
}
