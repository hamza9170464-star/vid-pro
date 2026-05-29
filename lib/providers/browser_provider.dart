import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_item.dart';

class BrowserState {
  final String currentUrl;
  final String pageTitle;
  final int loadingProgress;
  final bool isLoading;
  final MediaItem? detectedMedia;

  BrowserState({
    this.currentUrl = 'https://www.google.com',
    this.pageTitle = 'Google',
    this.loadingProgress = 0,
    this.isLoading = false,
    this.detectedMedia,
  });

  BrowserState copyWith({
    String? currentUrl,
    String? pageTitle,
    int? loadingProgress,
    bool? isLoading,
    MediaItem? detectedMedia,
    bool clearMedia = false,
  }) {
    return BrowserState(
      currentUrl: currentUrl ?? this.currentUrl,
      pageTitle: pageTitle ?? this.pageTitle,
      loadingProgress: loadingProgress ?? this.loadingProgress,
      isLoading: isLoading ?? this.isLoading,
      detectedMedia: clearMedia ? null : (detectedMedia ?? this.detectedMedia),
    );
  }
}

class BrowserNotifier extends StateNotifier<BrowserState> {
  BrowserNotifier() : super(BrowserState());

  void setUrl(String url) {
    state = state.copyWith(currentUrl: url);
  }

  void updateLoading(int progress) {
    state = state.copyWith(
      loadingProgress: progress,
      isLoading: progress < 100,
    );
  }

  void updatePage(String url, String title) {
    state = state.copyWith(
      currentUrl: url,
      pageTitle: title,
    );
  }

  void setDetectedMedia(MediaItem? media) {
    state = state.copyWith(detectedMedia: media);
  }

  void clearDetectedMedia() {
    state = state.copyWith(clearMedia: true);
  }
}

final browserProvider = StateNotifierProvider<BrowserNotifier, BrowserState>((ref) {
  return BrowserNotifier();
});
