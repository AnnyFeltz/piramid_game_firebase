import '../../core/typedefs/types_defs.dart';

abstract interface class IAvaliacaoFacade {
  Future<AvaliacaoResult> avaliar(AvaliarParams params);
  Future<AvaliacaoResult> alterarAvaliacao(AvaliarParams params);
  Future<OptAvaliacaoResult> consultarAvaliacao(PessoaIdParams params);
  Future<ListAvaliacaoResult> carregarAvaliacoes(NoParams params);
  Future<BoolResult> verificarAutoavaliacao(PessoaIdParams params);
}
