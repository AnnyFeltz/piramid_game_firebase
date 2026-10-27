import '../../core/typedefs/types_defs.dart';

abstract interface class IGoogleAuthService {
  Future<UsuarioResult> entrarComGoogle();
}
