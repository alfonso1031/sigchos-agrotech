import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Anillo de progreso circular con el % de confianza al centro,
/// tal como aparece en la tarjeta de resultado del prototipo.
class ConfidenceRing extends StatelessWidget {
  final double confianza; // 0..1
  final Color color;
  final double size;

  const ConfidenceRing({
    super.key,
    required this.confianza,
    required this.color,
    this.size = 84,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(confianza: confianza, color: color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(confianza * 100).round()}%',
                style: AppTheme.monoFont(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B2D22),
                ),
              ),
              Text('CONFIANZA',
                  style: AppTheme.bodyFont(fontSize: 9, color: const Color(0xFF717A70))),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double confianza;
  final Color color;
  const _RingPainter({required this.confianza, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final fondo = Paint()
      ..color = const Color(0xFFEFEBE0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11;
    canvas.drawCircle(center, radius, fondo);

    final progreso = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // -90deg
      6.2832 * confianza,
      false,
      progreso,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.confianza != confianza || oldDelegate.color != color;
}
