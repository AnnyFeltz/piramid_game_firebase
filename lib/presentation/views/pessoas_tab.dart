import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/avaliacao.dart';
import '../../domain/models/pessoa.dart';
import '../controllers/auth_viewmodel.dart';
import '../controllers/avaliacao_viewmodel.dart';
import '../controllers/pessoa_viewmodel.dart';
import '../widgets/nivel_lenda.dart';

/// Aba "Pessoas": lista as pessoas cadastradas no Firestore.
class PessoasTab extends StatefulWidget {
  const PessoasTab({super.key});

  @override
  State<PessoasTab> createState() => _PessoasTabState();
}

class _PessoasTabState extends State<PessoasTab> {
  late final PessoaViewModel _pessoas;
  late final AvaliacaoViewModel _avaliacoes;
  late final AuthViewModel _auth;

  @override
  void initState() {
    super.initState();
    _pessoas = injector.get<PessoaViewModel>();
    _avaliacoes = injector.get<AvaliacaoViewModel>();
    _auth = injector.get<AuthViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recarregar());
  }

  Future<void> _recarregar() async {
    await Future.wait([
      _pessoas.carregarPessoas(),
      _avaliacoes.carregarAvaliacoes(),
    ]);
  }

  Future<void> _confirmarRemocao(Pessoa pessoa) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
            'Deseja remover ${pessoa.nome}? As avaliações dessa pessoa também '
            'serão apagadas. Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remover')),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    final ok = await _pessoas.removerPessoa(pessoa);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? '${pessoa.nome} removida.'
          : (_pessoas.message.value ?? 'Não foi possível remover.')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      final carregado = _pessoas.carregado.value;
      final lista = _pessoas.pessoas.value;
      final erro = _pessoas.message.value;
      final uid = _auth.usuario.value?.uid;
      final minhasAvaliacoes = _avaliacoes.avaliacaoPorPessoa.value;

      if (!carregado) {
        return const Center(child: CircularProgressIndicator());
      }

      if (lista.isEmpty) {
        return _EstadoVazio(erro: erro, onTentarNovamente: _recarregar);
      }

      return RefreshIndicator(
        onRefresh: _recarregar,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
          itemCount: lista.length,
          itemBuilder: (context, i) {
            final pessoa = lista[i];
            final souEu = pessoa.usuarioUid != null && pessoa.usuarioUid == uid;
            final souDono = pessoa.criadoPor == uid;
            return _PessoaCard(
              pessoa: pessoa,
              minhaAvaliacao: minhasAvaliacoes[pessoa.id],
              souEu: souEu,
              podeEditar: souDono,
              onTap: () => context.pushNamed(AppRouteNames.detalhesPessoa,
                  extra: pessoa),
              onAvaliar: () =>
                  context.pushNamed(AppRouteNames.avaliarPessoa, extra: pessoa),
              onEditar: () =>
                  context.pushNamed(AppRouteNames.editarPessoa, extra: pessoa),
              onRemover: () => _confirmarRemocao(pessoa),
            );
          },
        ),
      );
    });
  }
}

class _EstadoVazio extends StatelessWidget {
  final String? erro;
  final VoidCallback onTentarNovamente;
  const _EstadoVazio({required this.erro, required this.onTentarNovamente});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(erro == null ? Icons.people_outline : Icons.cloud_off,
                size: 80, color: Colors.grey),
            const SizedBox(height: AppSpacing.lg),
            Text(erro == null ? 'Nenhuma pessoa cadastrada' : 'Algo deu errado',
                style: context.textStyles.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              erro ?? 'Cadastre pessoas e veja quem chega ao Nível Lenda!',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.withColor(Colors.grey),
            ),
            if (erro != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onTentarNovamente,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PessoaCard extends StatelessWidget {
  final Pessoa pessoa;
  final Avaliacao? minhaAvaliacao;
  final bool souEu;
  final bool podeEditar;
  final VoidCallback onTap;
  final VoidCallback onAvaliar;
  final VoidCallback onEditar;
  final VoidCallback onRemover;

  const _PessoaCard({
    required this.pessoa,
    required this.minhaAvaliacao,
    required this.souEu,
    required this.podeEditar,
    required this.onTap,
    required this.onAvaliar,
    required this.onEditar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final pontos = minhaAvaliacao?.pontuacaoTotal;
    final cor = pontos == null ? Colors.grey : corNivelLenda(pontos);
    final inicial = pessoa.nome.isEmpty ? '?' : pessoa.nome[0].toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: cor.withValues(alpha: 0.2),
                child: Text(inicial,
                    style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(pessoa.nome,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.titleMedium?.semiBold),
                        ),
                        if (souEu) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cores.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text('Você',
                                style: context.textStyles.labelSmall
                                    ?.withColor(cores.primary)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${pessoa.apelido.isEmpty ? '—' : pessoa.apelido}'
                      ' · ${pessoa.curso.displayName} ${pessoa.turmaAno}',
                      style: context.textStyles.bodySmall
                          ?.withColor(cores.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (pontos != null) ...[
                    Text('$pontos pts',
                        style: context.textStyles.titleMedium?.semiBold
                            .withColor(cor)),
                    Text('Sua nota',
                        style: context.textStyles.labelSmall
                            ?.withColor(Colors.grey)),
                  ] else
                    Text(souEu ? '' : 'Não avaliada',
                        style: context.textStyles.labelSmall
                            ?.withColor(Colors.grey)),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'avaliar') onAvaliar();
                  if (v == 'editar') onEditar();
                  if (v == 'remover') onRemover();
                },
                itemBuilder: (_) => [
                  // Ninguém pode avaliar a si próprio.
                  if (!souEu)
                    PopupMenuItem(
                      value: 'avaliar',
                      child: Row(children: [
                        const Icon(Icons.star, size: 18),
                        const SizedBox(width: 8),
                        Text(minhaAvaliacao == null
                            ? 'Avaliar'
                            : 'Alterar avaliação'),
                      ]),
                    ),
                  // Só quem cadastrou a pessoa pode editar/remover.
                  if (podeEditar) ...[
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'remover',
                      child: Row(children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remover', style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
