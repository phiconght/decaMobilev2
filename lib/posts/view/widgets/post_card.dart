import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/core/network/url_helper.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/util/time_ago.dart';
import 'package:deca_mobile/posts/data/models/post_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Anh bia bo goc — fallback icon khi khong co / loi tai.
class _Cover extends StatelessWidget {
  const _Cover({required this.url, this.height = 160, this.width});

  final String? url;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      height: height,
      width: width,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.article_outlined,
        color: theme.colorScheme.outline,
        size: 32,
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    final config = context.read<ApiClient>().config;
    return Image.network(
      config.toAbsoluteUrl(url),
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

/// Card bai viet lon: anh bia 16:9 tren cung + tieu de + mo ta + ngay.
class PostCard extends StatelessWidget {
  const PostCard({required this.post, required this.onTap, super.key});

  final PostItem post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Cover(url: post.coverImageUrl, width: double.infinity),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.pinned)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Icon(
                            Icons.push_pin,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Ghim',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    post.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.summary != null && post.summary!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      post.summary!,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    timeAgo(post.publishedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card bai viet nho: thumbnail trai + tieu de + ngay (dung cho feed Home).
class PostCardCompact extends StatelessWidget {
  const PostCardCompact({required this.post, required this.onTap, super.key});

  final PostItem post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 96,
              child: _Cover(url: post.coverImageUrl, height: 96, width: 96),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      post.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      timeAgo(post.publishedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
