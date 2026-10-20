import '../../core/typedefs/types_defs.dart';

/// Acesso direto ao Firebase Authentication (e-mail e senha).
abstract interface class IAuthService {
  Future<UsuarioResult> cadastrarComEmailESenha(String email, String senha);
  Future<UsuarioResult> entrarComEmailESenha(String email, String senha);

  /// Espera o Firebase restaurar a sessão salva e devolve o usuário (ou erro
  /// quando não há ninguém autenticado). Usado na tela de Splash.
  Future<UsuarioResult> verificarAutenticacao();

  /// Usuário autenticado neste instante (erro quando não há).
  UsuarioResult usuarioAtual();

  Future<VoidResult> sair();
}
