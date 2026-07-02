import 'dart:async';

import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/util/time_ago.dart';
import 'package:deca_mobile/core/widgets/async_list_view.dart';
import 'package:deca_mobile/home/cubit/inbox_badge_cubit.dart';
import 'package:deca_mobile/messages/cubit/messages_cubit.dart';
import 'package:deca_mobile/messages/data/messages_repository.dart';
import 'package:deca_mobile/messages/data/models/message_item.dart';
import 'package:deca_mobile/messages/view/message_detail_page.dart';
import 'package:deca_mobile/notifications/data/models/notif_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Hop thu tin nhan (noi dung day du) + loc theo loai.
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = MessagesCubit(ctx.read<MessagesRepository>());
        unawaited(cubit.load());
        return cubit;
      },
      child: const _MessagesView(),
    );
  }
}

class _MessagesView extends StatelessWidget {
  const _MessagesView();

  /// Cac loai thuong xuat hien trong hop thu (chip loc).
  static const _filters = <NotifType?>[
    null,
    NotifType.leaveSubmitted,
    NotifType.leaveResult,
    NotifType.checkinOk,
    NotifType.sessionReminder,
    NotifType.scheduleChanged,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu đã đọc tất cả',
            onPressed: () async {
              await context.read<MessagesCubit>().markAllRead();
              if (context.mounted) {
                await context.read<InboxBadgeCubit>().refresh();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const _FilterBar(filters: _filters),
          Expanded(
            child: BlocBuilder<MessagesCubit, DataState<List<MessageItem>>>(
              builder: (context, state) {
                return AsyncListView<MessageItem>(
                  state: state,
                  onRefresh: context.read<MessagesCubit>().refresh,
                  emptyMessage: 'Bạn chưa có tin nhắn nào.',
                  itemBuilder: (context, item) => _MessageTile(item: item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.filters});

  final List<NotifType?> filters;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MessagesCubit>();
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final type = filters[i];
          final selected = cubit.type == type;
          return Center(
            child: ChoiceChip(
              label: Text(type?.label ?? 'Tất cả'),
              selected: selected,
              onSelected: (_) => context.read<MessagesCubit>().setType(type),
            ),
          );
        },
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.item});

  final MessageItem item;

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
            Text(item.preview, maxLines: 2, overflow: TextOverflow.ellipsis),
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
    final messagesCubit = context.read<MessagesCubit>();
    final badge = context.read<InboxBadgeCubit>();
    final navigator = Navigator.of(context);

    await navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MessageDetailPage(messageId: item.id),
      ),
    );
    // Tin nhan da duoc danh dau da doc o server khi mo chi tiet -> lam moi.
    await messagesCubit.refresh();
    await badge.refresh();
  }
}
