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

  /// index tab: 0 Trang chu · 1 TKB LUON co dinh (nhung tab con lai an theo
  /// vai tro, xem `_HomeShellState._visibleTabs`) — chi goi voi 0/1.
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

/// Khung sau dang nhap: NavigationBar + IndexedStack (giu state moi tab).
/// So tab thay doi theo vai tro — xem `_visibleTabs`:
///
/// Trang chu, TKB — LUON co (moi vai tro)
/// Khoa hoc cua toi — AN voi PARENT (khong co lop nao de xem)
/// Bao cao — AN voi STUDENT
/// Tai khoan — LUON co
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

  @override
  Widget build(BuildContext context) {
    return HomeShellScope(
      switchTab: _switchTab,
      child: _buildScaffold(context),
    );
  }

  /// Trang chủ + TKB LUÔN hiện, giữ nguyên vị trí 0/1 — nơi khác trong app
  /// (vd `quick_actions.dart`, `today_session_card.dart`) đang gọi thẳng
  /// `switchTab(1)` để nhảy sang TKB, nên 2 tab đầu KHÔNG được đổi thứ tự
  /// hay ẩn theo vai trò (chỉ Khóa học/Báo cáo mới ẩn theo vai trò, và cả
  /// hai đều đứng SAU TKB nên không ảnh hưởng chỉ số 1).
  ///
  /// PH không có lớp nào để xem trong tab Khóa học (`CoursesRepositoryImpl
  /// .fetchCourses` chỉ trả lớp mà CHÍNH người đăng nhập là học viên) nên ẩn
  /// hẳn tab đó cho PH. HS đã có báo cáo của mình gộp sẵn trong "Bài phụ
  /// huynh giao" + màn khác nên ẩn tab Báo cáo cho HS (yêu cầu người dùng
  /// 11/08/2026).
  List<_Tab> _visibleTabs(BuildContext context) {
    final roles =
        context.read<AuthCubit>().state.user?.roles ?? const <String>[];
    final isParent = roles.contains('PARENT');
    final isStudent = roles.contains('STUDENT');
    return [
      _Tab(
        title: 'Trang chủ',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'Trang chủ',
        page: const HomePage(),
      ),
      _Tab(
        title: 'Thời khóa biểu',
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month,
        label: 'TKB',
        page: BlocProvider(
          create: (ctx) {
            final view = isStudent
                ? 'STUDENT'
                : isParent
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
      ),
      if (!isParent)
        _Tab(
          title: 'Khóa học của tôi',
          icon: Icons.menu_book_outlined,
          selectedIcon: Icons.menu_book,
          label: 'Khóa học',
          page: BlocProvider(
            create: (ctx) {
              final cubit = CoursesCubit(ctx.read<CoursesRepository>());
              unawaited(cubit.load());
              return cubit;
            },
            child: const CoursesPage(),
          ),
        ),
      if (!isStudent)
        const _Tab(
          title: 'Báo cáo',
          icon: Icons.bar_chart_outlined,
          selectedIcon: Icons.bar_chart,
          label: 'Báo cáo',
          page: ReportsPage(),
        ),
      const _Tab(
        title: 'Tài khoản',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: 'Tài khoản',
        page: AccountPage(),
      ),
    ];
  }

  Widget _buildScaffold(BuildContext context) {
    final tabs = _visibleTabs(context);
    // Vai trò đổi tab hiện có thể vượt ngoài danh sách mới (hiếm khi xảy ra
    // lúc runtime, nhưng phòng thủ để không crash IndexedStack/NavigationBar).
    final index = _index < tabs.length ? _index : 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[index].title),
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
        index: index,
        children: [for (final t in tabs) t.page],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final t in tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

/// 1 tab cua HomeShell: tieu de AppBar + icon/label NavigationBar + trang.
class _Tab {
  const _Tab({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.page,
  });

  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget page;
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
