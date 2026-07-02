import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/schedule/data/models/attendance_item.dart';
import 'package:deca_mobile/schedule/data/models/qr_token.dart';
import 'package:deca_mobile/schedule/data/models/teacher_work.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:intl/intl.dart';

/// Diem danh hoc vien, cap token QR, va cham cong day cua giao vien.
abstract class AttendanceRepository {
  /// Danh sach diem danh cua buoi [sessionId].
  Future<List<AttendanceItem>> list(int sessionId);

  /// Cap nhat trang thai diem danh cua [userId] trong buoi [sessionId].
  Future<void> setStatus(int sessionId, int userId, AttendanceStatus status);

  /// Lay token QR cho buoi [sessionId].
  Future<QrToken> qrToken(int sessionId);

  /// GV cham cong VAO bang ma QR phong [roomCode].
  Future<void> teacherCheckin(int sessionId, String roomCode);

  /// GV cham cong RA bang ma QR phong [roomCode].
  Future<void> teacherCheckout(int sessionId, String roomCode);

  /// Bao cao cong cua GV dang dang nhap trong khoang [from]..[to].
  Future<TeacherWorkReport> myWorkReport(DateTime from, DateTime to);
}

/// Trien khai [AttendanceRepository] qua [ApiClient].
class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<AttendanceItem>> list(int sessionId) async {
    final data = await _api.get('/api/v1/sessions/$sessionId/attendance');
    final rows = (data as List?) ?? const [];
    return rows
        .map((e) => AttendanceItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> setStatus(
    int sessionId,
    int userId,
    AttendanceStatus status,
  ) async {
    await _api.patch(
      '/api/v1/sessions/$sessionId/attendance/$userId',
      body: {'status': attendanceStatusToApi(status)},
    );
  }

  @override
  Future<QrToken> qrToken(int sessionId) async {
    final data = await _api.get('/api/v1/sessions/$sessionId/qr-token');
    return QrToken.fromJson(data! as Map<String, dynamic>);
  }

  static final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  @override
  Future<void> teacherCheckin(int sessionId, String roomCode) async {
    await _api.post(
      '/api/v1/sessions/$sessionId/teacher-checkin',
      body: {'roomCode': roomCode},
    );
  }

  @override
  Future<void> teacherCheckout(int sessionId, String roomCode) async {
    await _api.post(
      '/api/v1/sessions/$sessionId/teacher-checkout',
      body: {'roomCode': roomCode},
    );
  }

  @override
  Future<TeacherWorkReport> myWorkReport(DateTime from, DateTime to) async {
    final data = await _api.get(
      '/api/v1/teachers/me/teaching-attendance',
      query: {'from': _fmt.format(from), 'to': _fmt.format(to)},
    );
    return TeacherWorkReport.fromJson(data! as Map<String, dynamic>);
  }
}
