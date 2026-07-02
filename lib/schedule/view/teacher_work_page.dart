import 'dart:async';

import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_empty_view.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_loading_view.dart';
import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/schedule/cubit/teacher_work_cubit.dart';
import 'package:deca_mobile/schedule/data/attendance_repository.dart';
import 'package:deca_mobile/schedule/data/models/teacher_work.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Man "Chấm công của tôi" — GV xem cong day theo thang.
class TeacherWorkPage extends StatelessWidget {
  const TeacherWorkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = TeacherWorkCubit(
          ctx.read<AttendanceRepository>(),
          DateTime.now(),
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Chấm công của tôi')),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherWorkCubit, TeacherWorkState>(
      builder: (context, state) {
        final cubit = context.read<TeacherWorkCubit>();
        return Column(
          children: [
            _MonthBar(
              month: state.month,
              onPrev: cubit.prevMonth,
              onNext: cubit.nextMonth,
            ),
            Expanded(child: _content(context, state, cubit)),
          ],
        );
      },
    );
  }

  Widget _content(
    BuildContext context,
    TeacherWorkState state,
    TeacherWorkCubit cubit,
  ) {
    final report = state.report;
    if (report.isLoading && !report.hasData) {
      return const AppLoadingView();
    }
    if (report.isFailure && !report.hasData) {
      return AppErrorView(
        message: report.error ?? 'Đã có lỗi xảy ra',
        onRetry: cubit.refresh,
      );
    }
    final data = report.data;
    if (data == null || data.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: cubit.refresh,
        child: ListView(
          children: const [
            SizedBox(height: 96),
            AppEmptyView(message: 'Chưa có buổi dạy trong tháng này.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView(
        padding: AppSpacing.screen,
        children: [
          _SummaryCard(summary: data.summary),
          const SizedBox(height: AppSpacing.lg),
          for (final item in data.items) ...[
            _WorkTile(item: item),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Tháng trước',
          ),
          Text(
            'Tháng ${DateFormat('MM/yyyy').format(month)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Tháng sau',
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final TeacherWorkSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Tổng kết',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Metric(label: 'Tổng buổi', value: '${summary.totalSessions}'),
              _Metric(label: 'Giờ dạy', value: summary.taughtHours),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _CountChip(
                label: 'Đúng giờ',
                count: summary.dungGio,
                color: AppColors.success,
              ),
              _CountChip(
                label: 'Vào trễ',
                count: summary.vaoTre,
                color: AppColors.warning,
              ),
              _CountChip(
                label: 'Vắng',
                count: summary.vang,
                color: AppColors.danger,
              ),
              _CountChip(
                label: 'Chưa chấm',
                count: summary.chuaCham,
                color: AppColors.neutral,
              ),
            ],
          ),
          if (summary.totalSessions == 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Không có buổi dạy.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _WorkTile extends StatelessWidget {
  const _WorkTile({required this.item});

  final TeacherWorkItem item;

  static final DateFormat _dateFmt = DateFormat('dd/MM');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = item.roomName ?? 'Chưa xếp phòng';
    final subtitle = '${item.startTime}–${item.endTime}  ·  '
        '${item.className}  ·  $room';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _dateFmt.format(item.date),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      title: Text(subtitle, style: theme.textTheme.bodyMedium),
      subtitle: item.note != null && item.note!.isNotEmpty
          ? Text('Ghi chú: ${item.note}', style: theme.textTheme.bodySmall)
          : null,
      trailing: _StatusChip(status: item.status),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TeacherAttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TeacherAttendanceStatus.dungGio => AppColors.success,
      TeacherAttendanceStatus.vaoTre => AppColors.warning,
      TeacherAttendanceStatus.vang => AppColors.danger,
      TeacherAttendanceStatus.chuaCham => AppColors.neutral,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
      ),
      child: Text(
        teacherAttendanceLabel(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
