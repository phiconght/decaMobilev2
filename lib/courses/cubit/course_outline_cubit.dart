import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/state/view_status.dart';
import 'package:deca_mobile/courses/data/courses_repository.dart';
import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cay noi dung khoa hoc — NGUON DUY NHAT cho man chi tiet khoa hoc.
///
/// Thay ca `CourseSessionsCubit` lan `ExamsCubit` truoc day: 2 cubit do lay tu
/// 2 API khong lien quan nhau roi ghep o client, nen giao dien buoc phai chia
/// thanh 2 bang roi rac. Xem SPEC_KhoaHoc_NoiDung_Mobile §0.
class CourseOutlineCubit extends Cubit<DataState<ClassOutline>> {
  CourseOutlineCubit(this._repo, this._classId, {int? studentId})
      : _studentId = studentId,
        super(const DataState<ClassOutline>());

  final CoursesRepository _repo;
  final int _classId;
  final int? _studentId;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final outline = await _repo.fetchOutline(_classId, studentId: _studentId);
      emit(state.copyWith(status: ViewStatus.success, data: outline));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: e.message));
    } on Object catch (_) {
      emit(
        state.copyWith(status: ViewStatus.failure, error: 'Đã có lỗi xảy ra'),
      );
    }
  }

  Future<void> refresh() => load();
}
