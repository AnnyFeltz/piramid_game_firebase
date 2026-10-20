import 'package:signals_flutter/signals_flutter.dart';

import '../../core/patterns/command.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/pessoa_facade_usecases_interface.dart';
import '../../domain/models/pessoa.dart';

class PessoaViewModel {
  final IPessoaFacade _facade;

  PessoaViewModel({required IPessoaFacade facade}) : _facade = facade;

  // ── Estado (Signals) ───────────────────────────────────────────────────────
  final pessoas = signal<List<Pessoa>>([]);
  final message = signal<String?>(null);

  /// false até a primeira carga terminar (evita piscar "lista vazia").
  final carregado = signal<bool>(false);

  // ── Commands ───────────────────────────────────────────────────────────────
  late final carregarPessoasCommand =
      FunctionCommand<List<Pessoa>, NoParams>(_facade.listar);
  late final cadastrarPessoaCommand =
      FunctionCommand<Pessoa, PessoaParams>(_facade.cadastrar);
  late final alterarPessoaCommand =
      FunctionCommand<Pessoa, PessoaParams>(_facade.alterar);
  late final removerPessoaCommand =
      FunctionCommand<void, PessoaIdParams>(_facade.remover);

  // ── Ações chamadas pela UI ─────────────────────────────────────────────────
  Future<void> carregarPessoas() async {
    final result = await carregarPessoasCommand.executeWith(());
    result.fold<void>(
      onSuccess: (lista) {
        pessoas.value = lista;
        message.value = null;
      },
      onFailure: (f) => message.value = f.msg,
    );
    carregado.value = true;
  }

  Future<bool> cadastrarPessoa(Pessoa pessoa) async {
    message.value = null;
    final result = await cadastrarPessoaCommand.executeWith((pessoa: pessoa));
    return result.fold<bool>(
      onSuccess: (nova) {
        pessoas.value = _ordenar([...pessoas.value, nova]);
        return true;
      },
      onFailure: (f) {
        message.value = f.msg;
        return false;
      },
    );
  }

  Future<bool> alterarPessoa(Pessoa pessoa) async {
    message.value = null;
    final result = await alterarPessoaCommand.executeWith((pessoa: pessoa));
    return result.fold<bool>(
      onSuccess: (atualizada) {
        pessoas.value = _ordenar([
          for (final p in pessoas.value) p.id == atualizada.id ? atualizada : p,
        ]);
        return true;
      },
      onFailure: (f) {
        message.value = f.msg;
        return false;
      },
    );
  }

  Future<bool> removerPessoa(Pessoa pessoa) async {
    message.value = null;
    final result = await removerPessoaCommand.executeWith((id: pessoa.id));
    return result.fold<bool>(
      onSuccess: (_) {
        pessoas.value = pessoas.value.where((p) => p.id != pessoa.id).toList();
        return true;
      },
      onFailure: (f) {
        message.value = f.msg;
        return false;
      },
    );
  }

  /// Chamado no logout: o próximo usuário não pode ver dados do anterior.
  void limpar() {
    pessoas.value = [];
    message.value = null;
    carregado.value = false;
  }

  List<Pessoa> _ordenar(List<Pessoa> lista) => lista
    ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
}
