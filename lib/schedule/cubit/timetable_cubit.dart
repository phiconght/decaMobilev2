import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/view_status.dart';
import 'package:deca_mobile/schedule/data/models/child_ref.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/data/timetable_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Trang thai thoi khoa bieu — view, tuan dang xem, ngay chon va du lieu buoi.
class TimetableState extends Equatable {
  const TimetableState({
    required this.view,
    required this.weekStart,
    required this.selectedDay,
    this.status = ViewStatus.initial,
    this.items = const [],
    this.childFilter,
    this.error,
  });

  final String view;
  final DateTime weekStart;
  final DateTime selectedDay;
  final ViewStatus status;
  final List<TimetableItem> items;
  final int? childFilter;
  final String? error;

  bool get isLoading => status == ViewStatus.loading;
  bool get isFailure => status == ViewStatus.failure;
  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  /// Danh sach con (distinct studentId, bo null) de loc TKB.
  List<ChildRef> get children {
    final seen = <int>{};
    final result = <ChildRef>[];
    for (final item in items) {
      final id = item.studentId;
      if (id == null || !seen.add(id)) continue;
      result.add(
        ChildRef(
          studentId: id,
          studentName: item.studentName ?? 'Học viên',
          color: kChildColors[result.length % kChildColors.length],
        ),
      );
    }
    return result;
  }

  /// Toan bo buoi trong TUAN, da loc theo con, sap theo ngay roi gio bat dau.
  List<TimetableItem> get weekSessions {
    final filter = childFilter;
    final list = items
        .where((e) => filter == null || e.studentId == filter)
        .toList()
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        return c != 0 ? c : a.startTime.compareTo(b.startTime);
      });
    return list;
  }

  /// Cac thu (1..7) trong tuan co buoi hoc.
  Set<int> get daysWithSessions => items.map((e) => e.date.weekday).toSet();

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  TimetableState copyWith({
    String? view,
    DateTime? weekStart,
    DateTime? selectedDay,
    ViewStatus? status,
    List<TimetableItem>? items,
    int? childFilter,
    bool clearChildFilter = false,
    String? error,
  }) {
    return TimetableState(
      view: view ?? this.view,
      weekStart: weekStart ?? this.weekStart,
      selectedDay: selectedDay ?? this.selectedDay,
      status: status ?? this.status,
      items: items ?? this.items,
      childFilter: clearChildFilter ? null : (childFilter ?? this.childFilter),
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        view,
        weekStart,
        selectedDay,
        status,
        items,
        childFilter,
        error,
      ];
}

/// Quan ly trang thai thoi khoa bieu: tai theo tuan, doi view, dieu huong.
class TimetableCubit extends Cubit<TimetableState> {
  TimetableCubit(
    this._repo, {
    required String initialView,
    DateTime? now,
  }) : super(_initial(initialView, now ?? DateTime.now()));

  final TimetableRepository _repo;

  static TimetableState _initial(String view, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return TimetableState(view: view, weekStart: monday, selectedDay: today);
  }

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final items = await _repo.fetchTimetable(
        view: state.view,
        from: state.weekStart,
        to: state.weekEnd,
      );
      emit(state.copyWith(status: ViewStatus.success, items: items));
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

  Future<void> changeView(String view) async {
    if (view == state.view) return;
    emit(
      state.copyWith(
        view: view,
        clearChildFilter: true,
        items: const [],
        status: ViewStatus.loading,
      ),
    );
    await load();
  }

  Future<void> nextWeek() => _shift(7);

  Future<void> prevWeek() => _shift(-7);

  Future<void> _shift(int days) async {
    emit(
      state.copyWith(
        weekStart: state.weekStart.add(Duration(days: days)),
        selectedDay: state.selectedDay.add(Duration(days: days)),
      ),
    );
    await load();
  }

  Future<void> goToToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    if (TimetableState._sameDay(monday, state.weekStart)) {
      emit(state.copyWith(selectedDay: today));
    } else {
      emit(state.copyWith(weekStart: monday, selectedDay: today));
    }
    await load();
  }

  void selectDay(DateTime day) {
    emit(
      state.copyWith(
        selectedDay: DateTime(day.year, day.month, day.day),
      ),
    );
  }

  void selectChild(int? studentId) {
    emit(
      state.copyWith(
        childFilter: studentId,
        clearChildFilter: studentId == null,
      ),
    );
  }
}
