import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';

/// Hop dong du lieu bao cao. Goi cac endpoint /api/v1/reports/** cua BE.
abstract class ReportsRepository {
  Future<List<RecentExam>> recentExams(int studentId, {int limit = 3});
  Future<List<RecentExam>> examHistory(int studentId, int classId);
  Future<List<StudentClassOption>> studentClasses(int studentId);
  Future<ExamReportDetail> examDetail(int studentId, int examId, int classId);
  Future<List<ScoreTrendPoint>> scoreTrend(int studentId, int classId,
      {int? topicId});
  Future<Breakdown> breakdowns(int studentId, int classId, {int? topicId});
  Future<List<TopicMastery>> topicMastery(int studentId, int classId);
  Future<StudentAttendanceReport> attendance(int studentId, int classId,
      {int? topicId});
  Future<List<ChildOption>> myChildren();
  Future<List<StudentClassOption>> myClasses();
  // Bang "Phan tich tu dong" — cap toan khoa
  Future<ReportAnalysis> analysis(int studentId, int classId);
  // Bang "Phan tich tu dong" — cap Chuong/Buoi/Bai thi (§Phan C)
  Future<ChapterAnalysisDetail> chapterAnalysis(
      int studentId, int classId, int topicId);
  Future<SessionAnalysis> sessionAnalysis(
      int studentId, int classId, int sessionId);
  Future<ExamAnalysis> examAnalysis(int studentId, int examId, int classId);
  // Bao cao cap BUOI HOC (drill-down cap 3)
  Future<List<RecentExam>> sessionExams(
      int studentId, int classId, int sessionId);
  Future<Breakdown> sessionBreakdowns(
      int studentId, int classId, int sessionId);
  Future<List<ClassExamAverage>> classSessionExams(
      int classId, int sessionId);
  Future<Breakdown> classSessionBreakdowns(int classId, int sessionId);
  // Pho diem (§12)
  Future<ScoreDistribution> examScoreDistribution(
      int studentId, int examId, int classId);
  Future<ScoreDistribution> classExamScoreDistribution(int classId, int examId);
  Future<ScoreDistribution> courseSpectrum(int studentId, int classId,
      {int bandCount});
  Future<ScoreDistribution> classCourseSpectrum(int classId, {int bandCount});
  // Giao bai (§10). examId = bai thi nguon (tuy chon) — null khi giao truc
  // tiep tu cap khoa/chuong/buoi thay vi tu 1 bai thi cu the.
  Future<PracticeAssignmentResult> assignPractice(
      int studentId, int classId, {int? examId, int? topicId});
  // Toan bo de da giao cho 1 HV, gop MOI lop — the "Bai phu huynh giao"
  // o tab Khoa hoc (§10.11).
  Future<List<PracticeAssignmentItem>> myPracticeAssignments(int studentId);
  // Lop
  Future<List<ClassExamAverage>> classExamAverages(int classId,
      {int? topicId});
  Future<Breakdown> classBreakdowns(int classId, {int? topicId});
  Future<List<TopicMastery>> classTopicMastery(int classId);
  Future<StudentAttendanceReport> classAttendance(int classId,
      {int? topicId});
  Future<List<ClassStudentAverage>> classStudents(int classId);
  // Nhan xet
  Future<List<ReportComment>> comments(int studentId, int classId);
  Future<void> addComment({
    required int studentId,
    required int classId,
    required String content,
    required bool visibleToStudent,
  });
}

