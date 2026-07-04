import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Botón circular "‹" usado como header en casi todas las pantallas
/// secundarias del prototipo (fincas, parcela, cultivo, diagnóstico...).
class AppBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const AppBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        alignment: Alignment.center,
        child: const Text(
          '‹',
          style: TextStyle(fontSize: 20, color: AppColors.textoPrimario),
        ),
      ),
    );
  }
}
