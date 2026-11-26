import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
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

  @override
  Widget build(BuildContext context) {
    final empresasAsync = ref.watch(empresasProvider(_filtro));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _filtro,
              hint: const Text('Situação', style: TextStyle(color: Colors.white)),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: const [
                DropdownMenuItem(value: null, child: Text('Todas')),
                DropdownMenuItem(value: 'ATIVO', child: Text('Ativas')),
                DropdownMenuItem(value: 'INATIVO', child: Text('Inativas')),
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
      body: empresasAsync.when(
        data: (empresas) {
          if (empresas.isEmpty) {
            return const Center(child: Text('Nenhuma empresa cadastrada.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(empresasProvider(_filtro)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: empresas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final empresa = empresas[index];
                return Card(
                  child: ListTile(
                    title: Text(empresa.razaoSocial),
                    subtitle: Text('${empresa.cnpj} • ${empresa.email}'),
                    trailing: Chip(
                      label: Text(empresa.situacao),
                      backgroundColor: empresa.ativa
                          ? Colors.green.shade50
                          : Colors.grey.shade200,
                    ),
                    onTap: () => _abrirFormulario(empresa: empresa),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _cnpj,
                decoration: const InputDecoration(labelText: 'CNPJ (14 dígitos)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || !RegExp(r'^\d{14}$').hasMatch(v)) {
                    return 'Informe 14 dígitos';
                  }
                  return null;
                },
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
