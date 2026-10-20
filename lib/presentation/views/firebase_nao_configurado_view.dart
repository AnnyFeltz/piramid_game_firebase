import 'package:flutter/material.dart';

import '../../core/messages/app_messages.dart';
import '../../core/theme/app_theme.dart';

/// Mostrada quando o Firebase ainda não foi configurado (arquivo
/// `firebase_options.dart` ainda é o modelo) ou falhou ao iniciar.
class FirebaseNaoConfiguradoView extends StatelessWidget {
  final String detalhe;
  const FirebaseNaoConfiguradoView({super.key, required this.detalhe});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(Icons.cloud_off, size: 72, color: cores.error),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Text(AppMessages.appName,
                        style: context.textStyles.headlineSmall?.bold
                            .withColor(cores.primary)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Firebase não configurado',
                      style: context.textStyles.titleLarge?.semiBold),
                  const SizedBox(height: AppSpacing.sm),
                  Text(detalhe, style: context.textStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Como configurar',
                      style: context.textStyles.titleMedium?.semiBold),
                  const SizedBox(height: AppSpacing.sm),
                  const SelectableText(
                    '1. Crie um projeto no console do Firebase.\n'
                    '2. Ative Authentication (E-mail/senha e Google) e o Firestore.\n'
                    '3. No terminal, dentro da pasta do projeto:\n'
                    '     dart pub global activate flutterfire_cli\n'
                    '     flutterfire configure\n'
                    '4. Publique as regras do arquivo firestore.rules.\n'
                    '5. Rode o app de novo.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
