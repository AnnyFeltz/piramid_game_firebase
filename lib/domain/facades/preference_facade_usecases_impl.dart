import '../../core/typedefs/types_defs.dart';
import '../usecases/preference_usecases_interfaces.dart';
import 'preference_facade_usecases_interface.dart';

final class PreferenceFacadeImpl implements IPreferenceFacade {
  final ICarregarTemaUseCase _carregar;
  final IAlterarTemaUseCase _alterar;

  PreferenceFacadeImpl({
    required ICarregarTemaUseCase carregarTemaUseCase,
    required IAlterarTemaUseCase alterarTemaUseCase,
  })  : _carregar = carregarTemaUseCase,
        _alterar = alterarTemaUseCase;

  @override Future<BoolResult> carregarTema(NoParams p) => _carregar(p);
  @override Future<VoidResult> alterarTema(TemaParams p) => _alterar(p);
}
