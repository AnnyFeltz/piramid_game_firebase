import '../../core/typedefs/types_defs.dart';

abstract interface class IAuthFacade {
  Future<UsuarioResult> criarConta(CredenciaisParams params);
  Future<UsuarioResult> login(CredenciaisParams params);
  Future<UsuarioResult> loginComGoogle(NoParams params);
  Future<UsuarioResult> verificarAutenticacao(NoParams params);
  Future<VoidResult> logout(NoParams params);
}
