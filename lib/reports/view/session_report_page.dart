import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/courses/data/courses_repository.dart';
import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/reports/view/student_exam_detail_page.dart';
import 'package:deca_mobile/reports/widgets/report_charts.dart';
import 'package:deca_mobile/reports/widgets/session_analysis_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _Bundle {
  const _Bundle(this.outline, this.breakdown, this.exams, this.classExams,
      this.analysis, this.topics);
  final ClassOutline outline;
  final Breakdown breakdown;
  final List<RecentExam> exams;
  final List<ClassExamAverage> classExams;
  final SessionAnalysis? analysis;
  final List<TopicMastery> topics;
}

/// Bao cao CAP 3 — theo 1 buoi hoc. [studentId] null = pham vi ca lop.
/// Thong tin buoi (ngay/gio/phong/GV/diem danh) lay tu outline co san.
/// SessionAnalysisCard CHI hien voi studentId (§Phan C quyet dinh #1).
class SessionReportPage extends StatefulWidget {
  const SessionReportPage({
    required this.repository,
    required this.coursesRepository,
    required this.classId,
    required this.sessionId,
    this.studentId,
    super.key,
  });

  final ReportsRepository repository;
  final CoursesRepository coursesRepository;
  final int classId;
  final int sessionId;
  final int? studentId;

  @override
  State<SessionReportPage> createState() => _SessionReportPageState();
}

class _SessionReportPageState extends State<SessionReportPage> {
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
              .sessionBreakdowns(studentId, widget.classId, widget.sessionId)
          : widget.repository
              .classSessionBreakdowns(widget.classId, widget.sessionId),
      studentId != null
          ? widget.repository
              .sessionExams(studentId, widget.classId, widget.sessionId)
          : Future.value(<RecentExam>[]),
      studentId == null
          ? widget.repository
              .classSessionExams(widget.classId, widget.sessionId)
          : Future.value(<ClassExamAverage>[]),
      studentId != null
          ? widget.repository
              .sessionAnalysis(studentId, widget.classId, widget.sessionId)
          : Future.value(null),
      studentId != null
          ? widget.repository.topicMastery(studentId, widget.classId)
          : Future.value(<TopicMastery>[]),
    ]);
    return _Bundle(
      results[0] as ClassOutline,
      results[1] as Breakdown,
      results[2] as List<RecentExam>,
      results[3] as List<ClassExamAverage>,
      results[4] as SessionAnalysis?,
      results[5] as List<TopicMastery>,
    );
  }

  OutlineSession? _findSession(ClassOutline outline) {
    for (final g in outline.groups) {
      for (final s in g.sessions) {
        if (s.sessionId == widget.sessionId) return s;
      }
    }
    return null;
  }

  void _openExam(RecentExam e, List<TopicMastery> topics) {
    final studentId = widget.studentId;
    if (studentId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudentExamDetailPage(
          repository: widget.repository,
          studentId: studentId,
          classId: widget.classId,
          exam: e,
          topics: topics,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết buổi học')),
      body: FutureBuilder<_Bundle>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Center(child: Text('Không tải được báo cáo buổi học'));
          }
          final b = snap.data!;
          final session = _findSession(b.outline);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.studentId != null)
                SessionAnalysisCard(analysis: b.analysis),
              SectionCard(
                title: session != null
                    ? 'Buổi ${session.ordinal ?? '—'}: ${session.title ?? 'Chưa đặt tên'}'
                    : 'Buổi học',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (session != null) ...[
                      Text(
                          '${DateFormat('dd/MM/yyyy').format(session.date)}'
                          '${session.startTime != null ? ' ${session.startTime} - ${session.endTime ?? ''}' : ''}'),
                      if (session.roomName != null)
                        Text('Phòng: ${session.roomName}'),
                      if (session.teacherName != null)
                        Text('Giáo viên: ${session.teacherName}'),
                      if (widget.studentId != null &&
                          session.attendanceStatus != null)
                        Text('Điểm danh: ${session.attendanceStatus}'
                            '${session.onLeave ? ' (có phép)' : ''}'),
                    ] else
                      const Text('Không tìm thấy thông tin buổi học'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Báo cáo theo bài thi trong buổi',
                child: widget.studentId != null
                    ? (b.exams.isEmpty
                        ? const Text('Chưa có bài đã nộp')
                        : Column(
                            children: b.exams
                                .map((e) => ListTile(
                                      dense: true,
                                      title: Text(e.examName),
                                      trailing: Text(
                                          e.score?.toStringAsFixed(2) ??
                                              '—'),
                                      onTap: () => _openExam(e, b.topics),
                                    ))
                                .toList(),
                          ))
                    : (b.classExams.isEmpty
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
                          )),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Tỉ lệ đúng/sai trong buổi',
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
            ],
          );
        },
      ),
    );
  }
}
