import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/reports/widgets/report_charts.dart';
import 'package:flutter/material.dart';

/// Chi tiết 1 bài thi: điểm/TB lớp/hạng + breakdown độ khó & loại câu.
class StudentExamDetailPage extends StatefulWidget {
  const StudentExamDetailPage({
    required this.repository,
    required this.studentId,
    required this.classId,
    required this.exam,
    super.key,
  });

  final ReportsRepository repository;
  final int studentId;
  final int classId;
  final RecentExam exam;

  @override
  State<StudentExamDetailPage> createState() => _StudentExamDetailPageState();
}

class _StudentExamDetailPageState extends State<StudentExamDetailPage> {
  late Future<ExamReportDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository
        .examDetail(widget.studentId, widget.exam.examId, widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exam.examName)),
      body: FutureBuilder<ExamReportDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Center(child: Text('Không tải được chi tiết bài thi'));
          }
          final d = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Metric(
                        label: 'Điểm',
                        value: d.score?.toStringAsFixed(2) ?? '—',
                      ),
                      _Metric(
                        label: 'TB lớp',
                        value: d.classAverage?.toStringAsFixed(2) ?? '—',
                      ),
                      _Metric(
                        label: 'Xếp hạng',
                        value: d.rank != null
                            ? '${d.rank}/${d.submittedCount ?? '—'}'
                            : '—',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Đúng/sai theo độ khó',
                child: BreakdownBarChart(
                  buckets: d.breakdown.byDifficulty,
                  labelMap: difficultyLabel,
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Đúng/sai theo loại câu',
                child: BreakdownBarChart(
                  buckets: d.breakdown.byType,
                  labelMap: typeLabel,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
