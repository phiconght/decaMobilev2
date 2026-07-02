import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/posts/data/models/post_item.dart';
import 'package:deca_mobile/posts/data/posts_repository.dart';

/// Feed bai viet. pageSize nho cho Home, lon cho trang "Xem tat ca".
class PostsCubit extends CollectionCubit<PostItem> {
  PostsCubit(this._repo, {this.pageSize = 20});

  final PostsRepository _repo;
  final int pageSize;

  @override
  Future<List<PostItem>> readAll() => _repo.fetch(pageSize: pageSize);
}
