/// Metadatos estáticos de las 6 clases del clasificador — nombres para UI.
/// El contenido de recomendaciones vive en Firestore (`recomendaciones`).
class InfoEnfermedad {
  final String claseId;
  final String nombre;
  final String nombreCientifico;
  final String descripcion;
  final String sintomas;

  const InfoEnfermedad(
    this.claseId,
    this.nombre,
    this.nombreCientifico, {
    this.descripcion = '',
    this.sintomas = '',
  });
}

const Map<String, InfoEnfermedad> catalogoEnfermedades = {
  'hoja_sana': InfoEnfermedad(
    'hoja_sana',
    'Hoja sana',
    'Sin patógeno detectado',
    descripcion:
        'La hoja no presenta signos de enfermedad ni de daño por plaga. El tejido está vigoroso y de color uniforme.',
    sintomas: 'Color verde uniforme, sin manchas, polvo ni perforaciones.',
  ),
  'mancha_foliar': InfoEnfermedad(
    'mancha_foliar',
    'Mancha foliar',
    'Cercospora citrullina',
    descripcion:
        'Enfermedad fúngica que produce lesiones circulares en las hojas. Con humedad alta se propaga rápido y reduce la superficie fotosintética.',
    sintomas:
        'Manchas circulares marrones o grises con borde definido, a veces con halo amarillo.',
  ),
  'mildiu': InfoEnfermedad(
    'mildiu',
    'Mildiú',
    'Pseudoperonospora cubensis',
    descripcion:
        'Mildiú velloso, causado por un oomiceto. Muy agresivo en condiciones húmedas y frescas; puede defoliar la planta en pocos días.',
    sintomas:
        'Manchas angulares amarillas en el haz y un moho grisáceo en el envés de la hoja.',
  ),
  'oidio': InfoEnfermedad(
    'oidio',
    'Oídio',
    'Podosphaera xanthii',
    descripcion:
        'Oídio o "ceniza", hongo que cubre la hoja con un polvo blanco. Se favorece con follaje tierno y poca ventilación.',
    sintomas:
        'Polvo blanco harinoso sobre el haz y envés; las hojas se amarillean y secan.',
  ),
  'amarillamiento': InfoEnfermedad(
    'amarillamiento',
    'Amarillamiento',
    'Deficiencia / virosis',
    descripcion:
        'Puede deberse a deficiencia nutricional (nitrógeno, hierro) o a una virosis transmitida por insectos como la mosca blanca.',
    sintomas:
        'Hojas amarillentas de forma general o entre las nervaduras; a veces mosaico o deformación.',
  ),
  'dano_plaga': InfoEnfermedad(
    'dano_plaga',
    'Daño por plaga',
    'Diabrotica sp.',
    descripcion:
        'Daño mecánico causado por insectos que se alimentan de la hoja. Reduce el área foliar y abre puertas a infecciones.',
    sintomas: 'Perforaciones, hojas comidas por los bordes y presencia de insectos.',
  ),
};

InfoEnfermedad infoDe(String claseId) =>
    catalogoEnfermedades[claseId] ??
    const InfoEnfermedad('desconocido', 'Desconocido', '');

String severidadLabel(String claseId) {
  switch (claseId) {
    case 'hoja_sana':
      return 'Sin daño detectado';
    case 'mancha_foliar':
    case 'mildiu':
      return 'Severidad alta';
    default:
      return 'Severidad media';
  }
}
