import 'dart:async';

import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/widgets/async_list_view.dart';
import 'package:deca_mobile/posts/cubit/posts_cubit.dart';
import 'package:deca_mobile/posts/data/models/post_item.dart';
import 'package:deca_mobile/posts/data/posts_repository.dart';
import 'package:deca_mobile/posts/view/post_detail_page.dart';
import 'package:deca_mobile/posts/view/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Trang "Bang tin" — danh sach day du cac bai viet da dang.
class PostsListPage extends StatelessWidget {
  const PostsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = PostsCubit(ctx.read<PostsRepository>());
        unawaited(cubit.load());
        return cubit;
      },
      child: const _PostsListView(),
    );
  }
}

class _PostsListView extends StatelessWidget {
  const _PostsListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bảng tin')),
      body: BlocBuilder<PostsCubit, DataState<List<PostItem>>>(
        builder: (context, state) {
          return AsyncListView<PostItem>(
            state: state,
            onRefresh: context.read<PostsCubit>().refresh,
            emptyMessage: 'Chưa có bài viết nào.',
            itemBuilder: (context, post) => PostCard(
              post: post,
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => PostDetailPage(postId: post.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
