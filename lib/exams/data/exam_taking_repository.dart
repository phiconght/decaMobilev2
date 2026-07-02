import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/exams/data/models/exam_paper.dart';

/// Hop dong du lieu lam bai kiem tra.
abstract class ExamTakingRepository {
  /// Lay de de lam (kem trang thai + cau tra loi cu neu da nop / ban nhap).
  Future<ExamPaper> fetchPaper(int examId);

  /// Nop bai -> BE cham MC/TF (tu luan cham tay) va tra ket qua.
  Future<ExamResult> submit({
    required ExamPaper paper,
    required ExamAnswers answers,
  });

  /// Luu nhap (chua nop) de giu tien do lam bai.
  Future<void> saveDraft({required int examId, required ExamAnswers answers});
}

/// Cai dat goi BE that (self-scoped theo hoc vien dang dang nhap):
/// - GET  /api/v1/exams/{id}/paper  — de + cau hoi (an dap an khi dang lam)
/// - POST /api/v1/exams/{id}/submit — nop bai, BE cham va luu diem
/// - POST /api/v1/exams/{id}/draft  — luu nhap tien do
class ExamTakingRepositoryImpl implements ExamTakingRepository {
  const ExamTakingRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ExamPaper> fetchPaper(int examId) async {
    final data = await _api.get('/api/v1/exams/$examId/paper');
    return ExamPaper.fromJson(data! as Map<String, dynamic>);
  }

  @override
  Future<ExamResult> submit({
    required ExamPaper paper,
    required ExamAnswers answers,
  }) async {
    final data = await _api.post(
      '/api/v1/exams/${paper.examId}/submit',
      body: answers.toJson(),
    );
    return ExamResult.fromJson(data! as Map<String, dynamic>);
  }

  @override
  Future<void> saveDraft({
    required int examId,
    required ExamAnswers answers,
  }) async {
    await _api.post('/api/v1/exams/$examId/draft', body: answers.toJson());
  }
}
