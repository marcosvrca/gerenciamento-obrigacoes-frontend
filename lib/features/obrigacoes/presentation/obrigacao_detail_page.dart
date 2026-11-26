import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/navigation/app_page_route.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_palette.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/empty_state.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/list_skeleton.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/page_header.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/status_badge.dart';
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
        title: const Text('Detalhe'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final atual = obrigacaoAsync.valueOrNull;
              if (atual == null || atual.status == 'CONCLUIDA') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Obrigações concluídas não podem ser editadas.'),
                  ),
                );
                return;
              }
              final salvou = await Navigator.of(context).push<bool>(
                AppPageRoute(page: ObrigacaoFormPage(obrigacao: atual)),
              );
              if (salvou == true) {
                ref.invalidate(obrigacaoDetailProvider(id));
              }
            },
          ),
        ],
      ),
      body: ContentWidth(
        child: obrigacaoAsync.when(
          data: (obrigacao) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(obrigacaoDetailProvider(id));
                ref.invalidate(anexosProvider(id));
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.xxl,
                ),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          obrigacao.titulo,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      StatusBadge(status: obrigacao.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    obrigacao.descricao?.isNotEmpty == true
                        ? obrigacao.descricao!
                        : 'Sem descrição',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Builder(
                    builder: (context) {
                      final palette = AppPalette.of(context);
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(
                            color: palette.border,
                            width: palette.borderWidth,
                          ),
                        ),
                        child: Column(
                          children: [
                            _InfoRow(label: 'Prazo', value: obrigacao.prazo),
                            const Divider(height: AppSpacing.xl),
                            _InfoRow(
                              label: 'Empresa',
                              value: obrigacao.empresaRazaoSocial,
                            ),
                            const Divider(height: AppSpacing.xl),
                            _InfoRow(
                              label: 'Responsável',
                              value: obrigacao.usuarioNome,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (obrigacao.proximoStatus != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: () => _avancarStatus(context, ref, obrigacao),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        'Avançar para ${_label(obrigacao.proximoStatus!)}',
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    children: [
                      Text(
                        'Anexos',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () => _upload(context, ref),
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('Enviar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  anexosAsync.when(
                    data: (anexos) {
                      if (anexos.isEmpty) {
                        return const EmptyState(
                          icon: Icons.attach_file_outlined,
                          title: 'Nenhum anexo',
                          subtitle: 'Envie documentos relacionados a esta obrigação.',
                        );
                      }
                      return Column(
                        children: anexos
                            .map(
                              (anexo) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: Builder(
                                  builder: (context) {
                                    final palette = AppPalette.of(context);
                                    final scheme =
                                        Theme.of(context).colorScheme;
                                    return Material(
                                  color: palette.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.md),
                                    side: BorderSide(
                                      color: palette.border,
                                      width: palette.borderWidth,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.attach_file_rounded,
                                      color: scheme.primary,
                                    ),
                                    title: Text(anexo.nomeOriginal),
                                    subtitle:
                                        Text('${anexo.tamanhoBytes} bytes'),
                                    trailing: IconButton(
                                      tooltip: 'Baixar',
                                      icon: const Icon(
                                        Icons.download_outlined,
                                      ),
                                      onPressed: () =>
                                          _download(context, ref, anexo),
                                    ),
                                  ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const SizedBox(
                      height: 160,
                      child: ListSkeleton(itemCount: 2),
                    ),
                    error: (e, _) => Text(extractErrorMessage(e)),
                  ),
                ],
              ),
            );
          },
          loading: () => const DetailSkeleton(),
          error: (e, _) => ErrorState(
            message: extractErrorMessage(e),
            onRetry: () => ref.invalidate(obrigacaoDetailProvider(id)),
          ),
        ),
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

  Future<void> _download(
    BuildContext context,
    WidgetRef ref,
    Anexo anexo,
  ) async {
    try {
      final bytes = await ref.read(anexoRepositoryProvider).download(anexo.id);
      if (kIsWeb) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Download concluído (visualização local no web é limitada).',
              ),
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
    final textTheme = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: palette.muted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyLarge?.copyWith(color: palette.ink),
          ),
        ),
      ],
    );
  }
}
