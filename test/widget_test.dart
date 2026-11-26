import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_theme.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_visual_theme.dart';

void main() {
  testWidgets('Tema claro renderiza', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: Center(child: Text('Gerenciamento de Obrigações')),
          ),
        ),
      ),
    );

    expect(find.text('Gerenciamento de Obrigações'), findsOneWidget);
  });

  test('temas light, dark e highContrast são gerados', () {
    for (final visual in AppVisualTheme.values) {
      final theme = AppTheme.of(visual);
      expect(theme.extensions, isNotEmpty);
      expect(theme.colorScheme.primary, isNot(equals(Colors.transparent)));
    }
  });
}
