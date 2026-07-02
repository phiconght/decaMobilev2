// Models báo cáo — mirror DTO ở BE (com.trungtam.report.dto.response).

double? _d(Object? v) => v == null ? null : (v as num).toDouble();
int _i(Object? v) => v == null ? 0 : (v as num).toInt();
DateTime? _dt(Object? v) =>
    v == null ? null : DateTime.tryParse(v as String)?.toLocal();

class RecentExam {
  const RecentExam({
    required this.examStudentId,
    required this.examId,
    required this.examCode,
    required this.examName,
    required this.subjectName,
    required this.submittedAt,
    required this.score,
    required this.maxScore,
    this.classId,
    this.className,
  });

  factory RecentExam.fromJson(Map<String, dynamic> j) => RecentExam(
        examStudentId: _i(j['examStudentId']),
        examId: _i(j['examId']),
        examCode: j['examCode'] as String? ?? '',
        examName: j['examName'] as String? ?? '',
        subjectName: j['subjectName'] as String? ?? '',
        submittedAt: _dt(j['submittedAt']),
        score: _d(j['score']),
        maxScore: _d(j['maxScore']),
        classId: (j['classId'] as num?)?.toInt(),
        className: j['className'] as String?,
      );

  final int examStudentId;
  final int examId;
  final String examCode;
  final String examName;
  final String subjectName;
  final DateTime? submittedAt;
  final double? score;
  final double? maxScore;
  final int? classId;
  final String? className;

  double get ratio =>
      (score != null && maxScore != null && maxScore! > 0)
          ? score! / maxScore!
          : 0;
}

class ScoreTrendPoint {
  const ScoreTrendPoint({
    required this.examName,
    required this.score,
    required this.maxScore,
    required this.classAverage,
  });

  factory ScoreTrendPoint.fromJson(Map<String, dynamic> j) => ScoreTrendPoint(
        examName: j['examName'] as String? ?? '',
        score: _d(j['score']),
        maxScore: _d(j['maxScore']),
        classAverage: _d(j['classAverage']),
      );

  final String examName;
  final double? score;
  final double? maxScore;
  final double? classAverage;

  double? get selfPct =>
      (score != null && maxScore != null && maxScore! > 0)
          ? score! / maxScore! * 100
          : null;
  double? get avgPct =>
      (classAverage != null && maxScore != null && maxScore! > 0)
          ? classAverage! / maxScore! * 100
          : null;
}

class BucketStat {
  const BucketStat({
    required this.key,
    required this.correctCount,
    required this.incorrectCount,
    required this.ungradedCount,
    required this.correctPct,
  });

  factory BucketStat.fromJson(Map<String, dynamic> j) => BucketStat(
        key: j['key'] as String? ?? '',
        correctCount: _i(j['correctCount']),
        incorrectCount: _i(j['incorrectCount']),
        ungradedCount: _i(j['ungradedCount']),
        correctPct: _d(j['correctPct']),
      );

  final String key;
  final int correctCount;
  final int incorrectCount;
  final int ungradedCount;
  final double? correctPct;
}

class Breakdown {
  const Breakdown({required this.byDifficulty, required this.byType});

  factory Breakdown.fromJson(Map<String, dynamic> j) => Breakdown(
        byDifficulty: (j['byDifficulty'] as List<dynamic>? ?? [])
            .map((e) => BucketStat.fromJson(e as Map<String, dynamic>))
            .toList(),
        byType: (j['byType'] as List<dynamic>? ?? [])
            .map((e) => BucketStat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final List<BucketStat> byDifficulty;
  final List<BucketStat> byType;
}

class TopicMastery {
  const TopicMastery({
    required this.topicName,
    required this.masteryPct,
    required this.gradedCount,
  });

  factory TopicMastery.fromJson(Map<String, dynamic> j) => TopicMastery(
        topicName: j['topicName'] as String? ?? 'Chưa phân chương',
        masteryPct: _d(j['masteryPct']),
        gradedCount: _i(j['gradedCount']),
      );

  final String topicName;
  final double? masteryPct;
  final int gradedCount;
}

class ExamReportDetail {
  const ExamReportDetail({
    required this.examName,
    required this.score,
    required this.maxScore,
    required this.classAverage,
    required this.rank,
    required this.submittedCount,
    required this.classSize,
    required this.breakdown,
  });

  factory ExamReportDetail.fromJson(Map<String, dynamic> j) => ExamReportDetail(
        examName: j['examName'] as String? ?? '',
        score: _d(j['score']),
        maxScore: _d(j['maxScore']),
        classAverage: _d(j['classAverage']),
        rank: (j['rank'] as num?)?.toInt(),
        submittedCount: (j['submittedCount'] as num?)?.toInt(),
        classSize: (j['classSize'] as num?)?.toInt(),
        breakdown:
            Breakdown.fromJson(j['breakdown'] as Map<String, dynamic>? ?? {}),
      );

  final String examName;
  final double? score;
  final double? maxScore;
  final double? classAverage;
  final int? rank;
  final int? submittedCount;
  final int? classSize;
  final Breakdown breakdown;
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.totalSessions,
    required this.coMat,
    required this.tre,
    required this.vang,
    required this.coPhep,
    required this.chuaCheckin,
    required this.attendanceRate,
    required this.onTimeRate,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> j) =>
      AttendanceSummary(
        totalSessions: _i(j['totalSessions']),
        coMat: _i(j['coMat']),
        tre: _i(j['tre']),
        vang: _i(j['vang']),
        coPhep: _i(j['coPhep']),
        chuaCheckin: _i(j['chuaCheckin']),
        attendanceRate: _d(j['attendanceRate']),
        onTimeRate: _d(j['onTimeRate']),
      );

  final int totalSessions;
  final int coMat;
  final int tre;
  final int vang;
  final int coPhep;
  final int chuaCheckin;
  final double? attendanceRate;
  final double? onTimeRate;
}

class StudentAttendanceReport {
  const StudentAttendanceReport({required this.summary});

