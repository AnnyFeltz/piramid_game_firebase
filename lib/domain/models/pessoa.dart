import 'package:equatable/equatable.dart';

enum Curso {
  info,
  mec,
  mamb,
  prod,
  tads,
  tga;

  String get displayName {
    switch (this) {
      case Curso.info: return 'INFO';
      case Curso.mec:  return 'MEC';
      case Curso.mamb: return 'MAMB';
      case Curso.prod: return 'PROD';
      case Curso.tads: return 'TADS';
      case Curso.tga:  return 'TGA';
    }
  }
}

/// Pessoa cadastrada para receber avaliações (antes chamada de `Aluno`).
///
/// A pessoa NÃO carrega mais as notas: elas ficam em [Avaliacao], pois agora
/// cada usuário avalia a pessoa separadamente.
class Pessoa extends Equatable {
  /// Mínimo e máximo permitidos para o campo turma/ano (especificação, item 8.2).
  static const int turmaMinima = 1998;
  static const int turmaMaxima = 2026;

  final String id;
  final String nome;
  final String apelido;
  final Curso curso;
  final int turmaAno;
  final DateTime dataNascimento;

  /// uid do usuário que cadastrou a pessoa (só ele pode alterar/remover).
  final String criadoPor;

  /// uid do usuário autenticado que É esta pessoa (opcional). É esta relação
  /// que permite impedir a autoavaliação.
  final String? usuarioUid;

  const Pessoa({
    required this.id,
    required this.nome,
    required this.apelido,
    required this.curso,
    required this.turmaAno,
    required this.dataNascimento,
    required this.criadoPor,
    this.usuarioUid,
  });

  Pessoa copyWith({String? id, String? criadoPor}) {
    return Pessoa(
      id: id ?? this.id,
      nome: nome,
      apelido: apelido,
      curso: curso,
      turmaAno: turmaAno,
      dataNascimento: dataNascimento,
      criadoPor: criadoPor ?? this.criadoPor,
      usuarioUid: usuarioUid,
    );
  }

  @override
  List<Object?> get props =>
      [id, nome, apelido, curso, turmaAno, dataNascimento, criadoPor, usuarioUid];
}
