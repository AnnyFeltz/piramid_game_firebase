import '../../core/typedefs/types_defs.dart';

/// Login com conta Google integrado ao Firebase Authentication.
abstract interface class IGoogleAuthService {
  Future<UsuarioResult> entrarComGoogle();
}
