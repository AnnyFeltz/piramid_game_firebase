import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class ICarregarTemaUseCase
    implements IUseCase<BoolResult, NoParams> {}

abstract interface class IAlterarTemaUseCase
    implements IUseCase<VoidResult, TemaParams> {}
