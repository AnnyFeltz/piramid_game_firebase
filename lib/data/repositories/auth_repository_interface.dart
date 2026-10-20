import '../../core/typedefs/types_defs.dart';

abstract interface class IAuthRepository {
  Future<UsuarioResult> cadastrar(String email, String senha);
  Future<UsuarioResult> entrar(String email, String senha);
  Future<UsuarioResult> entrarComGoogle();

  /// Aguarda a restauração da sessão (usado no Splash).
  Future<UsuarioResult> verificarAutenticacao();

  /// Usuário autenticado agora; erro [AuthFailure] se não houver.
  Future<UsuarioResult> getUsuarioAtual();

  Future<VoidResult> sair();
}
