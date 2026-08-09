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
    required this.examId,
    required this.examName,
    required this.score,
    required this.maxScore,
    required this.classAverage,
  });

  factory ScoreTrendPoint.fromJson(Map<String, dynamic> j) => ScoreTrendPoint(
        examId: _i(j['examId']),
        examName: j['examName'] as String? ?? '',
        score: _d(j['score']),
        maxScore: _d(j['maxScore']),
        classAverage: _d(j['classAverage']),
      );

  final int examId;
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
    this.topicId,
  });

  factory TopicMastery.fromJson(Map<String, dynamic> j) => TopicMastery(
        topicId: (j['topicId'] as num?)?.toInt(),
        topicName: j['topicName'] as String? ?? 'Chưa phân chương',
        masteryPct: _d(j['masteryPct']),
        gradedCount: _i(j['gradedCount']),
      );

  final int? topicId;
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
    required this.topicId,
    required this.topicName,
    required this.breakdown,
    required this.distribution,
    this.sessionId,
    this.sessionTitle,
    this.sessionDate,
  });

  factory ExamReportDetail.fromJson(Map<String, dynamic> j) => ExamReportDetail(
        examName: j['examName'] as String? ?? '',
        score: _d(j['score']),
        maxScore: _d(j['maxScore']),
        classAverage: _d(j['classAverage']),
        rank: (j['rank'] as num?)?.toInt(),
        submittedCount: (j['submittedCount'] as num?)?.toInt(),
        classSize: (j['classSize'] as num?)?.toInt(),
        topicId: (j['topicId'] as num?)?.toInt(),
        topicName: j['topicName'] as String?,
        sessionId: (j['sessionId'] as num?)?.toInt(),
        sessionTitle: j['sessionTitle'] as String?,
        sessionDate: DateTime.tryParse(j['sessionDate'] as String? ?? ''),
        breakdown:
            Breakdown.fromJson(j['breakdown'] as Map<String, dynamic>? ?? {}),
        distribution: j['distribution'] == null
            ? null
            : ScoreDistribution.fromJson(
                j['distribution'] as Map<String, dynamic>),
      );

  final String examName;
  final double? score;
  final double? maxScore;
  final double? classAverage;
  final int? rank;
  final int? submittedCount;
  final int? classSize;
  final int? topicId;
  final String? topicName;
  final int? sessionId;
  final String? sessionTitle;
  final DateTime? sessionDate;
  final Breakdown breakdown;
  final ScoreDistribution? distribution;
}

class ScoreBand {
  const ScoreBand({
    required this.index,
    required this.fromScore,
    required this.toScore,
    required this.count,
    required this.containsStudent,
  });

  factory ScoreBand.fromJson(Map<String, dynamic> j) => ScoreBand(
        index: _i(j['index']),
        fromScore: _d(j['fromScore']) ?? 0,
        toScore: _d(j['toScore']) ?? 0,
        count: _i(j['count']),
        containsStudent: j['containsStudent'] as bool? ?? false,
      );

  final int index;
  final double fromScore;
  final double toScore;
  final int count;
  final bool containsStudent;
}

class ScoreDistribution {
  const ScoreDistribution({
    required this.maxScore,
    required this.bands,
    required this.studentScore,
    required this.percentile,
    required this.classAverage,
    required this.median,
    required this.highest,
    required this.lowest,
    required this.rank,
    required this.submittedCount,
  });

  factory ScoreDistribution.fromJson(Map<String, dynamic> j) => ScoreDistribution(
        maxScore: _d(j['maxScore']),
        bands: (j['bands'] as List<dynamic>? ?? [])
            .map((e) => ScoreBand.fromJson(e as Map<String, dynamic>))
            .toList(),
        studentScore: _d(j['studentScore']),
        percentile: _d(j['percentile']),
        classAverage: _d(j['classAverage']),
        median: _d(j['median']),
        highest: _d(j['highest']),
        lowest: _d(j['lowest']),
        rank: (j['rank'] as num?)?.toInt(),
        submittedCount: (j['submittedCount'] as num?)?.toInt(),
      );

