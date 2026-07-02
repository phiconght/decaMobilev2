import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/widgets/attendance_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Mot dong buoi hoc da qua trong man chi tiet khoa hoc:
/// cot ngay (thu + dd/MM) · gio · phong/giao vien · huy hieu diem danh.
class CourseSessionTile extends StatelessWidget {
  const CourseSessionTile({required this.item, super.key});

  final TimetableItem item;

  static const _weekdayLabels = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final roomTeacher = [
      if (item.roomName != null && item.roomName!.isNotEmpty) item.roomName,
      if (item.teacherName != null && item.teacherName!.isNotEmpty)
        item.teacherName,
    ].whereType<String>().join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _weekdayLabels[item.date.weekday],
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                Text(
                  DateFormat('dd/MM').format(item.date),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 13, color: muted),
                    const SizedBox(width: 4),
                    Text(
                      '${item.startTime} – ${item.endTime}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (roomTeacher.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    roomTeacher,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AttendanceBadge(
            status: item.attendanceStatus,
            onLeave: item.onLeave,
          ),
        ],
      ),
    );
  }
}
