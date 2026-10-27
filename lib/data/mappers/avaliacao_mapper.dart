import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/avaliacao.dart';
import '../../domain/models/criterios_popularidade.dart';
import 'pessoa_mapper.dart';

class AvaliacaoMapper {
  AvaliacaoMapper._();

  static Map<String, dynamic> toMap(Avaliacao avaliacao) => {
        'avaliadorUid': avaliacao.avaliadorUid,
        'pessoaId': avaliacao.pessoaId,
        ...avaliacao.criterios.toMap(),
        'pontuacaoTotal': avaliacao.pontuacaoTotal,
        'dataAvaliacao': Timestamp.fromDate(avaliacao.dataAvaliacao),
      };

  static Avaliacao fromMap(Map<String, dynamic> map) => Avaliacao(
        id: map['id'] as String,
        avaliadorUid: map['avaliadorUid'] as String,
        pessoaId: map['pessoaId'] as String,
        criterios: CriteriosPopularidade.fromMap(map),
        dataAvaliacao: PessoaMapper.toDateTime(map['dataAvaliacao']),
      );
}
