import 'dart:async';

import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/home/view/widgets/section_header.dart';
import 'package:deca_mobile/posts/cubit/posts_cubit.dart';
import 'package:deca_mobile/posts/data/models/post_item.dart';
import 'package:deca_mobile/posts/view/post_detail_page.dart';
import 'package:deca_mobile/posts/view/posts_list_page.dart';
import 'package:deca_mobile/posts/view/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bang tin (feed bai viet) tren Trang chu: 1 bai lon + vai bai nho.
class PostFeedSection extends StatelessWidget {
  const PostFeedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsCubit, DataState<List<PostItem>>>(
      builder: (context, state) {
        final items = state.data ?? const <PostItem>[];
        if (items.isEmpty) return const SizedBox.shrink();

        final first = items.first;
        final rest = items.skip(1).take(4).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Bảng tin',
              onSeeAll: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const PostsListPage(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  PostCard(post: first, onTap: () => _open(context, first)),
                  for (final p in rest) ...[
                    const SizedBox(height: AppSpacing.md),
                    PostCardCompact(post: p, onTap: () => _open(context, p)),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _open(BuildContext context, PostItem post) {
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PostDetailPage(postId: post.id),
        ),
      ),
    );
  }
}
