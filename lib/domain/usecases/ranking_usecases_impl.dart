import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/avaliacao_repository_interface.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import '../models/avaliacao.dart';
import '../models/pessoa.dart';
import '../models/ranking_item.dart';
import 'ranking_usecases_interfaces.dart';

/// Ranking PESSOAL: usa exclusivamente as avaliações feitas pelo usuário
/// autenticado ("na minha opinião, quem tem o maior Nível Lenda?").
final class CalcularRankingPessoalUseCaseImpl
    implements ICalcularRankingPessoalUseCase {
  final IAuthRepository _auth;
  final IAvaliacaoRepository _avaliacoes;
  final IPessoaRepository _pessoas;

  CalcularRankingPessoalUseCaseImpl({
    required IAuthRepository authRepository,
    required IAvaliacaoRepository avaliacaoRepository,
    required IPessoaRepository pessoaRepository,
  })  : _auth = authRepository,
        _avaliacoes = avaliacaoRepository,
        _pessoas = pessoaRepository;

  @override
  Future<RankingResult> call(NoParams params) async {
    final usuarioResult = await _auth.getUsuarioAtual();
    final usuario = usuarioResult.successValueOrNull;
    if (usuario == null) {
      return Error<List<RankingItem>, Failure>(
          usuarioResult.failureValueOrNull ?? AuthFailure());
    }

    final avaliacoesResult = await _avaliacoes.getPorUsuario(usuario.uid);
    final avaliacoes = avaliacoesResult.successValueOrNull;
    if (avaliacoes == null) {
      return Error<List<RankingItem>, Failure>(
          avaliacoesResult.failureValueOrNull ?? DefaultFailure());
    }

    final pessoasResult = await _pessoas.getTodas();
    final pessoas = pessoasResult.successValueOrNull;
    if (pessoas == null) {
      return Error<List<RankingItem>, Failure>(
          pessoasResult.failureValueOrNull ?? DefaultFailure());
    }

    final porId = {for (final p in pessoas) p.id: p};
    final itens = <RankingItem>[];
    for (final avaliacao in avaliacoes) {
      final pessoa = porId[avaliacao.pessoaId];
      if (pessoa == null) continue; // pessoa removida
      itens.add(RankingItem(
        pessoa: pessoa,
        pontuacao: avaliacao.pontuacaoTotal.toDouble(),
        quantidadeAvaliacoes: 1,
      ));
    }

    itens.sort(_comparar);
    return Success<List<RankingItem>, Failure>(itens);
  }
}

/// Ranking GLOBAL: usa as avaliações de TODOS os usuários. A pontuação de cada
/// pessoa é a MÉDIA das avaliações recebidas (ex.: 60, 70 e 65 => 65 pontos).
final class CalcularRankingGlobalUseCaseImpl
    implements ICalcularRankingGlobalUseCase {
  final IAvaliacaoRepository _avaliacoes;
  final IPessoaRepository _pessoas;

  CalcularRankingGlobalUseCaseImpl({
    required IAvaliacaoRepository avaliacaoRepository,
    required IPessoaRepository pessoaRepository,
  })  : _avaliacoes = avaliacaoRepository,
        _pessoas = pessoaRepository;

  @override
  Future<RankingResult> call(NoParams params) async {
    final avaliacoesResult = await _avaliacoes.getTodas();
    final avaliacoes = avaliacoesResult.successValueOrNull;
    if (avaliacoes == null) {
      return Error<List<RankingItem>, Failure>(
          avaliacoesResult.failureValueOrNull ?? DefaultFailure());
    }

    final pessoasResult = await _pessoas.getTodas();
    final pessoas = pessoasResult.successValueOrNull;
    if (pessoas == null) {
      return Error<List<RankingItem>, Failure>(
          pessoasResult.failureValueOrNull ?? DefaultFailure());
    }

    // Agrupa as avaliações por pessoa avaliada.
    final porPessoa = <String, List<Avaliacao>>{};
    for (final avaliacao in avaliacoes) {
      porPessoa.putIfAbsent(avaliacao.pessoaId, () => <Avaliacao>[]).add(avaliacao);
    }

    final itens = <RankingItem>[];
    for (final Pessoa pessoa in pessoas) {
      final recebidas = porPessoa[pessoa.id];
      if (recebidas == null || recebidas.isEmpty) continue;
      final soma = recebidas.fold<int>(0, (s, a) => s + a.pontuacaoTotal);
      itens.add(RankingItem(
        pessoa: pessoa,
        pontuacao: soma / recebidas.length,
        quantidadeAvaliacoes: recebidas.length,
      ));
    }

    itens.sort(_comparar);
    return Success<List<RankingItem>, Failure>(itens);
  }
}

/// Maior pontuação primeiro; empate: mais avaliações primeiro; depois por nome.
int _comparar(RankingItem a, RankingItem b) {
  final porPontos = b.pontuacao.compareTo(a.pontuacao);
  if (porPontos != 0) return porPontos;
  final porQuantidade = b.quantidadeAvaliacoes.compareTo(a.quantidadeAvaliacoes);
  if (porQuantidade != 0) return porQuantidade;
  return a.pessoa.nome.toLowerCase().compareTo(b.pessoa.nome.toLowerCase());
}
