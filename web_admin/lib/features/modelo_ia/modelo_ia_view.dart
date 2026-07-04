import 'package:flutter/material.dart';
import '../../core/constants/enfermedades.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Métricas del modelo TFLite. No existe (todavía) un pipeline de
/// entrenamiento/evaluación conectado a Firestore, así que estos valores son
/// de referencia — reemplazar por datos reales cuando se entrene el modelo
/// definitivo (ver PLAN.md sección 8).
const _precisionPorClase = {
  'hoja_sana': 0.96,
  'mancha_foliar': 0.93,
  'mildiu': 0.90,
  'oidio': 0.88,
  'amarillamiento': 0.84,
  'dano_plaga': 0.89,
};

class ModeloIaView extends StatelessWidget {
  const ModeloIaView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            Expanded(child: _metric('Precisión (accuracy)', '92.4%')),
            const SizedBox(width: 16),
            Expanded(child: _metric('Recall medio', '89.1%')),
            const SizedBox(width: 16),
            Expanded(child: _metric('Latencia media', '1.4s')),
            const SizedBox(width: 16),
            Expanded(child: _metric('Tamaño modelo', '4.8MB')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Precisión por clase',
                          style: AppTheme.display(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 18),
                      for (final claseId in nombreEnfermedad.keys)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: AppColors.colorEnfermedad(claseId),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(nombreDe(claseId), style: AppTheme.body(fontSize: 13)),
                                    ],
                                  ),
                                  Text('${((_precisionPorClase[claseId] ?? 0) * 100).round()}%',
                                      style: AppTheme.mono(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _precisionPorClase[claseId] ?? 0,
                                  minHeight: 7,
                                  backgroundColor: AppColors.divider,
                                  valueColor:
                                      AlwaysStoppedAnimation(AppColors.colorEnfermedad(claseId)),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estado del despliegue',
                              style: AppTheme.display(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 14),
                          _fila('Versión', 'TFLite v1.0'),
                          _fila('Dataset', 'Teachable Machine'),
                          _fila('Entrenamiento', 'Pendiente de modelo real'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Estado', style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.severidadMediaBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('En simulación',
                                    style: AppTheme.body(
                                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.severidadMedia)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: AppColors.verdeSidebar,
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Modelo pendiente de entrenar',
                              style: AppTheme.display(
                                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(
                            'El clasificador funciona en modo simulado. Entrena el modelo con Teachable Machine y reemplaza assets/ml/model.tflite en la app móvil (ver PLAN.md sección 8).',
                            style: AppTheme.body(fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
          Text(valor, style: AppTheme.body(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _metric(String titulo, String valor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
            const SizedBox(height: 10),
            Text(valor, style: AppTheme.display(fontSize: 28, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
