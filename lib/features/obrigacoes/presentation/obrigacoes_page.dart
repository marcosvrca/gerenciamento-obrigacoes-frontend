import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/navigation/app_page_route.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/empty_state.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/entity_card.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/list_pagination.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/list_skeleton.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/page_header.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/status_badge.dart';
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
  int _page = 0;

  void _setStatus(String? value) {
    setState(() {
      _status = value;
      _page = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final obrigacoesAsync = ref.watch(obrigacoesProvider(_status));
    final items = obrigacoesAsync.valueOrNull ?? const <Obrigacao>[];
    final showPagination = ListPagination.shouldShow(items.length);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final salvou = await Navigator.of(context).push<bool>(
            AppPageRoute(page: const ObrigacaoFormPage()),
          );
          if (salvou == true) {
            ref.invalidate(obrigacoesProvider(_status));
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova obrigação'),
      ),
      bottomNavigationBar: showPagination
          ? ListPaginationBar(
              page: _page,
              totalItems: items.length,
              onPageChanged: (page) => setState(() => _page = page),
            )
          : null,
      body: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'Obrigações',
              subtitle: 'Acompanhe prazos, responsáveis e status das demandas.',
            ),
            FilterChipsBar(
              label: 'Status',
              selected: _status,
              onSelected: _setStatus,
              options: const [
                FilterOption(label: 'Todas'),
                FilterOption(label: 'Pendentes', value: 'PENDENTE'),
                FilterOption(label: 'Em andamento', value: 'EM_ANDAMENTO'),
                FilterOption(label: 'Concluídas', value: 'CONCLUIDA'),
              ],
            ),
            Expanded(
              child: obrigacoesAsync.when(
                data: (obrigacoes) {
                  if (obrigacoes.isEmpty) {
                    return const EmptyState(
                      icon: Icons.assignment_outlined,
                      title: 'Nenhuma obrigação neste filtro',
                      subtitle:
                          'Crie uma nova obrigação ou ajuste o status selecionado.',
                    );
                  }
                  return PaginatedEntityList<Obrigacao>(
                    items: obrigacoes,
                    page: _page,
                    bottomClearanceForFab: !showPagination,
                    onRefresh: () async =>
                        ref.invalidate(obrigacoesProvider(_status)),
                    itemBuilder: (context, item) {
                      return EntityCard(
                        leading: const AvatarMark(
                          label: 'O',
                          icon: Icons.assignment_outlined,
                        ),
                        title: item.titulo,
                        subtitle:
                            '${item.empresaRazaoSocial}\n'
                            'Responsável: ${item.usuarioNome}  ·  Prazo: ${item.prazo}',
                        trailing: StatusBadge(status: item.status),
                        onTap: () async {
                          await Navigator.of(context).push(
                            AppPageRoute(
                              page: ObrigacaoDetailPage(id: item.id),
                            ),
                          );
                          ref.invalidate(obrigacoesProvider(_status));
                        },
                      );
                    },
                  );
                },
                loading: () => const ListSkeleton(),
                error: (error, _) => ErrorState(
                  message: extractErrorMessage(error),
                  onRetry: () =>
                      ref.invalidate(obrigacoesProvider(_status)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
