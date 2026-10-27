abstract interface class ILocalStorageService {
  bool? lerBool(String chave);
  Future<bool> salvarBool(String chave, bool valor);
  String? lerString(String chave);
  Future<bool> salvarString(String chave, String valor);
  Future<bool> remover(String chave);
}
