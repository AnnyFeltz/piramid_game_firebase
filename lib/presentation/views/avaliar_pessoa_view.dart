import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/avaliacao.dart';
import '../../domain/models/criterios_popularidade.dart';
import '../../domain/models/pessoa.dart';
import '../controllers/avaliacao_viewmodel.dart';
import '../widgets/criterio_rating_tile.dart';
import '../widgets/criterios_info.dart';
import '../widgets/nivel_lenda.dart';

/// Interface para avaliar uma pessoa: 15 critérios, de 1 a 5 estrelas.
///
/// • Se o usuário já avaliou a pessoa, a tela abre com as notas atuais e salvar
///   ALTERA a avaliação existente (uma avaliação ativa por usuário + pessoa).
/// • Se a pessoa é o próprio usuário, a avaliação é bloqueada (autoavaliação).
class AvaliarPessoaView extends StatefulWidget {
  final Pessoa pessoa;
  const AvaliarPessoaView({super.key, required this.pessoa});

  @override
  State<AvaliarPessoaView> createState() => _AvaliarPessoaViewState();
}

class _AvaliarPessoaViewState extends State<AvaliarPessoaView> {
  late final AvaliacaoViewModel _vm;

  /// Notas em edição, pelo nome do campo (mesmos nomes do Firestore).
  final Map<String, int> _notas = {
    for (final c in criteriosInfo) c.chave: CriteriosPopularidade.notaMinima,
  };

  bool _carregando = true;
  bool _autoavaliacao = false;
  Avaliacao? _existente;

  int get _total => _notas.values.fold(0, (soma, nota) => soma + nota);

  @override
  void initState() {
    super.initState();
    _vm = injector.get<AvaliacaoViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _preparar());
  }

  Future<void> _preparar() async {
    _vm.message.value = null;
    final pessoaId = widget.pessoa.id;

    final souEu = await _vm.verificarAutoavaliacao(pessoaId);
    final existente = souEu ? null : await _vm.consultarAvaliacao(pessoaId);
    if (!mounted) return;

    setState(() {
      _autoavaliacao = souEu;
      _existente = existente;
      if (existente != null) {
        final mapa = existente.criterios.toMap();
        for (final c in criteriosInfo) {
          _notas[c.chave] = (mapa[c.chave] as int?) ?? CriteriosPopularidade.notaMinima;
        }
      }
      _carregando = false;
    });
  }

  Future<void> _salvar() async {
    final alterando = _existente != null;
    final ok = await _vm.salvarAvaliacao(
      pessoaId: widget.pessoa.id,
      criterios: CriteriosPopularidade.fromMap(_notas),
      alterando: alterando,
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(alterando
            ? 'Avaliação de ${widget.pessoa.nome} alterada!'
            : '${widget.pessoa.nome} avaliada!'),
      ));
      context.pop();
    }
    // Se falhou, a mensagem aparece na própria tela (_vm.message).
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_existente == null ? 'Avaliar' : 'Alterar avaliação'),
      ),
      body: SafeArea(
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : _autoavaliacao
                ? _AutoavaliacaoBloqueada(nome: widget.pessoa.nome)
                : _formulario(context, cores),
      ),
    );
  }

  Widget _formulario(BuildContext context, ColorScheme cores) {
    return ListView(
      padding: AppSpacing.paddingMd,
      children: [
        Text(widget.pessoa.nome,
            style: context.textStyles.headlineSmall?.semiBold
                .withColor(cores.primary)),
        Text(
          'Avalie de ${CriteriosPopularidade.notaMinima} a '
          '${CriteriosPopularidade.notaMaxima} estrelas em cada critério.',
          style: context.textStyles.bodySmall?.withColor(cores.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),

        for (final criterio in criteriosInfo)
          CriterioRatingTile(
            label: criterio.label,
            descricao: criterio.descricao,
            value: _notas[criterio.chave]!,
            interactive: true,
            onChanged: (v) => setState(() => _notas[criterio.chave] = v),
          ),

        const SizedBox(height: AppSpacing.lg),

        // Pontuação total calculada automaticamente.
        Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: corNivelLenda(_total).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: corNivelLenda(_total)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Nível Lenda: $_total pts '
                '(${CriteriosPopularidade.pontuacaoMinima}–'
                '${CriteriosPopularidade.pontuacaoMaxima})',
                style: context.textStyles.titleMedium?.bold,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Watch((_) {
          final msg = _vm.message.value;
          if (msg == null) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: cores.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: cores.error),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: cores.error),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(msg, style: TextStyle(color: cores.error))),
              ],
            ),
          );
        }),

        Watch((_) {
          final salvando = _vm.avaliarPessoaCommand.isExecuting.value ||
              _vm.alterarAvaliacaoCommand.isExecuting.value;
          return FilledButton.icon(
            onPressed: salvando ? null : _salvar,
            icon: salvando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: Text(_existente == null ? 'Salvar avaliação' : 'Salvar alteração'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          );
        }),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _AutoavaliacaoBloqueada extends StatelessWidget {
  final String nome;
  const _AutoavaliacaoBloqueada({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 72, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            Text('Você não pode avaliar a si próprio',
                textAlign: TextAlign.center,
                style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$nome está vinculada à sua conta. Peça para outros usuários '
              'avaliarem você!',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.withColor(Colors.grey),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
