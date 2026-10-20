import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class ICadastrarPessoaUseCase
    implements IUseCase<PessoaResult, PessoaParams> {}

abstract interface class IAlterarPessoaUseCase
    implements IUseCase<PessoaResult, PessoaParams> {}

abstract interface class IRemoverPessoaUseCase
    implements IUseCase<VoidResult, PessoaIdParams> {}

abstract interface class IBuscarTodasPessoasUseCase
    implements IUseCase<ListPessoaResult, NoParams> {}

abstract interface class IBuscarPessoaPorIdUseCase
    implements IUseCase<PessoaResult, PessoaIdParams> {}
