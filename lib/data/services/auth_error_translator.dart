/// Traduz os códigos de erro do Firebase Authentication para mensagens
/// amigáveis em português (erros de autenticação são "informados ao usuário").
class AuthErrorTranslator {
  AuthErrorTranslator._();

  static String traduzir(String code) {
    switch (code) {
      case 'invalid-email':
        return 'O e-mail informado é inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Já existe uma conta com este e-mail.';
      case 'weak-password':
        return 'Senha fraca: use pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Este método de login não está habilitado no Firebase.';
      case 'network-request-failed':
        return 'Sem conexão com a internet. Tente novamente.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com este e-mail usando outro método de login.';
      case 'canceled':
      case 'cancelled':
      case 'popup-closed-by-user':
      case 'web-context-canceled':
      case 'cancelled-popup-request':
        return 'Login cancelado.';
      default:
        return 'Não foi possível autenticar ($code).';
    }
  }
}
