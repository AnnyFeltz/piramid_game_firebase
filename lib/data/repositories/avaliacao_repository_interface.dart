import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao.dart';

abstract interface class IAvaliacaoRepository {
  /// Grava a avaliação. O id é `avaliadorUid_pessoaId`, então gravar de novo
  /// substitui a avaliação anterior (nunca existem duas do mesmo par).
  Future<AvaliacaoResult> salvar(Avaliacao avaliacao);

  /// Avaliação de [avaliadorUid] sobre [pessoaId] (Success(null) se não existe).
  Future<OptAvaliacaoResult> getAvaliacao(String avaliadorUid, String pessoaId);

  Future<ListAvaliacaoResult> getPorUsuario(String avaliadorUid);
  Future<ListAvaliacaoResult> getTodas();
  Future<VoidResult> removerPorPessoa(String pessoaId);
}
