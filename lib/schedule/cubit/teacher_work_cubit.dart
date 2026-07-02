import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/state/view_status.dart';
import 'package:deca_mobile/schedule/data/attendance_repository.dart';
import 'package:deca_mobile/schedule/data/models/teacher_work.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State man "Cham cong cua toi": bao cao + thang dang xem.
class TeacherWorkState extends Equatable {
  const TeacherWorkState({
    required this.month,
    this.report = const DataState(),
  });

  /// Ngay dai dien cho thang (ngay 1 cua thang).
  final DateTime month;
  final DataState<TeacherWorkReport> report;

  TeacherWorkState copyWith({
    DateTime? month,
    DataState<TeacherWorkReport>? report,
  }) {
    return TeacherWorkState(
      month: month ?? this.month,
      report: report ?? this.report,
    );
  }

  @override
  List<Object?> get props => [month, report];
}

/// Tai bao cao cham cong GV theo thang.
class TeacherWorkCubit extends Cubit<TeacherWorkState> {
  TeacherWorkCubit(this._repo, DateTime now)
      : super(TeacherWorkState(month: DateTime(now.year, now.month)));

  final AttendanceRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(report: state.report.copyWith(status: ViewStatus.loading)));
    final from = DateTime(state.month.year, state.month.month);
    // Ngay cuoi thang = ngay 0 cua thang sau.
    final to = DateTime(state.month.year, state.month.month + 1, 0);
    try {
      final report = await _repo.myWorkReport(from, to);
      emit(
        state.copyWith(
          report: state.report.copyWith(status: ViewStatus.success, data: report),
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          report: state.report.copyWith(status: ViewStatus.failure, error: e.message),
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          report: state.report.copyWith(
            status: ViewStatus.failure,
            error: 'Đã có lỗi xảy ra',
          ),
        ),
      );
    }
  }

  Future<void> refresh() => load();

  Future<void> prevMonth() {
    emit(state.copyWith(month: DateTime(state.month.year, state.month.month - 1)));
    return load();
  }

  Future<void> nextMonth() {
    emit(state.copyWith(month: DateTime(state.month.year, state.month.month + 1)));
    return load();
  }
}
