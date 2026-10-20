import '../../core/typedefs/types_defs.dart';

abstract interface class IRankingFacade {
  Future<RankingResult> gerarRankingPessoal(NoParams params);
  Future<RankingResult> gerarRankingGlobal(NoParams params);
}
