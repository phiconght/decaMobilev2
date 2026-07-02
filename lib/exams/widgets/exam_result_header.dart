import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/exams/data/models/exam_paper.dart';
import 'package:flutter/material.dart';

/// Thẻ tổng kết hiển thị sau khi nộp bài: điểm + số câu tự chấm đúng.
class ExamResultHeader extends StatelessWidget {
  const ExamResultHeader({required this.result, super.key});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = result.total == 0 ? 0.0 : result.earned / result.total;
    final color = ratio >= 0.8
        ? AppColors.success
        : ratio >= 0.5
            ? AppColors.warning
            : AppColors.danger;

    return Card(
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: color),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Đã nộp bài',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _fmt(result.earned),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  ' / ${_fmt(result.total)} điểm',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _summary(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _summary() {
    final base = 'Tự chấm đúng ${result.autoCorrect}/${result.autoTotal} câu';
    return result.hasEssay
        ? '$base · câu tự luận chờ giáo viên chấm'
        : base;
  }

  static String _fmt(double p) =>
      p == p.roundToDouble() ? p.toInt().toString() : '$p';
}
