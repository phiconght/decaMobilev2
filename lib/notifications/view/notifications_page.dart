import 'dart:async';

import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/util/time_ago.dart';
import 'package:deca_mobile/core/widgets/async_list_view.dart';
import 'package:deca_mobile/home/cubit/inbox_badge_cubit.dart';
import 'package:deca_mobile/messages/view/message_detail_page.dart';
import 'package:deca_mobile/notifications/cubit/notifications_cubit.dart';
import 'package:deca_mobile/notifications/data/models/notification_item.dart';
import 'package:deca_mobile/notifications/data/notifications_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Danh sach thong bao (vắn tắt). Cham vao -> mo tin nhan day du (neu co).
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = NotificationsCubit(ctx.read<NotificationsRepository>());
        unawaited(cubit.load());
        return cubit;
      },
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu đã đọc tất cả',
            onPressed: () async {
              await context.read<NotificationsCubit>().markAllRead();
              if (context.mounted) {
                await context.read<InboxBadgeCubit>().refresh();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, DataState<List<NotificationItem>>>(
        builder: (context, state) {
          return AsyncListView<NotificationItem>(
            state: state,
            onRefresh: context.read<NotificationsCubit>().refresh,
            emptyMessage: 'Bạn chưa có thông báo nào.',
            itemBuilder: (context, item) => _NotificationTile(item: item),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = !item.read;
    return Card(
      margin: EdgeInsets.zero,
      color: unread
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            item.type.icon,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          item.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(item.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.xs),
            Text(
              timeAgo(item.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        trailing: unread
            ? Icon(Icons.circle, size: 10, color: theme.colorScheme.primary)
            : null,
        onTap: () => _open(context),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final notifCubit = context.read<NotificationsCubit>();
    final badge = context.read<InboxBadgeCubit>();
    final navigator = Navigator.of(context);

    if (!item.read) {
      await notifCubit.markRead(item.id);
      await badge.refresh();
    }
    if (item.messageId != null) {
      await navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => MessageDetailPage(messageId: item.messageId!),
        ),
      );
      await badge.refresh();
    }
  }
}
