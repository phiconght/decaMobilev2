import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_empty_view.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_loading_view.dart';
import 'package:deca_mobile/schedule/cubit/timetable_cubit.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/view/leaves_page.dart';
import 'package:deca_mobile/schedule/view/session_detail_page.dart';
import 'package:deca_mobile/schedule/widgets/child_filter_bar.dart';
import 'package:deca_mobile/schedule/widgets/session_card.dart';
import 'package:deca_mobile/schedule/widgets/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Thoi khoa bieu — chon view theo vai tro, xem theo tuan/ngay.
class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  /// Thu tu va nhan view theo vai tro.
  static const _viewOrder = ['STUDENT', 'PARENT', 'TEACHER'];
  static const _viewLabels = {
    'STUDENT': 'HV',
    'PARENT': 'PH',
    'TEACHER': 'GV',
  };

  /// Thu trong tuan tieng Viet tu DateTime.weekday.
  static String _weekdayLabel(int weekday) => switch (weekday) {
        DateTime.monday => 'Thứ Hai',
        DateTime.tuesday => 'Thứ Ba',
        DateTime.wednesday => 'Thứ Tư',
        DateTime.thursday => 'Thứ Năm',
        DateTime.friday => 'Thứ Sáu',
        DateTime.saturday => 'Thứ Bảy',
        _ => 'Chủ Nhật',
      };

  @override
  Widget build(BuildContext context) {
    final roles = context.read<AuthCubit>().state.user?.roles ?? const [];
    final availableViews =
        _viewOrder.where(roles.contains).toList(growable: false);

    if (availableViews.isEmpty) {
      return const Center(
        child: AppEmptyView(
          message: 'Thời khóa biểu chỉ dành cho giáo viên, '
              'học viên và phụ huynh.',
        ),
      );
    }

    return BlocBuilder<TimetableCubit, TimetableState>(
      builder: (context, state) {
        final cubit = context.read<TimetableCubit>();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LeavesPage(),
                      ),
                    ),
                    icon: const Icon(Icons.event_note),
                    label: const Text('Đơn nghỉ'),
                  ),
                ],
              ),
            ),
            if (availableViews.length > 1)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SegmentedButton<String>(
                  segments: [
                    for (final view in availableViews)
                      ButtonSegment<String>(
                        value: view,
                        label: Text(_viewLabels[view] ?? view),
                      ),
                  ],
                  selected: {state.view},
                  onSelectionChanged: (selection) =>
                      cubit.changeView(selection.first),
                ),
              ),
            WeekStrip(
              weekStart: state.weekStart,
              selectedDay: state.selectedDay,
              daysWithSessions: state.daysWithSessions,
              onSelectDay: cubit.selectDay,
              onPrevWeek: cubit.prevWeek,
              onNextWeek: cubit.nextWeek,
              onToday: cubit.goToToday,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_weekdayLabel(state.selectedDay.weekday)}, '
                      '${DateFormat('dd/MM/yyyy').format(state.selectedDay)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${state.daySessions.length} buổi',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (state.view == 'PARENT' && state.children.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                child: ChildFilterBar(
                  children: state.children,
                  selected: state.childFilter,
                  onSelect: cubit.selectChild,
                ),
              ),
            Expanded(
              child: _buildList(context, state, cubit),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    TimetableState state,
    TimetableCubit cubit,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppLoadingView();
    }
    if (state.isFailure && state.items.isEmpty) {
      return AppErrorView(
        message: state.error ?? 'Đã có lỗi xảy ra',
        onRetry: cubit.refresh,
      );
    }

    final sessions = state.daySessions;

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: sessions.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 96),
                AppEmptyView(message: 'Không có buổi học trong ngày này.'),
              ],
            )
          : ListView.separated(
              padding: AppSpacing.screen,
              itemCount: sessions.length,
              separatorBuilder: (_, _) => AppSpacing.gapSm,
              itemBuilder: (_, index) {
                final item = sessions[index];
                return SessionCard(
                  item: item,
                  view: state.view,
                  childColor: _childColorFor(state, item),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: SessionDetailPage(
                          item: item,
                          view: state.view,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Mau gan cho con (chi voi PARENT) — map tu state.children theo studentId.
  Color? _childColorFor(TimetableState state, TimetableItem item) {
    if (state.view != 'PARENT') return null;
    final id = item.studentId;
    if (id == null) return null;
    for (final child in state.children) {
      if (child.studentId == id) return child.color;
    }
    return null;
  }
}
