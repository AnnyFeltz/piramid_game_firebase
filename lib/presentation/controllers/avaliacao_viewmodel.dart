import 'package:signals_flutter/signals_flutter.dart';

import '../../core/patterns/command.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/avaliacao_facade_usecases_interface.dart';
import '../../domain/models/avaliacao.dart';
import '../../domain/models/criterios_popularidade.dart';

class AvaliacaoViewModel {
  final IAvaliacaoFacade _facade;

  AvaliacaoViewModel({required IAvaliacaoFacade facade}) : _facade = facade;

  // ── Estado (Signals) ───────────────────────────────────────────────────────
  /// Avaliações feitas pelo usuário autenticado.
  final avaliacoes = signal<List<Avaliacao>>([]);
  final message = signal<String?>(null);

  /// Avaliações do usuário indexadas pelo id da pessoa avaliada.
  late final avaliacaoPorPessoa = computed(
      () => {for (final a in avaliacoes.value) a.pessoaId: a});

  // ── Commands ───────────────────────────────────────────────────────────────
  late final carregarAvaliacoesCommand =
      FunctionCommand<List<Avaliacao>, NoParams>(_facade.carregarAvaliacoes);
  late final consultarAvaliacaoCommand =
      FunctionCommand<Avaliacao?, PessoaIdParams>(_facade.consultarAvaliacao);
  late final avaliarPessoaCommand =
      FunctionCommand<Avaliacao, AvaliarParams>(_facade.avaliar);
  late final alterarAvaliacaoCommand =
      FunctionCommand<Avaliacao, AvaliarParams>(_facade.alterarAvaliacao);
  late final verificarAutoavaliacaoCommand =
      FunctionCommand<bool, PessoaIdParams>(_facade.verificarAutoavaliacao);

  // ── Ações chamadas pela UI ─────────────────────────────────────────────────
  Future<void> carregarAvaliacoes() async {
    final result = await carregarAvaliacoesCommand.executeWith(());
    result.fold<void>(
      onSuccess: (lista) {
        avaliacoes.value = lista;
        message.value = null;
      },
      onFailure: (f) => message.value = f.msg,
    );
  }

  /// Avaliação do usuário sobre a pessoa (null se ainda não avaliou).
  Future<Avaliacao?> consultarAvaliacao(String pessoaId) async {
    final result = await consultarAvaliacaoCommand.executeWith((id: pessoaId));
    return result.fold<Avaliacao?>(
      onSuccess: (a) => a,
      onFailure: (f) {
        message.value = f.msg;
        return null;
      },
    );
  }

  /// true quando a pessoa é o próprio usuário autenticado.
  Future<bool> verificarAutoavaliacao(String pessoaId) async {
    final result =
        await verificarAutoavaliacaoCommand.executeWith((id: pessoaId));
    return result.fold<bool>(
      onSuccess: (ehEle) => ehEle,
      onFailure: (f) {
        message.value = f.msg;
        return false;
      },
    );
  }

  /// Registra uma nova avaliação ou altera a existente ([alterando]).
  Future<bool> salvarAvaliacao({
    required String pessoaId,
    required CriteriosPopularidade criterios,
    required bool alterando,
  }) async {
    message.value = null;
    final params = (pessoaId: pessoaId, criterios: criterios);
    final result = alterando
        ? await alterarAvaliacaoCommand.executeWith(params)
        : await avaliarPessoaCommand.executeWith(params);

    return result.fold<bool>(
      onSuccess: (salva) {
        avaliacoes.value = [
          for (final a in avaliacoes.value)
            if (a.pessoaId != salva.pessoaId) a,
          salva,
        ];
        return true;
      },
      onFailure: (f) {
        message.value = f.msg;
        return false;
      },
    );
  }

  void limpar() {
    avaliacoes.value = [];
    message.value = null;
  }
}
