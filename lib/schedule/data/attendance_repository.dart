import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/schedule/data/models/attendance_item.dart';
import 'package:deca_mobile/schedule/data/models/qr_token.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';

/// Diem danh hoc vien trong 1 buoi va cap token QR.
abstract class AttendanceRepository {
  /// Danh sach diem danh cua buoi [sessionId].
  Future<List<AttendanceItem>> list(int sessionId);

  /// Cap nhat trang thai diem danh cua [userId] trong buoi [sessionId].
  Future<void> setStatus(int sessionId, int userId, AttendanceStatus status);

  /// Lay token QR cho buoi [sessionId].
  Future<QrToken> qrToken(int sessionId);
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
}
