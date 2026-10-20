import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/usuario.dart';

class UsuarioMapper {
  UsuarioMapper._();

  /// Converte o `User` do Firebase na entidade [Usuario] do domínio.
  static Usuario fromFirebase(User user) {
    final email = user.email ?? '';
    final nomeBase = (user.displayName ?? '').trim();
    final nome = nomeBase.isNotEmpty
        ? nomeBase
        : (email.contains('@') ? email.split('@').first : 'Usuário');

    final providerId =
        user.providerData.isNotEmpty ? user.providerData.first.providerId : 'password';

    return Usuario(
      uid: user.uid,
      nome: nome,
      email: email,
      foto: user.photoURL,
      provider: providerId == 'google.com' ? 'google' : 'password',
    );
  }

  /// Documento `usuarios/{uid}` do Firestore.
  static Map<String, dynamic> toMap(Usuario usuario) => {
        'nome': usuario.nome,
        'email': usuario.email,
        'foto': usuario.foto,
        'provider': usuario.provider,
      };
}
