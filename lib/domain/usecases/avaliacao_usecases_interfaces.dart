import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class IRegistrarAvaliacaoUseCase
    implements IUseCase<AvaliacaoResult, AvaliarParams> {}

abstract interface class IAlterarAvaliacaoUseCase
    implements IUseCase<AvaliacaoResult, AvaliarParams> {}

abstract interface class IConsultarAvaliacaoUseCase
    implements IUseCase<OptAvaliacaoResult, PessoaIdParams> {}

abstract interface class IBuscarAvaliacoesDoUsuarioUseCase
    implements IUseCase<ListAvaliacaoResult, NoParams> {}

/// Success(true) quando a pessoa informada é o próprio usuário autenticado.
abstract interface class IVerificarAutoavaliacaoUseCase
    implements IUseCase<BoolResult, PessoaIdParams> {}
