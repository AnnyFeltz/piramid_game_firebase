import 'package:equatable/equatable.dart';
import 'criterios_popularidade.dart';

/// Avaliação que um usuário fez de uma pessoa.
///
/// Regra: um usuário só pode ter UMA avaliação ativa por pessoa. Por isso o id
/// do documento no Firestore é determinístico (`avaliadorUid_pessoaId`): gravar
/// de novo com o mesmo id substitui a avaliação em vez de criar outra.
class Avaliacao extends Equatable {
  final String id;
  final String avaliadorUid;
  final String pessoaId;
  final CriteriosPopularidade criterios;
  final DateTime dataAvaliacao;

  const Avaliacao({
    required this.id,
    required this.avaliadorUid,
    required this.pessoaId,
    required this.criterios,
    required this.dataAvaliacao,
  });

  /// Pontuação total calculada automaticamente a partir das 15 notas.
  int get pontuacaoTotal => criterios.nivelLenda;

  static String montarId(String avaliadorUid, String pessoaId) =>
      '${avaliadorUid}_$pessoaId';

  @override
  List<Object?> get props =>
      [id, avaliadorUid, pessoaId, criterios, dataAvaliacao];
}
