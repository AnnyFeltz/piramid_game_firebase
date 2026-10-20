import 'package:flutter_test/flutter_test.dart';
import 'package:piramid_game/core/failure/failure.dart';
import 'package:piramid_game/core/patterns/command.dart';
import 'package:piramid_game/core/patterns/result.dart';
import 'package:piramid_game/core/typedefs/types_defs.dart';
import 'package:piramid_game/data/repositories/auth_repository_interface.dart';
import 'package:piramid_game/data/repositories/avaliacao_repository_interface.dart';
import 'package:piramid_game/data/repositories/pessoa_repository_interface.dart';
import 'package:piramid_game/domain/models/avaliacao.dart';
import 'package:piramid_game/domain/models/criterios_popularidade.dart';
import 'package:piramid_game/domain/models/pessoa.dart';
import 'package:piramid_game/domain/models/usuario.dart';
import 'package:piramid_game/domain/usecases/avaliacao_usecases_impl.dart';
import 'package:piramid_game/domain/usecases/pessoa_usecases_impl.dart';
import 'package:piramid_game/domain/usecases/ranking_usecases_impl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repositórios em memória (substituem o Firebase nos testes)
// ─────────────────────────────────────────────────────────────────────────────

class FakeAuthRepository implements IAuthRepository {
  Usuario? atual;
  FakeAuthRepository(this.atual);

  @override
  Future<UsuarioResult> getUsuarioAtual() async => atual == null
      ? Error<Usuario, Failure>(AuthFailure())
      : Success<Usuario, Failure>(atual!);

  @override
  Future<UsuarioResult> cadastrar(String email, String senha) =>
      throw UnimplementedError();
  @override
  Future<UsuarioResult> entrar(String email, String senha) =>
      throw UnimplementedError();
  @override
  Future<UsuarioResult> entrarComGoogle() => throw UnimplementedError();
  @override
  Future<UsuarioResult> verificarAutenticacao() => getUsuarioAtual();
  @override
  Future<VoidResult> sair() => throw UnimplementedError();
}

class FakePessoaRepository implements IPessoaRepository {
  final Map<String, Pessoa> dados = {};
  int _seq = 0;

  @override
  Future<PessoaResult> salvar(Pessoa pessoa) async {
    final nova = pessoa.copyWith(id: 'p${++_seq}');
    dados[nova.id] = nova;
    return Success<Pessoa, Failure>(nova);
  }

  @override
  Future<PessoaResult> atualizar(Pessoa pessoa) async {
    dados[pessoa.id] = pessoa;
    return Success<Pessoa, Failure>(pessoa);
  }

  @override
  Future<VoidResult> remover(String id) async {
    dados.remove(id);
    return const Success<void, Failure>(null);
  }

  @override
  Future<ListPessoaResult> getTodas() async =>
      Success<List<Pessoa>, Failure>(dados.values.toList());

  @override
  Future<PessoaResult> getPorId(String id) async {
    final p = dados[id];
    return p == null
        ? Error<Pessoa, Failure>(EmptyResultFailure())
        : Success<Pessoa, Failure>(p);
  }

  @override
  Future<OptPessoaResult> getPorUsuarioUid(String usuarioUid) async {
    final achadas = dados.values.where((p) => p.usuarioUid == usuarioUid);
    return Success<Pessoa?, Failure>(achadas.isEmpty ? null : achadas.first);
  }
}

class FakeAvaliacaoRepository implements IAvaliacaoRepository {
  final Map<String, Avaliacao> dados = {};

  @override
  Future<AvaliacaoResult> salvar(Avaliacao avaliacao) async {
    dados[avaliacao.id] = avaliacao; // mesmo id => substitui
    return Success<Avaliacao, Failure>(avaliacao);
  }

  @override
  Future<OptAvaliacaoResult> getAvaliacao(
          String avaliadorUid, String pessoaId) async =>
      Success<Avaliacao?, Failure>(
          dados[Avaliacao.montarId(avaliadorUid, pessoaId)]);

  @override
  Future<ListAvaliacaoResult> getPorUsuario(String avaliadorUid) async =>
      Success<List<Avaliacao>, Failure>(
          dados.values.where((a) => a.avaliadorUid == avaliadorUid).toList());

  @override
  Future<ListAvaliacaoResult> getTodas() async =>
      Success<List<Avaliacao>, Failure>(dados.values.toList());

