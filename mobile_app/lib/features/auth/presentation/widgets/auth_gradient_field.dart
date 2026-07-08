import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Campo de texto translúcido usado sobre el fondo degradado verde
/// del Login/Registro (ver Sigchos Agrotech.dc.html, sección LOGIN).
///
/// Cuando [obscureText] es true muestra un ícono de "ojito" para
/// mostrar/ocultar la contraseña.
class AuthGradientField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const AuthGradientField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  State<AuthGradientField> createState() => _AuthGradientFieldState();
}

class _AuthGradientFieldState extends State<AuthGradientField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: AppTheme.monoFont(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ).copyWith(letterSpacing: 1.1),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          style: AppTheme.bodyFont(fontSize: 15, color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.12),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 21,
                    ),
                    tooltip:
                        _obscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFF5B199)),
            ),
            errorStyle: const TextStyle(color: Color(0xFFF5B199)),
          ),
        ),
      ],
    );
  }
}
