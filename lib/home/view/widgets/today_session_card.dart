import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/home/cubit/home_today_cubit.dart';
import 'package:deca_mobile/home/view/home_shell.dart';
import 'package:deca_mobile/home/view/widgets/section_header.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Buoi hoc hom nay tren Trang chu. Tap -> nhay tab TKB.
class TodaySessionCard extends StatelessWidget {
  const TodaySessionCard({super.key});

  static const _maxShown = 3;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTodayCubit, DataState<List<TimetableItem>>>(
      builder: (context, state) {
        final all = state.data ?? const <TimetableItem>[];
        // Bo qua buoi da huy.
        final items =
            all.where((s) => s.status != SessionStatus.cancelled).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Hôm nay'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: items.isEmpty
                  ? const _EmptyToday()
                  : Column(
                      children: [
                        for (final s in items.take(_maxShown))
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _SessionTile(session: s),
                          ),
                        if (items.length > _maxShown)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  HomeShellScope.of(context).switchTab(1),
                              child: Text(
                                'Xem thêm ${items.length - _maxShown} buổi',
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Text('🎉', style: theme.textTheme.headlineSmall),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Hôm nay bạn không có buổi học nào.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final TimetableItem session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      if (session.roomName != null) 'Phòng ${session.roomName}',
      if (session.teacherName != null) 'GV ${session.teacherName}',
    ].join(' · ');
    final (label, color) = _statusOf(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => HomeShellScope.of(context).switchTab(1),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.startTime,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    session.endTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Nhan trang thai ngan gon + mau.
  (String, Color) _statusOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onLeave = session.onLeave ||
        session.attendanceStatus == AttendanceStatus.coPhep;
    if (onLeave) {
      return ('Nghỉ phép', scheme.tertiary);
    }
    switch (session.attendanceStatus) {
      case AttendanceStatus.coMat:
      case AttendanceStatus.tre:
        return ('Đã điểm danh', scheme.primary);
      case AttendanceStatus.vang:
        return ('Vắng', scheme.error);
      case AttendanceStatus.coPhep:
      case AttendanceStatus.chuaCheckin:
      case null:
        break;
    }
    if (session.status == SessionStatus.done) {
      return ('Đã kết thúc', scheme.outline);
    }
    return ('Sắp diễn ra', scheme.primary);
  }
}
