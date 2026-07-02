import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:intl/intl.dart';

/// Truy van thoi khoa bieu va thao tac diem danh QR.
abstract class TimetableRepository {
  /// Lay danh sach buoi theo [view] trong khoang [from]..[to].
  Future<List<TimetableItem>> fetchTimetable({
    required String view,
    required DateTime from,
    required DateTime to,
  });

  /// Check-in buoi [sessionId] bang [token] QR.
  Future<void> checkin(int sessionId, String token);

  /// Check-out buoi [sessionId] bang [token] QR.
  Future<void> checkout(int sessionId, String token);
}

/// Trien khai [TimetableRepository] qua [ApiClient].
class TimetableRepositoryImpl implements TimetableRepository {
  const TimetableRepositoryImpl(this._api);

  final ApiClient _api;

  static final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  @override
  Future<List<TimetableItem>> fetchTimetable({
    required String view,
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await _api.get(
      '/api/v1/timetable',
      query: {
        'view': view,
        'from': _fmt.format(from),
        'to': _fmt.format(to),
      },
    );
    final list = (data as List?) ?? const [];
    return list
        .map((e) => TimetableItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> checkin(int sessionId, String token) async {
    await _api.post(
      '/api/v1/sessions/$sessionId/checkin',
      body: {'token': token},
    );
  }

  @override
  Future<void> checkout(int sessionId, String token) async {
    await _api.post(
      '/api/v1/sessions/$sessionId/checkout',
      body: {'token': token},
    );
  }
}
