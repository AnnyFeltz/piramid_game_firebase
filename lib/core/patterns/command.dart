import 'package:signals_flutter/signals_flutter.dart';
import '../failure/failure.dart';
import 'result.dart';

abstract interface class ICommand<S, E> {
  Future<Result<S, E>> execute();
}

/// Padrão Command: encapsula uma ação disparada pela interface e expõe, via
/// Signals, se ela está executando e qual foi o último resultado.
abstract base class Command<S, E> implements ICommand<S, E> {
  final _running = signal(false);
  final _result = signal<Result<S, E>?>(null);

  /// Execução em andamento (evita que um duplo toque dispare a ação 2 vezes,
  /// o que, por exemplo, cadastraria a mesma pessoa duas vezes no Firestore).
  Future<Result<S, E>>? _inFlight;

  ReadonlySignal<bool> get isExecuting => _running.readonly();
  ReadonlySignal<Result<S, E>?> get result => _result.readonly();

  late final hasResult = computed(() => _result.value != null);
  late final hasError = computed(() => _result.value?.isFailure ?? false);
  late final isSuccess = computed(() => _result.value?.isSuccess ?? false);

  Future<Result<S, E>> call() {
    final emAndamento = _inFlight;
    if (emAndamento != null) return emAndamento;
    return _inFlight = _executar();
  }

  Future<Result<S, E>> _executar() async {
    _running.value = true;
    _result.value = null;
    try {
      final resultado = await execute();
      _result.value = resultado;
      return resultado;
    } finally {
      _running.value = false;
      _inFlight = null;
    }
  }

  void clear() => _result.value = null;

  void reset() {
    _running.value = false;
    clear();
  }
}

/// Command que recebe um parâmetro ([P]) em cada execução.
abstract base class ParameterizedCommand<S, E, P> extends Command<S, E> {
  P? _parameter;
  set parameter(P? value) => _parameter = value;
  P? get parameter => _parameter;

  Future<Result<S, E>> executeWith(P parameter) {
    final emAndamento = _inFlight;
    if (emAndamento != null) {
      // Mesmo parâmetro (ex.: duplo toque): reaproveita a execução em curso.
      if (parameter == _parameter) return emAndamento;
      // Parâmetro diferente: é outra operação, executa à parte (sem misturar
      // o resultado com o da execução que já estava em andamento).
      _parameter = parameter;
      return execute();
    }
    _parameter = parameter;
    return call();
  }
}

/// Command pronto que delega a execução a uma função (normalmente um método
/// de uma Facade de use cases). Os ViewModels criam um por ação:
/// `loginCommand`, `cadastrarPessoaCommand`, `carregarRankingGlobalCommand`...
///
/// [S] é o tipo do sucesso e [P] o tipo do parâmetro; a falha é sempre
/// [Failure].
final class FunctionCommand<S, P> extends ParameterizedCommand<S, Failure, P> {
  final Future<Result<S, Failure>> Function(P) _acao;

  FunctionCommand(this._acao);

  @override
  Future<Result<S, Failure>> execute() => _acao(parameter as P);
}
