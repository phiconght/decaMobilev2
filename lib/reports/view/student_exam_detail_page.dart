import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/reports/widgets/report_charts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Chi tiết 1 bài thi: ĐIỂM (theo bài) + phổ điểm + NĂNG LỰC (theo chương,
/// dropdown mặc định chương của bài thi). PH có nút "Giao bài cho con".
class StudentExamDetailPage extends StatefulWidget {
  const StudentExamDetailPage({
    required this.repository,
    required this.studentId,
    required this.classId,
    required this.exam,
    this.topics = const [],
    this.canAssign = false,
    super.key,
  });

  final ReportsRepository repository;
  final int studentId;
  final int classId;
  final RecentExam exam;
  final List<TopicMastery> topics;
  final bool canAssign;

  @override
  State<StudentExamDetailPage> createState() => _StudentExamDetailPageState();
}

class _StudentExamDetailPageState extends State<StudentExamDetailPage> {
  late Future<ExamReportDetail> _future;
  int? _topicId; // chương đang chọn; -1 sentinel = toàn khóa (null)
  Breakdown? _breakdown;
  bool _assigning = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _future = widget.repository
        .examDetail(widget.studentId, widget.exam.examId, widget.classId);
  }

  Future<void> _onTopicChange(int? value, ExamReportDetail d) async {
    setState(() => _topicId = value);
    if (value == d.topicId) {
      setState(() => _breakdown = d.breakdown);
      return;
    }
    final b = await widget.repository
        .breakdowns(widget.studentId, widget.classId, topicId: value);
    if (mounted) setState(() => _breakdown = b);
  }

  Future<void> _assign() async {
    if (_topicId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Giao bài cho con'),
        content: const Text(
          'Hệ thống chọn 10 bài trong chương đang xem — độ khó/dạng bài '
          'nghiêng về phần con đang yếu (số liệu đang hiển thị).',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Giao bài')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _assigning = true);
    try {
      final r = await widget.repository.assignPractice(
        widget.studentId,
        widget.classId,
        examId: widget.exam.examId,
        topicId: _topicId,
      );
      if (mounted) _showResult(r);
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  void _showResult(PracticeAssignmentResult r) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đã giao bài luyện tập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.examName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Chuyên đề: ${r.topicName ?? '—'}'),
            Text('Số câu: ${r.numQuestions} — Dễ ${r.easy}/TB ${r.medium}/Khó ${r.hard}'),
            Text('Dạng: TN ${r.multipleChoice}/ĐS ${r.trueFalse}'),
            if (r.deadline != null)
              Text('Hạn: ${DateFormat('dd/MM/yyyy').format(r.deadline!)}'),
          ],
        ),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
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
          if (!_initialized) {
            _initialized = true;
            _topicId = d.topicId;
            _breakdown = d.breakdown;
          }
          final breakdown = _breakdown ?? d.breakdown;
          final topicLabel = _topicId == null
              ? 'Toàn khóa'
              : (widget.topics
                      .firstWhere(
                        (t) => t.topicId == _topicId,
                        orElse: () => TopicMastery(
                            topicName: d.topicName ?? 'Chương',
                            masteryPct: null,
                            gradedCount: 0),
                      )
                      .topicName);

          // Dedupe + đảm bảo chương của BÀI THI luôn có mặt (kể cả khi HV chưa
          // có câu đã chấm ở chương đó -> không nằm trong topicMastery).
          final seenTopics = <int>{};
          final topicItems = <DropdownMenuItem<int>>[
            const DropdownMenuItem(value: -1, child: Text('Toàn khóa')),
          ];
          void addTopic(int? id, String name) {
            if (id != null && seenTopics.add(id)) {
              topicItems.add(DropdownMenuItem(
                value: id,
                child: Text(name, overflow: TextOverflow.ellipsis),
              ));
            }
          }

          addTopic(d.topicId, d.topicName ?? 'Chương');
          for (final t in widget.topics) {
            addTopic(t.topicId, t.topicName);
          }
          // Giá trị hiện tại phải khớp 1 item; nếu không -> về "Toàn khóa".
          final currentValue =
              (_topicId != null && seenTopics.contains(_topicId)) ? _topicId : -1;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tầng ĐIỂM
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Metric(label: 'Điểm', value: d.score?.toStringAsFixed(2) ?? '—'),
                      _Metric(
                          label: 'TB lớp',
                          value: d.classAverage?.toStringAsFixed(2) ?? '—'),
                      _Metric(
                          label: 'Xếp hạng',
                          value: d.rank != null
                              ? '${d.rank}/${d.submittedCount ?? '—'}'
                              : '—'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Phổ điểm của lớp',
                child: ScoreDistributionChart(data: d.distribution),
              ),
              const SizedBox(height: 16),

              // Chọn chương + nút giao bài
              Row(
                children: [
                  const Text('Chương: '),
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: currentValue,
                      items: topicItems,
                      onChanged: (v) => _onTopicChange(v == -1 ? null : v, d),
                    ),
                  ),
                ],
              ),
              if (widget.canAssign)
                Align(
                  alignment: Alignment.centerLeft,
                  child: _topicId == null
                      ? const Tooltip(
                          message: 'Chọn 1 chương để giao bài',
                          child: FilledButton.tonal(
                            onPressed: null,
                            child: Text('Giao bài cho con'),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: _assigning ? null : _assign,
                          icon: const Icon(Icons.assignment_add),
                          label: const Text('Giao bài cho con'),
                        ),
                ),
              const SizedBox(height: 8),

              SectionCard(
                title: 'Năng lực chương "$topicLabel" — độ khó (tổng hợp mọi bài)',
                child: BreakdownBarChart(
                  buckets: breakdown.byDifficulty,
                  labelMap: difficultyLabel,
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Năng lực chương "$topicLabel" — loại câu',
                child: BreakdownBarChart(
                  buckets: breakdown.byType,
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
