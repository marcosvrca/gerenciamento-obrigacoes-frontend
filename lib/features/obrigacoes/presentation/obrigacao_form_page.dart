import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_palette.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/list_skeleton.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/page_header.dart';
import 'package:gerenciamento_obrigacoes_app/features/empresas/data/empresa_repository.dart';
import 'package:gerenciamento_obrigacoes_app/features/empresas/models/empresa.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/data/obrigacao_repository.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/models/obrigacao.dart';
import 'package:gerenciamento_obrigacoes_app/features/usuarios/data/usuario_repository.dart';
import 'package:gerenciamento_obrigacoes_app/features/usuarios/models/usuario.dart';
import 'package:intl/intl.dart';

class ObrigacaoFormPage extends ConsumerStatefulWidget {
  const ObrigacaoFormPage({super.key, this.obrigacao});

  final Obrigacao? obrigacao;

  @override
  ConsumerState<ObrigacaoFormPage> createState() => _ObrigacaoFormPageState();
}

class _ObrigacaoFormPageState extends ConsumerState<ObrigacaoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _descricao;
  DateTime _prazo = DateTime.now().add(const Duration(days: 7));
  int? _empresaId;
  int? _usuarioId;
  bool _carregando = true;
  bool _salvando = false;
  List<Empresa> _empresas = [];
  List<Usuario> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _titulo = TextEditingController(text: widget.obrigacao?.titulo ?? '');
    _descricao = TextEditingController(text: widget.obrigacao?.descricao ?? '');
    if (widget.obrigacao != null) {
      _prazo = DateTime.parse(widget.obrigacao!.prazo);
      _empresaId = widget.obrigacao!.empresaId;
      _usuarioId = widget.obrigacao!.usuarioId;
    }
    _carregarOpcoes();
  }

  Future<void> _carregarOpcoes() async {
    try {
      final empresas =
          await ref.read(empresaRepositoryProvider).listar(situacao: 'ATIVO');
      final usuarios =
          await ref.read(usuarioRepositoryProvider).listar(situacao: 'ATIVO');

      if (widget.obrigacao != null) {
        if (!empresas.any((e) => e.id == widget.obrigacao!.empresaId)) {
          final todas = await ref.read(empresaRepositoryProvider).listar();
          empresas.addAll(
            todas.where((e) => e.id == widget.obrigacao!.empresaId),
          );
        }
        if (!usuarios.any((u) => u.id == widget.obrigacao!.usuarioId)) {
          final todos = await ref.read(usuarioRepositoryProvider).listar();
          usuarios.addAll(
            todos.where((u) => u.id == widget.obrigacao!.usuarioId),
          );
        }
      }

      setState(() {
        _empresas = empresas;
        _usuarios = usuarios;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractErrorMessage(e))),
        );
      }
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNova = widget.obrigacao == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNova ? 'Nova obrigação' : 'Editar obrigação'),
      ),
      body: _carregando
          ? const FormSkeleton()
          : ContentWidth(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    AppSpacing.xxl,
                  ),
                  children: [
                    Text(
                      isNova
                          ? 'Preencha os dados da obrigação.'
                          : 'Atualize os dados mantendo empresa e responsável.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _titulo,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descricao,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Builder(
                      builder: (context) {
                        final palette = AppPalette.of(context);
                        return Material(
                      color: palette.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        side: BorderSide(
                          color: palette.border,
                          width: palette.borderWidth,
                        ),
                      ),
                      child: ListTile(
                        title: const Text('Prazo'),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(_prazo)),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: _prazo,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (selected != null) {
                            setState(() => _prazo = selected);
                          }
                        },
                      ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<int>(
                      initialValue: _empresaId,
                      decoration: const InputDecoration(labelText: 'Empresa'),
                      items: _empresas
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(
                                '${e.razaoSocial}${e.ativa ? '' : ' (inativa)'}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _empresaId = value),
                      validator: (v) =>
                          v == null ? 'Selecione uma empresa' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<int>(
                      initialValue: _usuarioId,
                      decoration:
                          const InputDecoration(labelText: 'Responsável'),
                      items: _usuarios
                          .map(
                            (u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(
                                '${u.nome}${u.ativo ? '' : ' (inativo)'}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _usuarioId = value),
                      validator: (v) =>
                          v == null ? 'Selecione um responsável' : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: _salvando ? null : _salvar,
                      child: _salvando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      await ref.read(obrigacaoRepositoryProvider).salvar(
            id: widget.obrigacao?.id,
            body: {
              'titulo': _titulo.text.trim(),
              'descricao': _descricao.text.trim().isEmpty
                  ? null
                  : _descricao.text.trim(),
              'prazo': DateFormat('yyyy-MM-dd').format(_prazo),
              'empresaId': _empresaId,
              'usuarioId': _usuarioId,
            },
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}
