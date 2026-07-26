import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:flutter/material.dart';

/// Dong tien do dau man chi tiet khoa hoc:
/// "Da hoc 8/24 buoi · Chuyen can 92%".
///
/// Tu so CHI dem buoi DONE — khong tinh buoi tuong lai (SPEC §2.3).
class CourseProgressBar extends StatelessWidget {
  const CourseProgressBar({required this.progress, super.key});

  final OutlineProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final total = progress.totalSessions;
    final done = progress.doneSessions;
    final ratio = total == 0 ? 0.0 : done / total;

    // Nhan doi theo pham vi: GV/admin xem ca lop thi phai noi ro la "lop",
    // neu khong ho se tuong day la chuyen can cua mot hoc vien nao do.
    final rate = progress.attendanceRate;
    final attendanceText = rate == null
        ? (progress.hasStarted ? null : 'Chưa bắt đầu')
        : '${progress.isClassScope ? 'Chuyên cần lớp' : 'Chuyên cần'} '
            '${(rate * 100).round()}%';

    final label = [
      if (progress.isClassScope)
        'Đã dạy $done/$total buổi'
      else
        'Đã học $done/$total buổi',
      ?attendanceText,
    ].join(' · ');

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: muted.withValues(alpha: 0.18),
            ),
          ),
        ],
      ),
    );
  }
}
