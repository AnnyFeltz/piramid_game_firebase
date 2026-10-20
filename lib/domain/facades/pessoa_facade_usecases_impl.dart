import '../../core/typedefs/types_defs.dart';
import '../usecases/pessoa_usecases_interfaces.dart';
import 'pessoa_facade_usecases_interface.dart';

final class PessoaFacadeImpl implements IPessoaFacade {
  final ICadastrarPessoaUseCase _cadastrar;
  final IBuscarPessoaPorIdUseCase _buscar;
  final IBuscarTodasPessoasUseCase _listar;
  final IAlterarPessoaUseCase _alterar;
  final IRemoverPessoaUseCase _remover;

  PessoaFacadeImpl({
    required ICadastrarPessoaUseCase cadastrarPessoaUseCase,
    required IBuscarPessoaPorIdUseCase buscarPessoaPorIdUseCase,
    required IBuscarTodasPessoasUseCase buscarTodasPessoasUseCase,
    required IAlterarPessoaUseCase alterarPessoaUseCase,
    required IRemoverPessoaUseCase removerPessoaUseCase,
  })  : _cadastrar = cadastrarPessoaUseCase,
        _buscar = buscarPessoaPorIdUseCase,
        _listar = buscarTodasPessoasUseCase,
        _alterar = alterarPessoaUseCase,
        _remover = removerPessoaUseCase;

  @override Future<PessoaResult> cadastrar(PessoaParams p) => _cadastrar(p);
  @override Future<PessoaResult> buscar(PessoaIdParams p) => _buscar(p);
  @override Future<ListPessoaResult> listar(NoParams p) => _listar(p);
  @override Future<PessoaResult> alterar(PessoaParams p) => _alterar(p);
  @override Future<VoidResult> remover(PessoaIdParams p) => _remover(p);
}
