import 'dart:typed_data';

import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/exams/data/models/exam.dart';

/// Hop dong du lieu de thi.
abstract class ExamsRepository {
  Future<List<Exam>> fetchExamsByClass(int classId);

  /// Tai file PDF de thi. variant: 'DE' (de trang) | 'DAP_AN' (chi EXAM:READ).
  Future<Uint8List> examPdf(int examId, {String variant = 'DE'});
}

/// Cai dat — lay de thi cua 1 lop tu BE:
/// GET /api/v1/exams/by-class/{classId} (tra ApiResponse boc danh sach).
class ExamsRepositoryImpl implements ExamsRepository {
  const ExamsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<Exam>> fetchExamsByClass(int classId) async {
    final data = await _api.get('/api/v1/exams/by-class/$classId');
    final list = (data as List<dynamic>?) ?? const [];
    return list
        .map((e) => Exam.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Uint8List> examPdf(int examId, {String variant = 'DE'}) {
    return _api.getBytes(
      '/api/v1/exams/$examId/pdf',
      query: {'variant': variant},
    );
  }
}
