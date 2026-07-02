import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Dai chon ngay theo tuan: hang dieu huong (tuan truoc/sau, nhan khoang
/// tuan, nut "Hom nay") va hang 7 o ngay (T2..CN) co cham bao co buoi hoc.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    required this.weekStart,
    required this.selectedDay,
    required this.daysWithSessions,
    required this.onSelectDay,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.onToday,
    super.key,
  });

  final DateTime weekStart;
  final DateTime selectedDay;
  final Set<int> daysWithSessions;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onToday;

  static const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final rangeLabel = '${DateFormat('dd/MM').format(weekStart)} – '
        '${DateFormat('dd/MM/yyyy').format(weekEnd)}';

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevWeek,
            ),
            Expanded(
              child: Center(
                child: Text(
                  rangeLabel,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNextWeek,
            ),
            TextButton(
              onPressed: onToday,
              child: const Text('Hôm nay'),
            ),
          ],
        ),
        Row(
          children: List.generate(7, (i) {
            final day = weekStart.add(Duration(days: i));
            return Expanded(
              child: _DayCell(
                day: day,
                label: _weekdayLabels[i],
                selected: _sameDay(day, selectedDay),
                isToday: _sameDay(day, DateTime.now()),
                hasSession: daysWithSessions.contains(i + 1),
                onTap: () => onSelectDay(day),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.label,
    required this.selected,
    required this.isToday,
    required this.hasSession,
    required this.onTap,
  });

  final DateTime day;
  final String label;
  final bool selected;
  final bool isToday;
  final bool hasSession;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: AppRadii.rmd,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            AppSpacing.gapXs,
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary : null,
                shape: BoxShape.circle,
                border: !selected && isToday
                    ? Border.all(color: colorScheme.primary)
                    : null,
              ),
              child: Text(
                '${day.day}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected ? colorScheme.onPrimary : null,
                ),
              ),
            ),
            AppSpacing.gapXs,
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: hasSession ? colorScheme.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
