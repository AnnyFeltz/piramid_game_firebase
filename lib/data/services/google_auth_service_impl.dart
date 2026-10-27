import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';
import '../mappers/usuario_mapper.dart';
import 'auth_error_translator.dart';
import 'google_auth_service_interface.dart';

final class GoogleAuthService implements IGoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UsuarioResult> entrarComGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      final UserCredential cred = kIsWeb
          ? await _auth.signInWithPopup(provider)
          : await _auth.signInWithProvider(provider);

      final user = cred.user;
      if (user == null) {
        return Error<Usuario, Failure>(
            AuthFailure('Não foi possível entrar com o Google.'));
      }
      return Success<Usuario, Failure>(UsuarioMapper.fromFirebase(user));
    } on FirebaseAuthException catch (e) {
      return Error<Usuario, Failure>(
          AuthFailure(AuthErrorTranslator.traduzir(e.code)));
    } catch (e) {
      return Error<Usuario, Failure>(
          AuthFailure('Erro ao entrar com o Google: $e'));
    }
  }
}
