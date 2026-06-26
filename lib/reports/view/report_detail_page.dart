import 'package:deca_mobile/core/widgets/info_row.dart';
import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/reports/data/models/report.dart';
import 'package:deca_mobile/reports/widgets/score_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({required this.report, super.key});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = scoreColor(report.ratio);

    return Scaffold(
      appBar: AppBar(title: Text(report.examName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text(
                    '${report.score.toStringAsFixed(1)} / ${report.maxScore.toStringAsFixed(0)}',
                    style: theme.textTheme.displaySmall
                        ?.copyWith(color: color, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nộp lúc '
                    '${DateFormat('dd/MM/yyyy').format(report.submittedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Chi tiết',
            child: Column(
              children: [
                InfoRow(label: 'Môn học', value: report.subjectName),
                InfoRow(label: 'Mã đề', value: report.examCode),
                if (report.multipleChoiceScore != null)
                  InfoRow(
                    label: 'Trắc nghiệm',
                    value: report.multipleChoiceScore!.toStringAsFixed(1),
                  ),
                if (report.essayScore != null)
                  InfoRow(
                    label: 'Tự luận',
                    value: report.essayScore!.toStringAsFixed(1),
                  ),
                if (report.durationMinutes != null)
                  InfoRow(
                    label: 'Thời gian làm',
                    value: '${report.durationMinutes} phút',
                  ),
              ],
            ),
          ),
          if (report.comment != null) ...[
            const SizedBox(height: 16),
            SectionCard(
              title: 'Nhận xét',
              child: Text(report.comment!, style: theme.textTheme.bodyMedium),
            ),
          ],
        ],
      ),
    );
  }
}
