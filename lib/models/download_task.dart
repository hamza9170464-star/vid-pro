enum DownloadStatus {
  enqueued,
  downloading,
  completed,
  failed,
  canceled,
  paused;

  String get displayName {
    switch (this) {
      case DownloadStatus.enqueued:
        return 'Queued';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.canceled:
        return 'Canceled';
      case DownloadStatus.paused:
        return 'Paused';
    }
  }
}

class AppDownloadTask {
  final String id;
  final String url;
  final String filename;
  final String savedDirectory;
  final int progress;
  final DownloadStatus status;
  final int sizeBytes;
  final double speedKbps;
  final Duration? timeRemaining;

  AppDownloadTask({
    required this.id,
    required this.url,
    required this.filename,
    required this.savedDirectory,
    this.progress = 0,
    this.status = DownloadStatus.enqueued,
    this.sizeBytes = 0,
    this.speedKbps = 0,
    this.timeRemaining,
  });

  AppDownloadTask copyWith({
    String? id,
    String? url,
    String? filename,
    String? savedDirectory,
    int? progress,
    DownloadStatus? status,
    int? sizeBytes,
    double? speedKbps,
    Duration? timeRemaining,
  }) {
    return AppDownloadTask(
      id: id ?? this.id,
      url: url ?? this.url,
      filename: filename ?? this.filename,
      savedDirectory: savedDirectory ?? this.savedDirectory,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      speedKbps: speedKbps ?? this.speedKbps,
      timeRemaining: timeRemaining ?? this.timeRemaining,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'filename': filename,
        'savedDirectory': savedDirectory,
        'progress': progress,
        'status': status.index,
        'sizeBytes': sizeBytes,
      };

  factory AppDownloadTask.fromJson(Map<String, dynamic> json) => AppDownloadTask(
        id: json['id'],
        url: json['url'],
        filename: json['filename'],
        savedDirectory: json['savedDirectory'],
        progress: json['progress'],
        status: DownloadStatus.values[json['status']],
        sizeBytes: json['sizeBytes'] ?? 0,
      );

  String get formattedProgress => '$progress%';

  String get formattedSpeed {
    if (speedKbps == 0) return '0 KB/s';
    if (speedKbps > 1024) {
      return '${(speedKbps / 1024).toStringAsFixed(1)} MB/s';
    }
    return '${speedKbps.toStringAsFixed(0)} KB/s';
  }

  String get formattedTimeRemaining {
    if (timeRemaining == null || progress == 100) return '';
    final seconds = timeRemaining!.inSeconds;
    if (seconds < 60) return '${seconds}s left';
    final minutes = timeRemaining!.inMinutes;
    return '${minutes}m left';
  }

  String get filePath => '$savedDirectory/$filename';
}
