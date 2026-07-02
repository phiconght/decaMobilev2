import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:flutter/material.dart';

/// Huy hieu trang thai diem danh cua HV trong 1 buoi.
///
/// Uu tien hien 'Nghi phep' khi [onLeave]; neu khong, map theo [status].
class AttendanceBadge extends StatelessWidget {
  const AttendanceBadge({
    required this.status,
    this.onLeave = false,
    super.key,
  });

  final AttendanceStatus? status;
  final bool onLeave;

  @override
  Widget build(BuildContext context) {
    if (status == null && !onLeave) return const SizedBox.shrink();

    final (label, color, icon) = _resolve();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadii.rsm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _resolve() {
    if (onLeave) {
      return ('Nghỉ phép', AppColors.info, Icons.event_busy);
    }
    return switch (status!) {
      AttendanceStatus.coMat => (
          'Có mặt',
          AppColors.success,
          Icons.check_circle,
        ),
      AttendanceStatus.tre => ('Trễ', AppColors.warning, Icons.schedule),
      AttendanceStatus.vang => ('Vắng', AppColors.danger, Icons.cancel),
      AttendanceStatus.coPhep => ('Có phép', AppColors.info, Icons.event_busy),
      AttendanceStatus.chuaCheckin => (
          'Chưa ĐD',
          AppColors.neutral,
          Icons.radio_button_unchecked,
        ),
    };
  }
}
