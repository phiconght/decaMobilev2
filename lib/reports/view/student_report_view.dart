import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/reports/view/student_exam_detail_page.dart';
import 'package:deca_mobile/reports/widgets/comments_section.dart';
import 'package:deca_mobile/reports/widgets/report_charts.dart';
import 'package:deca_mobile/reports/widgets/score_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _Bundle {
  const _Bundle(
      this.trend, this.breakdown, this.mastery, this.attendance, this.spectrum);
  final List<ScoreTrendPoint> trend;
  final Breakdown breakdown;
  final List<TopicMastery> mastery;
  final StudentAttendanceReport attendance;
  final ScoreDistribution spectrum;
}

/// Thân báo cáo của 1 học viên (HS xem mình / PH xem con).
class StudentReportView extends StatefulWidget {
  const StudentReportView({
    required this.repository,
    required this.studentId,
    required this.canComment,
    this.fixedClass,
    this.showVisibilityToggle = false,
    super.key,
  });

  final ReportsRepository repository;
  final int studentId;
  final bool canComment;

  /// Khi GV mở từ 1 lớp cụ thể: chỉ xem lớp này (bỏ picker + tránh 403 lớp khác).
  final StudentClassOption? fixedClass;
  final bool showVisibilityToggle;

  @override
  State<StudentReportView> createState() => _StudentReportViewState();
}

class _StudentReportViewState extends State<StudentReportView> {
  late Future<List<StudentClassOption>> _classesFuture;
  List<RecentExam> _classExams = const [];
  List<TopicMastery> _mastery = const [];
  int? _classId;
  Future<_Bundle>? _bundleFuture;
  bool _byType = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    _classesFuture = widget.fixedClass != null
        ? Future.value([widget.fixedClass!])
        : widget.repository.studentClasses(widget.studentId);
    _classesFuture.then((classes) {
      if (mounted && classes.isNotEmpty) {
        setState(() => _selectClass(classes.first.classId));
      }
    });
  }

  void _selectClass(int classId) {
    setState(() {
      _classId = classId;
      _classExams = const [];
      _bundleFuture = _loadBundle(classId);
    });
    // Tất cả bài thi của lớp (không giới hạn) cho danh sách cuộn ngang.
    widget.repository.examHistory(widget.studentId, classId).then((list) {
      if (mounted && _classId == classId) {
        setState(() => _classExams = list);
      }
    });
  }

  Future<_Bundle> _loadBundle(int classId) async {
    final results = await Future.wait([
      widget.repository.scoreTrend(widget.studentId, classId),
      widget.repository.breakdowns(widget.studentId, classId),
      widget.repository.topicMastery(widget.studentId, classId),
      widget.repository.attendance(widget.studentId, classId),
      widget.repository.courseSpectrum(widget.studentId, classId),
    ]);
    final mastery = results[2] as List<TopicMastery>;
    _mastery = mastery;
    return _Bundle(
      results[0] as List<ScoreTrendPoint>,
      results[1] as Breakdown,
      mastery,
      results[3] as StudentAttendanceReport,
      results[4] as ScoreDistribution,
    );
  }

  void _openExam(RecentExam e) {
    final classId = e.classId ?? _classId;
    if (classId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudentExamDetailPage(
          repository: widget.repository,
          studentId: widget.studentId,
          classId: classId,
          exam: e,
          topics: _mastery,
          canAssign: widget.canComment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudentClassOption>>(
      future: _classesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final classes = snap.data ?? const <StudentClassOption>[];
        if (classes.isEmpty) {
          return const Center(child: Text('Chưa tham gia khóa học nào.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Chọn khóa
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: classes.map((c) {
                  final selected = c.classId == _classId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c.name),
                      selected: selected,
                      onSelected: (_) => _selectClass(c.classId),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            Text('Tất cả bài thi (${_classExams.length})',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _RecentRow(exams: _classExams, onTap: _openExam),
            const SizedBox(height: 16),

            if (_bundleFuture != null)
              FutureBuilder<_Bundle>(
                future: _bundleFuture,
                builder: (context, bs) {
                  if (bs.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (bs.hasError || bs.data == null) {
                    return const Text('Không tải được dữ liệu báo cáo.');
                  }
                  final b = bs.data!;
                  final att = b.attendance.summary;
                  return Column(
                    children: [
                      SectionCard(
                        title: 'Phổ điểm toàn khóa',
                        child: CourseScoreSpectrum(data: b.spectrum),
                      ),
                      const SizedBox(height: 16),
                      SectionCard(
                        title: 'Xu hướng điểm trong khóa',
                        child: ScoreTrendChart(points: b.trend),
                      ),
                      const SizedBox(height: 16),
                      SectionCard(
                        title: 'Tỉ lệ đúng/sai',
                        child: Column(
                          children: [
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                    value: false, label: Text('Độ khó')),
                                ButtonSegment(
                                    value: true, label: Text('Loại câu')),
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
                        title: 'Nắm chắc kiến thức theo chương',
                        child: TopicMasteryChart(items: b.mastery),
                      ),
                      const SizedBox(height: 16),
                      SectionCard(
                        title: 'Chuyên cần',
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _Mini(
                                    label: 'Đi đủ',
                                    value: _pct(att.attendanceRate)),
                                _Mini(
                                    label: 'Đúng giờ',
                                    value: _pct(att.onTimeRate)),
                                _Mini(
                                    label: 'Số buổi',
                                    value: '${att.totalSessions}'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AttendanceDonut(summary: att),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_classId != null)
                        SectionCard(
                          title: 'Nhận xét',
                          child: CommentsSection(
                            key: ValueKey('cmt-${widget.studentId}-$_classId'),
                            repository: widget.repository,
                            studentId: widget.studentId,
                            classId: _classId!,
                            canComment: widget.canComment,
                            showVisibilityToggle: widget.showVisibilityToggle,
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }

  static String _pct(double? v) => v == null ? '—' : '${(v * 100).round()}%';
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.exams, required this.onTap});

  final List<RecentExam> exams;
  final void Function(RecentExam) onTap;

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return const Text('Chưa có bài thi đã nộp.');
    }
    // Cuộn NGANG tất cả bài thi của lớp.
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: exams.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final e = exams[i];
          final color = scoreColor(e.ratio);
          return SizedBox(
            width: 150,
            child: Card(
              margin: EdgeInsets.zero,
              child: InkWell(
                onTap: () => onTap(e),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.score?.toStringAsFixed(1) ?? '—',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(e.examName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12)),
                      if (e.submittedAt != null)
                        Text(
                          DateFormat('dd/MM').format(e.submittedAt!),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
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