  @override
  Future<VoidResult> removerPorPessoa(String pessoaId) async {
    dados.removeWhere((_, a) => a.pessoaId == pessoaId);
    return const Success<void, Failure>(null);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

const ana = Usuario(uid: 'ana', nome: 'Ana', email: 'ana@x.com', provider: 'password');
const beto = Usuario(uid: 'beto', nome: 'Beto', email: 'beto@x.com', provider: 'password');

Pessoa novaPessoa(String nome, {String criadoPor = 'ana', String? usuarioUid}) =>
    Pessoa(
      id: '',
      nome: nome,
      apelido: nome,
      curso: Curso.tads,
      turmaAno: 2024,
      dataNascimento: DateTime(2006, 5, 10),
      criadoPor: criadoPor,
      usuarioUid: usuarioUid,
    );

/// Critérios cuja soma é exatamente [total] (entre 15 e 75).
CriteriosPopularidade criteriosComTotal(int total) {
  var restante = total - CriteriosPopularidade.pontuacaoMinima;
  final mapa = <String, dynamic>{};
  for (final chave in const CriteriosPopularidade().toMap().keys) {
    final extra = restante > 4 ? 4 : restante;
    mapa[chave] = 1 + extra;
    restante -= extra;
  }
  return CriteriosPopularidade.fromMap(mapa);
}

Avaliacao avaliacao(String avaliador, String pessoaId, int total) => Avaliacao(
      id: Avaliacao.montarId(avaliador, pessoaId),
      avaliadorUid: avaliador,
      pessoaId: pessoaId,
      criterios: criteriosComTotal(total),
      dataAvaliacao: DateTime(2026, 10, 1),
    );

void main() {
  group('Pontuação (Nível Lenda)', () {
    test('mínimo 15 e máximo 75', () {
      expect(const CriteriosPopularidade().nivelLenda, 15);
      expect(criteriosComTotal(75).nivelLenda, 75);
    });

    test('exemplo da especificação (João Pedro) soma 58 pontos', () {
      const joao = CriteriosPopularidade(
        resenha: 4, presencaVip: 3, aura: 5, modoParceiro: 4,
        carismaNatural: 4, humorDeMilhoes: 5, energiaDeGrupo: 3,
        criatividadeCaotica: 4, modoAtleta: 5, talentoDePalco: 2,
        dripEscolar: 4, coracaoDeDorama: 3, queridinhoProfessores: 4,
        cerebroTurbo: 5, caosControlado: 3,
      );
      expect(joao.nivelLenda, 58);
    });

    test('notas fora de 1..5 são inválidas', () {
      expect(const CriteriosPopularidade(aura: 0).notasValidas, isFalse);
      expect(const CriteriosPopularidade(aura: 6).notasValidas, isFalse);
      expect(const CriteriosPopularidade(aura: 5).notasValidas, isTrue);
    });
  });

  group('Avaliação', () {
    late FakePessoaRepository pessoas;
    late FakeAvaliacaoRepository avaliacoes;
    late FakeAuthRepository auth;
    late RegistrarAvaliacaoUseCaseImpl registrar;
    late AlterarAvaliacaoUseCaseImpl alterar;

    setUp(() async {
      pessoas = FakePessoaRepository();
      avaliacoes = FakeAvaliacaoRepository();
      auth = FakeAuthRepository(ana);
      final verificar = VerificarAutoavaliacaoUseCaseImpl(
          authRepository: auth, pessoaRepository: pessoas);
      registrar = RegistrarAvaliacaoUseCaseImpl(
          authRepository: auth,
          avaliacaoRepository: avaliacoes,
          verificarAutoavaliacaoUseCase: verificar);
      alterar = AlterarAvaliacaoUseCaseImpl(
          authRepository: auth,
          avaliacaoRepository: avaliacoes,
          verificarAutoavaliacaoUseCase: verificar);
      // p1 = pessoa qualquer; p2 = a própria Ana (vinculada à conta dela)
      await pessoas.salvar(novaPessoa('Carla', criadoPor: 'beto'));
      await pessoas.salvar(novaPessoa('Ana', criadoPor: 'ana', usuarioUid: 'ana'));
    });

    test('usuário autenticado avalia outra pessoa', () async {
      final r = await registrar((pessoaId: 'p1', criterios: criteriosComTotal(60)));
      expect(r.isSuccess, isTrue);
      expect(r.successValueOrNull!.pontuacaoTotal, 60);
      expect(r.successValueOrNull!.avaliadorUid, 'ana');
      expect(r.successValueOrNull!.pessoaId, 'p1');
    });

    test('não pode avaliar a si próprio', () async {
      final r = await registrar((pessoaId: 'p2', criterios: criteriosComTotal(75)));
      expect(r.failureValueOrNull, isA<BusinessRuleFailure>());
      expect(avaliacoes.dados, isEmpty);
    });

    test('sem usuário autenticado não avalia', () async {
      auth.atual = null;
      final r = await registrar((pessoaId: 'p1', criterios: criteriosComTotal(60)));
      expect(r.failureValueOrNull, isA<AuthFailure>());
    });

    test('rejeita notas inválidas', () async {
      final r = await registrar(
          (pessoaId: 'p1', criterios: const CriteriosPopularidade(aura: 6)));
      expect(r.failureValueOrNull, isA<InputFailure>());
    });

    test('uma avaliação ativa por usuário + pessoa', () async {
      await registrar((pessoaId: 'p1', criterios: criteriosComTotal(60)));

      final duplicada =
          await registrar((pessoaId: 'p1', criterios: criteriosComTotal(70)));
      expect(duplicada.failureValueOrNull, isA<BusinessRuleFailure>());

      final alterada =
          await alterar((pessoaId: 'p1', criterios: criteriosComTotal(70)));
      expect(alterada.isSuccess, isTrue);
      expect(avaliacoes.dados.length, 1); // substituiu, não criou outra
      expect(avaliacoes.dados.values.single.pontuacaoTotal, 70);
    });

    test('não altera avaliação que ainda não existe', () async {
      final r = await alterar((pessoaId: 'p1', criterios: criteriosComTotal(70)));
      expect(r.failureValueOrNull, isA<BusinessRuleFailure>());
    });
  });

  group('Pessoa', () {
    late FakePessoaRepository pessoas;
    late FakeAvaliacaoRepository avaliacoes;
    late FakeAuthRepository auth;
    late CadastrarPessoaUseCaseImpl cadastrar;
    late AlterarPessoaUseCaseImpl alterar;
    late RemoverPessoaUseCaseImpl remover;

    setUp(() {
      pessoas = FakePessoaRepository();
      avaliacoes = FakeAvaliacaoRepository();
      auth = FakeAuthRepository(ana);
      cadastrar = CadastrarPessoaUseCaseImpl(
          authRepository: auth, pessoaRepository: pessoas);
      alterar = AlterarPessoaUseCaseImpl(
          authRepository: auth, pessoaRepository: pessoas);
      remover = RemoverPessoaUseCaseImpl(
          authRepository: auth,
          pessoaRepository: pessoas,
          avaliacaoRepository: avaliacoes);
    });

    test('cadastro grava quem cadastrou', () async {
      final r = await cadastrar((pessoa: novaPessoa('Carla', criadoPor: '')));
      expect(r.successValueOrNull!.criadoPor, 'ana');
    });

    test('turma/ano deve ficar entre 1998 e 2026', () async {
      final fora = Pessoa(
        id: '', nome: 'X', apelido: '', curso: Curso.info, turmaAno: 1997,
        dataNascimento: DateTime(2000), criadoPor: '',
      );
      final r = await cadastrar((pessoa: fora));
      expect(r.failureValueOrNull, isA<InputFailure>());
    });

    test('só vincula a pessoa a si mesmo e uma vez', () async {
      final deOutro = await cadastrar(
          (pessoa: novaPessoa('Fulano', criadoPor: '', usuarioUid: 'beto')));
      expect(deOutro.failureValueOrNull, isA<BusinessRuleFailure>());

      final eu = await cadastrar(
          (pessoa: novaPessoa('Ana', criadoPor: '', usuarioUid: 'ana')));
      expect(eu.isSuccess, isTrue);

      final outraVez = await cadastrar(
          (pessoa: novaPessoa('Ana 2', criadoPor: '', usuarioUid: 'ana')));
      expect(outraVez.failureValueOrNull, isA<BusinessRuleFailure>());
    });

    test('só quem cadastrou altera e remove', () async {
      final criada =
          (await cadastrar((pessoa: novaPessoa('Carla', criadoPor: '')))).successValueOrNull!;

      auth.atual = beto; // outro usuário
      final alteracao = await alterar((pessoa: criada));
      expect(alteracao.failureValueOrNull, isA<BusinessRuleFailure>());
      final remocao = await remover((id: criada.id));
      expect(remocao.failureValueOrNull, isA<BusinessRuleFailure>());
      expect(pessoas.dados.containsKey(criada.id), isTrue);

      auth.atual = ana; // dono
      expect((await remover((id: criada.id))).isSuccess, isTrue);
      expect(pessoas.dados, isEmpty);
    });

    test('remover pessoa apaga as avaliações dela', () async {
      final criada =
          (await cadastrar((pessoa: novaPessoa('Carla', criadoPor: '')))).successValueOrNull!;
      await avaliacoes.salvar(avaliacao('beto', criada.id, 50));
      await remover((id: criada.id));
      expect(avaliacoes.dados, isEmpty);
    });
  });

  group('Rankings', () {
    late FakePessoaRepository pessoas;
    late FakeAvaliacaoRepository avaliacoes;
    late FakeAuthRepository auth;
    late CalcularRankingPessoalUseCaseImpl pessoal;
    late CalcularRankingGlobalUseCaseImpl global;

    setUp(() async {
      pessoas = FakePessoaRepository();
      avaliacoes = FakeAvaliacaoRepository();
      auth = FakeAuthRepository(ana);
      pessoal = CalcularRankingPessoalUseCaseImpl(
          authRepository: auth,
          avaliacaoRepository: avaliacoes,
          pessoaRepository: pessoas);
      global = CalcularRankingGlobalUseCaseImpl(
          avaliacaoRepository: avaliacoes, pessoaRepository: pessoas);
      await pessoas.salvar(novaPessoa('Ana Clara')); // p1
      await pessoas.salvar(novaPessoa('João Pedro')); // p2
      await pessoas.salvar(novaPessoa('Maria Eduarda')); // p3
    });

    test('pessoal: só as avaliações do usuário autenticado, da maior para a menor',
        () async {
      await avaliacoes.salvar(avaliacao('ana', 'p1', 68));
      await avaliacoes.salvar(avaliacao('ana', 'p2', 58));
      await avaliacoes.salvar(avaliacao('ana', 'p3', 54));
      await avaliacoes.salvar(avaliacao('beto', 'p3', 75)); // não interfere

      final itens = (await pessoal(())).successValueOrNull!;
      expect(itens.map((i) => i.pessoa.nome),
          ['Ana Clara', 'João Pedro', 'Maria Eduarda']);
      expect(itens.map((i) => i.pontuacao), [68, 58, 54]);
    });

    test('global: média das avaliações recebidas (60, 70 e 65 => 65)', () async {
      await avaliacoes.salvar(avaliacao('u1', 'p1', 60));
      await avaliacoes.salvar(avaliacao('u2', 'p1', 70));
      await avaliacoes.salvar(avaliacao('u3', 'p1', 65));

      final itens = (await global(())).successValueOrNull!;
      expect(itens.single.pontuacao, 65);
      expect(itens.single.quantidadeAvaliacoes, 3);
    });

    test('global: ordena da maior média para a menor e ignora quem não foi avaliado',
        () async {
      await avaliacoes.salvar(avaliacao('u1', 'p1', 50));
      await avaliacoes.salvar(avaliacao('u1', 'p2', 70));

      final itens = (await global(())).successValueOrNull!;
      expect(itens.map((i) => i.pessoa.nome), ['João Pedro', 'Ana Clara']);
    });
  });

  group('Command', () {
    test('duplo toque executa a ação uma única vez', () async {
      var execucoes = 0;
      final comando = FunctionCommand<int, int>((p) async {
        execucoes++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return Success<int, Failure>(p);
      });

      final a = comando.executeWith(1);
      final b = comando.executeWith(1);
      await Future.wait([a, b]);

      expect(execucoes, 1);
      expect(comando.isExecuting.value, isFalse);
    });

    test('parâmetros diferentes não misturam resultados', () async {
      final comando = FunctionCommand<int, int>((p) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return Success<int, Failure>(p);
      });

      final a = await Future.wait([comando.executeWith(1), comando.executeWith(2)]);
      expect(a.map((r) => r.successValueOrNull), [1, 2]);
    });
  });
}
