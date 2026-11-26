import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/theme/app_visual_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeStorageKey = 'app_visual_theme';

final themeControllerProvider =
    StateNotifierProvider<ThemeController, AppVisualTheme>((ref) {
  return ThemeController();
});

class ThemeController extends StateNotifier<AppVisualTheme> {
  ThemeController() : super(AppVisualTheme.light) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppVisualTheme.fromStorage(prefs.getString(_themeStorageKey));
  }

  Future<void> setTheme(AppVisualTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeStorageKey, theme.name);
  }
}