class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._api);

  final ApiClient _api;

  static const _base = '/api/v1/reports';

  List<T> _list<T>(Object? data, T Function(Map<String, dynamic>) f) =>
      ((data as List<dynamic>?) ?? const [])
          .map((e) => f(e as Map<String, dynamic>))
          .toList();

  Map<String, dynamic> _map(Object? data) =>
      (data as Map<String, dynamic>?) ?? const {};

  @override
  Future<List<RecentExam>> recentExams(int studentId, {int limit = 3}) async {
    final data = await _api.get(
      '$_base/students/$studentId/recent-exams',
      query: {'limit': limit},
    );
    return _list(data, RecentExam.fromJson);
  }

  @override
  Future<List<RecentExam>> examHistory(int studentId, int classId) async {
    final data = await _api.get(
      '$_base/students/$studentId/exam-history',
      query: {'classId': classId},
    );
    return _list(data, RecentExam.fromJson);
  }

  @override
  Future<List<StudentClassOption>> studentClasses(int studentId) async {
    final data = await _api.get('$_base/students/$studentId/classes');
    return _list(data, StudentClassOption.fromJson);
  }

  @override
  Future<ExamReportDetail> examDetail(
    int studentId,
    int examId,
    int classId,
  ) async {
    final data = await _api.get(
      '$_base/students/$studentId/exams/$examId',
      query: {'classId': classId},
    );
    return ExamReportDetail.fromJson(_map(data));
  }

  @override
  Future<List<ScoreTrendPoint>> scoreTrend(int studentId, int classId,
      {int? topicId}) async {
    final data = await _api.get(
      '$_base/students/$studentId/classes/$classId/score-trend',
      query: topicId == null ? null : {'topicId': topicId},
    );
    return _list(data, ScoreTrendPoint.fromJson);
  }

  @override
  Future<Breakdown> breakdowns(int studentId, int classId, {int? topicId}) async {
    final data = await _api.get(
      '$_base/students/$studentId/classes/$classId/breakdowns',
      query: topicId == null ? null : {'topicId': topicId},
    );
    return Breakdown.fromJson(_map(data));
  }

  @override
  Future<ScoreDistribution> examScoreDistribution(
    int studentId,
    int examId,
    int classId,
  ) async {
    final data = await _api.get(
      '$_base/students/$studentId/exams/$examId/score-distribution',
      query: {'classId': classId},
    );
    return ScoreDistribution.fromJson(_map(data));
  }

  @override
  Future<ScoreDistribution> classExamScoreDistribution(
    int classId,
    int examId,
  ) async {
    final data =
        await _api.get('$_base/classes/$classId/exams/$examId/score-distribution');
    return ScoreDistribution.fromJson(_map(data));
  }

  @override
  Future<ScoreDistribution> courseSpectrum(int studentId, int classId,
      {int bandCount = 40}) async {
    final data = await _api.get(
      '$_base/students/$studentId/classes/$classId/score-distribution',
      query: {'bandCount': bandCount},
    );
    return ScoreDistribution.fromJson(_map(data));
  }

  @override
  Future<ScoreDistribution> classCourseSpectrum(int classId,
      {int bandCount = 40}) async {
    final data = await _api.get(
      '$_base/classes/$classId/score-distribution',
      query: {'bandCount': bandCount},
    );
    return ScoreDistribution.fromJson(_map(data));
  }

  @override
  Future<PracticeAssignmentResult> assignPractice(
    int studentId,
    int classId, {
    int? examId,
    int? topicId,
  }) async {
    final data = await _api.post(
      '$_base/students/$studentId/classes/$classId/assign-practice',
      body: {
        if (examId != null) 'examId': examId,
        if (topicId != null) 'topicId': topicId,
      },
    );
    return PracticeAssignmentResult.fromJson(_map(data));
  }

  @override
  Future<List<PracticeAssignmentItem>> myPracticeAssignments(
    int studentId,
  ) async {
    final data =
        await _api.get('$_base/students/$studentId/practice-assignments');
    return _list(data, PracticeAssignmentItem.fromJson);
  }

  @override
  Future<List<TopicMastery>> topicMastery(int studentId, int classId) async {
    final data = await _api
        .get('$_base/students/$studentId/classes/$classId/topic-mastery');
    return _list(data, TopicMastery.fromJson);
  }

  @override
  Future<StudentAttendanceReport> attendance(int studentId, int classId,
      {int? topicId}) async {
    final data = await _api.get(
      '$_base/students/$studentId/classes/$classId/attendance',
      query: topicId == null ? null : {'topicId': topicId},
    );
    return StudentAttendanceReport.fromJson(_map(data));
  }

  @override
  Future<List<RecentExam>> sessionExams(
      int studentId, int classId, int sessionId) async {
    final data = await _api.get(
      '$_base/students/$studentId/classes/$classId/sessions/$sessionId/exams',
    );
    return _list(data, RecentExam.fromJson);
  }

  @override
  Future<Breakdown> sessionBreakdowns(
      int studentId, int classId, int sessionId) async {
    final data = await _api.get(
      '$_base/students/$studentId/classes/$classId/sessions/$sessionId/breakdowns',
    );
    return Breakdown.fromJson(_map(data));
  }

  @override
  Future<List<ClassExamAverage>> classSessionExams(
      int classId, int sessionId) async {
    final data =
        await _api.get('$_base/classes/$classId/sessions/$sessionId/exams');
    return _list(data, ClassExamAverage.fromJson);
  }

  @override
  Future<Breakdown> classSessionBreakdowns(int classId, int sessionId) async {
    final data = await _api
        .get('$_base/classes/$classId/sessions/$sessionId/breakdowns');
    return Breakdown.fromJson(_map(data));
  }

  @override
  Future<ReportAnalysis> analysis(int studentId, int classId) async {
    final data =
        await _api.get('$_base/students/$studentId/classes/$classId/analysis');
    return ReportAnalysis.fromJson(_map(data));
  }

  @override
  Future<ChapterAnalysisDetail> chapterAnalysis(
      int studentId, int classId, int topicId) async {
    final data = await _api.get(
      '$_base/students/$studentId/classes/$classId/topics/$topicId/analysis',
    );
    return ChapterAnalysisDetail.fromJson(_map(data));
  }

  @override
  Future<SessionAnalysis> sessionAnalysis(
      int studentId, int classId, int sessionId) async {
    final data = await _api.get(
      '$_base/students/$studentId/classes/$classId/sessions/$sessionId/analysis',
    );
    return SessionAnalysis.fromJson(_map(data));
  }

  @override
  Future<ExamAnalysis> examAnalysis(
      int studentId, int examId, int classId) async {
    final data = await _api.get(
      '$_base/students/$studentId/exams/$examId/analysis',
      query: {'classId': classId},
    );
    return ExamAnalysis.fromJson(_map(data));
  }

  @override
  Future<List<ChildOption>> myChildren() async {
    final data = await _api.get('$_base/my-children');
    return _list(data, ChildOption.fromJson);
  }

  @override
  Future<List<StudentClassOption>> myClasses() async {
    final data = await _api.get('$_base/my-classes');
    return _list(data, StudentClassOption.fromJson);
  }

  @override
  Future<List<ClassExamAverage>> classExamAverages(int classId,
      {int? topicId}) async {
    final data = await _api.get(
      '$_base/classes/$classId/exam-averages',
      query: topicId == null ? null : {'topicId': topicId},
    );
    return _list(data, ClassExamAverage.fromJson);
  }

  @override
  Future<Breakdown> classBreakdowns(int classId, {int? topicId}) async {
    final data = await _api.get(
      '$_base/classes/$classId/breakdowns',
      query: topicId == null ? null : {'topicId': topicId},
    );
    return Breakdown.fromJson(_map(data));
  }

  @override
  Future<List<TopicMastery>> classTopicMastery(int classId) async {
    final data = await _api.get('$_base/classes/$classId/topic-mastery');
    return _list(data, TopicMastery.fromJson);
  }

  @override
  Future<StudentAttendanceReport> classAttendance(int classId,
      {int? topicId}) async {
    final data = await _api.get(
      '$_base/classes/$classId/attendance',
      query: topicId == null ? null : {'topicId': topicId},
    );
    return StudentAttendanceReport.fromJson(_map(data));
  }

  @override
  Future<List<ClassStudentAverage>> classStudents(int classId) async {
    final data = await _api.get('$_base/classes/$classId/students');
    return _list(data, ClassStudentAverage.fromJson);
  }

  @override
  Future<List<ReportComment>> comments(int studentId, int classId) async {
    final data = await _api.get(
      '$_base/comments',
      query: {'studentId': studentId, 'classId': classId},
    );
    return _list(data, ReportComment.fromJson);
  }

  @override
  Future<void> addComment({
    required int studentId,
    required int classId,
    required String content,
    required bool visibleToStudent,
  }) async {
    await _api.post(
      '$_base/comments',
      body: {
        'studentId': studentId,
        'classId': classId,
        'content': content,
        'visibleToStudent': visibleToStudent,
      },
    );
  }
}
