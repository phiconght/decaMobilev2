import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/exams/data/models/exam.dart';
import 'package:deca_mobile/exams/widgets/exam_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Mot dong de thi: ten + ngay bat dau (publishAt) + thoi luong, kem
/// chip trang thai ben phai.
class ExamListTile extends StatelessWidget {
  const ExamListTile({required this.exam, this.onTap, super.key});

  final Exam exam;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.rmd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _subtitle(exam),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ExamStatusChip(exam.status),
          ],
        ),
      ),
    );
  }

  static String _subtitle(Exam exam) {
    final publishAt = exam.publishAt;
    final start = publishAt == null
        ? 'Chưa đặt lịch'
        : 'Bắt đầu ${DateFormat('dd/MM/yyyy').format(publishAt.toLocal())}';
    if (exam.durationMinutes == null) return start;
    return '$start · ${exam.durationMinutes} phút';
  }
}
