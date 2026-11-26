import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/data/obrigacao_repository.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/models/obrigacao.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/presentation/obrigacao_detail_page.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/presentation/obrigacao_form_page.dart';

final obrigacoesProvider =
    FutureProvider.autoDispose.family<List<Obrigacao>, String?>((ref, status) {
  return ref.watch(obrigacaoRepositoryProvider).listar(status: status);
});

class ObrigacoesPage extends ConsumerStatefulWidget {
  const ObrigacoesPage({super.key});

  @override
  ConsumerState<ObrigacoesPage> createState() => _ObrigacoesPageState();
}

class _ObrigacoesPageState extends ConsumerState<ObrigacoesPage> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    final obrigacoesAsync = ref.watch(obrigacoesProvider(_status));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Obrigações'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _status,
              hint: const Text('Status', style: TextStyle(color: Colors.white)),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: 'PENDENTE', child: Text('Pendente')),
                DropdownMenuItem(
                    value: 'EM_ANDAMENTO', child: Text('Em andamento')),
                DropdownMenuItem(value: 'CONCLUIDA', child: Text('Concluída')),
              ],
              onChanged: (value) => setState(() => _status = value),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final salvou = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const ObrigacaoFormPage()),
          );
          if (salvou == true) {
            ref.invalidate(obrigacoesProvider(_status));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: obrigacoesAsync.when(
        data: (obrigacoes) {
          if (obrigacoes.isEmpty) {
            return const Center(child: Text('Nenhuma obrigação cadastrada.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(obrigacoesProvider(_status)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: obrigacoes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = obrigacoes[index];
                return Card(
                  child: ListTile(
                    title: Text(item.titulo),
                    subtitle: Text(
                      '${item.empresaRazaoSocial}\n'
                      'Responsável: ${item.usuarioNome} • Prazo: ${item.prazo}',
                    ),
                    isThreeLine: true,
                    trailing: Chip(label: Text(item.statusLabel)),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ObrigacaoDetailPage(id: item.id),
                        ),
                      );
                      ref.invalidate(obrigacoesProvider(_status));
                    },
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
}
