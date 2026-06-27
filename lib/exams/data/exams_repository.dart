import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/exams/data/models/exam.dart';

/// Hop dong du lieu de thi.
// ignore: one_member_abstracts
abstract class ExamsRepository {
  Future<List<Exam>> fetchExamsByClass(int classId);
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
}
