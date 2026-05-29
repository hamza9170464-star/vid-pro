class MediaItem {
  final String id;
  final String url;
  final String title;
  final String extension;
  final String? mimeType;
  final int? sizeBytes;
  final String? resolution;
  final String? thumbnailUrl;

  MediaItem({
    required this.id,
    required this.url,
    required this.title,
    required this.extension,
    this.mimeType,
    this.sizeBytes,
    this.resolution,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'title': title,
        'extension': extension,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'resolution': resolution,
        'thumbnailUrl': thumbnailUrl,
      };

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
        id: json['id'],
        url: json['url'],
        title: json['title'],
        extension: json['extension'],
        mimeType: json['mimeType'],
        sizeBytes: json['sizeBytes'],
        resolution: json['resolution'],
        thumbnailUrl: json['thumbnailUrl'],
      );

  String get formattedSize {
    if (sizeBytes == null || sizeBytes == 0) return 'Unknown Size';
    final kb = sizeBytes! / 1024;
    final mb = kb / 1024;
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    return '${kb.toStringAsFixed(1)} KB';
  }
}
