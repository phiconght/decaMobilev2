import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/messages/data/messages_repository.dart';
import 'package:deca_mobile/messages/data/models/message_item.dart';
import 'package:deca_mobile/notifications/data/models/notif_type.dart';

/// Hop thu tin nhan + loc theo loai.
class MessagesCubit extends CollectionCubit<MessageItem> {
  MessagesCubit(this._repo);

  final MessagesRepository _repo;

  NotifType? _type;
  NotifType? get type => _type;

  @override
  Future<List<MessageItem>> readAll() => _repo.fetch(type: _type);

  Future<void> setType(NotifType? type) {
    _type = type;
    return load();
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    return load();
  }
}
