import 'package:deca_mobile/messages/data/messages_repository.dart';
import 'package:deca_mobile/notifications/data/notifications_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// So luong chua doc cho 2 icon o AppBar (chuong + tin nhan).
class InboxBadgeState extends Equatable {
  const InboxBadgeState({this.notifications = 0, this.messages = 0});

  final int notifications;
  final int messages;

  @override
  List<Object?> get props => [notifications, messages];
}

/// Badge chua doc — la phu tro, moi loi khi lam mo (khong lam sap UI).
class InboxBadgeCubit extends Cubit<InboxBadgeState> {
  InboxBadgeCubit(this._notifications, this._messages)
      : super(const InboxBadgeState());

  final NotificationsRepository _notifications;
  final MessagesRepository _messages;

  Future<void> refresh() async {
    try {
      final counts = await Future.wait([
        _notifications.unreadCount(),
        _messages.unreadCount(),
      ]);
      emit(InboxBadgeState(notifications: counts[0], messages: counts[1]));
    } on Object catch (_) {
      // Bo qua: badge khong bat buoc, tranh anh huong luong chinh.
    }
  }
}
