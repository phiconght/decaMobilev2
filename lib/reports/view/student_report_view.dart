import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/courses/data/courses_repository.dart';
import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/reports/view/chapter_report_page.dart';
import 'package:deca_mobile/reports/view/session_report_page.dart';
import 'package:deca_mobile/reports/view/student_exam_detail_page.dart';
import 'package:deca_mobile/reports/widgets/analysis_card.dart';
import 'package:deca_mobile/reports/widgets/chapter_cards.dart';
import 'package:deca_mobile/reports/widgets/assign_practice_button.dart';
import 'package:deca_mobile/reports/widgets/comments_section.dart';
import 'package:deca_mobile/reports/widgets/report_charts.dart';
import 'package:deca_mobile/reports/widgets/score_color.dart';
import 'package:deca_mobile/reports/widgets/session_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Thứ tự cố định: bài thi, buổi học, rồi chương học.
enum _ReportTab { exams, sessions, chapters }

class _Bundle {
  const _Bundle(this.trend, this.breakdown, this.mastery, this.attendance,
      this.analysis, this.sessions);
  final List<ScoreTrendPoint> trend;
  final Breakdown breakdown;
  final List<TopicMastery> mastery;
  final StudentAttendanceReport attendance;
  final ReportAnalysis? analysis;
  final List<OutlineSession> sessions;
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
  _ReportTab _reportTab = _ReportTab.exams;

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
    // Tất cả bài thi của lớp (không giới hạn) cho danh sách cuộn ngang —
    // sắp theo ngày gần nhất trước (yêu cầu người dùng 13/08/2026).
    widget.repository.examHistory(widget.studentId, classId).then((list) {
      if (mounted && _classId == classId) {
        final sorted = [...list]..sort(_byMostRecent((e) => e.submittedAt));
        setState(() => _classExams = sorted);
      }
    });
  }

  /// Comparator dùng chung: ngày gần nhất (mới nhất) lên trước, null xuống
  /// cuối — dùng cho cả bài thi/buổi học/chương học (yêu cầu 13/08/2026).
  static int Function(T, T) _byMostRecent<T>(DateTime? Function(T) dateOf) {
    return (a, b) {
      final da = dateOf(a);
      final db = dateOf(b);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    };
  }

  Future<_Bundle> _loadBundle(int classId) async {
    final results = await Future.wait([
      widget.repository.scoreTrend(widget.studentId, classId),
      widget.repository.breakdowns(widget.studentId, classId),
      widget.repository.topicMastery(widget.studentId, classId),
      widget.repository.attendance(widget.studentId, classId),
      widget.repository.analysis(widget.studentId, classId),
      context.read<CoursesRepository>().fetchOutline(
            classId,
            studentId: widget.studentId,
            // BE tra CHI chuong/buoi ĐÃ HỌC, đã sắp theo ngày gần nhất
            // (yêu cầu 13/08/2026) — không lọc/sắp lại ở client nữa.
            onlyDone: true,
          ),
    ]);
    final outline = results[5] as ClassOutline;
    // Buổi: gộp phẳng qua các chương để có 1 dòng thời gian chung — BE chỉ
    // sắp xếp trong/giữa từng nhóm chương, nên vẫn cần sắp lại theo ngày khi
    // gộp phẳng liên chương.
    final sessions = outline.groups.expand((g) => g.sessions).toList()
      ..sort(_byMostRecent((s) => s.date));

    // Chương: giữ đúng thứ tự BE đã trả (đã lọc + sắp theo ngày gần nhất) —
    // topicMastery() là API khác (chỉ có %masteryPct), không tự có thứ tự đó.
    final chapterOrder = [
      for (final g in outline.groups)
        if (g.topicId != null) g.topicId!,
    ];
    final mastery = (results[2] as List<TopicMastery>)
        .where((t) => t.topicId != null && chapterOrder.contains(t.topicId))
        .toList()
      ..sort((a, b) => chapterOrder
          .indexOf(a.topicId!)
          .compareTo(chapterOrder.indexOf(b.topicId!)));
    _mastery = mastery;

    return _Bundle(
      results[0] as List<ScoreTrendPoint>,
      results[1] as Breakdown,
      mastery,
      results[3] as StudentAttendanceReport,
      results[4] as ReportAnalysis,
      sessions,
    );
  }

  void _openSession(int sessionId) {
    final classId = _classId;
    if (classId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionReportPage(
          repository: widget.repository,
          coursesRepository: context.read<CoursesRepository>(),
          classId: classId,
          sessionId: sessionId,
          studentId: widget.studentId,
          canAssign: widget.canComment,
        ),
      ),
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

  void _openChapter(TopicMastery t) {
    final classId = _classId;
    if (classId == null || t.topicId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChapterReportPage(
          repository: widget.repository,
          coursesRepository: context.read<CoursesRepository>(),
          classId: classId,
          topicId: t.topicId!,
          topicName: t.topicName,
          studentId: widget.studentId,
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

            // "Giao bài tập" cấp KHÓA — BE tự chọn chương HV đang yếu nhất
            // trong khóa (§10, mở rộng 11/08/2026). Chỉ hiện cho người có
            // quyền giao (PH/GV — tái dùng đúng cờ `canComment` như dropdown
            // giao bài ở màn chi tiết bài thi).
            if (widget.canComment && _classId != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: AssignPracticeButton(
                  repository: widget.repository,
                  studentId: widget.studentId,
                  classId: _classId!,
                  scopeLabel: 'toàn khóa',
                ),
              ),
              const SizedBox(height: 16),
            ],

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
                      // Cụm "bài thi / buổi học / chương học" — 1 hàng chọn
                      // + 1 khối nội dung dùng chung, thay vì 3 khối riêng
                      // (tốn diện tích — yêu cầu người dùng 13/08/2026).
                      // Thứ tự cố định: bài thi, buổi học, rồi chương học.
                      SegmentedButton<_ReportTab>(
                        segments: [
                          ButtonSegment(
                            value: _ReportTab.exams,
                            label: Text('Bài thi (${_classExams.length})'),
                          ),
                          const ButtonSegment(
                            value: _ReportTab.sessions,
                            label: Text('Buổi học'),
                          ),
                          const ButtonSegment(
                            value: _ReportTab.chapters,
                            label: Text('Chương học'),
                          ),
                        ],
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        showSelectedIcon: false,
                        selected: {_reportTab},
                        onSelectionChanged: (s) =>
                            setState(() => _reportTab = s.first),
                      ),
                      const SizedBox(height: 8),
                      switch (_reportTab) {
                        _ReportTab.exams =>
                          _RecentRow(exams: _classExams, onTap: _openExam),
                        _ReportTab.sessions => SessionCards(
                            sessions: b.sessions,
                            onTap: _openSession,
                          ),
                        _ReportTab.chapters => ChapterCards(
                            topics: b.mastery,
                            onTap: (topicId) {
                              final t = b.mastery
                                  .firstWhere((m) => m.topicId == topicId);
                              _openChapter(t);
                            },
                          ),
                      },
                      const SizedBox(height: 16),
                      AnalysisCard(analysis: b.analysis),
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
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: exams.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final e = exams[i];
          final color = scoreColor(e.ratio);
          return SizedBox(
            width: 120,
            child: Card(
              margin: EdgeInsets.zero,
              child: InkWell(
                onTap: () => onTap(e),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        e.score?.toStringAsFixed(1) ?? '—',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(e.examName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11)),
                      if (e.submittedAt != null)
                        Text(
                          DateFormat('dd/MM').format(e.submittedAt!),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey),
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
