import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/messages/app_messages.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/theme_controller.dart';
import '../controllers/auth_viewmodel.dart';
import '../controllers/avaliacao_viewmodel.dart';
import '../controllers/pessoa_viewmodel.dart';
import '../controllers/ranking_viewmodel.dart';
import 'pessoas_tab.dart';
import 'ranking_tab.dart';

/// Área principal (só para usuário autenticado). Navegação por abas:
///
///   HOME ── Pessoas · Ranking Pessoal · Ranking Global
///   + menu no topo: Tema · Sobre · Logout
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final AuthViewModel _auth;
  late final ThemeController _theme;
  int _aba = 0;

  static const _titulos = ['Pessoas', 'Ranking Pessoal', 'Ranking Global'];

  @override
  void initState() {
    super.initState();
    _auth = injector.get<AuthViewModel>();
    _theme = injector.get<ThemeController>();
  }

  Future<void> _sair() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja encerrar a sessão?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair')),
        ],
      ),
    );
    if (confirmou != true) return;

    final ok = await _auth.logout();
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_auth.message.value ?? 'Não foi possível sair.')));
      return;
    }

    // O próximo usuário não pode enxergar dados do anterior.
    injector.get<PessoaViewModel>().limpar();
    injector.get<AvaliacaoViewModel>().limpar();
    injector.get<RankingViewModel>().limpar();
    context.goNamed(AppRouteNames.login);
  }

  Widget _corpo() {
    switch (_aba) {
      case 1:
        return const RankingTab(
            key: ValueKey('ranking-pessoal'), tipo: RankingTipo.pessoal);
      case 2:
        return const RankingTab(
            key: ValueKey('ranking-global'), tipo: RankingTipo.global);
      default:
        return const PessoasTab(key: ValueKey('pessoas'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppMessages.appName),
            Watch((_) {
              final usuario = _auth.usuario.value;
              if (usuario == null) return const SizedBox.shrink();
              return Text(
                usuario.email.isEmpty ? usuario.nome : usuario.email,
                style: Theme.of(context).textTheme.labelSmall,
              );
            }),
          ],
        ),
        actions: [
          Watch((_) => IconButton(
                icon: Icon(
                    _theme.isLightMode.value ? Icons.dark_mode : Icons.light_mode),
                tooltip: 'Alternar tema',
                onPressed: _theme.toggleTheme,
              )),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sobre',
            onPressed: () => context.pushNamed(AppRouteNames.sobre),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _sair,
          ),
        ],
      ),
      body: _corpo(),
      floatingActionButton: _aba == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.pushNamed(AppRouteNames.novaPessoa),
              icon: const Icon(Icons.person_add),
              label: const Text('Nova pessoa'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: _titulos[0]),
          NavigationDestination(
              icon: const Icon(Icons.person_pin_outlined),
              selectedIcon: const Icon(Icons.person_pin),
              label: _titulos[1]),
          NavigationDestination(
              icon: const Icon(Icons.public_outlined),
              selectedIcon: const Icon(Icons.public),
              label: _titulos[2]),
        ],
      ),
    );
  }
}
