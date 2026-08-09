import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/courses/data/courses_repository.dart';
import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/reports/view/session_report_page.dart';
import 'package:deca_mobile/reports/view/student_exam_detail_page.dart';
import 'package:deca_mobile/reports/widgets/chapter_analysis_card.dart';
import 'package:deca_mobile/reports/widgets/exam_cards.dart';
import 'package:deca_mobile/reports/widgets/report_charts.dart';
import 'package:deca_mobile/reports/widgets/session_cards.dart';
import 'package:flutter/material.dart';

class _Bundle {
  const _Bundle(this.outline, this.breakdown, this.attendance, this.trend,
      this.classExams, this.analysis, this.topics);
  final ClassOutline outline;
  final Breakdown breakdown;
  final StudentAttendanceReport attendance;
  final List<ScoreTrendPoint> trend;
  final List<ClassExamAverage> classExams;
  final ChapterAnalysisDetail? analysis;
  final List<TopicMastery> topics;
}

/// Bao cao CAP 2 — theo 1 chuong. [studentId] null = pham vi ca lop (GV xem).
/// Danh sach buoi/de cua chuong lay tu outline co san (KHONG dung lai cay
/// phan cap rieng) — xem BE ClassOutlineService. ChapterAnalysisCard va
/// khung "De thi trong chuong" CHI hien voi studentId (§Phan C quyet dinh
/// #1) — GV xem ca lop khong co bang phan tich ca nhan.
class ChapterReportPage extends StatefulWidget {
  const ChapterReportPage({
    required this.repository,
    required this.coursesRepository,
    required this.classId,
    required this.topicId,
    required this.topicName,
    this.studentId,
    super.key,
  });

  final ReportsRepository repository;
  final CoursesRepository coursesRepository;
  final int classId;
  final int topicId;
  final String topicName;
  final int? studentId;

  @override
  State<ChapterReportPage> createState() => _ChapterReportPageState();
}

class _ChapterReportPageState extends State<ChapterReportPage> {
  late Future<_Bundle> _future;
  bool _byType = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Bundle> _load() async {
    final studentId = widget.studentId;
    final results = await Future.wait([
      widget.coursesRepository
          .fetchOutline(widget.classId, studentId: studentId),
      studentId != null
          ? widget.repository
              .breakdowns(studentId, widget.classId, topicId: widget.topicId)
          : widget.repository
              .classBreakdowns(widget.classId, topicId: widget.topicId),
      studentId != null
          ? widget.repository
              .attendance(studentId, widget.classId, topicId: widget.topicId)
          : widget.repository
              .classAttendance(widget.classId, topicId: widget.topicId),
      studentId != null
          ? widget.repository
              .scoreTrend(studentId, widget.classId, topicId: widget.topicId)
          : Future.value(<ScoreTrendPoint>[]),
      studentId == null
          ? widget.repository
              .classExamAverages(widget.classId, topicId: widget.topicId)
          : Future.value(<ClassExamAverage>[]),
      studentId != null
          ? widget.repository
              .chapterAnalysis(studentId, widget.classId, widget.topicId)
          : Future.value(null),
      studentId != null
          ? widget.repository.topicMastery(studentId, widget.classId)
          : Future.value(<TopicMastery>[]),
    ]);
    return _Bundle(
      results[0] as ClassOutline,
      results[1] as Breakdown,
      results[2] as StudentAttendanceReport,
      results[3] as List<ScoreTrendPoint>,
      results[4] as List<ClassExamAverage>,
      results[5] as ChapterAnalysisDetail?,
      results[6] as List<TopicMastery>,
    );
  }

  void _openSession(int sessionId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionReportPage(
          repository: widget.repository,
          coursesRepository: widget.coursesRepository,
          classId: widget.classId,
          sessionId: sessionId,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  void _openExam(OutlineExam e, List<TopicMastery> topics) {
    final studentId = widget.studentId;
    if (studentId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudentExamDetailPage(
          repository: widget.repository,
          studentId: studentId,
          classId: widget.classId,
          exam: RecentExam(
            examStudentId: e.examId,
            examId: e.examId,
            examCode: e.code ?? '',
            examName: e.name,
            subjectName: '',
            submittedAt: e.publishAt,
            score: e.score,
            maxScore: e.maxScore,
          ),
          topics: topics,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chương: ${widget.topicName}')),
      body: FutureBuilder<_Bundle>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Center(child: Text('Không tải được báo cáo chương'));
          }
          final b = snap.data!;
          final group = b.outline.groups.firstWhere(
            (g) => g.topicId == widget.topicId,
            orElse: () => const OutlineTopicGroup(sessions: [], exams: []),
          );
          final att = b.attendance.summary;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.studentId != null)
                ChapterAnalysisCard(analysis: b.analysis),
              if (widget.studentId != null)
                SectionCard(
                  title: 'Xu hướng điểm trong chương',
                  child: ScoreTrendChart(points: b.trend),
                )
              else
                SectionCard(
                  title: 'Điểm TB lớp qua các đề trong chương',
                  child: b.classExams.isEmpty
                      ? const Text('Chưa có dữ liệu')
                      : Column(
                          children: b.classExams
                              .map((e) => ListTile(
                                    dense: true,
                                    title: Text(e.examName),
                                    trailing: Text(
                                        e.avgScore?.toStringAsFixed(2) ??
                                            '—'),
                                  ))
                              .toList(),
                        ),
                ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Tỉ lệ đúng/sai trong chương',
                child: Column(
                  children: [
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Độ khó')),
                        ButtonSegment(value: true, label: Text('Loại câu')),
                      ],
                      selected: {_byType},
                      onSelectionChanged: (s) =>
                          setState(() => _byType = s.first),
                    ),
                    const SizedBox(height: 12),
                    BreakdownBarChart(
                      buckets: _byType
                          ? b.breakdown.byType
                          : b.breakdown.byDifficulty,
                      labelMap: _byType ? typeLabel : difficultyLabel,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Chuyên cần trong chương',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Mini(
                            label: 'Đi đủ', value: _pct(att.attendanceRate)),
                        _Mini(
                            label: 'Đúng giờ', value: _pct(att.onTimeRate)),
                        _Mini(
                            label: 'Số buổi', value: '${att.totalSessions}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AttendanceDonut(summary: att),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Báo cáo theo buổi học',
                child: SessionCards(
                  sessions: group.sessions,
                  onTap: _openSession,
                ),
              ),
              if (widget.studentId != null) ...[
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Báo cáo theo bài thi trong chương',
                  child: ExamCards(
                    exams: group.exams,
                    onTap: (e) => _openExam(e, b.topics),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  static String _pct(double? v) => v == null ? '—' : '${(v * 100).round()}%';
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
