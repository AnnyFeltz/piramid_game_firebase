import 'package:equatable/equatable.dart';

/// Usuário autenticado (conta no Firebase Authentication).
///
/// Não é o mesmo conceito de [Pessoa]: uma pessoa pode ser cadastrada para
/// receber avaliações sem ter conta, e um usuário só se relaciona a uma
/// pessoa quando marca "esta pessoa sou eu" no cadastro (ver Pessoa.usuarioUid).
class Usuario extends Equatable {
  final String uid;
  final String nome;
  final String email;
  final String? foto;
  final String provider; // 'password' ou 'google'

  const Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    this.foto,
    required this.provider,
  });

  @override
  List<Object?> get props => [uid, nome, email, foto, provider];
}
