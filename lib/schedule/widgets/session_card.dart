import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/schedule/data/models/teacher_work.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/widgets/attendance_badge.dart';
import 'package:deca_mobile/schedule/widgets/status_chips.dart';
import 'package:flutter/material.dart';

/// The mot buoi hoc trong thoi khoa bieu (dung cho ca TEACHER/STUDENT/PARENT).
class SessionCard extends StatelessWidget {
  const SessionCard({
    required this.item,
    required this.view,
    required this.onTap,
    this.childColor,
    super.key,
  });

  final TimetableItem item;
  final String view;
  final VoidCallback onTap;
  final Color? childColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCancelled = item.status == SessionStatus.cancelled;
    final isParent = view == 'PARENT';
    final showAttendance = view != 'TEACHER';

    final subtitle = _subtitle();

    final card = Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.rlg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cot gio.
              SizedBox(
                width: 52,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.startTime,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      item.endTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isParent && childColor != null) ...[
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: childColor,
                    borderRadius: AppRadii.rsm,
                  ),
                ),
                AppSpacing.gapMd,
              ] else
                AppSpacing.gapMd,
              // Thong tin chinh.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: isCancelled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SessionStatusChip(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isParent && item.studentName != null)
                      Text(
                        item.studentName!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: childColor,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.room_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          item.roomName ?? 'Chưa xếp phòng',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(
                          Icons.person_outline,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            item.teacherName ?? '—',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Diem danh + chevron cho STUDENT/PARENT.
              if (showAttendance) ...[
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AttendanceBadge(
                      status: item.attendanceStatus,
                      onLeave: item.onLeave,
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ] else if (view == 'TEACHER') ...[
                // Cham cong GV + chevron.
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _TeacherWorkChip(status: item.teacherAttendanceStatus),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (isCancelled) {
      return Opacity(opacity: 0.6, child: card);
    }
    return card;
  }

  String _subtitle() {
    final subject = item.subjectName;
    if (subject != null && subject.isNotEmpty) {
      final grade = item.gradeLevel;
      return (grade != null && grade.isNotEmpty)
          ? '$subject — $grade'
          : subject;
    }
    return item.className;
  }
}

/// Chip nho hien trang thai cham cong GV tren card TKB (view TEACHER).
class _TeacherWorkChip extends StatelessWidget {
  const _TeacherWorkChip({required this.status});

  /// 'DUNG_GIO' | 'VAO_TRE' | 'VANG' | null (chua cham).
  final String? status;

  @override
  Widget build(BuildContext context) {
    final s = teacherAttendanceStatusFromString(status);
    final color = switch (s) {
      TeacherAttendanceStatus.dungGio => AppColors.success,
      TeacherAttendanceStatus.vaoTre => AppColors.warning,
      TeacherAttendanceStatus.vang => AppColors.danger,
      TeacherAttendanceStatus.chuaCham => AppColors.neutral,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
      ),
      child: Text(
        teacherAttendanceLabel(s),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
