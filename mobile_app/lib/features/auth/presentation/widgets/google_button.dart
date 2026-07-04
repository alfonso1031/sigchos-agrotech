import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Botón "Continuar con Google" en blanco, con la G multicolor de Google
/// aproximada mediante un degradado (evita depender de un asset externo).
class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleG(size: 22),
            const SizedBox(width: 12),
            Text(
              'Continuar con Google',
              style: AppTheme.displayFont(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textoPrimario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleG extends StatelessWidget {
  final double size;
  const _GoogleG({required this.size});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const SweepGradient(
        startAngle: 0,
        endAngle: 6.2832,
        colors: [
          Color(0xFF4285F4), // azul
          Color(0xFF34A853), // verde
          Color(0xFFFBBC05), // amarillo
          Color(0xFFEA4335), // rojo
          Color(0xFF4285F4),
        ],
      ).createShader(bounds),
      child: Text(
        'G',
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}
