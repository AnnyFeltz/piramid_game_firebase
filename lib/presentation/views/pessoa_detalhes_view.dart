import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/criterios_popularidade.dart';
import '../../domain/models/pessoa.dart';
import '../controllers/auth_viewmodel.dart';
import '../controllers/avaliacao_viewmodel.dart';
import '../controllers/pessoa_viewmodel.dart';
import '../widgets/criterio_rating_tile.dart';
import '../widgets/criterios_info.dart';
import '../widgets/nivel_lenda.dart';

/// Informações completas de uma pessoa + a avaliação feita pelo usuário.
class PessoaDetalhesView extends StatefulWidget {
  final Pessoa pessoa;
  const PessoaDetalhesView({super.key, required this.pessoa});

  @override
  State<PessoaDetalhesView> createState() => _PessoaDetalhesViewState();
}

class _PessoaDetalhesViewState extends State<PessoaDetalhesView> {
  late final PessoaViewModel _pessoas;
  late final AvaliacaoViewModel _avaliacoes;
  late final AuthViewModel _auth;

  @override
  void initState() {
    super.initState();
    _pessoas = injector.get<PessoaViewModel>();
    _avaliacoes = injector.get<AvaliacaoViewModel>();
    _auth = injector.get<AuthViewModel>();
    // Garante que "minha avaliação" está carregada mesmo quando esta tela foi
    // aberta direto pelo ranking.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _avaliacoes.carregarAvaliacoes());
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Watch((_) {
      // Usa a versão mais recente da pessoa (ela pode ter sido editada).
      final pessoa = _pessoas.pessoas.value.firstWhere(
        (p) => p.id == widget.pessoa.id,
        orElse: () => widget.pessoa,
      );
      final uid = _auth.usuario.value?.uid;
      final souEu = pessoa.usuarioUid != null && pessoa.usuarioUid == uid;
      final souDono = pessoa.criadoPor == uid;
      final minha = _avaliacoes.avaliacaoPorPessoa.value[pessoa.id];
      final pontos = minha?.pontuacaoTotal;
      final cor = pontos == null ? Colors.grey : corNivelLenda(pontos);

      return Scaffold(
        appBar: AppBar(
          title: Text(pessoa.nome),
          actions: [
            if (souDono)
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Editar pessoa',
                onPressed: () =>
                    context.pushNamed(AppRouteNames.editarPessoa, extra: pessoa),
              ),
          ],
        ),
        body: ListView(
          padding: AppSpacing.paddingMd,
          children: [
            // ── Dados cadastrais ──────────────────────────────────────────
            Card(
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: cor.withValues(alpha: 0.2),
                      child: Text(
                        pessoa.nome.isEmpty ? '?' : pessoa.nome[0].toUpperCase(),
                        style: context.textStyles.headlineLarge?.withColor(cor),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(pessoa.nome,
                        textAlign: TextAlign.center,
                        style: context.textStyles.headlineSmall?.semiBold),
                    if (pessoa.apelido.isNotEmpty)
                      Text('"${pessoa.apelido}"',
                          style: context.textStyles.titleMedium
                              ?.withColor(cores.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        Chip(label: Text(pessoa.curso.displayName)),
                        Chip(label: Text('Turma ${pessoa.turmaAno}')),
                        if (souEu) const Chip(label: Text('Você')),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Nascimento: '
                      '${DateFormat('dd/MM/yyyy').format(pessoa.dataNascimento)}',
                      style: context.textStyles.bodySmall
                          ?.withColor(cores.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Minha avaliação ───────────────────────────────────────────
            Text('Sua avaliação',
                style: context.textStyles.titleLarge?.semiBold
                    .withColor(cores.primary)),
            const SizedBox(height: AppSpacing.md),

            if (souEu)
              _Aviso(
                icone: Icons.block,
                texto: 'Esta pessoa é você. Ninguém pode avaliar a si próprio.',
              )
            else if (minha == null)
              _Aviso(
                icone: Icons.star_border,
                texto: 'Você ainda não avaliou ${pessoa.nome}.',
              )
            else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events, size: 32, color: Colors.amber),
                    Text('$pontos',
                        style: context.textStyles.headlineLarge?.bold
                            .withColor(cor)),
                    Text('Nível Lenda',
                        style: context.textStyles.labelLarge?.withColor(cor)),
                    Text(
                      'de ${CriteriosPopularidade.pontuacaoMaxima} pontos possíveis',
                      style: context.textStyles.bodySmall
                          ?.withColor(cores.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: AppSpacing.paddingMd,
                  child: Column(
                    children: [
                      for (final criterio in criteriosInfo)
                        CriterioRatingTile(
                          label: criterio.label,
                          descricao: '',
                          value:
                              (minha.criterios.toMap()[criterio.chave] as int?) ??
                                  1,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Avaliado em ${DateFormat('dd/MM/yyyy HH:mm').format(minha.dataAvaliacao)}',
                textAlign: TextAlign.center,
                style: context.textStyles.bodySmall
                    ?.withColor(cores.onSurfaceVariant),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),
            if (!souEu)
              FilledButton.icon(
                onPressed: () =>
                    context.pushNamed(AppRouteNames.avaliarPessoa, extra: pessoa),
                icon: const Icon(Icons.star),
                label: Text(minha == null ? 'Avaliar' : 'Alterar avaliação'),
                style:
                    FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      );
    });
  }
}

class _Aviso extends StatelessWidget {
  final IconData icone;
  final String texto;
  const _Aviso({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Icon(icone, color: Colors.grey),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(texto, style: context.textStyles.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
