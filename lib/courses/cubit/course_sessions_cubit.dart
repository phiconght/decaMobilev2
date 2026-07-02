import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/data/timetable_repository.dart';

/// Tai cac buoi hoc DA QUA cua mot lop, suy tu thoi khoa bieu cua nguoi dung.
///
/// HV/PH khong co quyen CLASS:READ nen khong goi duoc /classes/{id}/sessions;
/// thay vao do dung GET /timetable (isAuthenticated) roi loc theo lop + buoi
/// da ket thuc. Sap xep moi nhat len truoc.
class CourseSessionsCubit extends CollectionCubit<TimetableItem> {
  CourseSessionsCubit(
    this._repo,
    this._classId,
    this._view, {
    DateTime? since,
    DateTime? now,
  })  : _since = since,
        _now = now ?? DateTime.now();

  final TimetableRepository _repo;
  final int _classId;
  final String _view;
  final DateTime? _since;
  final DateTime _now;

  @override
  Future<List<TimetableItem>> readAll() async {
    final to = DateTime(_now.year, _now.month, _now.day);
    final since = _since;
    // Can duoi = ngay bat dau khoa (neu co), nguoc lai lui 1 nam.
    final from = since != null
        ? DateTime(since.year, since.month, since.day)
        : DateTime(_now.year - 1, _now.month, _now.day);
    final items = await _repo.fetchTimetable(view: _view, from: from, to: to);
    return items
        .where(
          (s) =>
              s.classId == _classId &&
              s.status != SessionStatus.cancelled &&
              _isPast(s),
        )
        .toList()
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.startTime.compareTo(a.startTime);
      });
  }

  /// Buoi da qua = thoi diem ket thuc (ngay + endTime) truoc [_now].
  bool _isPast(TimetableItem s) {
    final parts = s.endTime.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final end = DateTime(
      s.date.year,
      s.date.month,
      s.date.day,
      hour,
      minute,
    );
    return end.isBefore(_now);
  }
}
