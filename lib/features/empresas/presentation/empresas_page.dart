import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/core/shell/shell_pagination.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/empty_state.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/entity_card.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/list_pagination.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/list_skeleton.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/page_header.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/status_badge.dart';
import 'package:gerenciamento_obrigacoes_app/features/empresas/data/empresa_repository.dart';
import 'package:gerenciamento_obrigacoes_app/features/empresas/models/empresa.dart';

final empresasProvider =
    FutureProvider.autoDispose.family<List<Empresa>, String?>((ref, situacao) {
  return ref.watch(empresaRepositoryProvider).listar(situacao: situacao);
});

class EmpresasPage extends ConsumerStatefulWidget {
  const EmpresasPage({super.key});

  @override
  ConsumerState<EmpresasPage> createState() => _EmpresasPageState();
}

class _EmpresasPageState extends ConsumerState<EmpresasPage> {
  String? _filtro;
  int _page = 0;

  void _setFiltro(String? value) {
    setState(() {
      _filtro = value;
      _page = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final empresasAsync = ref.watch(empresasProvider(_filtro));
    final items = empresasAsync.valueOrNull ?? const <Empresa>[];
    final showPagination = ListPagination.shouldShow(items.length);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova empresa'),
      ),
      body: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'Empresas',
              subtitle: 'Cadastro de clientes do escritório.',
            ),
            FilterChipsBar(
              label: 'Situação',
              selected: _filtro,
              onSelected: _setFiltro,
              options: const [
                FilterOption(label: 'Todas'),
                FilterOption(label: 'Ativas', value: 'ATIVO'),
                FilterOption(label: 'Inativas', value: 'INATIVO'),
              ],
            ),
            Expanded(
              child: empresasAsync.when(
                data: (empresas) {
                  if (empresas.isEmpty) {
                    return const EmptyState(
                      icon: Icons.apartment_outlined,
                      title: 'Nenhuma empresa cadastrada',
                      subtitle: 'Adicione a primeira empresa para começar.',
                    );
                  }
                  return PaginatedEntityList<Empresa>(
                    items: empresas,
                    page: _page,
                    bottomClearanceForFab: !showPagination,
                    onRefresh: () async =>
                        ref.invalidate(empresasProvider(_filtro)),
                    itemBuilder: (context, empresa) {
                      return EntityCard(
                        leading: AvatarMark(label: empresa.razaoSocial),
                        title: empresa.razaoSocial,
                        subtitle: '${empresa.cnpj}  ·  ${empresa.email}',
                        trailing: SituacaoBadge(
                          ativa: empresa.ativa,
                          label: empresa.situacao,
                        ),
                        onTap: () => _abrirFormulario(empresa: empresa),
                      );
                    },
                  );
                },
                loading: () => const ListSkeleton(),
                error: (error, _) => ErrorState(
                  message: extractErrorMessage(error),
                  onRetry: () => ref.invalidate(empresasProvider(_filtro)),
                ),
              ),
            ),
            if (showPagination && !wide)
              ListPaginationBar(
                page: _page,
                totalItems: items.length,
                onPageChanged: (page) => setState(() => _page = page),
              ),
            ShellPaginationBinder(
              enabled: wide && showPagination,
              page: _page,
              totalItems: items.length,
              onPageChanged: (page) => setState(() => _page = page),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirFormulario({Empresa? empresa}) async {
    final salvou = await showDialog<bool>(
      context: context,
      builder: (_) => _EmpresaFormDialog(empresa: empresa),
    );
    if (salvou == true) {
      ref.invalidate(empresasProvider(_filtro));
    }
  }
}

class _EmpresaFormDialog extends ConsumerStatefulWidget {
  const _EmpresaFormDialog({this.empresa});

  final Empresa? empresa;

  @override
  ConsumerState<_EmpresaFormDialog> createState() => _EmpresaFormDialogState();
}

class _EmpresaFormDialogState extends ConsumerState<_EmpresaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _razao;
  late final TextEditingController _cnpj;
  late final TextEditingController _email;
  late String _situacao;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _razao = TextEditingController(text: widget.empresa?.razaoSocial ?? '');
    _cnpj = TextEditingController(text: widget.empresa?.cnpj ?? '');
    _email = TextEditingController(text: widget.empresa?.email ?? '');
    _situacao = widget.empresa?.situacao ?? 'ATIVO';
  }

  @override
  void dispose() {
    _razao.dispose();
    _cnpj.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.empresa == null ? 'Nova empresa' : 'Editar empresa'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _razao,
                decoration: const InputDecoration(labelText: 'Razão social'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _cnpj,
                decoration:
                    const InputDecoration(labelText: 'CNPJ (14 dígitos)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || !RegExp(r'^\d{14}$').hasMatch(v)
                        ? 'Informe 14 dígitos'
                        : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _situacao,
                decoration: const InputDecoration(labelText: 'Situação'),
                items: const [
                  DropdownMenuItem(value: 'ATIVO', child: Text('Ativo')),
                  DropdownMenuItem(value: 'INATIVO', child: Text('Inativo')),
                ],
                onChanged: (value) => setState(() => _situacao = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: _salvando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      await ref.read(empresaRepositoryProvider).salvar(
            id: widget.empresa?.id,
            body: {
              'razaoSocial': _razao.text.trim(),
              'cnpj': _cnpj.text.trim(),
              'email': _email.text.trim(),
              'situacao': _situacao,
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
