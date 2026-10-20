import 'package:equatable/equatable.dart';

/// As 15 notas (1 a 5 estrelas) de uma avaliação.
///
/// Os nomes dos campos seguem a estrutura sugerida para o Firestore na
/// especificação (resenha, presencaVip, aura, modoParceiro, carismaNatural...).
class CriteriosPopularidade extends Equatable {
  static const int quantidade = 15;
  static const int notaMinima = 1;
  static const int notaMaxima = 5;
  static const int pontuacaoMinima = quantidade * notaMinima; // 15
  static const int pontuacaoMaxima = quantidade * notaMaxima; // 75

  final int resenha;
  final int presencaVip;
  final int aura;
  final int modoParceiro;
  final int carismaNatural;
  final int humorDeMilhoes;
  final int energiaDeGrupo;
  final int criatividadeCaotica;
  final int modoAtleta;
  final int talentoDePalco;
  final int dripEscolar;
  final int coracaoDeDorama;
  final int queridinhoProfessores;
  final int cerebroTurbo;
  final int caosControlado;

  const CriteriosPopularidade({
    this.resenha = 1,
    this.presencaVip = 1,
    this.aura = 1,
    this.modoParceiro = 1,
    this.carismaNatural = 1,
    this.humorDeMilhoes = 1,
    this.energiaDeGrupo = 1,
    this.criatividadeCaotica = 1,
    this.modoAtleta = 1,
    this.talentoDePalco = 1,
    this.dripEscolar = 1,
    this.coracaoDeDorama = 1,
    this.queridinhoProfessores = 1,
    this.cerebroTurbo = 1,
    this.caosControlado = 1,
  });

  /// Todas as notas em lista (útil para validar e somar).
  List<int> get notas => [
        resenha, presencaVip, aura, modoParceiro, carismaNatural,
        humorDeMilhoes, energiaDeGrupo, criatividadeCaotica, modoAtleta,
        talentoDePalco, dripEscolar, coracaoDeDorama, queridinhoProfessores,
        cerebroTurbo, caosControlado,
      ];

  /// Pontuação total (Nível Lenda): soma das 15 notas, de 15 a 75.
  int get nivelLenda => notas.fold(0, (soma, nota) => soma + nota);

  /// true quando todas as notas estão entre 1 e 5.
  bool get notasValidas =>
      notas.every((n) => n >= notaMinima && n <= notaMaxima);

  Map<String, dynamic> toMap() => {
    'resenha': resenha,
    'presencaVip': presencaVip,
    'aura': aura,
    'modoParceiro': modoParceiro,
    'carismaNatural': carismaNatural,
    'humorDeMilhoes': humorDeMilhoes,
    'energiaDeGrupo': energiaDeGrupo,
    'criatividadeCaotica': criatividadeCaotica,
    'modoAtleta': modoAtleta,
    'talentoDePalco': talentoDePalco,
    'dripEscolar': dripEscolar,
    'coracaoDeDorama': coracaoDeDorama,
    'queridinhoProfessores': queridinhoProfessores,
    'cerebroTurbo': cerebroTurbo,
    'caosControlado': caosControlado,
  };

  factory CriteriosPopularidade.fromMap(Map<String, dynamic> map) {
    int nota(String chave) => (map[chave] as num?)?.toInt() ?? 1;
    return CriteriosPopularidade(
      resenha: nota('resenha'),
      presencaVip: nota('presencaVip'),
      aura: nota('aura'),
      modoParceiro: nota('modoParceiro'),
      carismaNatural: nota('carismaNatural'),
      humorDeMilhoes: nota('humorDeMilhoes'),
      energiaDeGrupo: nota('energiaDeGrupo'),
      criatividadeCaotica: nota('criatividadeCaotica'),
      modoAtleta: nota('modoAtleta'),
      talentoDePalco: nota('talentoDePalco'),
      dripEscolar: nota('dripEscolar'),
      coracaoDeDorama: nota('coracaoDeDorama'),
      queridinhoProfessores: nota('queridinhoProfessores'),
      cerebroTurbo: nota('cerebroTurbo'),
      caosControlado: nota('caosControlado'),
    );
  }

  @override
  List<Object?> get props => notas;
}
