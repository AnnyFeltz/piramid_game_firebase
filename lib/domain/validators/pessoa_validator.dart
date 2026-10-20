import '../models/pessoa.dart';

/// Regras de validação do cadastro de pessoa (retorna a mensagem de erro ou null).
class PessoaValidator {
  PessoaValidator._();

  static String? validar(Pessoa pessoa) {
    if (pessoa.nome.trim().isEmpty) return 'Informe o nome da pessoa.';
    if (pessoa.turmaAno < Pessoa.turmaMinima ||
        pessoa.turmaAno > Pessoa.turmaMaxima) {
      return 'A turma/ano deve estar entre ${Pessoa.turmaMinima} e '
          '${Pessoa.turmaMaxima}.';
    }
    if (pessoa.dataNascimento.isAfter(DateTime.now())) {
      return 'A data de nascimento não pode estar no futuro.';
    }
    return null;
  }
}
