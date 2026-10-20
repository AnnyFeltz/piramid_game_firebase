import '../../core/typedefs/types_defs.dart';

abstract interface class IPreferenceFacade {
  Future<BoolResult> carregarTema(NoParams params);
  Future<VoidResult> alterarTema(TemaParams params);
}
