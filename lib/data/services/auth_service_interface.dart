import '../../core/typedefs/types_defs.dart';

abstract interface class IAuthService {
  Future<UsuarioResult> cadastrarComEmailESenha(String email, String senha);
  Future<UsuarioResult> entrarComEmailESenha(String email, String senha);

  Future<UsuarioResult> verificarAutenticacao();

  UsuarioResult usuarioAtual();

  Future<VoidResult> sair();
}
