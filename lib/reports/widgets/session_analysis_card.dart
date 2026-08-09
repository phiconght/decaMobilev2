import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:flutter/material.dart';

/// Bang "Phan tich tu dong" cho 1 BUOI HOC — cau chu da ghep san o BE.
class SessionAnalysisCard extends StatelessWidget {
  const SessionAnalysisCard({required this.analysis, super.key});

  final SessionAnalysis? analysis;

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    if (a == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phân tích tự động — Buổi học',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              'Điểm TB buổi: ${a.avgScore?.toStringAsFixed(2) ?? '—'}'
              ' — TB lớp: ${a.classAverage?.toStringAsFixed(2) ?? '—'}',
            ),
            const SizedBox(height: 4),
            Text('Số đề: ${a.submittedCount}/${a.examCount} đã làm'),
            if (a.comparisonInsight != null) ...[
              const SizedBox(height: 8),
              Text(a.comparisonInsight!),
            ],
            if (a.abilityInsights.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Nhận định năng lực:',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...a.abilityInsights.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('• $s'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
