import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/messages/data/models/message_detail.dart';
import 'package:deca_mobile/messages/data/models/message_item.dart';
import 'package:deca_mobile/notifications/data/models/notif_type.dart';

/// Truy xuat hop thu tin nhan (noi dung day du) cua nguoi dung dang dang nhap.
abstract class MessagesRepository {
  Future<List<MessageItem>> fetch({int current, int pageSize, NotifType? type});

  Future<MessageDetail> detail(int id);

  Future<int> unreadCount();

  Future<void> markAllRead();
}

class MessagesRepositoryImpl implements MessagesRepository {
  const MessagesRepositoryImpl(this._api);

  final ApiClient _api;

  static const Map<NotifType, String> _typeCode = {
    NotifType.missingCheckin: 'MISSING_CHECKIN',
    NotifType.missingCheckout: 'MISSING_CHECKOUT',
    NotifType.checkinOk: 'CHECKIN_OK',
    NotifType.checkoutOk: 'CHECKOUT_OK',
    NotifType.leaveSubmitted: 'LEAVE_SUBMITTED',
    NotifType.leaveResult: 'LEAVE_RESULT',
    NotifType.scheduleChanged: 'SCHEDULE_CHANGED',
    NotifType.sessionReminder: 'SESSION_REMINDER',
  };

  @override
  Future<List<MessageItem>> fetch({
    int current = 1,
    int pageSize = 30,
    NotifType? type,
  }) async {
    final query = <String, dynamic>{'current': current, 'pageSize': pageSize};
    final code = type == null ? null : _typeCode[type];
    if (code != null) query['type'] = code;
    final data = await _api.get('/api/v1/messages/me', query: query);
    final list = (data as List<dynamic>?) ?? const [];
    return list
        .map((e) => MessageItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MessageDetail> detail(int id) async {
    final data = await _api.get('/api/v1/messages/$id');
    return MessageDetail.fromJson(data! as Map<String, dynamic>);
  }

  @override
  Future<int> unreadCount() async {
    final data = await _api.get('/api/v1/messages/me/unread-count');
    final map = (data as Map<String, dynamic>?) ?? const {};
    return (map['count'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> markAllRead() => _api.patch('/api/v1/messages/read-all');
}
