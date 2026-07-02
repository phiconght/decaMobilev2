import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/auth/data/auth_repository.dart';
import 'package:deca_mobile/auth/view/login_page.dart';
import 'package:deca_mobile/auth/view/splash_page.dart';
import 'package:deca_mobile/catalog/data/catalog_repository.dart';
import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/core/storage/token_storage.dart';
import 'package:deca_mobile/core/theme/app_theme.dart';
import 'package:deca_mobile/courses/data/courses_repository.dart';
import 'package:deca_mobile/exams/data/exam_taking_repository.dart';
import 'package:deca_mobile/exams/data/exams_repository.dart';
import 'package:deca_mobile/home/cubit/inbox_badge_cubit.dart';
import 'package:deca_mobile/home/view/home_shell.dart';
import 'package:deca_mobile/l10n/l10n.dart';
import 'package:deca_mobile/messages/data/messages_repository.dart';
import 'package:deca_mobile/notifications/data/notifications_repository.dart';
import 'package:deca_mobile/posts/data/posts_repository.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/schedule/data/attendance_repository.dart';
import 'package:deca_mobile/schedule/data/leave_repository.dart';
import 'package:deca_mobile/schedule/data/timetable_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({required this.apiClient, required this.tokenStorage, super.key});

  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(
            api: apiClient,
            tokenStorage: tokenStorage,
          ),
        ),
        RepositoryProvider<CoursesRepository>(
          create: (_) => CoursesRepositoryImpl(apiClient),
        ),
        RepositoryProvider<ReportsRepository>(
          create: (_) => ReportsRepositoryImpl(apiClient),
        ),
        RepositoryProvider<TimetableRepository>(
          create: (_) => TimetableRepositoryImpl(apiClient),
        ),
        RepositoryProvider<LeaveRepository>(
          create: (_) => LeaveRepositoryImpl(apiClient),
        ),
        RepositoryProvider<AttendanceRepository>(
          create: (_) => AttendanceRepositoryImpl(apiClient),
        ),
        RepositoryProvider<CatalogRepository>(
          create: (_) => CatalogRepositoryImpl(apiClient),
        ),
        RepositoryProvider<ExamsRepository>(
          create: (_) => ExamsRepositoryImpl(apiClient),
        ),
        RepositoryProvider<ExamTakingRepository>(
          create: (_) => ExamTakingRepositoryImpl(apiClient),
        ),
        RepositoryProvider<NotificationsRepository>(
          create: (_) => NotificationsRepositoryImpl(apiClient),
        ),
        RepositoryProvider<MessagesRepository>(
          create: (_) => MessagesRepositoryImpl(apiClient),
        ),
        RepositoryProvider<PostsRepository>(
          create: (_) => PostsRepositoryImpl(apiClient),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final auth = AuthCubit(context.read<AuthRepository>());
              // Strategy: 401 -> Login
              apiClient.onUnauthorized = auth.forceLogout;
              unawaited(auth.restoreSession());
              return auth;
            },
          ),
          BlocProvider(
            create: (context) => InboxBadgeCubit(
              context.read<NotificationsRepository>(),
              context.read<MessagesRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Trung tâm đào tạo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              switch (state.status) {
                case AuthStatus.authenticated:
                  return const HomeShell();
                case AuthStatus.unknown:
                  return const SplashPage();
                case AuthStatus.unauthenticated:
                case AuthStatus.loading:
                case AuthStatus.failure:
                  return const LoginPage();
              }
            },
          ),
        ),
      ),
    );
  }
}
