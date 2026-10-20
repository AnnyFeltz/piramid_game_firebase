import 'package:signals_flutter/signals_flutter.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/auth_facade_usecases_interface.dart';
import '../../domain/models/usuario.dart';

/// ViewModel de autenticação. A UI só conversa com ele: nunca com o Firebase.
class AuthViewModel {
  final IAuthFacade _facade;

  AuthViewModel({required IAuthFacade facade}) : _facade = facade;

  // ── Estado (Signals) ───────────────────────────────────────────────────────
  /// Usuário autenticado (null = ninguém logado).
  final usuario = signal<Usuario?>(null);
  final message = signal<String?>(null);
  late final isAuthenticated = computed(() => usuario.value != null);

  // ── Commands ───────────────────────────────────────────────────────────────
  late final loginCommand =
      FunctionCommand<Usuario, CredenciaisParams>(_facade.login);
  late final cadastrarUsuarioCommand =
      FunctionCommand<Usuario, CredenciaisParams>(_facade.criarConta);
  late final loginGoogleCommand =
      FunctionCommand<Usuario, NoParams>(_facade.loginComGoogle);
  late final verificarAutenticacaoCommand =
      FunctionCommand<Usuario, NoParams>(_facade.verificarAutenticacao);
  late final logoutCommand = FunctionCommand<void, NoParams>(_facade.logout);

  late final isLoading = computed(() =>
      loginCommand.isExecuting.value ||
      cadastrarUsuarioCommand.isExecuting.value ||
      loginGoogleCommand.isExecuting.value);

  // ── Ações chamadas pela UI ─────────────────────────────────────────────────
  Future<bool> verificarAutenticacao() async {
    final result = await verificarAutenticacaoCommand.executeWith(());
    return _aplicarUsuario(result, mostrarErro: false);
  }

  Future<bool> login(String email, String senha) async {
    message.value = null;
    final result = await loginCommand.executeWith((email: email, senha: senha));
    return _aplicarUsuario(result);
  }

  Future<bool> criarConta(String email, String senha) async {
    message.value = null;
    final result =
        await cadastrarUsuarioCommand.executeWith((email: email, senha: senha));
    return _aplicarUsuario(result);
  }

  Future<bool> loginComGoogle() async {
    message.value = null;
    final result = await loginGoogleCommand.executeWith(());
    return _aplicarUsuario(result);
  }

  Future<bool> logout() async {
    final result = await logoutCommand.executeWith(());
    return result.fold<bool>(
      onSuccess: (_) {
        usuario.value = null;
        message.value = null;
        return true;
      },
      onFailure: (f) {
        message.value = f.msg;
        return false;
      },
    );
  }

  void limparMensagem() => message.value = null;

  bool _aplicarUsuario(Result<Usuario, Failure> result,
      {bool mostrarErro = true}) {
    return result.fold<bool>(
      onSuccess: (u) {
        usuario.value = u;
        message.value = null;
        return true;
      },
      onFailure: (f) {
        usuario.value = null;
        if (mostrarErro) message.value = f.msg;
        return false;
      },
    );
  }
}
