import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/facades/preference_facade_usecases_interface.dart';

/// Controla o tema claro/escuro em tempo de execução. A escolha é salva no
/// SharedPreferences (via PreferenceFacade → use cases → repository → service)
/// para ser lembrada na próxima vez que o app abrir.
class ThemeController {
  final IPreferenceFacade _facade;

  ThemeController({required IPreferenceFacade facade}) : _facade = facade;

  final themeMode = signal<ThemeMode>(ThemeMode.light);
  late final isLightMode = computed(() => themeMode.value == ThemeMode.light);

  /// Lê a preferência salva. Chamado uma vez no `main`, antes do `runApp`.
  Future<void> carregar() async {
    final result = await _facade.carregarTema(());
    final escuro = result.successValueOrNull ?? false;
    themeMode.value = escuro ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final escuro = themeMode.value == ThemeMode.light;
    themeMode.value = escuro ? ThemeMode.dark : ThemeMode.light;
    // Persistência "melhor esforço": se falhar, o tema continua trocado.
    _facade.alterarTema((escuro: escuro));
  }
}
