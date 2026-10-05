class NotificationModel {
  final int id;
  final String? type;
  final String title;
  final String body;
  final String? imageUrl;
  final int? seriesId;
  final bool read;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.seriesId,
    required this.read,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as num).toInt(),
      type: json['type'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['imageUrl'],
      seriesId: (json['seriesId'] as num?)?.toInt(),
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  NotificationModel markRead() => NotificationModel(
        id: id,
        type: type,
        title: title,
        body: body,
        imageUrl: imageUrl,
        seriesId: seriesId,
        read: true,
        createdAt: createdAt,
      );
}
