/// Falhas da aplicação. Viajam dentro de um `Result` (padrão Result), nunca
/// como exceções soltas entre as camadas.
sealed class Failure implements Exception {
  final String msg;
  Failure(this.msg);
  @override
  String toString() => '$runtimeType: $msg';
}

class DefaultFailure extends Failure {
  DefaultFailure([String? msg]) : super(msg ?? 'Erro inesperado.');
}

/// Erro no armazenamento local auxiliar (SharedPreferences).
class ApiLocalFailure extends Failure {
  ApiLocalFailure([String? msg])
      : super(msg ?? 'Erro ao acessar armazenamento local.');
}

class EmptyResultFailure extends Failure {
  EmptyResultFailure([String? msg]) : super(msg ?? 'Nenhum dado encontrado.');
}

class InputFailure extends Failure {
  InputFailure([String? msg]) : super(msg ?? 'Entrada inválida.');
}

/// Erro do Firebase Authentication (ou usuário não autenticado).
class AuthFailure extends Failure {
  AuthFailure([String? msg]) : super(msg ?? 'Usuário não autenticado.');
}

/// Erro de comunicação com o Firestore.
class FirestoreFailure extends Failure {
  FirestoreFailure([String? msg])
      : super(msg ?? 'Erro ao acessar o banco de dados remoto.');
}

/// Violação de regra de negócio (autoavaliação, avaliação duplicada,
/// alterar pessoa de outro usuário...).
class BusinessRuleFailure extends Failure {
  BusinessRuleFailure([String? msg]) : super(msg ?? 'Operação não permitida.');
}
