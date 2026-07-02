import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/state/view_status.dart';
import 'package:deca_mobile/posts/data/models/post_detail.dart';
import 'package:deca_mobile/posts/data/posts_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Chi tiet 1 bai viet.
class PostDetailCubit extends Cubit<DataState<PostDetail>> {
  PostDetailCubit(this._repo) : super(const DataState<PostDetail>());

  final PostsRepository _repo;

  Future<void> load(int id) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final detail = await _repo.detail(id);
      emit(state.copyWith(status: ViewStatus.success, data: detail));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: e.message));
    } on Object catch (_) {
      emit(
        state.copyWith(status: ViewStatus.failure, error: 'Đã có lỗi xảy ra'),
      );
    }
  }
}
