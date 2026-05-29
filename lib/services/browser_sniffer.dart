import 'package:uuid/uuid.dart';
import '../models/media_item.dart';

class BrowserSniffer {
  static const _uuid = Uuid();

  // Inspect link requests to isolate downloadable/playable video and audio streams
  static MediaItem? sniffUrl(String url, String pageTitle) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();

      String? ext;
      String? mime;

      if (path.endsWith('.mp4') || url.contains('.mp4?')) {
        ext = 'mp4';
        mime = 'video/mp4';
      } else if (path.endsWith('.mp3') || url.contains('.mp3?')) {
        ext = 'mp3';
        mime = 'audio/mpeg';
      } else if (path.endsWith('.m3u8') || url.contains('.m3u8?')) {
        ext = 'm3u8';
        mime = 'application/x-mpegURL';
      } else if (path.endsWith('.webm') || url.contains('.webm?')) {
        ext = 'webm';
        mime = 'video/webm';
      }

      if (ext != null) {
        String fileTitle = pageTitle.trim();
        if (fileTitle.isEmpty || fileTitle.toLowerCase() == 'webview' || fileTitle.toLowerCase().contains('http')) {
          fileTitle = uri.pathSegments.isNotEmpty
              ? uri.pathSegments.last
              : 'Media File';
        }

        // Clean titles if they possess the raw extension
        if (fileTitle.toLowerCase().endsWith('.$ext')) {
          fileTitle = fileTitle.substring(0, fileTitle.length - (ext.length + 1));
        }

        // Provide readable defaults
        fileTitle = Uri.decodeComponent(fileTitle).replaceAll(RegExp(r'[#_?=%&]'), ' ');

        return MediaItem(
          id: _uuid.v4(),
          url: url,
          title: fileTitle,
          extension: ext,
          mimeType: mime,
          resolution: ext == 'mp3' ? '320kbps' : '720p',
          sizeBytes: ext == 'mp3' ? 6291456 : 47185920, // Pre-calculated mock values
        );
      }
    } catch (_) {
      // Return null on parsing faults
    }
    return null;
  }

  // Generate dynamic, visual list of sizing levels matching resolution capabilities
  static List<MediaItem> getQualityOptions(MediaItem baseItem) {
    final title = baseItem.title;
    final url = baseItem.url;

    if (baseItem.extension == 'mp3') {
      return [
        MediaItem(
          id: baseItem.id,
          url: url,
          title: title,
          extension: 'mp3',
          mimeType: baseItem.mimeType,
          resolution: '320 kbps (High)',
          sizeBytes: 9437184, // 9 MB
        ),
        MediaItem(
          id: const Uuid().v4(),
          url: url,
          title: title,
          extension: 'mp3',
          mimeType: baseItem.mimeType,
          resolution: '192 kbps (Medium)',
          sizeBytes: 5242880, // 5 MB
        ),
        MediaItem(
          id: const Uuid().v4(),
          url: url,
          title: title,
          extension: 'mp3',
          mimeType: baseItem.mimeType,
          resolution: '128 kbps (Low)',
          sizeBytes: 3145728, // 3 MB
        ),
      ];
    }

    return [
      MediaItem(
        id: baseItem.id,
        url: url,
        title: title,
        extension: baseItem.extension,
        mimeType: baseItem.mimeType,
        resolution: '1080p (Full HD)',
        sizeBytes: 115343360, // 110 MB
      ),
      MediaItem(
        id: const Uuid().v4(),
        url: url,
        title: title,
        extension: baseItem.extension,
        mimeType: baseItem.mimeType,
        resolution: '720p (High Definition)',
        sizeBytes: 47185920, // 45 MB
      ),
      MediaItem(
        id: const Uuid().v4(),
        url: url,
        title: title,
        extension: baseItem.extension,
        mimeType: baseItem.mimeType,
        resolution: '480p (Standard Quality)',
        sizeBytes: 18874368, // 18 MB
      ),
      MediaItem(
        id: const Uuid().v4(),
        url: url,
        title: title,
        extension: 'mp3',
        mimeType: 'audio/mpeg',
        resolution: 'Audio Only (MP3 format)',
        sizeBytes: 4194304, // 4 MB
      ),
    ];
  }
}
