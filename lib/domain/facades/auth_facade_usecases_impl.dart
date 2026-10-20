import '../../core/typedefs/types_defs.dart';
import '../usecases/auth_usecases_interfaces.dart';
import 'auth_facade_usecases_interface.dart';

final class AuthFacadeImpl implements IAuthFacade {
  final ICadastrarUsuarioUseCase _cadastrar;
  final IAutenticarUsuarioUseCase _autenticar;
  final IAutenticarComGoogleUseCase _autenticarGoogle;
  final IVerificarUsuarioAutenticadoUseCase _verificar;
  final ILogoutUseCase _logout;

  AuthFacadeImpl({
    required ICadastrarUsuarioUseCase cadastrarUsuarioUseCase,
    required IAutenticarUsuarioUseCase autenticarUsuarioUseCase,
    required IAutenticarComGoogleUseCase autenticarComGoogleUseCase,
    required IVerificarUsuarioAutenticadoUseCase verificarUsuarioAutenticadoUseCase,
    required ILogoutUseCase logoutUseCase,
  })  : _cadastrar = cadastrarUsuarioUseCase,
        _autenticar = autenticarUsuarioUseCase,
        _autenticarGoogle = autenticarComGoogleUseCase,
        _verificar = verificarUsuarioAutenticadoUseCase,
        _logout = logoutUseCase;

  @override Future<UsuarioResult> criarConta(CredenciaisParams p) => _cadastrar(p);
  @override Future<UsuarioResult> login(CredenciaisParams p) => _autenticar(p);
  @override Future<UsuarioResult> loginComGoogle(NoParams p) => _autenticarGoogle(p);
  @override Future<UsuarioResult> verificarAutenticacao(NoParams p) => _verificar(p);
  @override Future<VoidResult> logout(NoParams p) => _logout(p);
}
