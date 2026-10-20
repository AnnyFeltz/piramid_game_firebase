import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../services/local_storage_service_interface.dart';
import 'preference_repository_interface.dart';

final class PreferenceRepositoryImpl implements IPreferenceRepository {
  static const String _chaveTemaEscuro = 'tema_escuro';

  final ILocalStorageService _localStorage;

  PreferenceRepositoryImpl({required ILocalStorageService localStorage})
      : _localStorage = localStorage;

  @override
  Future<BoolResult> getTemaEscuro() async {
    try {
      return Success<bool, Failure>(
          _localStorage.lerBool(_chaveTemaEscuro) ?? false);
    } catch (e) {
      return Error<bool, Failure>(
          ApiLocalFailure('Erro ao ler preferência de tema: $e'));
    }
  }

  @override
  Future<VoidResult> salvarTemaEscuro(bool escuro) async {
    try {
      await _localStorage.salvarBool(_chaveTemaEscuro, escuro);
      return const Success<void, Failure>(null);
    } catch (e) {
      return Error<void, Failure>(
          ApiLocalFailure('Erro ao salvar preferência de tema: $e'));
    }
  }
}
