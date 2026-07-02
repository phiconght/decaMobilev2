import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/core/state/view_status.dart';
import 'package:deca_mobile/notifications/data/models/notification_item.dart';
import 'package:deca_mobile/notifications/data/notifications_repository.dart';

/// Danh sach thong bao cua nguoi dung + danh dau da doc.
class NotificationsCubit extends CollectionCubit<NotificationItem> {
  NotificationsCubit(this._repo);

  final NotificationsRepository _repo;

  @override
  Future<List<NotificationItem>> readAll() => _repo.fetch();

  Future<void> markRead(int id) async {
    await _repo.markRead(id);
    _patchLocal((n) => n.id == id ? n.copyWith(read: true) : n);
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    _patchLocal((n) => n.copyWith(read: true));
  }

  void _patchLocal(NotificationItem Function(NotificationItem) map) {
    final items = (state.data ?? const <NotificationItem>[]).map(map).toList();
    emit(state.copyWith(status: ViewStatus.success, data: items));
  }
}
