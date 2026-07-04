const Map<String, String> nombreEnfermedad = {
  'hoja_sana': 'Hoja sana',
  'mancha_foliar': 'Mancha foliar',
  'mildiu': 'Mildiú',
  'oidio': 'Oídio',
  'amarillamiento': 'Amarillamiento',
  'dano_plaga': 'Daño por plaga',
};

String nombreDe(String claseId) => nombreEnfermedad[claseId] ?? claseId;
