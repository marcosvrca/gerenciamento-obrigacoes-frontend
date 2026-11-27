import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/shell/shell_pagination.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_palette.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_theme.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/theme_controller.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/list_pagination.dart';
import 'package:gerenciamento_obrigacoes_app/core/widgets/theme_switcher.dart';
import 'package:gerenciamento_obrigacoes_app/features/empresas/presentation/empresas_page.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/presentation/obrigacoes_page.dart';
import 'package:gerenciamento_obrigacoes_app/features/usuarios/presentation/usuarios_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: GerenciamentoObrigacoesApp()));
}

class GerenciamentoObrigacoesApp extends ConsumerWidget {
  const GerenciamentoObrigacoesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visualTheme = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Gerenciamento de Obrigações',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(visualTheme),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;
  bool _sidebarCollapsed = false;

  static const double _sidebarExpanded = 248;
  static const double _sidebarCollapsedWidth = 76;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.assignment_outlined),
      selectedIcon: Icon(Icons.assignment_rounded),
      label: 'Obrigações',
    ),
    NavigationDestination(
      icon: Icon(Icons.apartment_outlined),
      selectedIcon: Icon(Icons.apartment_rounded),
      label: 'Empresas',
    ),
    NavigationDestination(
      icon: Icon(Icons.group_outlined),
      selectedIcon: Icon(Icons.group_rounded),
      label: 'Usuários',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final palette = AppPalette.of(context);

    // Keep all modules mounted so each tab's pagination slot stays warm and
    // switches with the shell in the same frame (no deferred footer).
    const pages = [
      ObrigacoesPage(shellTabIndex: 0),
      EmpresasPage(shellTabIndex: 1),
      UsuariosPage(shellTabIndex: 2),
    ];

    if (!wide) {
      return Scaffold(
        body: Column(
          children: [
            const SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: ThemeSwitcherButton(),
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _index,
                sizing: StackFit.expand,
                children: pages,
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: _destinations,
        ),
      );
    }

    final sidebarWidth =
        _sidebarCollapsed ? _sidebarCollapsedWidth : _sidebarExpanded;
    final slots = ref.watch(shellPaginationSlotsProvider);
    final shellPagination = slots[_index];

    // One continuous chrome: sidebar + bottom pagination share [palette.surface]
    // with no seam/border between them. Content sits in the remaining region.
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: sidebarWidth,
                  color: palette.surface,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: palette.border,
                          width: palette.borderWidth,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              _sidebarCollapsed
                                  ? AppSpacing.sm
                                  : AppSpacing.lg,
                              AppSpacing.md,
                              _sidebarCollapsed
                                  ? AppSpacing.sm
                                  : AppSpacing.sm,
                              AppSpacing.sm,
                            ),
                            child: _sidebarCollapsed
                                ? Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          tooltip: 'Expandir menu',
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () => setState(
                                            () => _sidebarCollapsed = false,
                                          ),
                                          icon: const Icon(
                                            Icons
                                                .keyboard_double_arrow_right_rounded,
                                          ),
                                        ),
                                      ),
                                      const _BrandMark(compact: true),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(child: _BrandMark()),
                                      IconButton(
                                        tooltip: 'Retrair menu',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => setState(
                                          () => _sidebarCollapsed = true,
                                        ),
                                        icon: const Icon(
                                          Icons
                                              .keyboard_double_arrow_left_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          Expanded(
                            child: NavigationRail(
                              extended: !_sidebarCollapsed,
                              selectedIndex: _index,
                              onDestinationSelected: (value) =>
                                  setState(() => _index = value),
                              labelType: NavigationRailLabelType.none,
                              minWidth: 56,
                              minExtendedWidth: 220,
                              destinations: const [
                                NavigationRailDestination(
                                  icon: Icon(Icons.assignment_outlined),
                                  selectedIcon:
                                      Icon(Icons.assignment_rounded),
                                  label: Text('Obrigações'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.apartment_outlined),
                                  selectedIcon:
                                      Icon(Icons.apartment_rounded),
                                  label: Text('Empresas'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.group_outlined),
                                  selectedIcon: Icon(Icons.group_rounded),
                                  label: Text('Usuários'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              _sidebarCollapsed ? 4 : AppSpacing.lg,
                              AppSpacing.sm,
                              _sidebarCollapsed ? 4 : AppSpacing.lg,
                              AppSpacing.lg,
                            ),
                            child: _sidebarCollapsed
                                ? const Center(
                                    child:
                                        ThemeSwitcherButton(compact: true),
                                  )
                                : const ThemeSwitcherButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _index,
                    sizing: StackFit.expand,
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
          // Pagination is part of the same shell surface (not a separate footer).
          ColoredBox(
            color: palette.surface,
            child: shellPagination == null
                ? const SizedBox.shrink()
                : ListPaginationBar(
                    page: shellPagination.page,
                    totalItems: shellPagination.totalItems,
                    onPageChanged: shellPagination.onPageChanged,
                    embeddedInShell: true,
                  ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.compact = false});

  final bool compact;

  Color _markForeground(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);

    final mark = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: palette.brandMark,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: palette.border,
          width: palette.borderWidth,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'GO',
        style: textTheme.titleSmall?.copyWith(
          color: _markForeground(palette.brandMark),
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    if (compact) {
      return Center(child: mark);
    }

    return Row(
      children: [
        mark,
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Obrigações',
                style: textTheme.titleMedium?.copyWith(
                  color: palette.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Escritório contábil',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
