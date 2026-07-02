import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/notifications/data/models/notification_item.dart';

/// Truy xuat thong bao (vắn tắt) cua nguoi dung dang dang nhap.
abstract class NotificationsRepository {
  Future<List<NotificationItem>> fetch({int current, int pageSize});

  Future<int> unreadCount();

  Future<void> markRead(int id);

  Future<void> markAllRead();
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<NotificationItem>> fetch({
    int current = 1,
    int pageSize = 30,
  }) async {
    final data = await _api.get(
      '/api/v1/notifications/me',
      query: {'current': current, 'pageSize': pageSize},
    );
    final list = (data as List<dynamic>?) ?? const [];
    return list
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> unreadCount() async {
    final data = await _api.get('/api/v1/notifications/me/unread-count');
    final map = (data as Map<String, dynamic>?) ?? const {};
    return (map['count'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> markRead(int id) => _api.patch('/api/v1/notifications/$id/read');

  @override
  Future<void> markAllRead() => _api.patch('/api/v1/notifications/read-all');
}
