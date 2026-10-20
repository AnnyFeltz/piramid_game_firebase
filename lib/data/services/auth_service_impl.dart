import 'package:firebase_auth/firebase_auth.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';
import '../mappers/usuario_mapper.dart';
import 'auth_error_translator.dart';
import 'auth_service_interface.dart';

/// Implementação de [IAuthService] com Firebase Authentication.
final class AuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UsuarioResult> cadastrarComEmailESenha(
      String email, String senha) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      return _toResult(cred.user);
    } on FirebaseAuthException catch (e) {
      return Error<Usuario, Failure>(
          AuthFailure(AuthErrorTranslator.traduzir(e.code)));
    } catch (e) {
      return Error<Usuario, Failure>(AuthFailure('Erro ao criar conta: $e'));
    }
  }

  @override
  Future<UsuarioResult> entrarComEmailESenha(
      String email, String senha) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      return _toResult(cred.user);
    } on FirebaseAuthException catch (e) {
      return Error<Usuario, Failure>(
          AuthFailure(AuthErrorTranslator.traduzir(e.code)));
    } catch (e) {
      return Error<Usuario, Failure>(AuthFailure('Erro ao entrar: $e'));
    }
  }

  @override
  Future<UsuarioResult> verificarAutenticacao() async {
    try {
      // O primeiro evento de authStateChanges já traz a sessão restaurada
      // (ou null, se ninguém estiver autenticado).
      final user = await _auth.authStateChanges().first;
      return _toResult(user);
    } catch (e) {
      return Error<Usuario, Failure>(
          AuthFailure('Erro ao verificar autenticação: $e'));
    }
  }

  @override
  UsuarioResult usuarioAtual() => _toResult(_auth.currentUser);

  @override
  Future<VoidResult> sair() async {
    try {
      await _auth.signOut();
      return const Success<void, Failure>(null);
    } catch (e) {
      return Error<void, Failure>(AuthFailure('Erro ao sair: $e'));
    }
  }

  UsuarioResult _toResult(User? user) {
    if (user == null) {
      return Error<Usuario, Failure>(
          AuthFailure('Nenhum usuário autenticado.'));
    }
    return Success<Usuario, Failure>(UsuarioMapper.fromFirebase(user));
  }
}
