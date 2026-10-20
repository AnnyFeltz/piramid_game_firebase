import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/pessoa.dart';
import '../controllers/auth_viewmodel.dart';
import '../controllers/pessoa_viewmodel.dart';

/// Cadastro / edição de pessoa (salva no Firestore).
///
/// Campos (especificação, itens 7 e 8):
///  • digitação: nome e apelido;
///  • seleção: curso (INFO, MEC, MAMB, PROD, TADS, TGA), turma/ano (1998–2026)
///    e data de nascimento (DatePicker).
class PessoaFormView extends StatefulWidget {
  /// null = nova pessoa; preenchido = edição.
  final Pessoa? pessoa;
  const PessoaFormView({super.key, this.pessoa});

  @override
  State<PessoaFormView> createState() => _PessoaFormViewState();
}

class _PessoaFormViewState extends State<PessoaFormView> {
  late final PessoaViewModel _vm;
  late final AuthViewModel _auth;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _apelidoCtrl;

  late Curso _curso;
  late int _turma;
  DateTime? _dataNascimento;
  late bool _souEu;
  bool _tentouSalvar = false;

  bool get _editando => widget.pessoa != null;

  @override
  void initState() {
    super.initState();
    _vm = injector.get<PessoaViewModel>();
    _auth = injector.get<AuthViewModel>();

    final p = widget.pessoa;
    _nomeCtrl = TextEditingController(text: p?.nome ?? '');
    _apelidoCtrl = TextEditingController(text: p?.apelido ?? '');
    _curso = p?.curso ?? Curso.info;
    _turma = p?.turmaAno ?? Pessoa.turmaMaxima;
    _dataNascimento = p?.dataNascimento;
    _souEu = p?.usuarioUid != null && p?.usuarioUid == _auth.usuario.value?.uid;

    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.message.value = null);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _apelidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final agora = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(agora.year - 17),
      firstDate: DateTime(1950),
      lastDate: agora,
      helpText: 'Data de nascimento',
    );
    if (escolhida != null) setState(() => _dataNascimento = escolhida);
  }

  Future<void> _salvar() async {
    setState(() => _tentouSalvar = true);
    final formularioOk = _formKey.currentState!.validate();
    if (!formularioOk || _dataNascimento == null) return;

    final uid = _auth.usuario.value?.uid;
    final original = widget.pessoa;

    final pessoa = Pessoa(
      id: original?.id ?? '', // o Firestore gera o id no cadastro
      nome: _nomeCtrl.text.trim(),
      apelido: _apelidoCtrl.text.trim(),
      curso: _curso,
      turmaAno: _turma,
      dataNascimento: _dataNascimento!,
      criadoPor: original?.criadoPor ?? uid ?? '', // o use case reforça isso
      usuarioUid: _souEu ? uid : null,
    );

    final ok = _editando
        ? await _vm.alterarPessoa(pessoa)
        : await _vm.cadastrarPessoa(pessoa);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_editando
            ? '${pessoa.nome} atualizada!'
            : '${pessoa.nome} cadastrada!'),
      ));
      context.pop();
    }
    // Se falhou, a mensagem aparece no próprio formulário (_vm.message).
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final semData = _tentouSalvar && _dataNascimento == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar pessoa' : 'Nova pessoa'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _tentouSalvar
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            padding: AppSpacing.paddingMd,
            children: [
              // ── Campos com digitação ───────────────────────────────────────
              TextFormField(
                controller: _nomeCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe o nome da pessoa'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _apelidoCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Apelido',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Campos com seleção ─────────────────────────────────────────
              DropdownButtonFormField<Curso>(
                initialValue: _curso,
                decoration: const InputDecoration(
                  labelText: 'Curso',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final c in Curso.values)
                    DropdownMenuItem(value: c, child: Text(c.displayName)),
                ],
                onChanged: (v) => setState(() => _curso = v ?? _curso),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<int>(
                initialValue: _turma,
                decoration: const InputDecoration(
                  labelText: 'Turma/ano',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (var ano = Pessoa.turmaMaxima;
                      ano >= Pessoa.turmaMinima;
                      ano--)
                    DropdownMenuItem(value: ano, child: Text('$ano')),
                ],
                onChanged: (v) => setState(() => _turma = v ?? _turma),
              ),
              const SizedBox(height: AppSpacing.md),

              // DatePicker para a data de nascimento.
              InkWell(
                onTap: _escolherData,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data de nascimento *',
                    prefixIcon: const Icon(Icons.cake),
                    suffixIcon: const Icon(Icons.edit_calendar),
                    border: const OutlineInputBorder(),
                    errorText:
                        semData ? 'Selecione a data de nascimento' : null,
                  ),
                  child: Text(
                    _dataNascimento == null
                        ? 'Toque para selecionar'
                        : DateFormat('dd/MM/yyyy').format(_dataNascimento!),
                    style: _dataNascimento == null
                        ? TextStyle(color: cores.onSurfaceVariant)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Relação usuário autenticado ⇄ pessoa (impede a autoavaliação).
              Card(
                child: CheckboxListTile(
                  value: _souEu,
                  onChanged: (v) => setState(() => _souEu = v ?? false),
                  title: const Text('Esta pessoa sou eu'),
                  subtitle: const Text(
                      'Vincula este cadastro à sua conta. Assim você não '
                      'consegue avaliar a si próprio.'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Erro vindo do Firestore / regras de negócio.
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
                          child: Text(msg, style: TextStyle(color: cores.error))),
                    ],
                  ),
                );
              }),

              Watch((_) {
                final salvando = _vm.cadastrarPessoaCommand.isExecuting.value ||
                    _vm.alterarPessoaCommand.isExecuting.value;
                return FilledButton.icon(
                  onPressed: salvando ? null : _salvar,
                  icon: salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(_editando ? 'Salvar alterações' : 'Cadastrar pessoa'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
