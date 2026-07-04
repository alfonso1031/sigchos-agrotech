// PLACEHOLDER — reemplazado automáticamente al correr:
//   flutterfire configure --project=<id-proyecto-AgroTech>
// Ver PLAN.md sección 7.3 / 11. No editar a mano.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'web_admin solo corre en Flutter Web — corre `flutterfire configure`.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCnqVbJ-O2fMq8nzKx7f_OjSuGzBY_uKFs',
    appId: '1:246186140382:web:45f8890382c36b1606984f',
    messagingSenderId: '246186140382',
    projectId: 'agrotech-19ec5',
    authDomain: 'agrotech-19ec5.firebaseapp.com',
    storageBucket: 'agrotech-19ec5.firebasestorage.app',
    measurementId: 'G-CYXW09P3MT',
  );
}
