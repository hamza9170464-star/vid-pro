import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_item.dart';
import '../models/download_task.dart';
import '../services/download_service.dart';
import 'history_provider.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  final service = DownloadService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

class DownloadNotifier extends StateNotifier<List<AppDownloadTask>> {
  final Ref _ref;
  final DownloadService _service;

  DownloadNotifier(this._ref, this._service) : super([]) {
    _service.taskStream.listen((tasks) {
      state = tasks;
    });
  }

  Future<void> startDownload(MediaItem item, {String? customPath}) async {
    final taskId = await _service.download(item, customPath: customPath);
    if (taskId != null) {
      await _ref.read(historyProvider.notifier).addVisit(
            item.title,
            item.url,
            isDownload: true,
          );
    }
  }

  Future<void> pauseDownload(String id) async {
    await _service.pause(id);
  }

  Future<void> resumeDownload(String id) async {
    await _service.resume(id);
  }

  Future<void> cancelDownload(String id) async {
    await _service.cancel(id);
  }

  Future<void> retryDownload(String id) async {
    await _service.retry(id);
  }

  void removeDownload(String id) {
    _service.removeTask(id);
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, List<AppDownloadTask>>((ref) {
  final service = ref.watch(downloadServiceProvider);
  return DownloadNotifier(ref, service);
});
