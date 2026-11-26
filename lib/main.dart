import 'package:flutter/material.dart';
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

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 248,
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.lg,
                    ),
                    child: _BrandMark(),
                  ),
                  Expanded(
                    child: NavigationRail(
                      extended: true,
                      selectedIndex: _index,
                      onDestinationSelected: (value) =>
                          setState(() => _index = value),
                      labelType: NavigationRailLabelType.none,
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    child: ThemeSwitcherButton(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _pages[_index]),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  Color _markForeground(Color background, ColorScheme scheme) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
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
              color: _markForeground(palette.brandMark, scheme),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
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
