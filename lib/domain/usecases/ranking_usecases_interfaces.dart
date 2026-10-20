import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class ICalcularRankingPessoalUseCase
    implements IUseCase<RankingResult, NoParams> {}

abstract interface class ICalcularRankingGlobalUseCase
    implements IUseCase<RankingResult, NoParams> {}
