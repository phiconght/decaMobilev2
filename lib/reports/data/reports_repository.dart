import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/reports/data/models/report.dart';

/// Hop dong du lieu bao cao (Repository pattern — co the co nhieu cai dat).
// ignore: one_member_abstracts
abstract class ReportsRepository {
  Future<List<Report>> fetchReports();
}

/// Cai dat — hien tra MOCK (BE chua co cham diem).
class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._api);

  // ignore: unused_field — se dung khi noi endpoint that
  final ApiClient _api;

  @override
  Future<List<Report>> fetchReports() async {
    // TODO(be): goi endpoint ket qua bai lam khi co (cham diem la pha sau).
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _mock;
  }

  static final List<Report> _mock = [
    Report(
      examCode: 'DTO10-00001L',
      examName: 'KT giữa kỳ Toán',
      subjectName: 'Toán',
      score: 8.5,
      maxScore: 10,
      submittedAt: DateTime(2026, 5, 20),
      multipleChoiceScore: 6,
      essayScore: 2.5,
      durationMinutes: 42,
      comment: 'Làm tốt phần đại số, cần luyện thêm hình học.',
    ),
    Report(
      examCode: 'DLY11-00002L',
      examName: "KT 15' Vật lý",
      subjectName: 'Vật lý',
      score: 5,
      maxScore: 10,
      submittedAt: DateTime(2026, 5, 18),
      multipleChoiceScore: 5,
      durationMinutes: 15,
    ),
    Report(
      examCode: 'DAN10-00003L',
      examName: 'Kiểm tra Tiếng Anh',
      subjectName: 'Tiếng Anh',
      score: 9,
      maxScore: 10,
      submittedAt: DateTime(2026, 5, 10),
    ),
  ];
}
