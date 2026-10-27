import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';

abstract interface class IFirestoreService {
  Future<Result<String, Failure>> adicionar(
      String colecao, Map<String, dynamic> dados);

  Future<Result<void, Failure>> definir(
      String colecao, String id, Map<String, dynamic> dados);

  Future<Result<void, Failure>> atualizar(
      String colecao, String id, Map<String, dynamic> dados);

  Future<Result<Map<String, dynamic>, Failure>> buscarPorId(
      String colecao, String id);

  Future<Result<List<Map<String, dynamic>>, Failure>> listar(
    String colecao, {
    String? campo,
    Object? valor,
  });

  Future<Result<void, Failure>> remover(String colecao, String id);

  Future<Result<void, Failure>> removerPorCampo(
      String colecao, String campo, Object valor);
}
