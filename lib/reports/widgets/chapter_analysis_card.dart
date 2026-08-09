import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:flutter/material.dart';

/// Bang "Phan tich tu dong" cho 1 CHUONG — cau chu da ghep san o BE.
class ChapterAnalysisCard extends StatelessWidget {
  const ChapterAnalysisCard({required this.analysis, super.key});

  final ChapterAnalysisDetail? analysis;

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
            Text('Phân tích tự động — ${a.chapterLabel ?? 'Chương'}',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              'Điểm TB chương: ${a.avgScore?.toStringAsFixed(2) ?? '—'}'
              '${a.rank != null ? ' — Hạng ${a.rank}/${a.classSize ?? '—'}' : ''}',
            ),
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
            if (a.attendanceInsight != null) ...[
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Chuyên cần: ',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: a.attendanceInsight),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