  final double? maxScore;
  final List<ScoreBand> bands;
  final double? studentScore;
  final double? percentile;
  final double? classAverage;
  final double? median;
  final double? highest;
  final double? lowest;
  final int? rank;
  final int? submittedCount;
}

class PracticeAssignmentResult {
  const PracticeAssignmentResult({
    required this.examName,
    required this.topicName,
    required this.numQuestions,
    required this.easy,
    required this.medium,
    required this.hard,
    required this.multipleChoice,
    required this.trueFalse,
    required this.deadline,
  });

  factory PracticeAssignmentResult.fromJson(Map<String, dynamic> j) {
    final bd = j['byDifficulty'] as Map<String, dynamic>? ?? {};
    final bt = j['byType'] as Map<String, dynamic>? ?? {};
    return PracticeAssignmentResult(
      examName: j['examName'] as String? ?? '',
      topicName: j['topicName'] as String?,
      numQuestions: _i(j['numQuestions']),
      easy: _i(bd['easy']),
      medium: _i(bd['medium']),
      hard: _i(bd['hard']),
      multipleChoice: _i(bt['multipleChoice']),
      trueFalse: _i(bt['trueFalse']),
      deadline: _dt(j['deadline']),
    );
  }

  final String examName;
  final String? topicName;
  final int numQuestions;
  final int easy;
  final int medium;
  final int hard;
  final int multipleChoice;
  final int trueFalse;
  final DateTime? deadline;
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
    required this.examId,
    required this.examName,
    required this.avgScore,
    required this.maxScore,
  });

  factory ClassExamAverage.fromJson(Map<String, dynamic> j) => ClassExamAverage(
        examId: _i(j['examId']),
        examName: j['examName'] as String? ?? '',
        avgScore: _d(j['avgScore']),
        maxScore: _d(j['maxScore']),
      );

  final int examId;
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

class ChapterAnalysis {
  const ChapterAnalysis({
    required this.chapterLabel,
    this.topicId,
    this.avgScore,
    this.rank,
    this.classSize,
  });

  factory ChapterAnalysis.fromJson(Map<String, dynamic> j) => ChapterAnalysis(
        topicId: (j['topicId'] as num?)?.toInt(),
        chapterLabel: j['chapterLabel'] as String? ?? '',
        avgScore: _d(j['avgScore']),
        rank: (j['rank'] as num?)?.toInt(),
        classSize: (j['classSize'] as num?)?.toInt(),
      );

  final int? topicId;
  final String chapterLabel;
  final double? avgScore;
  final int? rank;
  final int? classSize;
}

/// Bang "Phan tich tu dong" o dau bao cao ca nhan — cau chu da ghep san o BE
/// (ReportNarrativeBuilder), Mobile chi render, khong tu tinh toan.
class ReportAnalysis {
  const ReportAnalysis({
    required this.studentName,
    required this.className,
    required this.chapters,
    required this.abilityInsights,
    this.scoreSpectrumLabel,
    this.courseAverage,
    this.courseRank,
    this.classSize,
    this.attendanceInsight,
    this.teacherCommentAuthor,
    this.teacherCommentContent,
  });

  factory ReportAnalysis.fromJson(Map<String, dynamic> j) => ReportAnalysis(
        studentName: j['studentName'] as String? ?? '',
        className: j['className'] as String? ?? '',
        scoreSpectrumLabel: j['scoreSpectrumLabel'] as String?,
        courseAverage: _d(j['courseAverage']),
        courseRank: (j['courseRank'] as num?)?.toInt(),
        classSize: (j['classSize'] as num?)?.toInt(),
        chapters: ((j['chapters'] as List<dynamic>?) ?? const [])
            .map((e) => ChapterAnalysis.fromJson(e as Map<String, dynamic>))
            .toList(),
        abilityInsights: ((j['abilityInsights'] as List<dynamic>?) ?? const [])
            .map((e) => e as String)
            .toList(),
        attendanceInsight: j['attendanceInsight'] as String?,
        teacherCommentAuthor: j['teacherCommentAuthor'] as String?,
        teacherCommentContent: j['teacherCommentContent'] as String?,
      );

