import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/history_item.dart';
import 'storage_provider.dart';

class HistoryNotifier extends StateNotifier<List<HistoryItem>> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    try {
      final storage = _ref.read(storageServiceProvider);
      state = storage.getHistory();
    } catch (_) {}
  }

  Future<void> addVisit(String title, String url, {bool isDownload = false}) async {
    final item = HistoryItem(
      id: const Uuid().v4(),
      title: title,
      url: url,
      timestamp: DateTime.now(),
      isDownload: isDownload,
    );
    try {
      final storage = _ref.read(storageServiceProvider);
      await storage.addHistoryItem(item);
      state = storage.getHistory();
    } catch (_) {}
  }

  Future<void> deleteItem(String id) async {
    try {
      final storage = _ref.read(storageServiceProvider);
      await storage.deleteHistoryItem(id);
      state = storage.getHistory();
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      final storage = _ref.read(storageServiceProvider);
      await storage.clearHistory();
      state = [];
    } catch (_) {}
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<HistoryItem>>((ref) {
  return HistoryNotifier(ref);
});
