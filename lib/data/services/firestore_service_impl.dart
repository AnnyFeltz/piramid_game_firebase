import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import 'firestore_service_interface.dart';

/// Implementação de [IFirestoreService] com `cloud_firestore`.
final class FirestoreService implements IFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Limite de operações por batch do Firestore é 500; usamos folga.
  static const int _tamanhoLote = 400;

  @override
  Future<Result<String, Failure>> adicionar(
      String colecao, Map<String, dynamic> dados) async {
    try {
      final ref = await _db.collection(colecao).add(dados);
      return Success<String, Failure>(ref.id);
    } catch (e) {
      return _erro<String>('gravar em $colecao', e);
    }
  }

  @override
  Future<Result<void, Failure>> definir(
      String colecao, String id, Map<String, dynamic> dados) async {
    try {
      await _db.collection(colecao).doc(id).set(dados);
      return const Success<void, Failure>(null);
    } catch (e) {
      return _erro<void>('gravar em $colecao', e);
    }
  }

  @override
  Future<Result<void, Failure>> atualizar(
      String colecao, String id, Map<String, dynamic> dados) async {
    try {
      await _db.collection(colecao).doc(id).update(dados);
      return const Success<void, Failure>(null);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return Error<void, Failure>(
            EmptyResultFailure('Registro não encontrado.'));
      }
      return _erro<void>('atualizar em $colecao', e);
    } catch (e) {
      return _erro<void>('atualizar em $colecao', e);
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> buscarPorId(
      String colecao, String id) async {
    try {
      final snap = await _db.collection(colecao).doc(id).get();
      final dados = snap.data();
      if (!snap.exists || dados == null) {
        return Error<Map<String, dynamic>, Failure>(
            EmptyResultFailure('Registro não encontrado.'));
      }
      return Success<Map<String, dynamic>, Failure>({...dados, 'id': snap.id});
    } catch (e) {
      return _erro<Map<String, dynamic>>('buscar em $colecao', e);
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>, Failure>> listar(
    String colecao, {
    String? campo,
    Object? valor,
  }) async {
    try {
      Query<Map<String, dynamic>> consulta = _db.collection(colecao);
      if (campo != null) {
        consulta = consulta.where(campo, isEqualTo: valor);
      }
      final snap = await consulta.get();
      final lista = snap.docs
          .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
          .toList();
      return Success<List<Map<String, dynamic>>, Failure>(lista);
    } catch (e) {
      return _erro<List<Map<String, dynamic>>>('listar $colecao', e);
    }
  }

  @override
  Future<Result<void, Failure>> remover(String colecao, String id) async {
    try {
      await _db.collection(colecao).doc(id).delete();
      return const Success<void, Failure>(null);
    } catch (e) {
      return _erro<void>('remover de $colecao', e);
    }
  }

  @override
  Future<Result<void, Failure>> removerPorCampo(
      String colecao, String campo, Object valor) async {
    try {
      final snap =
          await _db.collection(colecao).where(campo, isEqualTo: valor).get();
      final docs = snap.docs;
      for (var i = 0; i < docs.length; i += _tamanhoLote) {
        final fim = (i + _tamanhoLote < docs.length) ? i + _tamanhoLote : docs.length;
        final batch = _db.batch();
        for (final doc in docs.sublist(i, fim)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
      return const Success<void, Failure>(null);
    } catch (e) {
      return _erro<void>('remover de $colecao', e);
    }
  }

  Result<T, Failure> _erro<T>(String acao, Object e) {
    if (e is FirebaseException && e.code == 'permission-denied') {
      return Error<T, Failure>(FirestoreFailure(
          'Sem permissão para $acao. Verifique as regras do Firestore.'));
    }
    if (e is FirebaseException && e.code == 'unavailable') {
      return Error<T, Failure>(FirestoreFailure(
          'Sem conexão com o servidor. Tente novamente.'));
    }
    return Error<T, Failure>(FirestoreFailure('Erro ao $acao: $e'));
  }
}