  final String studentName;
  final String className;
  final String? scoreSpectrumLabel;
  final double? courseAverage;
  final int? courseRank;
  final int? classSize;
  final List<ChapterAnalysis> chapters;
  final List<String> abilityInsights;
  final String? attendanceInsight;
  final String? teacherCommentAuthor;
  final String? teacherCommentContent;
}

/// Bang "Phan tich tu dong" cho 1 CHUONG (§Phan C) — doc lap voi
/// [ChapterAnalysis] (item long trong [ReportAnalysis] cap toan khoa).
class ChapterAnalysisDetail {
  const ChapterAnalysisDetail({
    required this.abilityInsights,
    this.chapterLabel,
    this.avgScore,
    this.rank,
    this.classSize,
    this.attendanceInsight,
  });

  factory ChapterAnalysisDetail.fromJson(Map<String, dynamic> j) =>
      ChapterAnalysisDetail(
        chapterLabel: j['chapterLabel'] as String?,
        avgScore: _d(j['avgScore']),
        rank: (j['rank'] as num?)?.toInt(),
        classSize: (j['classSize'] as num?)?.toInt(),
        abilityInsights: ((j['abilityInsights'] as List<dynamic>?) ?? const [])
            .map((e) => e as String)
            .toList(),
        attendanceInsight: j['attendanceInsight'] as String?,
      );

  final String? chapterLabel;
  final double? avgScore;
  final int? rank;
  final int? classSize;
  final List<String> abilityInsights;
  final String? attendanceInsight;
}

/// Bang "Phan tich tu dong" cho 1 BUOI HOC (§Phan C).
class SessionAnalysis {
  const SessionAnalysis({
    required this.abilityInsights,
    required this.examCount,
    required this.submittedCount,
    this.avgScore,
    this.classAverage,
    this.comparisonInsight,
  });

  factory SessionAnalysis.fromJson(Map<String, dynamic> j) => SessionAnalysis(
        avgScore: _d(j['avgScore']),
        classAverage: _d(j['classAverage']),
        comparisonInsight: j['comparisonInsight'] as String?,
        abilityInsights: ((j['abilityInsights'] as List<dynamic>?) ?? const [])
            .map((e) => e as String)
            .toList(),
        examCount: _i(j['examCount']),
        submittedCount: _i(j['submittedCount']),
      );

  final double? avgScore;
  final double? classAverage;
  final String? comparisonInsight;
  final List<String> abilityInsights;
  final int examCount;
  final int submittedCount;
}

/// Bang "Phan tich tu dong" cho 1 BAI THI (§Phan C).
class ExamAnalysis {
  const ExamAnalysis({
    required this.abilityInsights,
    this.score,
    this.classAverage,
    this.rank,
    this.classSize,
    this.comparisonInsight,
  });

  factory ExamAnalysis.fromJson(Map<String, dynamic> j) => ExamAnalysis(
        score: _d(j['score']),
        classAverage: _d(j['classAverage']),
        rank: (j['rank'] as num?)?.toInt(),
        classSize: (j['classSize'] as num?)?.toInt(),
        comparisonInsight: j['comparisonInsight'] as String?,
        abilityInsights: ((j['abilityInsights'] as List<dynamic>?) ?? const [])
            .map((e) => e as String)
            .toList(),
      );

  final double? score;
  final double? classAverage;
  final int? rank;
  final int? classSize;
  final String? comparisonInsight;
  final List<String> abilityInsights;
}
