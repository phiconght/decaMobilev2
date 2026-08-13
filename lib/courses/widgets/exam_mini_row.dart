import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:flutter/material.dart';

/// 1 dong gon cho de thi GAN RIENG 1 buoi hoc — thay the ExamListTile day du
/// (card rieng, to) khi de thi xuat hien o MOI buoi: qua nhieu card lien
/// tiep gay roi mat. Chi 1 dong, long ngay trong the buoi hoc.
///
/// Khong lap lai ten buoi (da hien o tren cung 1 the) — chi hien nhan chung
/// "Bài kiểm tra nhanh" + trang thai/diem, bam de mo lam bai.
class ExamMiniRow extends StatelessWidget {
  const ExamMiniRow({required this.exam, this.onTap, super.key});

  final OutlineExam exam;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final (trailingText, trailingColor) = _trailing();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(Icons.quiz_outlined, size: 15, color: muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Bài kiểm tra nhanh',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              trailingText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: trailingColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: muted),
          ],
        ),
      ),
    );
  }

  (String, Color) _trailing() {
    if (exam.isSubmitted && exam.score != null) {
      final score = exam.score!;
      final formatted =
          score % 1 == 0 ? score.toStringAsFixed(0) : score.toStringAsFixed(1);
      return ('Đã nộp · $formatted đ', AppColors.success);
    }
    final now = DateTime.now();
    if (exam.publishAt != null && now.isBefore(exam.publishAt!)) {
      return ('Chưa mở', AppColors.neutral);
    }
    if (exam.endAt != null && now.isAfter(exam.endAt!)) {
      return ('Đã đóng', AppColors.neutral);
    }
    return ('Làm bài', AppColors.brand);
  }
}
