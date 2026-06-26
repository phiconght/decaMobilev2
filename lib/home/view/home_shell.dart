import 'dart:async';

import 'package:deca_mobile/account/view/account_page.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/courses/cubit/courses_cubit.dart';
import 'package:deca_mobile/courses/data/courses_repository.dart';
import 'package:deca_mobile/courses/view/courses_page.dart';
import 'package:deca_mobile/home/view/home_page.dart';
import 'package:deca_mobile/messages/view/messages_page.dart';
import 'package:deca_mobile/notifications/view/notifications_page.dart';
import 'package:deca_mobile/reports/cubit/reports_cubit.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/reports/view/reports_page.dart';
import 'package:deca_mobile/schedule/cubit/schedule_cubit.dart';
import 'package:deca_mobile/schedule/data/schedule_repository.dart';
import 'package:deca_mobile/schedule/view/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  static const _titles = [
    'Trang chủ',
    'Thời khóa biểu',
    'Khóa học của tôi',
    'Báo cáo',
    'Tài khoản',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Thông báo',
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsPage(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Tin nhắn',
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const MessagesPage()),
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
              final cubit = ScheduleCubit(ctx.read<ScheduleRepository>());
              unawaited(cubit.load());
              return cubit;
            },
            child: const SchedulePage(),
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

          // Tab 4: Bao cao
          BlocProvider(
            create: (ctx) {
              final cubit = ReportsCubit(ctx.read<ReportsRepository>());
              unawaited(cubit.load());
              return cubit;
            },
            child: const ReportsPage(),
          ),

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
