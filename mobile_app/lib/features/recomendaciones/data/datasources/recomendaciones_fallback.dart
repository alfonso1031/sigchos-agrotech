import '../../domain/entities/recomendacion_entity.dart';

/// Contenido de respaldo (idéntico al prototipo Claude Design) que se usa
/// mientras la colección `recomendaciones` de Firestore no ha sido poblada
/// — ver PLAN.md sección 7.8 para el seed real.
final Map<String, List<RecomendacionEntity>> recomendacionesFallback = {
  'mancha_foliar': [
    const RecomendacionEntity(id: 'f1', enfermedad: 'mancha_foliar', orden: 1, titulo: 'Retira hojas afectadas', descripcion: 'Elimina y destruye las hojas con manchas para reducir el inóculo del hongo.'),
    const RecomendacionEntity(id: 'f2', enfermedad: 'mancha_foliar', orden: 2, titulo: 'Aplica fungicida foliar', descripcion: 'Usa clorotalonil o mancozeb siguiendo la dosis recomendada.'),
    const RecomendacionEntity(id: 'f3', enfermedad: 'mancha_foliar', orden: 3, titulo: 'Mejora la ventilación', descripcion: 'Reduce la densidad de siembra para bajar la humedad del follaje.'),
    const RecomendacionEntity(id: 'f4', enfermedad: 'mancha_foliar', orden: 4, titulo: 'Riega al pie', descripcion: 'Evita mojar las hojas; el agua libre favorece la enfermedad.'),
  ],
  'mildiu': [
    const RecomendacionEntity(id: 'f1', enfermedad: 'mildiu', orden: 1, titulo: 'Aísla los focos', descripcion: 'Marca y elimina las hojas con mildiú visible en el envés.'),
    const RecomendacionEntity(id: 'f2', enfermedad: 'mildiu', orden: 2, titulo: 'Fungicida sistémico', descripcion: 'Aplica metalaxil + mancozeb de forma preventiva.'),
    const RecomendacionEntity(id: 'f3', enfermedad: 'mildiu', orden: 3, titulo: 'Baja la humedad', descripcion: 'Mejora el drenaje y la ventilación entre plantas.'),
    const RecomendacionEntity(id: 'f4', enfermedad: 'mildiu', orden: 4, titulo: 'Monitorea el envés', descripcion: 'Revisa la cara inferior de las hojas cada 2–3 días.'),
  ],
  'oidio': [
    const RecomendacionEntity(id: 'f1', enfermedad: 'oidio', orden: 1, titulo: 'Poda hojas cubiertas', descripcion: 'Retira las hojas con polvo blanco abundante.'),
    const RecomendacionEntity(id: 'f2', enfermedad: 'oidio', orden: 2, titulo: 'Azufre mojable', descripcion: 'Aplica azufre o bicarbonato en horas frescas del día.'),
    const RecomendacionEntity(id: 'f3', enfermedad: 'oidio', orden: 3, titulo: 'Evita exceso de nitrógeno', descripcion: 'El follaje muy tierno es más susceptible al oídio.'),
    const RecomendacionEntity(id: 'f4', enfermedad: 'oidio', orden: 4, titulo: 'Mejora la luz', descripcion: 'Aumenta la exposición solar de la planta.'),
  ],
  'amarillamiento': [
    const RecomendacionEntity(id: 'f1', enfermedad: 'amarillamiento', orden: 1, titulo: 'Analiza el suelo', descripcion: 'Verifica deficiencia de nitrógeno o hierro.'),
    const RecomendacionEntity(id: 'f2', enfermedad: 'amarillamiento', orden: 2, titulo: 'Fertiliza dirigido', descripcion: 'Aplica el nutriente faltante según el análisis.'),
    const RecomendacionEntity(id: 'f3', enfermedad: 'amarillamiento', orden: 3, titulo: 'Controla vectores', descripcion: 'Maneja mosca blanca y áfidos si hay sospecha de virus.'),
    const RecomendacionEntity(id: 'f4', enfermedad: 'amarillamiento', orden: 4, titulo: 'Elimina plantas virosas', descripcion: 'Retira las plantas con síntomas severos.'),
  ],
  'dano_plaga': [
    const RecomendacionEntity(id: 'f1', enfermedad: 'dano_plaga', orden: 1, titulo: 'Identifica la plaga', descripcion: 'Revisa el haz y el envés en busca de insectos.'),
    const RecomendacionEntity(id: 'f2', enfermedad: 'dano_plaga', orden: 2, titulo: 'Control biológico', descripcion: 'Favorece enemigos naturales cuando sea posible.'),
    const RecomendacionEntity(id: 'f3', enfermedad: 'dano_plaga', orden: 3, titulo: 'Insecticida selectivo', descripcion: 'Aplica solo si supera el umbral de daño económico.'),
    const RecomendacionEntity(id: 'f4', enfermedad: 'dano_plaga', orden: 4, titulo: 'Trampas cromáticas', descripcion: 'Coloca trampas amarillas para monitorear adultos.'),
  ],
  'hoja_sana': [
    const RecomendacionEntity(id: 'f1', enfermedad: 'hoja_sana', orden: 1, titulo: 'Mantén el monitoreo', descripcion: 'Revisa las hojas cada 3–4 días para detección temprana.'),
    const RecomendacionEntity(id: 'f2', enfermedad: 'hoja_sana', orden: 2, titulo: 'Riega al pie', descripcion: 'Conserva el follaje seco para prevenir hongos.'),
    const RecomendacionEntity(id: 'f3', enfermedad: 'hoja_sana', orden: 3, titulo: 'Nutrición balanceada', descripcion: 'Asegura nitrógeno y potasio para hojas vigorosas.'),
    const RecomendacionEntity(id: 'f4', enfermedad: 'hoja_sana', orden: 4, titulo: 'Parcela limpia', descripcion: 'Mantén el contorno libre de malezas hospederas.'),
  ],
};
