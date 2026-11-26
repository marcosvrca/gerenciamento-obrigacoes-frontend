import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/features/anexos/data/anexo_repository.dart';
import 'package:gerenciamento_obrigacoes_app/features/anexos/models/anexo.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/data/obrigacao_repository.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/models/obrigacao.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/presentation/obrigacao_form_page.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

final obrigacaoDetailProvider =
    FutureProvider.autoDispose.family<Obrigacao, int>((ref, id) {
  return ref.watch(obrigacaoRepositoryProvider).buscar(id);
});

final anexosProvider =
    FutureProvider.autoDispose.family<List<Anexo>, int>((ref, obrigacaoId) {
  return ref.watch(anexoRepositoryProvider).listar(obrigacaoId);
});

class ObrigacaoDetailPage extends ConsumerWidget {
  const ObrigacaoDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obrigacaoAsync = ref.watch(obrigacaoDetailProvider(id));
    final anexosAsync = ref.watch(anexosProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da obrigação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final atual = obrigacaoAsync.valueOrNull;
              if (atual == null || atual.status == 'CONCLUIDA') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Obrigações concluídas não podem ser editadas.'),
                  ),
                );
                return;
              }
              final salvou = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => ObrigacaoFormPage(obrigacao: atual),
                ),
              );
              if (salvou == true) {
                ref.invalidate(obrigacaoDetailProvider(id));
              }
            },
          ),
        ],
      ),
      body: obrigacaoAsync.when(
        data: (obrigacao) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(obrigacaoDetailProvider(id));
              ref.invalidate(anexosProvider(id));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(obrigacao.titulo, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(obrigacao.descricao?.isNotEmpty == true
                    ? obrigacao.descricao!
                    : 'Sem descrição'),
                const SizedBox(height: 16),
                _InfoRow(label: 'Status', value: obrigacao.statusLabel),
                _InfoRow(label: 'Prazo', value: obrigacao.prazo),
                _InfoRow(label: 'Empresa', value: obrigacao.empresaRazaoSocial),
                _InfoRow(label: 'Responsável', value: obrigacao.usuarioNome),
                const SizedBox(height: 16),
                if (obrigacao.proximoStatus != null)
                  FilledButton.icon(
                    onPressed: () => _avancarStatus(context, ref, obrigacao),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text('Avançar para ${_label(obrigacao.proximoStatus!)}'),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text('Anexos', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _upload(context, ref),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Enviar'),
                    ),
                  ],
                ),
                anexosAsync.when(
                  data: (anexos) {
                    if (anexos.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Nenhum anexo.'),
                      );
                    }
                    return Column(
                      children: anexos
                          .map(
                            (anexo) => Card(
                              child: ListTile(
                                leading: const Icon(Icons.attach_file),
                                title: Text(anexo.nomeOriginal),
                                subtitle: Text('${anexo.tamanhoBytes} bytes'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () => _download(context, ref, anexo),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Text(extractErrorMessage(e)),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(extractErrorMessage(e))),
      ),
    );
  }

  Future<void> _avancarStatus(
    BuildContext context,
    WidgetRef ref,
    Obrigacao obrigacao,
  ) async {
    try {
      await ref
          .read(obrigacaoRepositoryProvider)
          .atualizarStatus(obrigacao.id, obrigacao.proximoStatus!);
      ref.invalidate(obrigacaoDetailProvider(id));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractErrorMessage(e))),
        );
      }
    }
  }

  Future<void> _upload(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível ler o arquivo.')),
        );
      }
      return;
    }
    try {
      await ref.read(anexoRepositoryProvider).upload(
            obrigacaoId: id,
            fileName: file.name,
            bytes: bytes,
          );
      ref.invalidate(anexosProvider(id));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractErrorMessage(e))),
        );
      }
    }
  }

  Future<void> _download(BuildContext context, WidgetRef ref, Anexo anexo) async {
    try {
      final bytes = await ref.read(anexoRepositoryProvider).download(anexo.id);
      if (kIsWeb) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download concluído (visualização local no web é limitada).'),
            ),
          );
        }
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/${anexo.nomeOriginal}';
      final file = File(path);
      await file.writeAsBytes(bytes);
      await OpenFilex.open(path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractErrorMessage(e))),
        );
      }
    }
  }

  String _label(String status) {
    switch (status) {
      case 'EM_ANDAMENTO':
        return 'Em andamento';
      case 'CONCLUIDA':
        return 'Concluída';
      default:
        return status;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
