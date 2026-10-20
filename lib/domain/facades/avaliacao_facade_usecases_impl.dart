import '../../core/typedefs/types_defs.dart';
import '../usecases/avaliacao_usecases_interfaces.dart';
import 'avaliacao_facade_usecases_interface.dart';

final class AvaliacaoFacadeImpl implements IAvaliacaoFacade {
  final IRegistrarAvaliacaoUseCase _registrar;
  final IAlterarAvaliacaoUseCase _alterar;
  final IConsultarAvaliacaoUseCase _consultar;
  final IBuscarAvaliacoesDoUsuarioUseCase _doUsuario;
  final IVerificarAutoavaliacaoUseCase _autoavaliacao;

  AvaliacaoFacadeImpl({
    required IRegistrarAvaliacaoUseCase registrarAvaliacaoUseCase,
    required IAlterarAvaliacaoUseCase alterarAvaliacaoUseCase,
    required IConsultarAvaliacaoUseCase consultarAvaliacaoUseCase,
    required IBuscarAvaliacoesDoUsuarioUseCase buscarAvaliacoesDoUsuarioUseCase,
    required IVerificarAutoavaliacaoUseCase verificarAutoavaliacaoUseCase,
  })  : _registrar = registrarAvaliacaoUseCase,
        _alterar = alterarAvaliacaoUseCase,
        _consultar = consultarAvaliacaoUseCase,
        _doUsuario = buscarAvaliacoesDoUsuarioUseCase,
        _autoavaliacao = verificarAutoavaliacaoUseCase;

  @override Future<AvaliacaoResult> avaliar(AvaliarParams p) => _registrar(p);
  @override Future<AvaliacaoResult> alterarAvaliacao(AvaliarParams p) => _alterar(p);
  @override Future<OptAvaliacaoResult> consultarAvaliacao(PessoaIdParams p) => _consultar(p);
  @override Future<ListAvaliacaoResult> carregarAvaliacoes(NoParams p) => _doUsuario(p);
  @override Future<BoolResult> verificarAutoavaliacao(PessoaIdParams p) => _autoavaliacao(p);
}
