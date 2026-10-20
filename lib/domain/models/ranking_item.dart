import 'package:equatable/equatable.dart';
import 'pessoa.dart';

/// Uma linha de ranking.
///
/// - Ranking pessoal: [pontuacao] é a nota que o usuário deu e
///   [quantidadeAvaliacoes] é sempre 1.
/// - Ranking global: [pontuacao] é a MÉDIA das avaliações recebidas e
///   [quantidadeAvaliacoes] diz de quantos usuários vieram.
class RankingItem extends Equatable {
  final Pessoa pessoa;
  final double pontuacao;
  final int quantidadeAvaliacoes;

  const RankingItem({
    required this.pessoa,
    required this.pontuacao,
    required this.quantidadeAvaliacoes,
  });

  @override
  List<Object?> get props => [pessoa, pontuacao, quantidadeAvaliacoes];
}
