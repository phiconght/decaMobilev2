import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Chip mau theo trang thai (ACTIVE/INACTIVE/LOCKED/DISABLED).
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

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
        return ('Đang học', AppColors.success);
      case 'INACTIVE':
        return ('Đã kết thúc', AppColors.neutral);
      case 'LOCKED':
        return ('Đã khóa', AppColors.danger);
      case 'DISABLED':
        return ('Vô hiệu', AppColors.neutral);
      default:
        return (status, AppColors.info);
    }
  }
}
