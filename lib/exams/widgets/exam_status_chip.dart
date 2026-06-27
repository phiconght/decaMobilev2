import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Chip trang thai de thi: ACTIVE -> "Đang mở", INACTIVE -> "Đã đóng".
class ExamStatusChip extends StatelessWidget {
  const ExamStatusChip(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _map(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  (String, Color) _map(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return ('Đang mở', AppColors.success);
      case 'INACTIVE':
        return ('Đã đóng', AppColors.neutral);
      default:
        return (status, AppColors.info);
    }
  }
}
