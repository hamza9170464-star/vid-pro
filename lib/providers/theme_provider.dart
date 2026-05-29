import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_option.dart';
import 'storage_provider.dart';

class ThemeNotifier extends StateNotifier<ThemeOption> {
  final Ref _ref;

  ThemeNotifier(this._ref) : super(ThemeOption.darkRed) {
    _loadTheme();
  }

  void _loadTheme() {
    try {
      final storage = _ref.read(storageServiceProvider);
      state = storage.getSelectedTheme();
    } catch (_) {
      state = ThemeOption.darkRed;
    }
  }

  Future<void> setTheme(ThemeOption option) async {
    state = option;
    try {
      final storage = _ref.read(storageServiceProvider);
      await storage.saveSelectedTheme(option);
    } catch (_) {}
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeOption>((ref) {
  return ThemeNotifier(ref);
});
