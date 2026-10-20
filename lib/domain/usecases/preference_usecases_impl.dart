import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/preference_repository_interface.dart';
import 'preference_usecases_interfaces.dart';

final class CarregarTemaUseCaseImpl implements ICarregarTemaUseCase {
  final IPreferenceRepository _repository;
  CarregarTemaUseCaseImpl({required IPreferenceRepository repository})
      : _repository = repository;

  @override
  Future<BoolResult> call(NoParams params) => _repository.getTemaEscuro();
}

final class AlterarTemaUseCaseImpl implements IAlterarTemaUseCase {
  final IPreferenceRepository _repository;
  AlterarTemaUseCaseImpl({required IPreferenceRepository repository})
      : _repository = repository;

  @override
  Future<VoidResult> call(TemaParams params) =>
      _repository.salvarTemaEscuro(params.escuro);
}
