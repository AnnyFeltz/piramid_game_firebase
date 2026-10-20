import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/messages/app_messages.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/auth_viewmodel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  /// Fluxo da especificação: Splash → verificar autenticação →
  /// (autenticado) Home | (não autenticado) Login.
  /// A Splash fica visível por pelo menos 2 segundos.
  Future<void> _iniciar() async {
    final vm = injector.get<AuthViewModel>();
    final tempoMinimo = Future<void>.delayed(const Duration(seconds: 2));

    final autenticado = await vm.verificarAutenticacao();
    await tempoMinimo;

    if (!mounted) return;
    context.goNamed(autenticado ? AppRouteNames.home : AppRouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events,
                  size: 72, color: Colors.amber),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'PiramidGame',
              style: context.textStyles.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppMessages.appSubtitle,
              style: context.textStyles.titleMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppMessages.ifprCampus,
              style: context.textStyles.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              AppMessages.splashTagline,
              style: context.textStyles.bodyLarge?.copyWith(
                color: Colors.amber.shade200,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const CircularProgressIndicator(
              color: Colors.amber,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
