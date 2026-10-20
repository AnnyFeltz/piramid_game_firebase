import 'package:signals_flutter/signals_flutter.dart';

import '../../core/patterns/command.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/ranking_facade_usecases_interface.dart';
import '../../domain/models/ranking_item.dart';

class RankingViewModel {
  final IRankingFacade _facade;

  RankingViewModel({required IRankingFacade facade}) : _facade = facade;

  // ── Estado (Signals) ───────────────────────────────────────────────────────
  final rankingPessoal = signal<List<RankingItem>>([]);
  final rankingGlobal = signal<List<RankingItem>>([]);
  final message = signal<String?>(null);

  // ── Commands ───────────────────────────────────────────────────────────────
  late final carregarRankingPessoalCommand =
      FunctionCommand<List<RankingItem>, NoParams>(_facade.gerarRankingPessoal);
  late final carregarRankingGlobalCommand =
      FunctionCommand<List<RankingItem>, NoParams>(_facade.gerarRankingGlobal);

  // ── Ações chamadas pela UI ─────────────────────────────────────────────────
  Future<void> carregarRankingPessoal() async {
    final result = await carregarRankingPessoalCommand.executeWith(());
    result.fold<void>(
      onSuccess: (lista) {
        rankingPessoal.value = lista;
        message.value = null;
      },
      onFailure: (f) => message.value = f.msg,
    );
  }

  Future<void> carregarRankingGlobal() async {
    final result = await carregarRankingGlobalCommand.executeWith(());
    result.fold<void>(
      onSuccess: (lista) {
        rankingGlobal.value = lista;
        message.value = null;
      },
      onFailure: (f) => message.value = f.msg,
    );
  }

  void limpar() {
    rankingPessoal.value = [];
    rankingGlobal.value = [];
    message.value = null;
  }
}
