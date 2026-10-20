import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao.dart';
import '../mappers/avaliacao_mapper.dart';
import '../services/firestore_service_interface.dart';
import 'avaliacao_repository_interface.dart';

final class AvaliacaoRepositoryImpl implements IAvaliacaoRepository {
  static const String colecao = 'avaliacoes';

  final IFirestoreService _firestore;

  AvaliacaoRepositoryImpl({required IFirestoreService firestoreService})
      : _firestore = firestoreService;

  @override
  Future<AvaliacaoResult> salvar(Avaliacao avaliacao) async {
    final result = await _firestore.definir(
        colecao, avaliacao.id, AvaliacaoMapper.toMap(avaliacao));
    return result.fold(
      onSuccess: (_) => Success<Avaliacao, Failure>(avaliacao),
      onFailure: (f) => Error<Avaliacao, Failure>(f),
    );
  }

  @override
  Future<OptAvaliacaoResult> getAvaliacao(
      String avaliadorUid, String pessoaId) async {
    final result = await _firestore.buscarPorId(
        colecao, Avaliacao.montarId(avaliadorUid, pessoaId));
    // "Não encontrada" não é erro aqui: significa que o usuário ainda não avaliou.
    if (result.failureValueOrNull is EmptyResultFailure) {
      return const Success<Avaliacao?, Failure>(null);
    }
    return result.fold(
      onSuccess: (doc) =>
          Success<Avaliacao?, Failure>(AvaliacaoMapper.fromMap(doc)),
      onFailure: (f) => Error<Avaliacao?, Failure>(f),
    );
  }

  @override
  Future<ListAvaliacaoResult> getPorUsuario(String avaliadorUid) async {
    final result = await _firestore.listar(colecao,
        campo: 'avaliadorUid', valor: avaliadorUid);
    return _toList(result);
  }

  @override
  Future<ListAvaliacaoResult> getTodas() async {
    final result = await _firestore.listar(colecao);
    return _toList(result);
  }

  @override
  Future<VoidResult> removerPorPessoa(String pessoaId) =>
      _firestore.removerPorCampo(colecao, 'pessoaId', pessoaId);

  ListAvaliacaoResult _toList(
      Result<List<Map<String, dynamic>>, Failure> result) {
    return result.fold(
      onSuccess: (docs) => Success<List<Avaliacao>, Failure>(
          docs.map(AvaliacaoMapper.fromMap).toList()),
      onFailure: (f) => Error<List<Avaliacao>, Failure>(f),
    );
  }
}
