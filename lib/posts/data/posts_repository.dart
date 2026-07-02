import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/posts/data/models/post_detail.dart';
import 'package:deca_mobile/posts/data/models/post_item.dart';

/// Truy xuat bai viet (content) da PUBLISHED cho mobile.
abstract class PostsRepository {
  Future<List<PostItem>> fetch({int current, int pageSize});

  Future<PostDetail> detail(int id);
}

class PostsRepositoryImpl implements PostsRepository {
  const PostsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<PostItem>> fetch({int current = 1, int pageSize = 10}) async {
    final data = await _api.get(
      '/api/v1/posts',
      query: {'current': current, 'pageSize': pageSize},
    );
    final list = (data as List<dynamic>?) ?? const [];
    return list
        .map((e) => PostItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PostDetail> detail(int id) async {
    final data = await _api.get('/api/v1/posts/$id');
    return PostDetail.fromJson(data! as Map<String, dynamic>);
  }
}
