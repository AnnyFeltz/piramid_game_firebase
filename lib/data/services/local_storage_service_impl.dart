import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_service_interface.dart';

final class LocalStorageService implements ILocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  bool? lerBool(String chave) => _prefs.getBool(chave);

  @override
  Future<bool> salvarBool(String chave, bool valor) =>
      _prefs.setBool(chave, valor);

  @override
  String? lerString(String chave) => _prefs.getString(chave);

  @override
  Future<bool> salvarString(String chave, String valor) =>
      _prefs.setString(chave, valor);

  @override
  Future<bool> remover(String chave) => _prefs.remove(chave);
}
