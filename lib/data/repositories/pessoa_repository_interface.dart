import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa.dart';

abstract interface class IPessoaRepository {
  Future<PessoaResult> salvar(Pessoa pessoa);
  Future<PessoaResult> atualizar(Pessoa pessoa);
  Future<VoidResult> remover(String id);
  Future<ListPessoaResult> getTodas();
  Future<PessoaResult> getPorId(String id);

  /// Pessoa que representa o usuário autenticado (ou Success(null) se não há).
  Future<OptPessoaResult> getPorUsuarioUid(String usuarioUid);
}
