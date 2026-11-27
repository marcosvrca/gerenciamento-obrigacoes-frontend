import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/core/shell/shell_pagination.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/empty_state.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/entity_card.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/list_pagination.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/list_skeleton.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/page_create_fab.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/page_header.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/searchable_select_field.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/status_badge.dart';
import 'package:gerenciamento_obrigacoes_app/features/usuarios/data/usuario_repository.dart';
import 'package:gerenciamento_obrigacoes_app/features/usuarios/models/usuario.dart';

final usuariosProvider =
    FutureProvider.autoDispose.family<List<Usuario>, String?>((ref, situacao) {
  return ref.watch(usuarioRepositoryProvider).listar(situacao: situacao);
});

class UsuariosPage extends ConsumerStatefulWidget {
  const UsuariosPage({super.key, this.shellTabIndex = 2});

  /// Slot in the unified shell pagination map (desktop IndexedStack).
  final int shellTabIndex;

  @override
  ConsumerState<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends ConsumerState<UsuariosPage> {
  String? _filtro;
  int _page = 0;

  void _setFiltro(String? value) {
    setState(() {
      _filtro = value;
      _page = 0;
    });
  }

  void _clampPage(int totalItems) {
    final maxPage = ListPagination.pageCount(totalItems) - 1;
    if (_page > maxPage) {
      setState(() => _page = maxPage < 0 ? 0 : maxPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuariosAsync = ref.watch(usuariosProvider(_filtro));
    final items = usuariosAsync.valueOrNull ?? const <Usuario>[];
    // Always show pagination when there is at least one user (even page 1/1).
    final showPagination =
        ListPagination.shouldShow(items.length, always: true);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    ref.listen(usuariosProvider(_filtro), (previous, next) {
      next.whenData((list) => _clampPage(list.length));
    });

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: PageCreateFab(
        label: 'Novo usuário',
        liftAbovePagination: showPagination,
        onPressed: () => _abrirFormulario(),
      ),
      body: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'Usuários',
              subtitle: 'Responsáveis pelas obrigações do escritório.',
            ),
            FilterChipsBar(
              label: 'Situação',
              selected: _filtro,
              onSelected: _setFiltro,
              options: const [
                FilterOption(label: 'Todos'),
                FilterOption(label: 'Ativos', value: 'ATIVO'),
                FilterOption(label: 'Inativos', value: 'INATIVO'),
              ],
            ),
            Expanded(
              child: usuariosAsync.when(
                data: (usuarios) {
                  if (usuarios.isEmpty) {
                    return const EmptyState(
                      icon: Icons.group_outlined,
                      title: 'Nenhum usuário cadastrado',
                      subtitle:
                          'Cadastre responsáveis para atribuir obrigações.',
                    );
                  }
                  return PaginatedEntityList<Usuario>(
                    items: usuarios,
                    page: _page,
                    bottomClearanceForFab: !showPagination,
                    onRefresh: () async =>
                        ref.invalidate(usuariosProvider(_filtro)),
                    itemBuilder: (context, usuario) {
                      return EntityCard(
                        leading: AvatarMark(label: usuario.nome),
                        title: usuario.nome,
                        subtitle: usuario.email,
                        trailing: SituacaoBadge(
                          ativa: usuario.ativo,
                          label: usuario.situacao,
                        ),
                        onTap: () => _abrirFormulario(usuario: usuario),
                      );
                    },
                  );
                },
                loading: () => const ListSkeleton(),
                error: (error, _) => ErrorState(
                  message: extractErrorMessage(error),
                  onRetry: () => ref.invalidate(usuariosProvider(_filtro)),
                ),
              ),
            ),
            if (showPagination && !wide)
              ListPaginationBar(
                page: _page,
                totalItems: items.length,
                alwaysShow: true,
                onPageChanged: (page) => setState(() => _page = page),
              ),
            ShellPaginationBinder(
              tabIndex: widget.shellTabIndex,
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

  Future<void> _abrirFormulario({Usuario? usuario}) async {
    final salvou = await showDialog<bool>(
      context: context,
      builder: (_) => _UsuarioFormDialog(usuario: usuario),
    );
    if (salvou == true) {
      // Refresh list + pagination totals after create/edit.
      ref.invalidate(usuariosProvider(_filtro));
    }
  }
}

class _UsuarioFormDialog extends ConsumerStatefulWidget {
  const _UsuarioFormDialog({this.usuario});

  final Usuario? usuario;

  @override
  ConsumerState<_UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends ConsumerState<_UsuarioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _email;
  late String _situacao;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.usuario?.nome ?? '');
    _email = TextEditingController(text: widget.usuario?.email ?? '');
    _situacao = widget.usuario?.situacao ?? 'ATIVO';
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.usuario == null ? 'Novo usuário' : 'Editar usuário'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              SearchableSelectField<String>(
                label: 'Situação',
                value: _situacao,
                options: const [
                  SearchableSelectOption(value: 'ATIVO', label: 'Ativo'),
                  SearchableSelectOption(value: 'INATIVO', label: 'Inativo'),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _situacao = value);
                },
                validator: (v) =>
                    v == null ? 'Selecione a situação' : null,
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
      await ref.read(usuarioRepositoryProvider).salvar(
            id: widget.usuario?.id,
            body: {
              'nome': _nome.text.trim(),
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
