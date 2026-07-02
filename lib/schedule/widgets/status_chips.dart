import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/schedule/data/models/leave_item.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:flutter/material.dart';

/// Chip pill cho trang thai buoi hoc.
class SessionStatusChip extends StatelessWidget {
  const SessionStatusChip({required this.status, super.key});

  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      SessionStatus.planned => (null, null),
      SessionStatus.done => ('Đã dạy', AppColors.neutral),
      SessionStatus.cancelled => ('Đã hủy', AppColors.danger),
    };
    if (label == null || color == null) return const SizedBox.shrink();
    return _Pill(label: label, color: color);
  }
}

/// Chip pill cho trang thai don nghi phep.
class LeaveStatusChip extends StatelessWidget {
  const LeaveStatusChip({required this.status, super.key});

  final LeaveStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      LeaveStatus.pending => ('Chờ duyệt', AppColors.warning),
      LeaveStatus.approved => ('Đã duyệt', AppColors.success),
      LeaveStatus.rejected => ('Từ chối', AppColors.danger),
    };
    return _Pill(label: label, color: color);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
}
