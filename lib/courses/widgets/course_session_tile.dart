import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:deca_mobile/courses/widgets/exam_mini_row.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/widgets/attendance_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Mot dong buoi hoc trong cay noi dung khoa hoc.
///
/// 3 tang: "Buoi n · Ten buoi" (dam) / ngay-gio-phong (mo) / huy hieu.
/// Hien thi theo 3 trang thai DONE - PLANNED - CANCELLED (SPEC §2.2).
class CourseSessionTile extends StatelessWidget {
  const CourseSessionTile({
    required this.session,
    this.isNext = false,
    this.isToday = false,
    this.onTap,
    this.onExamTap,
    super.key,
  });

  final OutlineSession session;

  /// Buoi ke tiep cua khoa — chi DUY NHAT 1 buoi duoc danh dau.
  final bool isNext;

  /// Buoi ke tiep va dien ra hom nay -> doi nhan thanh "Hom nay".
  /// Suy o client tu ngay, KHONG phai trang thai DB (khong co IN_PROGRESS).
  final bool isToday;

  /// Mo chi tiet buoi (video bai giang, link Zoom...). Khong bat buoc.
  final VoidCallback? onTap;

  /// Mo bai lam cua 1 de thi gan RIENG buoi nay (session.exams). De thi
  /// duoc ve GON trong chinh the buoi (ExamMiniRow), khong tach the rieng —
  /// tranh moi buoi bi nhan doi thanh 2 card lien tiep (roi mat).
  final ValueChanged<OutlineExam>? onExamTap;

  static const _weekdayLabels = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final cancelled = session.status == OutlineSessionStatus.cancelled;
    final planned = session.status == OutlineSessionStatus.planned;

    final title = session.title;
    final hasTitle = title != null && title.isNotEmpty;
    final heading = switch ((session.ordinal, hasTitle)) {
      (final int n, true) => 'Buổi $n · $title',
      (final int n, false) => 'Buổi $n',
      (null, true) => title!,
      _ => 'Buổi học',
    };

    final day = _weekdayLabels[session.date.weekday];
    final date = DateFormat('dd/MM').format(session.date);
    final meta = <String>[
      '$day $date',
      if (session.startTime != null && session.endTime != null)
        '${session.startTime}–${session.endTime}',
      if (session.roomName != null && session.roomName!.isNotEmpty)
        session.roomName!,
    ].join(' · ');

    // Buoi chua dien ra / da huy -> chu mo. Giu opacity du cao de con dat
    // tuong phan WCAG AA (§2.5-2): 0.7 thay vi 0.4-0.5 nhu thuong thay.
    final dim = cancelled || planned;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  heading,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: cancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (isNext) ...[
                const SizedBox(width: AppSpacing.sm),
                _Pill(
                  label: isToday ? 'Hôm nay' : 'Buổi kế tiếp',
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(meta, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
          if (cancelled &&
              session.cancelReason != null &&
              session.cancelReason!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Đã hủy — ${session.cancelReason}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ] else if (cancelled) ...[
            const SizedBox(height: 2),
            Text(
              'Đã hủy',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (_hasTrailing) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Tai lieu thuoc DOT 2 — materialCount luon 0 o dot 1 nen chip
                // nay chua hien bao gio. Giu de dot sau khong phai sua tile.
                if (!planned && !cancelled && session.materialCount > 0)
                  _Chip(
                    icon: Icons.description_outlined,
                    label: '${session.materialCount} tài liệu',
                  ),
                if (planned)
                  _Pill(
                    label: 'Sắp diễn ra',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                // CHI buoi DONE moi hien diem danh: BE tra CHUA_CHECKIN (khac
                // null) cho ca buoi tuong lai, loc theo null se sai (§2.3).
                if (session.showsAttendance)
                  AttendanceBadge(
                    status: attendanceStatusFromString(
                      session.attendanceStatus,
                    ),
                    onLeave: session.onLeave,
                  ),
              ],
            ),
          ],
          // De thi cua RIENG buoi nay — 1 dong gon, khong tach the rieng
          // (tranh moi buoi bi nhan doi thanh 2 card lien tiep, roi mat).
          if (session.exams.isNotEmpty) ...[
            const Divider(height: AppSpacing.md),
            ...session.exams.map(
              (exam) => ExamMiniRow(
                exam: exam,
                onTap: onExamTap == null ? null : () => onExamTap!(exam),
              ),
            ),
          ],
        ],
      ),
    );

    // Buoi CHUA dien ra (PLANNED — "chua phat hanh") hoac DA HUY thi khong
    // cho bam vao xem chi tiet — chi buoi DONE (da hoc) moi mo duoc.
    final canOpen = session.status == OutlineSessionStatus.done;

    return Semantics(
      // Gop thanh 1 nhan de screen reader doc lien mach thay vi doc roi tung
      // manh chu + icon (§2.5-5).
      label: _semanticsLabel(heading, meta),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48), // §2.5-3
        decoration: isNext
            ? BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Opacity(
          opacity: dim ? 0.7 : 1,
          child: (onTap == null || !canOpen)
              ? content
              : InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: content,
                ),
        ),
      ),
    );
  }

  bool get _hasTrailing =>
      session.status == OutlineSessionStatus.planned ||
      session.showsAttendance ||
      session.materialCount > 0;

  String _semanticsLabel(String heading, String meta) {
    final parts = <String>[heading, meta];
    switch (session.status) {
      case OutlineSessionStatus.cancelled:
        parts.add('Đã hủy');
      case OutlineSessionStatus.planned:
        parts.add('Sắp diễn ra');
      case OutlineSessionStatus.done:
        if (session.showsAttendance) {
          parts.add(_attendanceText(session.attendanceStatus, session.onLeave));
        }
    }
    if (isNext) parts.add(isToday ? 'Hôm nay' : 'Buổi kế tiếp');
    return parts.where((e) => e.isNotEmpty).join(', ');
  }

  static String _attendanceText(String? status, bool onLeave) {
    if (onLeave) return 'Nghỉ phép';
    return switch (status) {
      'CO_MAT' => 'Có mặt',
      'TRE' => 'Đi trễ',
      'VANG' => 'Vắng',
      'CO_PHEP' => 'Nghỉ phép',
      _ => 'Chưa điểm danh',
    };
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: muted),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: muted)),
      ],
    );
  }
}
