import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/reports/view/student_report_view.dart';
import 'package:deca_mobile/reports/widgets/report_charts.dart';
import 'package:flutter/material.dart';

class _ClassBundle {
  const _ClassBundle(
    this.averages,
    this.breakdown,
    this.mastery,
    this.attendance,
    this.students,
    this.spectrum,
  );
  final List<ClassExamAverage> averages;
  final Breakdown breakdown;
  final List<TopicMastery> mastery;
  final StudentAttendanceReport attendance;
  final List<ClassStudentAverage> students;
  final ScoreDistribution spectrum;
}

/// Báo cáo cả lớp cho giáo viên: chart tổng hợp + danh sách HV.
class ClassReportPage extends StatefulWidget {
  const ClassReportPage({
    required this.repository,
    required this.clazz,
    super.key,
  });

  final ReportsRepository repository;
  final StudentClassOption clazz;

  @override
  State<ClassReportPage> createState() => _ClassReportPageState();
}

class _ClassReportPageState extends State<ClassReportPage> {
  late Future<_ClassBundle> _future;
  int? _distExamId;
  ScoreDistribution? _distribution;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _future.then((b) {
      if (b.averages.isNotEmpty && mounted) {
        _onDistExamChange(b.averages.first.examId);
      }
    });
  }

  Future<void> _onDistExamChange(int examId) async {
    setState(() => _distExamId = examId);
    final d = await widget.repository
        .classExamScoreDistribution(widget.clazz.classId, examId);
    if (mounted) setState(() => _distribution = d);
  }

  Future<_ClassBundle> _load() async {
    final id = widget.clazz.classId;
    final r = await Future.wait([
      widget.repository.classExamAverages(id),
      widget.repository.classBreakdowns(id),
      widget.repository.classTopicMastery(id),
      widget.repository.classAttendance(id),
      widget.repository.classStudents(id),
      widget.repository.classCourseSpectrum(id),
    ]);
    return _ClassBundle(
      r[0] as List<ClassExamAverage>,
      r[1] as Breakdown,
      r[2] as List<TopicMastery>,
      r[3] as StudentAttendanceReport,
      r[4] as List<ClassStudentAverage>,
      r[5] as ScoreDistribution,
    );
  }

  void _openStudent(ClassStudentAverage s) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(s.fullName)),
          body: StudentReportView(
            repository: widget.repository,
            studentId: s.studentId,
            canComment: true,
            showVisibilityToggle: true,
            fixedClass: widget.clazz,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.clazz.name)),
      body: FutureBuilder<_ClassBundle>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Center(child: Text('Không tải được báo cáo lớp'));
          }
          final b = snap.data!;
          final att = b.attendance.summary;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                title: 'Điểm TB lớp qua các đề',
                child: ClassAvgChart(items: b.averages),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Đúng/sai cả lớp theo độ khó',
                child: BreakdownBarChart(
                  buckets: b.breakdown.byDifficulty,
                  labelMap: difficultyLabel,
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Phổ điểm toàn khóa (điểm TB HV)',
                child: CourseScoreSpectrum(data: b.spectrum),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Phổ điểm theo bài thi',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (b.averages.isNotEmpty)
                      DropdownButton<int>(
                        isExpanded: true,
                        value: _distExamId,
                        items: b.averages
                            .map((a) => DropdownMenuItem(
                                  value: a.examId,
                                  child: Text(a.examName,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) _onDistExamChange(v);
                        },
                      ),
                    ScoreDistributionChart(data: _distribution),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Nắm chắc kiến thức theo chương (cả lớp)',
                child: TopicMasteryChart(items: b.mastery),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Chuyên cần cả lớp',
                child: AttendanceDonut(summary: att),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Danh sách học viên',
                child: Column(
                  children: b.students.map((s) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(s.fullName),
                      subtitle: Text(
                        'Điểm TB: ${s.avgScore?.toStringAsFixed(2) ?? '—'} · '
                        'Nộp: ${s.submittedCount} · '
                        'Chuyên cần: ${s.attendanceRate != null ? '${(s.attendanceRate! * 100).round()}%' : '—'}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openStudent(s),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
