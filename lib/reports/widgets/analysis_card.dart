import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:flutter/material.dart';

/// Bang "Phan tich tu dong" o dau bao cao ca nhan — cau chu da ghep san o BE
/// (ReportNarrativeBuilder). Widget nay CHI render, khong tu tinh toan
/// nguong/xep hang, tranh lech logic voi ADMIN.
class AnalysisCard extends StatelessWidget {
  const AnalysisCard({required this.analysis, super.key});

  final ReportAnalysis? analysis;

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
            Text('Phân tích tự động', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('${a.studentName} · ${a.className}'),
            const SizedBox(height: 4),
            Text(
              'Điểm TB toàn khóa: ${a.courseAverage?.toStringAsFixed(2) ?? '—'}'
              '${a.courseRank != null ? ' — Hạng ${a.courseRank}/${a.classSize ?? '—'}' : ''}',
            ),
            if (a.chapters.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Điểm TB & xếp hạng theo chương:',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: a.chapters
                    .map((c) => Chip(
                          label: Text(
                            '${c.chapterLabel}: ${c.avgScore?.toStringAsFixed(2) ?? '—'}'
                            '${c.rank != null ? ' (hạng ${c.rank}/${c.classSize ?? '—'})' : ''}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
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
            if (a.teacherCommentAuthor != null) ...[
              const SizedBox(height: 12),
              Text('Nhận xét của ${a.teacherCommentAuthor} (GV):',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(a.teacherCommentContent ?? ''),
            ],
          ],
        ),
      ),
    );
  }
}
