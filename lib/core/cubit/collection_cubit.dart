import 'package:bloc/bloc.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/state/view_status.dart';

/// Lop Cubit truu tuong cho man danh sach (Template Method).
///
/// Khung loading -> success/failure + refresh viet mot lan o day; lop con
/// chi cung cap [readAll]. Khi refresh van giu danh sach cu de UI hien thi
/// trong luc tai lai (nho `copyWith` giu `data`).
abstract class CollectionCubit<T> extends Cubit<DataState<List<T>>> {
  CollectionCubit() : super(DataState<List<T>>());

  /// Buoc thay doi theo module — lop con override.
  Future<List<T>> readAll();

  /// Khung co dinh — lop con KHONG override.
  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final items = await readAll();
      emit(state.copyWith(status: ViewStatus.success, data: items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: e.message));
    } on Object catch (_) {
      emit(
        state.copyWith(
          status: ViewStatus.failure,
          error: 'Đã có lỗi xảy ra',
        ),
      );
    }
  }

  Future<void> refresh() => load();
}
