import 'package:auto_injector/auto_injector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/theme_controller.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/avaliacao_repository_impl.dart';
import '../../data/repositories/avaliacao_repository_interface.dart';
import '../../data/repositories/pessoa_repository_impl.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import '../../data/repositories/preference_repository_impl.dart';
import '../../data/repositories/preference_repository_interface.dart';
import '../../data/services/auth_service_impl.dart';
import '../../data/services/auth_service_interface.dart';
import '../../data/services/firestore_service_impl.dart';
import '../../data/services/firestore_service_interface.dart';
import '../../data/services/google_auth_service_impl.dart';
import '../../data/services/google_auth_service_interface.dart';
import '../../data/services/local_storage_service_impl.dart';
import '../../data/services/local_storage_service_interface.dart';
import '../../domain/facades/auth_facade_usecases_impl.dart';
import '../../domain/facades/auth_facade_usecases_interface.dart';
import '../../domain/facades/avaliacao_facade_usecases_impl.dart';
import '../../domain/facades/avaliacao_facade_usecases_interface.dart';
import '../../domain/facades/pessoa_facade_usecases_impl.dart';
import '../../domain/facades/pessoa_facade_usecases_interface.dart';
import '../../domain/facades/preference_facade_usecases_impl.dart';
import '../../domain/facades/preference_facade_usecases_interface.dart';
import '../../domain/facades/ranking_facade_usecases_impl.dart';
import '../../domain/facades/ranking_facade_usecases_interface.dart';
import '../../domain/usecases/auth_usecases_impl.dart';
import '../../domain/usecases/auth_usecases_interfaces.dart';
import '../../domain/usecases/avaliacao_usecases_impl.dart';
import '../../domain/usecases/avaliacao_usecases_interfaces.dart';
import '../../domain/usecases/pessoa_usecases_impl.dart';
import '../../domain/usecases/pessoa_usecases_interfaces.dart';
import '../../domain/usecases/preference_usecases_impl.dart';
import '../../domain/usecases/preference_usecases_interfaces.dart';
import '../../domain/usecases/ranking_usecases_impl.dart';
import '../../domain/usecases/ranking_usecases_interfaces.dart';
import '../../presentation/controllers/auth_viewmodel.dart';
import '../../presentation/controllers/avaliacao_viewmodel.dart';
import '../../presentation/controllers/pessoa_viewmodel.dart';
import '../../presentation/controllers/ranking_viewmodel.dart';

final injector = AutoInjector();

/// Registra todas as dependências, na ordem das camadas da arquitetura:
///
///   services → repositories → use cases → facades → viewmodels → UI
///
/// [prefs] é obtido de forma assíncrona no `main` (SharedPreferences.getInstance)
/// e entregue já pronto aqui.
void setupDependencyInjection(SharedPreferences prefs) {
  // ── Services (acesso direto a Firebase Auth, Firestore e SharedPreferences)
  injector.addInstance<SharedPreferences>(prefs);
  injector.addSingleton<IAuthService>(AuthService.new);
  injector.addSingleton<IGoogleAuthService>(GoogleAuthService.new);
  injector.addSingleton<IFirestoreService>(FirestoreService.new);
  injector.addSingleton<ILocalStorageService>(LocalStorageService.new);

  // ── Repositories
  injector.addSingleton<IAuthRepository>(AuthRepositoryImpl.new);
  injector.addSingleton<IPessoaRepository>(PessoaRepositoryImpl.new);
  injector.addSingleton<IAvaliacaoRepository>(AvaliacaoRepositoryImpl.new);
  injector.addSingleton<IPreferenceRepository>(PreferenceRepositoryImpl.new);

  // ── Use Cases: autenticação
  injector.addSingleton<ICadastrarUsuarioUseCase>(
      CadastrarUsuarioUseCaseImpl.new);
  injector.addSingleton<IAutenticarUsuarioUseCase>(
      AutenticarUsuarioUseCaseImpl.new);
  injector.addSingleton<IAutenticarComGoogleUseCase>(
      AutenticarComGoogleUseCaseImpl.new);
  injector.addSingleton<IVerificarUsuarioAutenticadoUseCase>(
      VerificarUsuarioAutenticadoUseCaseImpl.new);
  injector.addSingleton<ILogoutUseCase>(LogoutUseCaseImpl.new);

  // ── Use Cases: pessoas
  injector.addSingleton<ICadastrarPessoaUseCase>(CadastrarPessoaUseCaseImpl.new);
  injector.addSingleton<IAlterarPessoaUseCase>(AlterarPessoaUseCaseImpl.new);
  injector.addSingleton<IRemoverPessoaUseCase>(RemoverPessoaUseCaseImpl.new);
  injector.addSingleton<IBuscarTodasPessoasUseCase>(
      BuscarTodasPessoasUseCaseImpl.new);
  injector.addSingleton<IBuscarPessoaPorIdUseCase>(
      BuscarPessoaPorIdUseCaseImpl.new);

  // ── Use Cases: avaliações
  injector.addSingleton<IVerificarAutoavaliacaoUseCase>(
      VerificarAutoavaliacaoUseCaseImpl.new);
  injector.addSingleton<IRegistrarAvaliacaoUseCase>(
      RegistrarAvaliacaoUseCaseImpl.new);
  injector.addSingleton<IAlterarAvaliacaoUseCase>(
      AlterarAvaliacaoUseCaseImpl.new);
  injector.addSingleton<IConsultarAvaliacaoUseCase>(
      ConsultarAvaliacaoUseCaseImpl.new);
  injector.addSingleton<IBuscarAvaliacoesDoUsuarioUseCase>(
      BuscarAvaliacoesDoUsuarioUseCaseImpl.new);

  // ── Use Cases: rankings
  injector.addSingleton<ICalcularRankingPessoalUseCase>(
      CalcularRankingPessoalUseCaseImpl.new);
  injector.addSingleton<ICalcularRankingGlobalUseCase>(
      CalcularRankingGlobalUseCaseImpl.new);

  // ── Use Cases: preferências (tema)
  injector.addSingleton<ICarregarTemaUseCase>(CarregarTemaUseCaseImpl.new);
  injector.addSingleton<IAlterarTemaUseCase>(AlterarTemaUseCaseImpl.new);

  // ── Facades de use cases
  injector.addSingleton<IAuthFacade>(AuthFacadeImpl.new);
  injector.addSingleton<IPessoaFacade>(PessoaFacadeImpl.new);
  injector.addSingleton<IAvaliacaoFacade>(AvaliacaoFacadeImpl.new);
  injector.addSingleton<IRankingFacade>(RankingFacadeImpl.new);
  injector.addSingleton<IPreferenceFacade>(PreferenceFacadeImpl.new);

  // ── Core / ViewModels
  injector.addSingleton<ThemeController>(ThemeController.new);
  injector.addSingleton<AuthViewModel>(AuthViewModel.new);
  injector.addSingleton<PessoaViewModel>(PessoaViewModel.new);
  injector.addSingleton<AvaliacaoViewModel>(AvaliacaoViewModel.new);
  injector.addSingleton<RankingViewModel>(RankingViewModel.new);

  injector.commit();
}
