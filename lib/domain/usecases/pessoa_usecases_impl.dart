import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/avaliacao_repository_interface.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import '../models/pessoa.dart';
import '../models/usuario.dart';
import '../validators/pessoa_validator.dart';
import 'pessoa_usecases_interfaces.dart';

/// Vínculo "esta pessoa sou eu" (Pessoa.usuarioUid): só pode apontar para o
/// próprio usuário autenticado e cada usuário só pode ter UMA pessoa vinculada.
Future<Failure?> _validarVinculo(
  IPessoaRepository repository,
  Pessoa pessoa,
  Usuario usuario,
) async {
  final vinculo = pessoa.usuarioUid;
  if (vinculo == null) return null;

  if (vinculo != usuario.uid) {
    return BusinessRuleFailure(
        'Você só pode marcar a si mesmo como "esta pessoa sou eu".');
  }

  final existente = await repository.getPorUsuarioUid(usuario.uid);
  final outra = existente.successValueOrNull;
  if (existente.isFailure) return existente.failureValueOrNull;
  if (outra != null && outra.id != pessoa.id) {
    return BusinessRuleFailure(
        'Você já tem uma pessoa vinculada ao seu usuário (${outra.nome}).');
  }
  return null;
}

final class CadastrarPessoaUseCaseImpl implements ICadastrarPessoaUseCase {
  final IAuthRepository _auth;
  final IPessoaRepository _pessoas;

  CadastrarPessoaUseCaseImpl({
    required IAuthRepository authRepository,
    required IPessoaRepository pessoaRepository,
  })  : _auth = authRepository,
        _pessoas = pessoaRepository;

  @override
  Future<PessoaResult> call(PessoaParams params) async {
    final usuarioResult = await _auth.getUsuarioAtual();
    final usuario = usuarioResult.successValueOrNull;
    if (usuario == null) {
      return Error<Pessoa, Failure>(
          usuarioResult.failureValueOrNull ?? AuthFailure());
    }

    final erro = PessoaValidator.validar(params.pessoa);
    if (erro != null) return Error<Pessoa, Failure>(InputFailure(erro));

    final pessoa = params.pessoa.copyWith(criadoPor: usuario.uid);

    final falhaVinculo = await _validarVinculo(_pessoas, pessoa, usuario);
    if (falhaVinculo != null) return Error<Pessoa, Failure>(falhaVinculo);

    return _pessoas.salvar(pessoa);
  }
}

final class AlterarPessoaUseCaseImpl implements IAlterarPessoaUseCase {
  final IAuthRepository _auth;
  final IPessoaRepository _pessoas;

  AlterarPessoaUseCaseImpl({
    required IAuthRepository authRepository,
    required IPessoaRepository pessoaRepository,
  })  : _auth = authRepository,
        _pessoas = pessoaRepository;

  @override
  Future<PessoaResult> call(PessoaParams params) async {
    final usuarioResult = await _auth.getUsuarioAtual();
    final usuario = usuarioResult.successValueOrNull;
    if (usuario == null) {
      return Error<Pessoa, Failure>(
          usuarioResult.failureValueOrNull ?? AuthFailure());
    }

    final erro = PessoaValidator.validar(params.pessoa);
    if (erro != null) return Error<Pessoa, Failure>(InputFailure(erro));

    final atualResult = await _pessoas.getPorId(params.pessoa.id);
    final atual = atualResult.successValueOrNull;
    if (atual == null) {
      return Error<Pessoa, Failure>(
          atualResult.failureValueOrNull ?? EmptyResultFailure());
    }
    if (atual.criadoPor != usuario.uid) {
      return Error<Pessoa, Failure>(BusinessRuleFailure(
          'Só quem cadastrou a pessoa pode alterar os dados dela.'));
    }

    // criadoPor nunca muda numa alteração.
    final pessoa = params.pessoa.copyWith(criadoPor: atual.criadoPor);

    final falhaVinculo = await _validarVinculo(_pessoas, pessoa, usuario);
    if (falhaVinculo != null) return Error<Pessoa, Failure>(falhaVinculo);

    return _pessoas.atualizar(pessoa);
  }
}

final class RemoverPessoaUseCaseImpl implements IRemoverPessoaUseCase {
  final IAuthRepository _auth;
  final IPessoaRepository _pessoas;
  final IAvaliacaoRepository _avaliacoes;

  RemoverPessoaUseCaseImpl({
    required IAuthRepository authRepository,
    required IPessoaRepository pessoaRepository,
    required IAvaliacaoRepository avaliacaoRepository,
  })  : _auth = authRepository,
        _pessoas = pessoaRepository,
        _avaliacoes = avaliacaoRepository;

  @override
  Future<VoidResult> call(PessoaIdParams params) async {
    final usuarioResult = await _auth.getUsuarioAtual();
    final usuario = usuarioResult.successValueOrNull;
    if (usuario == null) {
      return Error<void, Failure>(
          usuarioResult.failureValueOrNull ?? AuthFailure());
    }

    final pessoaResult = await _pessoas.getPorId(params.id);
    final pessoa = pessoaResult.successValueOrNull;
    if (pessoa == null) {
      return Error<void, Failure>(
          pessoaResult.failureValueOrNull ?? EmptyResultFailure());
    }
    if (pessoa.criadoPor != usuario.uid) {
      return Error<void, Failure>(BusinessRuleFailure(
          'Só quem cadastrou a pessoa pode removê-la.'));
    }

    // Primeiro apaga as avaliações da pessoa (para não sobrarem avaliações
    // "órfãs" e bagunçarem o ranking global), depois a própria pessoa.
    final removidas = await _avaliacoes.removerPorPessoa(pessoa.id);
    if (removidas.isFailure) return removidas;

    return _pessoas.remover(pessoa.id);
  }
}

final class BuscarTodasPessoasUseCaseImpl implements IBuscarTodasPessoasUseCase {
  final IPessoaRepository _repository;
  BuscarTodasPessoasUseCaseImpl({required IPessoaRepository repository})
      : _repository = repository;

  @override
  Future<ListPessoaResult> call(NoParams params) => _repository.getTodas();
}

final class BuscarPessoaPorIdUseCaseImpl implements IBuscarPessoaPorIdUseCase {
  final IPessoaRepository _repository;
  BuscarPessoaPorIdUseCaseImpl({required IPessoaRepository repository})
      : _repository = repository;

  @override
  Future<PessoaResult> call(PessoaIdParams params) =>
      _repository.getPorId(params.id);
}
