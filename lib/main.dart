import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'core/di/dependency_injection.dart';
import 'core/messages/app_messages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart' as app_theme;
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';
import 'presentation/views/firebase_nao_configurado_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase (Authentication + Firestore). Se não conseguir iniciar,
  //    mostramos uma tela explicando em vez de quebrar.
  final erroFirebase = await _iniciarFirebase();
  if (erroFirebase != null) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppMessages.appName,
      theme: app_theme.lightTheme,
      home: FirebaseNaoConfiguradoView(detalhe: erroFirebase),
    ));
    return;
  }

  // 2. SharedPreferences: somente armazenamento local AUXILIAR (tema).
  final prefs = await SharedPreferences.getInstance();

  // 3. Injeção de dependências (services → repositories → use cases → facades
  //    → viewmodels).
  setupDependencyInjection(prefs);

  // 4. Tema salvo na última utilização.
  await injector.get<ThemeController>().carregar();

  runApp(const MyApp());
}

/// Devolve null quando o Firebase iniciou, ou o motivo da falha.
Future<String?> _iniciarFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return null;
  } catch (e) {
    return 'Não foi possível iniciar o Firebase: $e';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = injector.get<ThemeController>();

    return Watch((_) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: AppMessages.appName,
          theme: app_theme.lightTheme,
          darkTheme: app_theme.darkTheme,
          themeMode: themeController.themeMode.value,
          routerConfig: AppRouter.router,
        ));
  }
}
