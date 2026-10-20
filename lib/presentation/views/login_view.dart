import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/messages/app_messages.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final AuthViewModel _vm;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _ocultarSenha = true;

  @override
  void initState() {
    super.initState();
    _vm = injector.get<AuthViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.limparMensagem());
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _vm.login(_emailCtrl.text, _senhaCtrl.text);
    if (!mounted) return;
    if (ok) context.goNamed(AppRouteNames.home);
  }

  Future<void> _entrarComGoogle() async {
    final ok = await _vm.loginComGoogle();
    if (!mounted) return;
    if (ok) context.goNamed(AppRouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.emoji_events, size: 72, color: cores.secondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      AppMessages.appName,
                      textAlign: TextAlign.center,
                      style: context.textStyles.headlineSmall?.bold
                          .withColor(cores.primary),
                    ),
                    Text(
                      AppMessages.ifprCampus,
                      textAlign: TextAlign.center,
                      style: context.textStyles.bodyMedium
                          ?.withColor(cores.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Informe o e-mail';
                        if (!t.contains('@') || !t.contains('.')) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _senhaCtrl,
                      obscureText: _ocultarSenha,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _entrar(),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_ocultarSenha
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () =>
                              setState(() => _ocultarSenha = !_ocultarSenha),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe a senha' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Erros de autenticação são informados ao usuário.
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
                            Expanded(
                              child: Text(msg,
                                  style: TextStyle(color: cores.error)),
                            ),
                          ],
                        ),
                      );
                    }),

                    Watch((_) {
                      final carregando = _vm.isLoading.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton(
                            onPressed: carregando ? null : _entrar,
                            style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52)),
                            child: carregando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Entrar'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md),
                                child: Text('ou',
                                    style: context.textStyles.bodySmall),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: carregando ? null : _entrarComGoogle,
                            icon: const Icon(Icons.account_circle),
                            label: const Text('Entrar com Google'),
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52)),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: carregando
                                ? null
                                : () => context
                                    .goNamed(AppRouteNames.cadastroUsuario),
                            child: const Text('Não tem conta? Criar conta'),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
