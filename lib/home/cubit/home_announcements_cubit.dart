import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/messages/data/messages_repository.dart';
import 'package:deca_mobile/messages/data/models/message_item.dart';
import 'package:deca_mobile/notifications/data/models/notif_type.dart';

/// Thong bao trung tam (ANNOUNCEMENT) chua doc — banner tren Trang chu.
class HomeAnnouncementsCubit extends CollectionCubit<MessageItem> {
  HomeAnnouncementsCubit(this._repo);

  final MessagesRepository _repo;

  @override
  Future<List<MessageItem>> readAll() => _repo.fetch(
        type: NotifType.announcement,
        unread: true,
        pageSize: 3,
      );
}
