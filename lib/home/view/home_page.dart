import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/auth/data/auth_repository.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/quick_action_strip.dart';
import 'package:deca_mobile/home/cubit/home_announcements_cubit.dart';
import 'package:deca_mobile/home/cubit/home_today_cubit.dart';
import 'package:deca_mobile/home/data/quick_actions.dart';
import 'package:deca_mobile/home/view/widgets/announcement_banner.dart';
import 'package:deca_mobile/home/view/widgets/post_feed_section.dart';
import 'package:deca_mobile/home/view/widgets/today_session_card.dart';
import 'package:deca_mobile/messages/data/messages_repository.dart';
import 'package:deca_mobile/posts/cubit/posts_cubit.dart';
import 'package:deca_mobile/posts/data/posts_repository.dart';
import 'package:deca_mobile/schedule/data/timetable_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Tab Trang chu: loi chao + quick actions + thong bao trung tam + buoi hoc hom
/// nay + bang tin. Cung cap 3 cubit rieng cho cac section dong.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final roles =
        context.read<AuthCubit>().state.user?.roles ?? const <String>[];
    final view = _viewForRoles(roles);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) {
            final cubit = HomeTodayCubit(
              ctx.read<TimetableRepository>(),
              view: view,
            );
            unawaited(cubit.load());
            return cubit;
          },
        ),
        BlocProvider(
          create: (ctx) {
            final cubit =
                HomeAnnouncementsCubit(ctx.read<MessagesRepository>());
            unawaited(cubit.load());
            return cubit;
          },
        ),
        BlocProvider(
          create: (ctx) {
            final cubit = PostsCubit(ctx.read<PostsRepository>(), pageSize: 5);
            unawaited(cubit.load());
            return cubit;
          },
        ),
      ],
      child: const _HomeBody(),
    );
  }

  static String _viewForRoles(List<String> roles) {
    if (roles.contains('STUDENT')) return 'STUDENT';
    if (roles.contains('PARENT')) return 'PARENT';
    if (roles.contains('TEACHER')) return 'TEACHER';
    return 'STUDENT';
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  Future<void> _refreshAll(BuildContext context) async {
    await Future.wait([
      context.read<HomeTodayCubit>().refresh(),
      context.read<HomeAnnouncementsCubit>().refresh(),
      context.read<PostsCubit>().refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthCubit, AuthUser?>(
      (cubit) => cubit.state.user,
    );
    final firstName = _firstName(user?.fullName);

    return RefreshIndicator(
      onRefresh: () => _refreshAll(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          _GreetingHeader(firstName: firstName),
          const SizedBox(height: AppSpacing.lg),
          QuickActionStrip(
            actions: quickActionsFor(user?.roles ?? const <String>[]),
          ),
          const SizedBox(height: AppSpacing.sm),
          const AnnouncementBanner(),
          const TodaySessionCard(),
          const PostFeedSection(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  static String _firstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.last;
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Chào buổi sáng'
        : hour < 18
            ? 'Chào buổi chiều'
            : 'Chào buổi tối';
    final dateStr = '${_weekday(now.weekday)}, '
        '${DateFormat('dd/MM/yyyy').format(now)}';

    // Gradient do ruby (Mobile_MauSac_DoTrang.md §4.2). 2 vong tron trang mo
    // goc phai tao chieu sau, khong lam roi.
    const white90 = Color(0xE6FFFFFF);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadii.xl),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFC84151), Color(0xFF8A1C29)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -36,
              right: -24,
              child: _decorCircle(120),
            ),
            Positioned(
              top: 34,
              right: 44,
              child: _decorCircle(64),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.school_rounded,
                        size: 20,
                        color: white90,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Trung tâm đào tạo',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: white90,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    firstName.isNotEmpty
                        ? '$greeting, $firstName!'
                        : '$greeting!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vong tron trang mo trang tri (chieu sau, khong loe loet).
  Widget _decorCircle(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
        ),
      );

  static String _weekday(int weekday) => switch (weekday) {
        DateTime.monday => 'Thứ Hai',
        DateTime.tuesday => 'Thứ Ba',
        DateTime.wednesday => 'Thứ Tư',
        DateTime.thursday => 'Thứ Năm',
        DateTime.friday => 'Thứ Sáu',
        DateTime.saturday => 'Thứ Bảy',
        _ => 'Chủ Nhật',
      };
}
