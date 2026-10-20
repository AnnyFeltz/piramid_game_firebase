import 'package:go_router/go_router.dart';

import '../../domain/models/pessoa.dart';
import '../../presentation/controllers/auth_viewmodel.dart';
import '../../presentation/views/avaliar_pessoa_view.dart';
import '../../presentation/views/cadastro_usuario_view.dart';
import '../../presentation/views/home_view.dart';
import '../../presentation/views/login_view.dart';
import '../../presentation/views/pessoa_detalhes_view.dart';
import '../../presentation/views/pessoa_form_view.dart';
import '../../presentation/views/sobre_view.dart';
import '../../presentation/views/splash_view.dart';
import '../di/dependency_injection.dart';

class AppRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const cadastroUsuario = 'cadastro_usuario';
  static const home = 'home';
  static const novaPessoa = 'nova_pessoa';
  static const editarPessoa = 'editar_pessoa';
  static const detalhesPessoa = 'detalhes_pessoa';
  static const avaliarPessoa = 'avaliar_pessoa';
  static const sobre = 'sobre';
}

class AppPaths {
  static const splash = '/';
  static const login = '/login';
  static const cadastroUsuario = '/cadastro';
  static const home = '/home';
  static const novaPessoa = '/pessoa/nova';
  static const editarPessoa = '/pessoa/editar';
  static const detalhesPessoa = '/pessoa/detalhes';
  static const avaliarPessoa = '/pessoa/avaliar';
  static const sobre = '/sobre';
}

class AppRouter {
  AppRouter._();

  /// Telas que podem ser abertas sem estar autenticado.
  static const _rotasPublicas = {
    AppPaths.splash,
    AppPaths.login,
    AppPaths.cadastroUsuario,
  };

  /// As rotas de pessoa recebem a [Pessoa] em `extra`. Se o app foi recarregado
  /// (ex.: F5 no navegador) o `extra` se perde, então voltamos para a home.
  static String? _exigePessoa(GoRouterState state) =>
      state.extra is Pessoa ? null : AppPaths.home;

  static final GoRouter router = GoRouter(
    initialLocation: AppPaths.splash,

    // Somente usuários autenticados acessam as funcionalidades principais.
    redirect: (context, state) {
      final autenticado = injector.get<AuthViewModel>().isAuthenticated.value;
      final publica = _rotasPublicas.contains(state.matchedLocation);
      if (!autenticado && !publica) return AppPaths.login;
      return null;
    },

    routes: [
      GoRoute(
        path: AppPaths.splash,
        name: AppRouteNames.splash,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashView()),
      ),
      GoRoute(
        path: AppPaths.login,
        name: AppRouteNames.login,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginView()),
      ),
      GoRoute(
        path: AppPaths.cadastroUsuario,
        name: AppRouteNames.cadastroUsuario,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CadastroUsuarioView()),
      ),
      GoRoute(
        path: AppPaths.home,
        name: AppRouteNames.home,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomeView()),
      ),
      GoRoute(
        path: AppPaths.novaPessoa,
        name: AppRouteNames.novaPessoa,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: PessoaFormView()),
      ),
      GoRoute(
        path: AppPaths.editarPessoa,
        name: AppRouteNames.editarPessoa,
        redirect: (context, state) => _exigePessoa(state),
        pageBuilder: (context, state) => NoTransitionPage(
            child: PessoaFormView(pessoa: state.extra as Pessoa)),
      ),
      GoRoute(
        path: AppPaths.detalhesPessoa,
        name: AppRouteNames.detalhesPessoa,
        redirect: (context, state) => _exigePessoa(state),
        pageBuilder: (context, state) => NoTransitionPage(
            child: PessoaDetalhesView(pessoa: state.extra as Pessoa)),
      ),
      GoRoute(
        path: AppPaths.avaliarPessoa,
        name: AppRouteNames.avaliarPessoa,
        redirect: (context, state) => _exigePessoa(state),
        pageBuilder: (context, state) => NoTransitionPage(
            child: AvaliarPessoaView(pessoa: state.extra as Pessoa)),
      ),
      GoRoute(
        path: AppPaths.sobre,
        name: AppRouteNames.sobre,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SobreView()),
      ),
    ],
  );
}
