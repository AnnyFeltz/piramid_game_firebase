import 'package:flutter/material.dart';
import '../../core/messages/app_messages.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/criterios_info.dart';

/// Tela "Sobre o App" (especificação, item 20): objetivo, contexto do IFPR,
/// critérios, cálculo do Nível Lenda, os dois rankings, Firestore,
/// Firebase Authentication e tema claro/escuro.
class SobreView extends StatelessWidget {
  const SobreView({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o App')),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.paddingLg,
          children: [
            Center(
              child: Icon(Icons.emoji_events, size: 80, color: cores.secondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(AppMessages.appName,
                  style: context.textStyles.headlineSmall?.bold
                      .withColor(cores.primary)),
            ),
            Center(
              child: Text(AppMessages.ifprCampus,
                  style: context.textStyles.bodyMedium
                      ?.withColor(cores.onSurfaceVariant)),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _InfoCard(
              titulo: 'Objetivo',
              conteudo:
                  'O PiramidGame IFPR-Pgua é um aplicativo desenvolvido em Flutter '
                  'para fins didáticos. Ele permite cadastrar pessoas do IFPR – '
                  'Campus Paranaguá e avaliá-las em critérios descontraídos de '
                  'convivência, destaque e participação.',
            ),
            const _InfoCard(
              titulo: 'Contexto',
              conteudo:
                  'O app nasceu no IFPR – Campus Paranaguá, com a missão de '
                  'descobrir quem domina o Nível Lenda do campus. Como o '
                  'ranking precisa ser o mesmo para todo mundo, os dados ficam '
                  'na nuvem e não em cada celular.',
            ),
            _InfoCard(
              titulo: 'Critérios',
              conteudo: 'Cada pessoa é avaliada em ${criteriosInfo.length} '
                  'critérios, com notas de 1 a 5 estrelas:\n\n'
                  '${criteriosInfo.map((c) => '• ${c.label}').join('\n')}',
            ),
            const _InfoCard(
              titulo: 'Cálculo do Nível Lenda',
              conteudo:
                  'Cada avaliação atribui notas de 1 a 5 estrelas em 15 '
                  'categorias. A soma dessas notas forma o Nível Lenda: no '
                  'mínimo 15 pontos (15 × 1) e no máximo 75 pontos (15 × 5).\n\n'
                  'Exemplo: 4+3+5+4+4+5+3+4+5+2+4+3+4+5+3 = 58 pontos.',
            ),
            const _InfoCard(
              titulo: 'Ranking pessoal',
              conteudo:
                  'Responde à pergunta: "${AppMessages.perguntaRankingPessoal}"\n\n'
                  'Usa exclusivamente as avaliações feitas por você. As '
                  'avaliações dos demais usuários não interferem nele.',
            ),
            const _InfoCard(
              titulo: 'Ranking global',
              conteudo:
                  'Responde à pergunta: "${AppMessages.perguntaRankingGlobal}"\n\n'
                  'Considera as avaliações de todos os usuários. Como uma '
                  'pessoa pode ser avaliada por vários usuários, a pontuação é a '
                  'média das avaliações recebidas (ex.: 60, 70 e 65 resultam em '
                  '65 pontos). O ranking é ordenado da maior média para a menor '
                  'e mostra quantas avaliações cada pessoa recebeu.',
            ),
            const _InfoCard(
              titulo: 'Regras das avaliações',
              conteudo:
                  '• Você não pode avaliar a si próprio.\n'
                  '• Cada usuário tem apenas uma avaliação ativa por pessoa: '
                  'para mudar de opinião, altere a avaliação existente.\n'
                  '• Cada nota deve estar entre 1 e 5.',
            ),
            const _InfoCard(
              titulo: 'Firestore',
              conteudo:
                  'Os dados principais (usuários, pessoas, avaliações e notas) '
                  'são armazenados remotamente no Cloud Firestore. Por isso você '
                  'acessa suas informações em outro dispositivo, bastando entrar '
                  'com a mesma conta.',
            ),
            const _InfoCard(
              titulo: 'Firebase Authentication',
              conteudo:
                  'O acesso ao aplicativo usa o Firebase Authentication, com '
                  'e-mail e senha ou com a sua conta Google. Sua senha nunca é '
                  'guardada no aparelho.',
            ),
            const _InfoCard(
              titulo: 'Tema claro e escuro',
              conteudo:
                  'O aplicativo permite alternar entre tema claro e escuro em '
                  'tempo de execução. Use o ícone de lua/sol na barra superior. '
                  'Sua escolha fica salva no aparelho (SharedPreferences).',
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Desenvolvido por alunos de TADS – IFPR Campus Paranaguá',
              textAlign: TextAlign.center,
              style: context.textStyles.bodySmall
                  ?.withColor(cores.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String titulo;
  final String conteudo;
  const _InfoCard({required this.titulo, required this.conteudo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: context.textStyles.titleMedium?.semiBold
                      .withColor(Theme.of(context).colorScheme.primary)),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: Text(conteudo, style: context.textStyles.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
