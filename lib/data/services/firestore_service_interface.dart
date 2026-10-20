import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';

/// Acesso direto ao Firestore. É genérico (trabalha com coleções e mapas):
/// quem sabe o que cada coleção significa são os repositories.
abstract interface class IFirestoreService {
  /// Cria um documento com id gerado pelo Firestore e devolve o id.
  Future<Result<String, Failure>> adicionar(
      String colecao, Map<String, dynamic> dados);

  /// Grava (cria ou substitui) o documento com o id informado.
  Future<Result<void, Failure>> definir(
      String colecao, String id, Map<String, dynamic> dados);

  /// Atualiza um documento que já existe (erro se ele não existir).
  Future<Result<void, Failure>> atualizar(
      String colecao, String id, Map<String, dynamic> dados);

  /// Busca um documento. Erro [EmptyResultFailure] quando não existe.
  /// O mapa retornado inclui a chave `id` com o id do documento.
  Future<Result<Map<String, dynamic>, Failure>> buscarPorId(
      String colecao, String id);

  /// Lista os documentos da coleção (opcionalmente filtrando `campo == valor`).
  Future<Result<List<Map<String, dynamic>>, Failure>> listar(
    String colecao, {
    String? campo,
    Object? valor,
  });

  Future<Result<void, Failure>> remover(String colecao, String id);

  /// Remove todos os documentos em que `campo == valor`.
  Future<Result<void, Failure>> removerPorCampo(
      String colecao, String campo, Object valor);
}
