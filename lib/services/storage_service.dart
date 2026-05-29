import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/theme_option.dart';
import '../models/history_item.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _keyTheme = 'app_theme_mode';
  static const String _keyHistory = 'browser_search_history';
  static const String _keyDownloadPath = 'custom_download_path';
  static const String _keyNotifications = 'enable_notifications';

  // Theme Persistence
  ThemeOption getSelectedTheme() {
    final name = _prefs.getString(_keyTheme);
    if (name == null) return ThemeOption.darkRed;
    return ThemeOption.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ThemeOption.darkRed,
    );
  }

  Future<void> saveSelectedTheme(ThemeOption theme) async {
    await _prefs.setString(_keyTheme, theme.name);
  }

  // History Persistence
  List<HistoryItem> getHistory() {
    final list = _prefs.getStringList(_keyHistory) ?? [];
    return list.map((e) => HistoryItem.fromJson(jsonDecode(e))).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> saveHistory(List<HistoryItem> history) async {
    final list = history.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_keyHistory, list);
  }

  Future<void> addHistoryItem(HistoryItem item) async {
    final history = getHistory();
    history.removeWhere((e) => e.url == item.url);
    history.insert(0, item);
    await saveHistory(history);
  }

  Future<void> deleteHistoryItem(String id) async {
    final history = getHistory();
    history.removeWhere((e) => e.id == id);
    await saveHistory(history);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_keyHistory);
  }

  // Download Path Configuration
  String getDownloadPath(String fallbackPath) {
    return _prefs.getString(_keyDownloadPath) ?? fallbackPath;
  }

  Future<void> saveDownloadPath(String path) async {
    await _prefs.setString(_keyDownloadPath, path);
  }

  // Notifications Toggle
  bool areNotificationsEnabled() {
    return _prefs.getBool(_keyNotifications) ?? true;
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotifications, enabled);
  }
}
