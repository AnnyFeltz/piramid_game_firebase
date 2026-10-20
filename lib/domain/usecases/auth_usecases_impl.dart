import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../models/usuario.dart';
import 'auth_usecases_interfaces.dart';

/// Regras mínimas de credenciais, antes de chamar o Firebase.
Failure? _validarCredenciais(CredenciaisParams p, {required bool novaConta}) {
  final email = p.email.trim();
  if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
    return InputFailure('Informe um e-mail válido.');
  }
  if (p.senha.isEmpty) return InputFailure('Informe a senha.');
  if (novaConta && p.senha.length < 6) {
    return InputFailure('A senha deve ter pelo menos 6 caracteres.');
  }
  return null;
}

final class CadastrarUsuarioUseCaseImpl implements ICadastrarUsuarioUseCase {
  final IAuthRepository _repository;
  CadastrarUsuarioUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<UsuarioResult> call(CredenciaisParams params) async {
    final erro = _validarCredenciais(params, novaConta: true);
    if (erro != null) return Error<Usuario, Failure>(erro);
    return _repository.cadastrar(params.email, params.senha);
  }
}

final class AutenticarUsuarioUseCaseImpl implements IAutenticarUsuarioUseCase {
  final IAuthRepository _repository;
  AutenticarUsuarioUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<UsuarioResult> call(CredenciaisParams params) async {
    final erro = _validarCredenciais(params, novaConta: false);
    if (erro != null) return Error<Usuario, Failure>(erro);
    return _repository.entrar(params.email, params.senha);
  }
}

final class AutenticarComGoogleUseCaseImpl
    implements IAutenticarComGoogleUseCase {
  final IAuthRepository _repository;
  AutenticarComGoogleUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<UsuarioResult> call(NoParams params) => _repository.entrarComGoogle();
}

final class VerificarUsuarioAutenticadoUseCaseImpl
    implements IVerificarUsuarioAutenticadoUseCase {
  final IAuthRepository _repository;
  VerificarUsuarioAutenticadoUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<UsuarioResult> call(NoParams params) =>
      _repository.verificarAutenticacao();
}

final class LogoutUseCaseImpl implements ILogoutUseCase {
  final IAuthRepository _repository;
  LogoutUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<VoidResult> call(NoParams params) => _repository.sair();
}
