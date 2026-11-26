import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/features/usuarios/data/usuario_repository.dart';
import 'package:gerenciamento_obrigacoes_app/features/usuarios/models/usuario.dart';

final usuariosProvider =
    FutureProvider.autoDispose.family<List<Usuario>, String?>((ref, situacao) {
  return ref.watch(usuarioRepositoryProvider).listar(situacao: situacao);
});

class UsuariosPage extends ConsumerStatefulWidget {
  const UsuariosPage({super.key});

  @override
  ConsumerState<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends ConsumerState<UsuariosPage> {
  String? _filtro;

  @override
  Widget build(BuildContext context) {
    final usuariosAsync = ref.watch(usuariosProvider(_filtro));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _filtro,
              hint: const Text('Situação', style: TextStyle(color: Colors.white)),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: 'ATIVO', child: Text('Ativos')),
                DropdownMenuItem(value: 'INATIVO', child: Text('Inativos')),
              ],
              onChanged: (value) => setState(() => _filtro = value),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: usuariosAsync.when(
        data: (usuarios) {
          if (usuarios.isEmpty) {
            return const Center(child: Text('Nenhum usuário cadastrado.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(usuariosProvider(_filtro)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: usuarios.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return Card(
                  child: ListTile(
                    title: Text(usuario.nome),
                    subtitle: Text(usuario.email),
                    trailing: Chip(
                      label: Text(usuario.situacao),
                      backgroundColor: usuario.ativo
                          ? Colors.green.shade50
                          : Colors.grey.shade200,
                    ),
                    onTap: () => _abrirFormulario(usuario: usuario),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(extractErrorMessage(error))),
      ),
    );
  }

  Future<void> _abrirFormulario({Usuario? usuario}) async {
    final salvou = await showDialog<bool>(
      context: context,
      builder: (_) => _UsuarioFormDialog(usuario: usuario),
    );
    if (salvou == true) {
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _situacao,
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
