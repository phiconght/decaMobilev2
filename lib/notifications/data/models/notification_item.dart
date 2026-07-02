import 'package:deca_mobile/notifications/data/models/notif_type.dart';

/// Mot dong thong bao (vắn tắt) — GET /notifications/me.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    this.messageId,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      type: NotifType.fromString(json['type'] as String?),
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      read: (json['read'] as bool?) ?? false,
      messageId: json['messageId'] as int?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  final int id;
  final NotifType type;
  final String title;
  final String body;
  final bool read;
  final int? messageId;
  final DateTime? createdAt;

  NotificationItem copyWith({bool? read}) => NotificationItem(
        id: id,
        type: type,
        title: title,
        body: body,
        read: read ?? this.read,
        messageId: messageId,
        createdAt: createdAt,
      );
}
