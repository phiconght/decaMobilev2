import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/state/view_status.dart';
import 'package:deca_mobile/schedule/data/leave_repository.dart';
import 'package:deca_mobile/schedule/data/models/leave_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit quan ly danh sach don nghi phep.
class LeavesCubit extends Cubit<DataState<List<LeaveItem>>> {
  LeavesCubit(this._repo, {this.statusFilter}) : super(const DataState());

  final LeaveRepository _repo;
  final String? statusFilter;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final items = await _repo.list(status: statusFilter);
      emit(state.copyWith(status: ViewStatus.success, data: items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: e.message));
    } on Object {
      emit(
        state.copyWith(
          status: ViewStatus.failure,
          error: 'Đã có lỗi xảy ra',
        ),
      );
    }
  }

  Future<void> refresh() => load();

  Future<void> approve(int id) async {
    await _repo.approve(id);
    await load();
  }

  Future<void> reject(int id) async {
    await _repo.reject(id);
    await load();
  }

  Future<void> confirmByParent(int id) async {
    await _repo.confirmByParent(id);
    await load();
  }
}
