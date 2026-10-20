import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/auth_viewmodel.dart';

/// Criação de conta (Firebase Authentication) com e-mail e senha.
class CadastroUsuarioView extends StatefulWidget {
  const CadastroUsuarioView({super.key});

  @override
  State<CadastroUsuarioView> createState() => _CadastroUsuarioViewState();
}

class _CadastroUsuarioViewState extends State<CadastroUsuarioView> {
  late final AuthViewModel _vm;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaCtrl = TextEditingController();
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
    _confirmaCtrl.dispose();
    super.dispose();
  }

  Future<void> _criarConta() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _vm.criarConta(_emailCtrl.text, _senhaCtrl.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );
      context.goNamed(AppRouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(AppRouteNames.login),
        ),
      ),
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
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        helperText: 'Mínimo de 6 caracteres',
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
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe a senha';
                        if (v.length < 6) return 'Use pelo menos 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _confirmaCtrl,
                      obscureText: _ocultarSenha,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _criarConta(),
                      decoration: const InputDecoration(
                        labelText: 'Confirmar senha',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v != _senhaCtrl.text ? 'As senhas não conferem' : null,
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
                      return FilledButton(
                        onPressed: carregando ? null : _criarConta,
                        style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52)),
                        child: carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Criar conta'),
                      );
                    }),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () => context.goNamed(AppRouteNames.login),
                      child: const Text('Já tenho conta'),
                    ),
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
