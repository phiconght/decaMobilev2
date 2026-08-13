import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/schedule/data/models/session_content.dart';

/// Video bai giang + link Zoom + de thi cua 1 buoi hoc (chi doc video/zoom —
/// quan ly o Admin; de thi hoc vien lam truc tiep tu day).
/// Xem SPEC_VideoBaiGiang_Zoom.md §5.
abstract class SessionContentRepository {
  /// Danh sach video bai giang cua buoi [sessionId], da sap theo sortOrder.
  Future<List<SessionVideoItem>> fetchVideos(int sessionId);

  /// Danh sach link Zoom cua buoi [sessionId], da sap theo sortOrder.
  Future<List<ZoomLinkItem>> fetchZoomLinks(int sessionId);

  /// De thi gan RIENG buoi [sessionId] (khong phai de chung ca chuyen de).
  Future<List<SessionExamItem>> fetchExams(int sessionId);
}

/// Trien khai [SessionContentRepository] qua [ApiClient].
class SessionContentRepositoryImpl implements SessionContentRepository {
  const SessionContentRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<SessionVideoItem>> fetchVideos(int sessionId) async {
    final data = await _api.get('/api/v1/sessions/$sessionId/videos');
    final list = (data as List?) ?? const [];
    return list
        .map((e) => SessionVideoItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ZoomLinkItem>> fetchZoomLinks(int sessionId) async {
    final data = await _api.get('/api/v1/sessions/$sessionId/zoom-links');
    final list = (data as List?) ?? const [];
    return list
        .map((e) => ZoomLinkItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SessionExamItem>> fetchExams(int sessionId) async {
    final data = await _api.get('/api/v1/exams/by-session/$sessionId');
    final list = (data as List?) ?? const [];
    return list
        .map((e) => SessionExamItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
