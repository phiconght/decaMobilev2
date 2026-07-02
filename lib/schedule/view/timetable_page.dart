import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_empty_view.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_loading_view.dart';
import 'package:deca_mobile/schedule/cubit/timetable_cubit.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/view/leaves_page.dart';
import 'package:deca_mobile/schedule/view/session_detail_page.dart';
import 'package:deca_mobile/schedule/view/teacher_work_page.dart';
import 'package:deca_mobile/schedule/widgets/child_filter_bar.dart';
import 'package:deca_mobile/schedule/widgets/session_card.dart';
import 'package:deca_mobile/schedule/widgets/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Thoi khoa bieu — chon view theo vai tro, xem TOAN BO buoi trong tuan
/// (nhom theo ngay). Cham 1 ngay tren WeekStrip -> cuon toi ngay do.
class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  /// Thu tu va nhan view theo vai tro.
  static const _viewOrder = ['STUDENT', 'PARENT', 'TEACHER'];
  static const _viewLabels = {
    'STUDENT': 'HV',
    'PARENT': 'PH',
    'TEACHER': 'GV',
  };

  final ScrollController _scroll = ScrollController();

  /// weekday (1..7) -> key cua header ngay do (de cuon toi).
  final Map<int, GlobalKey> _dayKeys = {};

  GlobalKey _dayKey(int weekday) => _dayKeys.putIfAbsent(weekday, GlobalKey.new);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

  void _scrollToDay(int weekday) {
    final ctx = _dayKeys[weekday]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      alignment: 0.02,
    );
  }

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

    return BlocConsumer<TimetableCubit, TimetableState>(
      // Cham ngay tren WeekStrip -> cuon toi section cua ngay do.
      listenWhen: (prev, curr) =>
          !_sameDay(prev.selectedDay, curr.selectedDay),
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToDay(state.selectedDay.weekday),
        );
      },
      builder: (context, state) {
        final cubit = context.read<TimetableCubit>();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (roles.contains('TEACHER'))
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const TeacherWorkPage(),
                        ),
                      ),
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('Chấm công'),
                    ),
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
                      'Cả tuần',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${state.weekSessions.length} buổi',
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

    final sessions = state.weekSessions;

    if (sessions.isEmpty) {
      return RefreshIndicator(
        onRefresh: cubit.refresh,
        child: ListView(
          children: const [
            SizedBox(height: 96),
            AppEmptyView(message: 'Không có buổi học nào trong tuần này.'),
          ],
        ),
      );
    }

    // Sessions da sap theo ngay+gio -> gom section theo ngay, moi ngay 1 header.
    final children = <Widget>[];
    DateTime? currentDay;
    for (final item in sessions) {
      final day = DateTime(item.date.year, item.date.month, item.date.day);
      if (currentDay == null || !_sameDay(currentDay, day)) {
        currentDay = day;
        children.add(_dayHeader(context, day, key: _dayKey(day.weekday)));
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: SessionCard(
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
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView(
        controller: _scroll,
        padding: AppSpacing.screen,
        children: children,
      ),
    );
  }

  /// Header ngay: 'Thứ Năm, 02/07' + tag 'Hôm nay' cho ngay hien tai.
  Widget _dayHeader(BuildContext context, DateTime day, {Key? key}) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday = _sameDay(day, now);
    return Padding(
      key: key,
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            '${_weekdayLabel(day.weekday)}, ${DateFormat('dd/MM').format(day)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius:
                    const BorderRadius.all(Radius.circular(AppRadii.pill)),
              ),
              child: Text(
                'Hôm nay',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
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
