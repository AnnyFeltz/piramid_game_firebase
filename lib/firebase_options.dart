// ============================================================================
//  ARQUIVO MODELO (PLACEHOLDER) — substitua rodando o FlutterFire CLI:
//
//      dart pub global activate flutterfire_cli
//      flutterfire configure
//
//  O comando cria o projeto/apps no Firebase e SOBRESCREVE este arquivo com os
//  valores reais (apiKey, appId, projectId...). Enquanto isso não for feito,
//  o app mostra uma tela explicando que o Firebase não está configurado.
// ============================================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const String placeholder = 'SUBSTITUIR_COM_FLUTTERFIRE_CONFIGURE';

  /// true quando este arquivo ainda não foi gerado pelo `flutterfire configure`.
  static bool get naoConfigurado => currentPlatform.apiKey == placeholder;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'Firebase não está configurado para esta plataforma. '
          'Use Android, iOS, macOS ou Web.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: placeholder,
    appId: placeholder,
    messagingSenderId: placeholder,
    projectId: placeholder,
    authDomain: placeholder,
    storageBucket: placeholder,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: placeholder,
    appId: placeholder,
    messagingSenderId: placeholder,
    projectId: placeholder,
    storageBucket: placeholder,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: placeholder,
    appId: placeholder,
    messagingSenderId: placeholder,
    projectId: placeholder,
    storageBucket: placeholder,
    iosBundleId: 'com.example.piramidGame',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: placeholder,
    appId: placeholder,
    messagingSenderId: placeholder,
    projectId: placeholder,
    storageBucket: placeholder,
    iosBundleId: 'com.example.piramidGame',
  );
}
