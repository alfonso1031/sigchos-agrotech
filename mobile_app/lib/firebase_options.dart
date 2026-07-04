// PLACEHOLDER — reemplazado automáticamente al correr:
//   flutterfire configure --project=<id-proyecto-AgroTech>
// Ver PLAN.md sección 7.3. No editar a mano.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma — '
          'corre `flutterfire configure`.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: 'PLACEHOLDER',
    messagingSenderId: 'PLACEHOLDER',
    projectId: 'PLACEHOLDER',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0fyaugtxhan3kWcIOFrTMp2_2gsDsIH8',
    appId: '1:246186140382:android:8a1ca161319159f906984f',
    messagingSenderId: '246186140382',
    projectId: 'agrotech-19ec5',
    storageBucket: 'agrotech-19ec5.firebasestorage.app',
  );
}
