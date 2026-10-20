import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class ICadastrarUsuarioUseCase
    implements IUseCase<UsuarioResult, CredenciaisParams> {}

abstract interface class IAutenticarUsuarioUseCase
    implements IUseCase<UsuarioResult, CredenciaisParams> {}

abstract interface class IAutenticarComGoogleUseCase
    implements IUseCase<UsuarioResult, NoParams> {}

abstract interface class IVerificarUsuarioAutenticadoUseCase
    implements IUseCase<UsuarioResult, NoParams> {}

abstract interface class ILogoutUseCase
    implements IUseCase<VoidResult, NoParams> {}
