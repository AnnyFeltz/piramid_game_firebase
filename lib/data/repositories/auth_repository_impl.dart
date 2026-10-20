import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario.dart';
import '../mappers/usuario_mapper.dart';
import '../services/auth_service_interface.dart';
import '../services/firestore_service_interface.dart';
import '../services/google_auth_service_interface.dart';
import 'auth_repository_interface.dart';

final class AuthRepositoryImpl implements IAuthRepository {
  static const String _colecaoUsuarios = 'usuarios';

  final IAuthService _authService;
  final IGoogleAuthService _googleAuthService;
  final IFirestoreService _firestoreService;

  AuthRepositoryImpl({
    required IAuthService authService,
    required IGoogleAuthService googleAuthService,
    required IFirestoreService firestoreService,
  })  : _authService = authService,
        _googleAuthService = googleAuthService,
        _firestoreService = firestoreService;

  @override
  Future<UsuarioResult> cadastrar(String email, String senha) async {
    final result = await _authService.cadastrarComEmailESenha(email, senha);
    return _salvarPerfilSeSucesso(result);
  }

  @override
  Future<UsuarioResult> entrar(String email, String senha) async {
    final result = await _authService.entrarComEmailESenha(email, senha);
    return _salvarPerfilSeSucesso(result);
  }

  @override
  Future<UsuarioResult> entrarComGoogle() async {
    final result = await _googleAuthService.entrarComGoogle();
    return _salvarPerfilSeSucesso(result);
  }

  @override
  Future<UsuarioResult> verificarAutenticacao() =>
      _authService.verificarAutenticacao();

  @override
  Future<UsuarioResult> getUsuarioAtual() async => _authService.usuarioAtual();

  @override
  Future<VoidResult> sair() => _authService.sair();

  /// Grava/atualiza o perfil em `usuarios/{uid}` (nome, email, foto, provider).
  /// É "melhor esforço": se a gravação do perfil falhar, o login continua
  /// valendo, pois a autenticação é responsabilidade do Firebase Authentication.
  Future<UsuarioResult> _salvarPerfilSeSucesso(UsuarioResult result) async {
    final Usuario? usuario = result.successValueOrNull;
    if (usuario != null) {
      await _firestoreService.definir(
        _colecaoUsuarios,
        usuario.uid,
        UsuarioMapper.toMap(usuario),
      );
    }
    return result;
  }
}
