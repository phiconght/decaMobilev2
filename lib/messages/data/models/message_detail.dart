import 'package:deca_mobile/notifications/data/models/notif_type.dart';

/// Chi tiet tin nhan (noi dung day du) — GET /messages/{id}.
class MessageDetail {
  const MessageDetail({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.payload,
    this.createdAt,
  });

  factory MessageDetail.fromJson(Map<String, dynamic> json) {
    return MessageDetail(
      id: json['id'] as int,
      type: NotifType.fromString(json['type'] as String?),
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      payload: json['payload'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  final int id;
  final NotifType type;
  final String title;
  final String content;
  final String? payload;
  final DateTime? createdAt;
}
