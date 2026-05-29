class HistoryItem {
  final String id;
  final String title;
  final String url;
  final DateTime timestamp;
  final bool isDownload;

  HistoryItem({
    required this.id,
    required this.title,
    required this.url,
    required this.timestamp,
    this.isDownload = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'timestamp': timestamp.toIso8601String(),
        'isDownload': isDownload,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'],
        title: json['title'],
        url: json['url'],
        timestamp: DateTime.parse(json['timestamp']),
        isDownload: json['isDownload'] ?? false,
      );
}
