import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/avaliacao_repository_interface.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import '../models/avaliacao.dart';
import '../models/criterios_popularidade.dart';
import '../models/usuario.dart';
import 'avaliacao_usecases_interfaces.dart';

final class VerificarAutoavaliacaoUseCaseImpl
    implements IVerificarAutoavaliacaoUseCase {
  final IAuthRepository _auth;
  final IPessoaRepository _pessoas;

  VerificarAutoavaliacaoUseCaseImpl({
    required IAuthRepository authRepository,
    required IPessoaRepository pessoaRepository,
  })  : _auth = authRepository,
        _pessoas = pessoaRepository;

  @override
  Future<BoolResult> call(PessoaIdParams params) async {
    final usuarioResult = await _auth.getUsuarioAtual();
    final usuario = usuarioResult.successValueOrNull;
    if (usuario == null) {
      return Error<bool, Failure>(
          usuarioResult.failureValueOrNull ?? AuthFailure());
    }

    final pessoaResult = await _pessoas.getPorId(params.id);
    final pessoa = pessoaResult.successValueOrNull;
    if (pessoa == null) {
      return Error<bool, Failure>(
          pessoaResult.failureValueOrNull ?? EmptyResultFailure());
    }

    // Autoavaliação = a pessoa avaliada está vinculada ao usuário autenticado.
    return Success<bool, Failure>(pessoa.usuarioUid == usuario.uid);
  }
}

/// Regras comuns a registrar e alterar uma avaliação (especificação, item 16):
/// usuário autenticado, notas de 1 a 5, pessoa existente e sem autoavaliação.
/// Devolve o usuário avaliador, ou a falha que impede a avaliação.
Future<Result<Usuario, Failure>> _validarRegrasDeAvaliacao({
  required IAuthRepository auth,
  required IVerificarAutoavaliacaoUseCase verificarAutoavaliacao,
  required AvaliarParams params,
}) async {
  final usuarioResult = await auth.getUsuarioAtual();
  final usuario = usuarioResult.successValueOrNull;
  if (usuario == null) {
    return Error<Usuario, Failure>(
        usuarioResult.failureValueOrNull ?? AuthFailure());
  }

  if (!params.criterios.notasValidas) {
    return Error<Usuario, Failure>(InputFailure(
        'As notas devem estar entre ${CriteriosPopularidade.notaMinima} e '
        '${CriteriosPopularidade.notaMaxima}.'));
  }

  final autoResult = await verificarAutoavaliacao((id: params.pessoaId));
  if (autoResult.isFailure) {
    return Error<Usuario, Failure>(
        autoResult.failureValueOrNull ?? DefaultFailure());
  }
  if (autoResult.successValueOrNull == true) {
    return Error<Usuario, Failure>(
        BusinessRuleFailure('Você não pode avaliar a si próprio.'));
  }

  return Success<Usuario, Failure>(usuario);
}

final class RegistrarAvaliacaoUseCaseImpl implements IRegistrarAvaliacaoUseCase {
  final IAuthRepository _auth;
  final IAvaliacaoRepository _avaliacoes;
  final IVerificarAutoavaliacaoUseCase _verificarAutoavaliacao;

  RegistrarAvaliacaoUseCaseImpl({
    required IAuthRepository authRepository,
    required IAvaliacaoRepository avaliacaoRepository,
    required IVerificarAutoavaliacaoUseCase verificarAutoavaliacaoUseCase,
  })  : _auth = authRepository,
        _avaliacoes = avaliacaoRepository,
        _verificarAutoavaliacao = verificarAutoavaliacaoUseCase;

  @override
  Future<AvaliacaoResult> call(AvaliarParams params) async {
    final regras = await _validarRegrasDeAvaliacao(
      auth: _auth,
      verificarAutoavaliacao: _verificarAutoavaliacao,
      params: params,
    );
    final usuario = regras.successValueOrNull;
    if (usuario == null) {
      return Error<Avaliacao, Failure>(
          regras.failureValueOrNull ?? DefaultFailure());
    }

    // Um usuário só tem uma avaliação ativa por pessoa.
    final existente = await _avaliacoes.getAvaliacao(usuario.uid, params.pessoaId);
    if (existente.isFailure) {
      return Error<Avaliacao, Failure>(
          existente.failureValueOrNull ?? DefaultFailure());
    }
    if (existente.successValueOrNull != null) {
      return Error<Avaliacao, Failure>(BusinessRuleFailure(
          'Você já avaliou esta pessoa. Altere a avaliação existente.'));
    }

    return _avaliacoes.salvar(Avaliacao(
      id: Avaliacao.montarId(usuario.uid, params.pessoaId),
      avaliadorUid: usuario.uid,
      pessoaId: params.pessoaId,
      criterios: params.criterios,
      dataAvaliacao: DateTime.now(),
    ));
  }
}

