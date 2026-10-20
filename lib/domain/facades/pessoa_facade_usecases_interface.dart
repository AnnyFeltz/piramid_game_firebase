import '../../core/typedefs/types_defs.dart';

abstract interface class IPessoaFacade {
  Future<PessoaResult> cadastrar(PessoaParams params);
  Future<PessoaResult> buscar(PessoaIdParams params);
  Future<ListPessoaResult> listar(NoParams params);
  Future<PessoaResult> alterar(PessoaParams params);
  Future<VoidResult> remover(PessoaIdParams params);
}
