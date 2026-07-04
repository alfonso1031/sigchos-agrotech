import 'package:flutter/material.dart';
import '../../core/constants/enfermedades.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Métricas reales de `classification_report` sobre el set de validación
/// (400 imágenes), obtenidas en el notebook de entrenamiento — ver
/// `mobile_app/tool/entrenar_modelo_colab.ipynb` celda 20.
const _accuracyGlobal = 0.83;
const _recallMacro = 0.83;

const _precisionPorClase = {
  'amarillamiento': 0.95,
  'hoja_sana': 0.86,
  'mancha_foliar': 0.66,
  'mildiu': 0.81,
  'oidio': 0.96,
};

const _recallPorClase = {
  'amarillamiento': 0.85,
  'hoja_sana': 0.84,
  'mancha_foliar': 0.86,
  'mildiu': 0.88,
  'oidio': 0.72,
};

const _clasesModelo = [
  'hoja_sana',
  'mancha_foliar',
  'mildiu',
  'oidio',
  'amarillamiento',
];

class ModeloIaView extends StatelessWidget {
  const ModeloIaView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            Expanded(child: _metric('Precisión (accuracy)', '${(_accuracyGlobal * 100).round()}%')),
            const SizedBox(width: 16),
            Expanded(child: _metric('Recall medio', '${(_recallMacro * 100).round()}%')),
            const SizedBox(width: 16),
            Expanded(child: _metric('Clases entrenadas', '${_clasesModelo.length} de 6')),
            const SizedBox(width: 16),
            Expanded(child: _metric('Tamaño modelo', '2.4 MB')),
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
                      Text('Precisión y recall por clase',
                          style: AppTheme.display(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        'Validación: 400 imágenes (classification_report, Colab).',
                        style: AppTheme.body(fontSize: 12, color: AppColors.textoSecundario),
                      ),
                      const SizedBox(height: 14),
                      for (final claseId in _clasesModelo)
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
                                  Text(
                                    'precisión ${((_precisionPorClase[claseId] ?? 0) * 100).round()}% '
                                    '· recall ${((_recallPorClase[claseId] ?? 0) * 100).round()}%',
                                    style: AppTheme.mono(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _recallPorClase[claseId] ?? 0,
                                  minHeight: 7,
                                  backgroundColor: AppColors.divider,
                                  valueColor:
                                      AlwaysStoppedAnimation(AppColors.colorEnfermedad(claseId)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: AppColors.textoDeshabilitado,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Daño por plaga (sin dataset — no soportada aún)',
                                style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
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
                          _fila('Arquitectura', 'MobileNetV2 (transfer learning)'),
                          _fila('Dataset', 'Pumpkin Leaf Diseases (Kaggle, Bangladesh)'),
                          _fila('Entrenamiento', 'Google Colab'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Estado', style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.sanoBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Modelo entrenado',
                                    style: AppTheme.body(
                                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.sano)),
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
                          Text('Pendiente',
                              style: AppTheme.display(
                                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(
                            'Falta clase "daño por plaga" (sin dataset público adecuado). '
                            'Precisión más baja en mancha foliar (66%) — confundida con mildiu '
                            'y oídio en la matriz de confusión, candidata a más datos.',
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
