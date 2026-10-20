import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa.dart';
import '../mappers/pessoa_mapper.dart';
import '../services/firestore_service_interface.dart';
import 'pessoa_repository_interface.dart';

final class PessoaRepositoryImpl implements IPessoaRepository {
  static const String colecao = 'pessoas';

  final IFirestoreService _firestore;

  PessoaRepositoryImpl({required IFirestoreService firestoreService})
      : _firestore = firestoreService;

  @override
  Future<PessoaResult> salvar(Pessoa pessoa) async {
    final result = await _firestore.adicionar(colecao, PessoaMapper.toMap(pessoa));
    return result.fold(
      onSuccess: (id) => Success<Pessoa, Failure>(pessoa.copyWith(id: id)),
      onFailure: (f) => Error<Pessoa, Failure>(f),
    );
  }

  @override
  Future<PessoaResult> atualizar(Pessoa pessoa) async {
    final result =
        await _firestore.atualizar(colecao, pessoa.id, PessoaMapper.toMap(pessoa));
    return result.fold(
      onSuccess: (_) => Success<Pessoa, Failure>(pessoa),
      onFailure: (f) => Error<Pessoa, Failure>(f),
    );
  }

  @override
  Future<VoidResult> remover(String id) => _firestore.remover(colecao, id);

  @override
  Future<ListPessoaResult> getTodas() async {
    final result = await _firestore.listar(colecao);
    return result.fold(
      onSuccess: (docs) {
        final pessoas = docs.map(PessoaMapper.fromMap).toList()
          ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
        return Success<List<Pessoa>, Failure>(pessoas);
      },
      onFailure: (f) => Error<List<Pessoa>, Failure>(f),
    );
  }

  @override
  Future<PessoaResult> getPorId(String id) async {
    final result = await _firestore.buscarPorId(colecao, id);
    return result.fold(
      onSuccess: (doc) => Success<Pessoa, Failure>(PessoaMapper.fromMap(doc)),
      onFailure: (f) => Error<Pessoa, Failure>(f),
    );
  }

  @override
  Future<OptPessoaResult> getPorUsuarioUid(String usuarioUid) async {
    final result =
        await _firestore.listar(colecao, campo: 'usuarioUid', valor: usuarioUid);
    return result.fold(
      onSuccess: (docs) => Success<Pessoa?, Failure>(
          docs.isEmpty ? null : PessoaMapper.fromMap(docs.first)),
      onFailure: (f) => Error<Pessoa?, Failure>(f),
    );
  }
}
