// Puebla la colección `recomendaciones` de Firestore con el contenido
// del prototipo (ver PLAN.md sección 7.8). Ejecutar una sola vez, después
// de `flutterfire configure`:
//
//   dart run tool/seed_recomendaciones.dart
//
// Requiere que `firebase_options.dart` ya tenga las credenciales reales
// (no el placeholder).
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/recomendaciones/data/datasources/recomendaciones_fallback.dart';
import 'package:mobile_app/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;
  final coleccion = firestore.collection('recomendaciones');

  var total = 0;
  for (final entrada in recomendacionesFallback.entries) {
    for (final rec in entrada.value) {
      await coleccion.add({
        'enfermedad': rec.enfermedad,
        'orden': rec.orden,
        'titulo': rec.titulo,
        'descripcion': rec.descripcion,
      });
      total++;
    }
  }
  // ignore: avoid_print
  print('Listo: $total recomendaciones creadas en Firestore.');
}
