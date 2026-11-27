import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_palette.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_spacing.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_theme.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/theme_controller.dart';
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

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _sidebarCollapsed = false;

  static const double _sidebarExpanded = 248;
  static const double _sidebarCollapsedWidth = 76;

  static const _pages = [
    ObrigacoesPage(),
    EmpresasPage(),
    UsuariosPage(),
  ];

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
            Expanded(child: _pages[_index]),
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

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: sidebarWidth,
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border(
                right: BorderSide(
                  color: palette.border,
                  width: palette.borderWidth,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      _sidebarCollapsed ? AppSpacing.sm : AppSpacing.lg,
                      AppSpacing.md,
                      _sidebarCollapsed ? AppSpacing.sm : AppSpacing.sm,
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
                                    Icons.keyboard_double_arrow_right_rounded,
                                  ),
                                ),
                              ),
                              const _BrandMark(compact: true),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(child: _BrandMark()),
                              IconButton(
                                tooltip: 'Retrair menu',
                                visualDensity: VisualDensity.compact,
                                onPressed: () => setState(
                                  () => _sidebarCollapsed = true,
                                ),
                                icon: const Icon(
                                  Icons.keyboard_double_arrow_left_rounded,
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
                      labelType: _sidebarCollapsed
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.none,
                      minWidth: 56,
                      minExtendedWidth: 220,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.assignment_outlined),
                          selectedIcon: Icon(Icons.assignment_rounded),
                          label: Text('Obrigações'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.apartment_outlined),
                          selectedIcon: Icon(Icons.apartment_rounded),
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
                        ? const Center(child: ThemeSwitcherButton(compact: true))
                        : const ThemeSwitcherButton(),
                  ),
                ],
              ),
            ),
          ),
          // Right pane: page owns list + footer; FAB floats above footer.
          Expanded(child: _pages[_index]),
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
