import 'dart:async';

import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/core/network/url_helper.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/util/time_ago.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_loading_view.dart';
import 'package:deca_mobile/messages/cubit/message_detail_cubit.dart';
import 'package:deca_mobile/messages/data/messages_repository.dart';
import 'package:deca_mobile/messages/data/models/message_detail.dart';
import 'package:deca_mobile/notifications/data/models/notif_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Chi tiet tin nhan (noi dung day du). Mo tu Thong bao hoac Hop thu.
class MessageDetailPage extends StatelessWidget {
  const MessageDetailPage({required this.messageId, super.key});

  final int messageId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = MessageDetailCubit(ctx.read<MessagesRepository>());
        unawaited(cubit.load(messageId));
        return cubit;
      },
      child: const _MessageDetailView(),
    );
  }
}

class _MessageDetailView extends StatelessWidget {
  const _MessageDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết')),
      body: BlocBuilder<MessageDetailCubit, DataState<MessageDetail>>(
        builder: (context, state) {
          if (state.isLoading && !state.hasData) {
            return const AppLoadingView(itemCount: 3);
          }
          if (state.isFailure && !state.hasData) {
            return AppErrorView(
              message: state.error ?? 'Đã có lỗi xảy ra',
              onRetry: () =>
                  context.read<MessageDetailCubit>().load(state.data?.id ?? 0),
            );
          }
          final m = state.data;
          if (m == null) return const SizedBox.shrink();
          return _Content(message: m);
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.message});

  final MessageDetail message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = context.read<ApiClient>().config;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                message.type.icon,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.title, style: theme.textTheme.titleMedium),
                  if (message.createdAt != null)
                    Text(
                      timeAgo(message.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: AppSpacing.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            // Thong bao trung tam soan bang markdown; loai khac la plain text
            // (giu xuong dong don) nen render truc tiep.
            child: message.type == NotifType.announcement
                ? MarkdownBody(
                    data: message.content,
                    selectable: true,
                    sizedImageBuilder: (imgConfig) => Image.network(
                      config.toAbsoluteUrl(imgConfig.uri.toString()),
                      width: imgConfig.width,
                      height: imgConfig.height,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  )
                : SelectableText(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
          ),
        ),
      ],
    );
  }
}
