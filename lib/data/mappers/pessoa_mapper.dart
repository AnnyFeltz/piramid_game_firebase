import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/pessoa.dart';

/// Converte [Pessoa] <-> documento da coleção `pessoas` do Firestore.
/// O id da pessoa é o id do documento (não é repetido dentro dele).
class PessoaMapper {
  PessoaMapper._();

  static Map<String, dynamic> toMap(Pessoa pessoa) => {
        'nome': pessoa.nome,
        'apelido': pessoa.apelido,
        'curso': pessoa.curso.name,
        'turma': pessoa.turmaAno,
        'dataNascimento': Timestamp.fromDate(pessoa.dataNascimento),
        'criadoPor': pessoa.criadoPor,
        'usuarioUid': pessoa.usuarioUid,
      };

  static Pessoa fromMap(Map<String, dynamic> map) => Pessoa(
        id: map['id'] as String,
        nome: map['nome'] as String? ?? '',
        apelido: map['apelido'] as String? ?? '',
        curso: Curso.values.byName(map['curso'] as String),
        turmaAno: (map['turma'] as num).toInt(),
        dataNascimento: toDateTime(map['dataNascimento']),
        criadoPor: map['criadoPor'] as String? ?? '',
        usuarioUid: map['usuarioUid'] as String?,
      );

  /// Lê datas vindas do Firestore (Timestamp) com tolerância a outros formatos.
  static DateTime toDateTime(Object? valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.parse(valor);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
