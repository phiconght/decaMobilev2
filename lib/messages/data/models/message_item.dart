import 'package:deca_mobile/notifications/data/models/notif_type.dart';

/// Mot dong hop thu (khong kem noi dung day du) — GET /messages/me.
class MessageItem {
  const MessageItem({
    required this.id,
    required this.type,
    required this.title,
    required this.preview,
    required this.read,
    this.createdAt,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: json['id'] as int,
      type: NotifType.fromString(json['type'] as String?),
      title: (json['title'] as String?) ?? '',
      preview: (json['preview'] as String?) ?? '',
      read: (json['read'] as bool?) ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  final int id;
  final NotifType type;
  final String title;
  final String preview;
  final bool read;
  final DateTime? createdAt;
}