final class AlterarAvaliacaoUseCaseImpl implements IAlterarAvaliacaoUseCase {
  final IAuthRepository _auth;
  final IAvaliacaoRepository _avaliacoes;
  final IVerificarAutoavaliacaoUseCase _verificarAutoavaliacao;

  AlterarAvaliacaoUseCaseImpl({
    required IAuthRepository authRepository,
    required IAvaliacaoRepository avaliacaoRepository,
    required IVerificarAutoavaliacaoUseCase verificarAutoavaliacaoUseCase,
  })  : _auth = authRepository,
        _avaliacoes = avaliacaoRepository,
        _verificarAutoavaliacao = verificarAutoavaliacaoUseCase;

  @override
  Future<AvaliacaoResult> call(AvaliarParams params) async {
    final regras = await _validarRegrasDeAvaliacao(
      auth: _auth,
      verificarAutoavaliacao: _verificarAutoavaliacao,
      params: params,
    );
    final usuario = regras.successValueOrNull;
    if (usuario == null) {
      return Error<Avaliacao, Failure>(
          regras.failureValueOrNull ?? DefaultFailure());
    }

    final existente = await _avaliacoes.getAvaliacao(usuario.uid, params.pessoaId);
    if (existente.isFailure) {
      return Error<Avaliacao, Failure>(
          existente.failureValueOrNull ?? DefaultFailure());
    }
    if (existente.successValueOrNull == null) {
      return Error<Avaliacao, Failure>(BusinessRuleFailure(
          'Você ainda não avaliou esta pessoa. Registre uma avaliação primeiro.'));
    }

    // Mesmo id => substitui a avaliação (não cria outra).
    return _avaliacoes.salvar(Avaliacao(
      id: Avaliacao.montarId(usuario.uid, params.pessoaId),
      avaliadorUid: usuario.uid,
      pessoaId: params.pessoaId,
      criterios: params.criterios,
      dataAvaliacao: DateTime.now(),
    ));
  }
}

final class ConsultarAvaliacaoUseCaseImpl implements IConsultarAvaliacaoUseCase {
  final IAuthRepository _auth;
  final IAvaliacaoRepository _avaliacoes;

  ConsultarAvaliacaoUseCaseImpl({
    required IAuthRepository authRepository,
    required IAvaliacaoRepository avaliacaoRepository,
  })  : _auth = authRepository,
        _avaliacoes = avaliacaoRepository;

  @override
  Future<OptAvaliacaoResult> call(PessoaIdParams params) async {
    final usuarioResult = await _auth.getUsuarioAtual();
    final usuario = usuarioResult.successValueOrNull;
    if (usuario == null) {
      return Error<Avaliacao?, Failure>(
          usuarioResult.failureValueOrNull ?? AuthFailure());
    }
    return _avaliacoes.getAvaliacao(usuario.uid, params.id);
  }
}

final class BuscarAvaliacoesDoUsuarioUseCaseImpl
    implements IBuscarAvaliacoesDoUsuarioUseCase {
  final IAuthRepository _auth;
  final IAvaliacaoRepository _avaliacoes;

  BuscarAvaliacoesDoUsuarioUseCaseImpl({
    required IAuthRepository authRepository,
    required IAvaliacaoRepository avaliacaoRepository,
  })  : _auth = authRepository,
        _avaliacoes = avaliacaoRepository;

  @override
  Future<ListAvaliacaoResult> call(NoParams params) async {
    final usuarioResult = await _auth.getUsuarioAtual();
    final usuario = usuarioResult.successValueOrNull;
    if (usuario == null) {
      return Error<List<Avaliacao>, Failure>(
          usuarioResult.failureValueOrNull ?? AuthFailure());
    }
    return _avaliacoes.getPorUsuario(usuario.uid);
  }
}
