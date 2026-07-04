import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Muestra un aviso explicando para qué se usa un permiso ANTES de disparar
/// el diálogo nativo del sistema, y maneja el caso de "denegado para siempre"
/// ofreciendo abrir los ajustes de la app.
Future<bool> solicitarPermisoConAviso(
  BuildContext context, {
  required Permission permiso,
  required String titulo,
  required String mensaje,
  required IconData icono,
}) async {
  final estadoActual = await permiso.status;
  if (estadoActual.isGranted) return true;

  if (estadoActual.isPermanentlyDenied) {
    if (!context.mounted) return false;
    final abrirAjustes = await _mostrarDialogo(
      context,
      titulo: titulo,
      mensaje: '$mensaje\n\nLo denegaste antes de forma permanente. '
          'Actívalo manualmente en Ajustes de la app.',
      icono: icono,
      textoBoton: 'Abrir ajustes',
    );
    if (abrirAjustes) await openAppSettings();
    return false;
  }

  if (!context.mounted) return false;
  final continuar = await _mostrarDialogo(
    context,
    titulo: titulo,
    mensaje: mensaje,
    icono: icono,
    textoBoton: 'Continuar',
  );
  if (!continuar) return false;

  final resultado = await permiso.request();
  return resultado.isGranted;
}

Future<bool> _mostrarDialogo(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required IconData icono,
  required String textoBoton,
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.sanoBg,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Icon(icono, color: AppColors.verdeMedio, size: 26),
      ),
      title: Text(titulo,
          textAlign: TextAlign.center,
          style: AppTheme.displayFont(fontSize: 17, fontWeight: FontWeight.w600)),
      content: Text(mensaje,
          textAlign: TextAlign.center,
          style: AppTheme.bodyFont(fontSize: 14, color: AppColors.textoSecundario)),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Ahora no'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(textoBoton),
        ),
      ],
    ),
  );
  return resultado ?? false;
}
