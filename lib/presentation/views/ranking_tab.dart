import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/messages/app_messages.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/criterios_popularidade.dart';
import '../../domain/models/ranking_item.dart';
import '../controllers/ranking_viewmodel.dart';
import '../widgets/nivel_lenda.dart';

enum RankingTipo { pessoal, global }

/// Aba de ranking. Serve para os dois rankings, que respondem a perguntas
/// diferentes (especificação, item 25):
///  • Pessoal: "Na minha opinião, quem possui o maior Nível Lenda?"
///  • Global:  "Na opinião dos usuários do aplicativo, quem possui o maior Nível Lenda?"
class RankingTab extends StatefulWidget {
  final RankingTipo tipo;
  const RankingTab({super.key, required this.tipo});

  @override
  State<RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<RankingTab> {
  late final RankingViewModel _vm;

  bool get _global => widget.tipo == RankingTipo.global;

  @override
  void initState() {
    super.initState();
    _vm = injector.get<RankingViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() =>
      _global ? _vm.carregarRankingGlobal() : _vm.carregarRankingPessoal();

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      final carregando = (_global
              ? _vm.carregarRankingGlobalCommand
              : _vm.carregarRankingPessoalCommand)
          .isExecuting
          .value;
      final itens = _global ? _vm.rankingGlobal.value : _vm.rankingPessoal.value;
      final erro = _vm.message.value;

      if (carregando && itens.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.paddingMd,
          children: [
            _Cabecalho(global: _global),
            const SizedBox(height: AppSpacing.md),
            if (erro != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(erro,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            if (itens.isEmpty && erro == null)
              _SemDados(global: _global)
            else
              for (var i = 0; i < itens.length; i++)
                _RankingItemCard(
                  posicao: i + 1,
                  item: itens[i],
                  global: _global,
                  onTap: () => context.pushNamed(AppRouteNames.detalhesPessoa,
                      extra: itens[i].pessoa),
                ),
          ],
        ),
      );
    });
  }
}

class _Cabecalho extends StatelessWidget {
  final bool global;
  const _Cabecalho({required this.global});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Card(
      color: cores.primary.withValues(alpha: 0.10),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(global ? Icons.public : Icons.person_pin,
                    color: cores.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(global ? 'Ranking global' : 'Ranking pessoal',
                    style: context.textStyles.titleMedium?.bold
                        .withColor(cores.primary)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              global
                  ? '“${AppMessages.perguntaRankingGlobal}”'
                  : '“${AppMessages.perguntaRankingPessoal}”',
              style: context.textStyles.bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              global
                  ? 'Média das avaliações de todos os usuários.'
                  : 'Considera somente as avaliações que você fez.',
              style: context.textStyles.bodySmall
                  ?.withColor(cores.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemDados extends StatelessWidget {
  final bool global;
  const _SemDados({required this.global});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.leaderboard, size: 72, color: Colors.grey),
          const SizedBox(height: AppSpacing.md),
          Text(
            global
                ? 'Ainda não há avaliações no aplicativo'
                : 'Você ainda não avaliou ninguém',
            style: context.textStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Avalie pessoas na aba "Pessoas" para montar o ranking.',
            style: context.textStyles.bodySmall?.withColor(Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RankingItemCard extends StatelessWidget {
  final int posicao;
  final RankingItem item;
  final bool global;
  final VoidCallback onTap;

  const _RankingItemCard({
    required this.posicao,
    required this.item,
    required this.global,
    required this.onTap,
  });

  Widget _medalha(int pos) {
    if (pos == 1) return const Text('🥇', style: TextStyle(fontSize: 28));
    if (pos == 2) return const Text('🥈', style: TextStyle(fontSize: 28));
    if (pos == 3) return const Text('🥉', style: TextStyle(fontSize: 28));
    return SizedBox(
      width: 28,
      child: Text('$pos°',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final pessoa = item.pessoa;
    final cor = corNivelLenda(item.pontuacao);
    final progresso =
        (item.pontuacao / CriteriosPopularidade.pontuacaoMaxima).clamp(0.0, 1.0);
    final qtd = item.quantidadeAvaliacoes;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: posicao <= 3 ? cores.primary.withValues(alpha: 0.08) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            children: [
              Row(
                children: [
                  _medalha(posicao),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pessoa.nome,
                            style: context.textStyles.titleMedium?.semiBold),
                        Text(
                          '"${pessoa.apelido}" · ${pessoa.curso.displayName} ${pessoa.turmaAno}',
                          style: context.textStyles.bodySmall
                              ?.withColor(cores.onSurfaceVariant),
                        ),
                        if (global)
                          Text(
                            qtd == 1 ? '1 avaliação' : '$qtd avaliações',
                            style: context.textStyles.labelSmall
                                ?.withColor(cores.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatarPontos(item.pontuacao),
                          style:
                              context.textStyles.titleLarge?.bold.withColor(cor)),
                      Text('pts',
                          style: context.textStyles.labelSmall?.withColor(cor)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progresso,
                  backgroundColor: cores.surfaceContainerHighest,
                  color: cor,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
