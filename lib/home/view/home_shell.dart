import 'dart:async';

import 'package:deca_mobile/account/view/account_page.dart';
import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/courses/cubit/courses_cubit.dart';
import 'package:deca_mobile/courses/data/courses_repository.dart';
import 'package:deca_mobile/courses/view/courses_page.dart';
import 'package:deca_mobile/home/cubit/inbox_badge_cubit.dart';
import 'package:deca_mobile/home/view/home_page.dart';
import 'package:deca_mobile/messages/view/messages_page.dart';
import 'package:deca_mobile/notifications/view/notifications_page.dart';
import 'package:deca_mobile/reports/view/reports_page.dart';
import 'package:deca_mobile/schedule/cubit/timetable_cubit.dart';
import 'package:deca_mobile/schedule/data/timetable_repository.dart';
import 'package:deca_mobile/schedule/view/timetable_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cho phep cac widget con doi tab hien tai (vd tien ich "Diem danh" tren
/// Trang chu nhay sang tab TKB). Dat quanh HomeShell.
class HomeShellScope extends InheritedWidget {
  const HomeShellScope({
    required this.switchTab,
    required super.child,
    super.key,
  });

  /// index tab: 0 Trang chu · 1 TKB · 2 Khoa hoc · 3 Bao cao · 4 Tai khoan.
  final void Function(int index) switchTab;

  static HomeShellScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<HomeShellScope>();
    assert(scope != null, 'HomeShellScope khong tim thay trong cay widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(HomeShellScope oldWidget) => false;
}

/// Khung sau dang nhap: NavigationBar 5 tab + IndexedStack (giu state moi tab).
///
/// Tab 1 — Trang chu (dashboard + quick action strip)
/// Tab 2 — Thoi khoa bieu
/// Tab 3 — Khoa hoc cua toi
/// Tab 4 — Bao cao
/// Tab 5 — Tai khoan
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Nap so chua doc cho badge ngay khi vao khung chinh (da dang nhap).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(context.read<InboxBadgeCubit>().refresh());
    });
  }

  void _switchTab(int index) => setState(() => _index = index);

  /// Mo mot trang inbox roi lam moi badge khi quay lai.
  Future<void> _openInbox(Widget page) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => page),
    );
    if (mounted) unawaited(context.read<InboxBadgeCubit>().refresh());
  }

  static const _titles = [
    'Trang chủ',
    'Thời khóa biểu',
    'Khóa học của tôi',
    'Báo cáo',
    'Tài khoản',
  ];

  @override
  Widget build(BuildContext context) {
    return HomeShellScope(
      switchTab: _switchTab,
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          BlocBuilder<InboxBadgeCubit, InboxBadgeState>(
            builder: (context, badge) => Row(
              children: [
                IconButton(
                  icon: _BadgeIcon(
                    icon: Icons.notifications_outlined,
                    count: badge.notifications,
                  ),
                  tooltip: 'Thông báo',
                  onPressed: () => _openInbox(const NotificationsPage()),
                ),
                IconButton(
                  icon: _BadgeIcon(
                    icon: Icons.chat_bubble_outline,
                    count: badge.messages,
                  ),
                  tooltip: 'Tin nhắn',
                  onPressed: () => _openInbox(const MessagesPage()),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          // Tab 1: Trang chu — khong can Cubit rieng (doc AuthCubit)
          const HomePage(),

          // Tab 2: Thoi khoa bieu
          BlocProvider(
            create: (ctx) {
              final roles =
                  ctx.read<AuthCubit>().state.user?.roles ?? const <String>[];
              final view = roles.contains('STUDENT')
                  ? 'STUDENT'
                  : roles.contains('PARENT')
                      ? 'PARENT'
                      : roles.contains('TEACHER')
                          ? 'TEACHER'
                          : 'STUDENT';
              final cubit = TimetableCubit(
                ctx.read<TimetableRepository>(),
                initialView: view,
              );
              unawaited(cubit.load());
              return cubit;
            },
            child: const TimetablePage(),
          ),

          // Tab 3: Khoa hoc cua toi
          BlocProvider(
            create: (ctx) {
              final cubit = CoursesCubit(ctx.read<CoursesRepository>());
              unawaited(cubit.load());
              return cubit;
            },
            child: const CoursesPage(),
          ),

          // Tab 4: Bao cao (tu dieu huong theo vai tro, doc ReportsRepository + AuthCubit)
          const ReportsPage(),

          // Tab 5: Tai khoan
          const AccountPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'TKB',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Khóa học',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Báo cáo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

/// Icon kem badge so chua doc (an khi = 0).
class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return Icon(icon);
    return Badge(
      label: Text(count > 99 ? '99+' : '$count'),
      child: Icon(icon),
    );
  }
}
