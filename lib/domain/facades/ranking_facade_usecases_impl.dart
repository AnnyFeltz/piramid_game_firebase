import '../../core/typedefs/types_defs.dart';
import '../usecases/ranking_usecases_interfaces.dart';
import 'ranking_facade_usecases_interface.dart';

final class RankingFacadeImpl implements IRankingFacade {
  final ICalcularRankingPessoalUseCase _pessoal;
  final ICalcularRankingGlobalUseCase _global;

  RankingFacadeImpl({
    required ICalcularRankingPessoalUseCase calcularRankingPessoalUseCase,
    required ICalcularRankingGlobalUseCase calcularRankingGlobalUseCase,
  })  : _pessoal = calcularRankingPessoalUseCase,
        _global = calcularRankingGlobalUseCase;

  @override Future<RankingResult> gerarRankingPessoal(NoParams p) => _pessoal(p);
  @override Future<RankingResult> gerarRankingGlobal(NoParams p) => _global(p);
}
