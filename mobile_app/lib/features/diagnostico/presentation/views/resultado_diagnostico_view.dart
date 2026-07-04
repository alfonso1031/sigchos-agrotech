import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/enfermedades.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../viewmodels/diagnostico_viewmodel.dart';
import '../widgets/confidence_ring.dart';

/// Muestra un diagnóstico ya persistido (imagenUrl de Storage) — se usa tanto
/// justo después de analizar una hoja como al abrir un ítem del historial.
/// Si la imagen no llegó a Storage (subida tolerante a fallo) pero venimos del
/// flujo de captura, muestra la foto local del ViewModel como respaldo.
class ResultadoDiagnosticoView extends StatelessWidget {
  final DiagnosticoEntity diagnostico;
  const ResultadoDiagnosticoView({super.key, required this.diagnostico});

  @override
  Widget build(BuildContext context) {
    final info = infoDe(diagnostico.enfermedad);
    final imagenLocal = context.select<DiagnosticoViewModel, File?>(
      (vm) => vm.resultado?.id == diagnostico.id ? vm.imagen : null,
    );
    final color = AppColors.colorEnfermedad(diagnostico.enfermedad);
    final fondoColor = AppColors.fondoEnfermedad(diagnostico.enfermedad);
    final severidad = severidadLabel(diagnostico.enfermedad);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  AppBackButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(AppRoutes.inicio, (r) => false),
                  ),
                  const SizedBox(width: 14),
                  Text('Resultado del diagnóstico',
                      style: AppTheme.displayFont(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (diagnostico.imagenUrl.isNotEmpty)
                            Image.network(
                              diagnostico.imagenUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : Container(
                                          color: AppColors.inputFill,
                                          alignment: Alignment.center,
                                          child: const CircularProgressIndicator(),
                                        ),
                              errorBuilder: (_, _, _) => imagenLocal != null
                                  ? Image.file(imagenLocal, fit: BoxFit.cover)
                                  : Container(color: AppColors.inputFill),
                            )
                          else if (imagenLocal != null)
                            Image.file(imagenLocal, fit: BoxFit.cover)
                          else
                            _placeholderImagen(),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 11, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: fondoColor,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                              color: color, shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          severidad.toUpperCase(),
                                          style: AppTheme.monoFont(
                                                  fontSize: 11, color: color)
                                              .copyWith(letterSpacing: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => _mostrarDefinicion(context, info),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(info.nombre,
                                              style: AppTheme.displayFont(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(Icons.info_outline,
                                            size: 18, color: color),
                                      ],
                                    ),
                                  ),
                                  Text(info.nombreCientifico,
                                      style: AppTheme.bodyFont(
                                        fontSize: 13,
                                        color: AppColors.textoSecundario,
                                      ).copyWith(fontStyle: FontStyle.italic)),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _mostrarDefinicion(context, info),
                                    child: Text('Ver qué significa',
                                        style: AppTheme.bodyFont(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.verdeMedio)),
                                  ),
                                ],
                              ),
                            ),
                            ConfidenceRing(confianza: diagnostico.confianza, color: color),
                          ],
                        ),
                        const Divider(height: 32, color: AppColors.divider),
                        Row(
                          children: [
                            Expanded(
                              child: _EtiquetaValor(
                                etiqueta: 'Fecha',
                                valor: DateFormat('dd/MM/yyyy HH:mm')
                                    .format(diagnostico.fecha),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _explicarConfianza(context),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('CONFIANZA IA',
                                            style: AppTheme.monoFont(fontSize: 11)
                                                .copyWith(letterSpacing: 0.5)),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.help_outline,
                                            size: 13,
                                            color: AppColors.textoSecundario),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${(diagnostico.confianza * 100).round()}%',
                                      style: AppTheme.bodyFont(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (diagnostico.top3.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OTRAS PROBABILIDADES',
                              style: AppTheme.monoFont(fontSize: 12)
                                  .copyWith(letterSpacing: 0.5)),
                          const SizedBox(height: 10),
                          for (final p in diagnostico.top3)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 96,
                                    child: Text(infoDe(p.claseId).nombre,
                                        style: AppTheme.bodyFont(fontSize: 13)),
                                  ),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: p.probabilidad,
                                        minHeight: 7,
                                        backgroundColor: AppColors.divider,
                                        valueColor: const AlwaysStoppedAnimation(
                                            Color(0xFFC4C9BD)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '${(p.probabilidad * 100).round()}%',
                                      textAlign: TextAlign.right,
                                      style: AppTheme.monoFont(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (diagnostico.lat != null && diagnostico.lng != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: AppColors.verdeMedio),
                              const SizedBox(width: 6),
                              Text('UBICACIÓN DEL DIAGNÓSTICO',
                                  style: AppTheme.monoFont(fontSize: 11)
                                      .copyWith(letterSpacing: 0.5)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 150,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      diagnostico.lat!, diagnostico.lng!),
                                  zoom: 16,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('dx'),
                                    position: LatLng(
                                        diagnostico.lat!, diagnostico.lng!),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                      _hueDe(diagnostico.enfermedad),
                                    ),
                                  ),
                                },
                                mapType: MapType.hybrid,
                                zoomControlsEnabled: false,
                                liteModeEnabled: true,
                                myLocationButtonEnabled: false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${diagnostico.lat!.toStringAsFixed(5)}, ${diagnostico.lng!.toStringAsFixed(5)}',
                            style: AppTheme.monoFont(
                                fontSize: 11, color: AppColors.textoSecundario),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(AppRoutes.historial, (r) => false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(54, 54),
                        side: const BorderSide(color: Color(0xFFC9CEC2)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Icon(Icons.history, color: AppColors.verdeMedio),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AppRoutes.recomendaciones, arguments: diagnostico),
                        child: const Text('Ver recomendaciones'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImagen() {
    return Container(
      color: AppColors.inputFill,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined,
              size: 34, color: AppColors.textoDeshabilitado),
          const SizedBox(height: 6),
          Text('Imagen no disponible',
              style: AppTheme.bodyFont(
                  fontSize: 12, color: AppColors.textoDeshabilitado)),
        ],
      ),
    );
  }

  double _hueDe(String claseId) {
    switch (claseId) {
      case 'hoja_sana':
        return BitmapDescriptor.hueGreen;
      case 'mancha_foliar':
      case 'mildiu':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueOrange;
    }
  }

  void _explicarConfianza(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.sanoBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.insights, color: AppColors.verdeMedio),
                ),
                const SizedBox(width: 12),
                Text('¿Qué es la confianza?',
                    style: AppTheme.displayFont(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Es el nivel de certeza del modelo de inteligencia artificial sobre '
              'el resultado. Un 90% significa que el modelo está muy seguro de que '
              'la hoja corresponde a esa clase.\n\n'
              'Cuando la confianza es baja (menos del 55%), conviene repetir la '
              'foto con mejor luz y enfoque, o consultar con un técnico agrícola. '
              'El diagnóstico es una ayuda, no reemplaza la revisión de un experto.',
              style: AppTheme.bodyFont(
                  fontSize: 14, color: AppColors.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDefinicion(BuildContext context, InfoEnfermedad info) {
    final color = AppColors.colorEnfermedad(info.claseId);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.fondoEnfermedad(info.claseId),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(info.nombreCientifico,
                  style: AppTheme.monoFont(fontSize: 11, color: color)
                      .copyWith(fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 12),
            Text(info.nombre,
                style: AppTheme.displayFont(
                    fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(info.descripcion,
                style: AppTheme.bodyFont(
                    fontSize: 14, color: AppColors.textoSecundario)),
            const SizedBox(height: 16),
            Text('SÍNTOMAS',
                style: AppTheme.monoFont(fontSize: 11).copyWith(letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(info.sintomas,
                style: AppTheme.bodyFont(
                    fontSize: 14, color: AppColors.textoPrimario)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EtiquetaValor extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _EtiquetaValor({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta.toUpperCase(),
            style: AppTheme.monoFont(fontSize: 11).copyWith(letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(valor,
            style: AppTheme.bodyFont(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
