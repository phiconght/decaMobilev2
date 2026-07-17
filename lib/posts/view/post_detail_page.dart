import 'dart:async';

import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/core/network/url_helper.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/util/time_ago.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_loading_view.dart';
import 'package:deca_mobile/posts/cubit/post_detail_cubit.dart';
import 'package:deca_mobile/posts/data/models/post_detail.dart';
import 'package:deca_mobile/posts/data/posts_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Chi tiet bai viet — render noi dung MARKDOWN.
class PostDetailPage extends StatelessWidget {
  const PostDetailPage({required this.postId, super.key});

  final int postId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = PostDetailCubit(ctx.read<PostsRepository>());
        unawaited(cubit.load(postId));
        return cubit;
      },
      child: _PostDetailView(postId: postId),
    );
  }
}

class _PostDetailView extends StatelessWidget {
  const _PostDetailView({required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài viết')),
      body: BlocBuilder<PostDetailCubit, DataState<PostDetail>>(
        builder: (context, state) {
          if (state.isLoading && !state.hasData) {
            return const AppLoadingView(itemCount: 3);
          }
          if (state.isFailure && !state.hasData) {
            return AppErrorView(
              message: state.error ?? 'Đã có lỗi xảy ra',
              onRetry: () => context.read<PostDetailCubit>().load(postId),
            );
          }
          final post = state.data;
          if (post == null) return const SizedBox.shrink();
          return _Content(post: post);
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.post});

  final PostDetail post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = context.read<ApiClient>().config;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (post.coverImageUrl != null && post.coverImageUrl!.isNotEmpty)
          Image.network(
            config.toAbsoluteUrl(post.coverImageUrl),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                [
                  if (post.author != null && post.author!.isNotEmpty)
                    post.author,
                  timeAgo(post.publishedAt),
                ].whereType<String>().join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const Divider(height: AppSpacing.xl),
              MarkdownBody(
                data: post.contentMd,
                selectable: true,
                sizedImageBuilder: (imgConfig) => Image.network(
                  config.toAbsoluteUrl(imgConfig.uri.toString()),
                  width: imgConfig.width,
                  height: imgConfig.height,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
