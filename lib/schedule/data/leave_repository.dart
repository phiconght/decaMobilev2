import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/schedule/data/models/leave_item.dart';

/// Kho du lieu don nghi phep.
abstract class LeaveRepository {
  Future<LeaveItem> create(CreateLeaveRequest req);
  Future<List<LeaveItem>> list({int? studentId, String? status});
  Future<LeaveItem> approve(int id);
  Future<LeaveItem> reject(int id);

  /// PHU HUYNH xac nhan don xin nghi cua con — bat buoc truoc khi GV/nhan
  /// vien duyet duoc (yeu cau nguoi dung 13/08/2026).
  Future<LeaveItem> confirmByParent(int id);
}

/// Trien khai [LeaveRepository] dung [ApiClient].
class LeaveRepositoryImpl implements LeaveRepository {
  const LeaveRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<LeaveItem> create(CreateLeaveRequest req) async {
    final data = await _api.post('/api/v1/leaves', body: req.toJson());
    return LeaveItem.fromJson(data! as Map<String, dynamic>);
  }

  @override
  Future<List<LeaveItem>> list({int? studentId, String? status}) async {
    final data = await _api.get(
      '/api/v1/leaves',
      query: <String, dynamic>{
        'studentId': ?studentId,
        'status': ?status,
        'current': 1,
        'pageSize': 50,
      },
    );
    final listData = (data as List?) ?? const [];
    return listData
        .map((e) => LeaveItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LeaveItem> approve(int id) async {
    final data = await _api.patch('/api/v1/leaves/$id/approve');
    return LeaveItem.fromJson(data! as Map<String, dynamic>);
  }

  @override
  Future<LeaveItem> reject(int id) async {
    final data = await _api.patch('/api/v1/leaves/$id/reject');
    return LeaveItem.fromJson(data! as Map<String, dynamic>);
  }

  @override
  Future<LeaveItem> confirmByParent(int id) async {
    final data = await _api.patch('/api/v1/leaves/$id/parent-confirm');
    return LeaveItem.fromJson(data! as Map<String, dynamic>);
  }
}