  factory StudentAttendanceReport.fromJson(Map<String, dynamic> j) =>
      StudentAttendanceReport(
        summary: AttendanceSummary.fromJson(
            j['summary'] as Map<String, dynamic>? ?? {}),
      );

  final AttendanceSummary summary;
}

class ClassStudentAverage {
  const ClassStudentAverage({
    required this.studentId,
    required this.fullName,
    required this.username,
    required this.submittedCount,
    required this.avgScore,
    required this.attendanceRate,
  });

  factory ClassStudentAverage.fromJson(Map<String, dynamic> j) =>
      ClassStudentAverage(
        studentId: _i(j['studentId']),
        fullName: j['fullName'] as String? ?? '',
        username: j['username'] as String? ?? '',
        submittedCount: _i(j['submittedCount']),
        avgScore: _d(j['avgScore']),
        attendanceRate: _d(j['attendanceRate']),
      );

  final int studentId;
  final String fullName;
  final String username;
  final int submittedCount;
  final double? avgScore;
  final double? attendanceRate;
}

class ClassExamAverage {
  const ClassExamAverage({
    required this.examName,
    required this.avgScore,
    required this.maxScore,
  });

  factory ClassExamAverage.fromJson(Map<String, dynamic> j) => ClassExamAverage(
        examName: j['examName'] as String? ?? '',
        avgScore: _d(j['avgScore']),
        maxScore: _d(j['maxScore']),
      );

  final String examName;
  final double? avgScore;
  final double? maxScore;

  double? get pct => (avgScore != null && maxScore != null && maxScore! > 0)
      ? avgScore! / maxScore! * 100
      : null;
}

class ReportComment {
  const ReportComment({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.visibleToStudent,
    required this.createdAt,
  });

  factory ReportComment.fromJson(Map<String, dynamic> j) => ReportComment(
        id: _i(j['id']),
        authorName: j['authorName'] as String? ?? '',
        authorRole: j['authorRole'] as String? ?? '',
        content: j['content'] as String? ?? '',
        visibleToStudent: j['visibleToStudent'] as bool? ?? false,
        createdAt: _dt(j['createdAt']),
      );

  final int id;
  final String authorName;
  final String authorRole;
  final String content;
  final bool visibleToStudent;
  final DateTime? createdAt;
}

class StudentClassOption {
  const StudentClassOption({
    required this.classId,
    required this.code,
    required this.name,
    required this.subjectName,
    required this.teacherNames,
  });

  factory StudentClassOption.fromJson(Map<String, dynamic> j) =>
      StudentClassOption(
        classId: _i(j['classId']),
        code: j['code'] as String? ?? '',
        name: j['name'] as String? ?? '',
        subjectName: j['subjectName'] as String? ?? '',
        teacherNames: j['teacherNames'] as String? ?? '',
      );

  final int classId;
  final String code;
  final String name;
  final String subjectName;
  final String teacherNames;
}

class ChildOption {
  const ChildOption({
    required this.studentId,
    required this.fullName,
    required this.username,
  });

  factory ChildOption.fromJson(Map<String, dynamic> j) => ChildOption(
        studentId: _i(j['studentId']),
        fullName: j['fullName'] as String? ?? '',
        username: j['username'] as String? ?? '',
      );

  final int studentId;
  final String fullName;
  final String username;
}
