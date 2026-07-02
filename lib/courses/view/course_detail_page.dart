import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/core/widgets/status_chip.dart';
import 'package:deca_mobile/courses/cubit/course_sessions_cubit.dart';
import 'package:deca_mobile/courses/data/models/course.dart';
import 'package:deca_mobile/courses/widgets/course_session_tile.dart';
import 'package:deca_mobile/exams/cubit/exams_cubit.dart';
import 'package:deca_mobile/exams/data/exams_repository.dart';
import 'package:deca_mobile/exams/data/models/exam.dart';
import 'package:deca_mobile/exams/view/exam_paper_page.dart';
import 'package:deca_mobile/exams/widgets/exam_list_tile.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/data/timetable_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Chi tiet khoa hoc — nhan [Course] tu danh sach (khong fetch lai).
///
/// Hien thi theo thu tu: thong tin lop -> cac BUOI HOC DA QUA -> cac DE THI
/// da/dang phat.
class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({required this.course, super.key});

  final Course course;

  /// View timetable de suy buoi da qua theo vai tro nguoi dung.
  static String _viewFor(List<String> roles) {
    if (roles.contains('STUDENT')) return 'STUDENT';
    if (roles.contains('TEACHER')) return 'TEACHER';
    return 'STUDENT';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roles = context.read<AuthCubit>().state.user?.roles ?? const [];
    final view = _viewFor(roles);

    final f = DateFormat('dd/MM/yyyy');
    final time = (course.startDate != null && course.endDate != null)
        ? '${f.format(course.startDate!)} – ${f.format(course.endDate!)}'
        : 'Chưa cập nhật';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) {
            final cubit = CourseSessionsCubit(
              ctx.read<TimetableRepository>(),
              course.id,
              view,
              since: course.startDate,
            );
            unawaited(cubit.load());
            return cubit;
          },
        ),
        BlocProvider(
          create: (ctx) {
            final cubit = ExamsCubit(ctx.read<ExamsRepository>(), course.id);
            unawaited(cubit.load());
            return cubit;
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(course.name)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _header(theme, time),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              title: 'Buổi học đã qua',
              child: BlocBuilder<CourseSessionsCubit,
                  DataState<List<TimetableItem>>>(
                builder: _buildSessions,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              title: 'Đề thi đã/đang phát',
              child: BlocBuilder<ExamsCubit, DataState<List<Exam>>>(
                builder: _buildExams,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(ThemeData theme, String time) {
    final onContainer = theme.colorScheme.onPrimaryContainer;
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    course.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: onContainer),
                  ),
                ),
                StatusChip(course.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${course.subjectName} — ${course.gradeLevel}',
              style: theme.textTheme.bodyMedium?.copyWith(color: onContainer),
            ),
            Text(
              'Mã: ${course.code}',
              style: theme.textTheme.bodySmall?.copyWith(color: onContainer),
            ),
            Text(
              'Thời gian: $time',
              style: theme.textTheme.bodySmall?.copyWith(color: onContainer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessions(
    BuildContext context,
    DataState<List<TimetableItem>> state,
  ) {
    final sessions = state.data ?? const <TimetableItem>[];

    if (state.isLoading && sessions.isEmpty) {
      return const _SectionLoading();
    }
    if (state.isFailure && sessions.isEmpty) {
      return _SectionError(
        message: state.error ?? 'Đã có lỗi xảy ra',
        onRetry: () => unawaited(context.read<CourseSessionsCubit>().refresh()),
      );
    }
    if (sessions.isEmpty) {
      return const _SectionEmpty(message: 'Chưa có buổi học nào đã qua.');
    }

    return Column(
      children: [
        for (var i = 0; i < sessions.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          CourseSessionTile(item: sessions[i]),
        ],
      ],
    );
  }

  Widget _buildExams(BuildContext context, DataState<List<Exam>> state) {
    final all = state.data ?? const <Exam>[];

    if (state.isLoading && all.isEmpty) {
      return const _SectionLoading();
    }
    if (state.isFailure && all.isEmpty) {
      return _SectionError(
        message: state.error ?? 'Đã có lỗi xảy ra',
        onRetry: () => unawaited(context.read<ExamsCubit>().refresh()),
      );
    }

    final published = _publishedExams(all);
    if (published.isEmpty) {
      return const _SectionEmpty(message: 'Chưa có đề thi nào được phát.');
    }

    return Column(
      children: [
        for (var i = 0; i < published.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          ExamListTile(
            exam: published[i],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ExamPaperPage(exam: published[i]),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// De thi DA/DANG PHAT = da co moc phat (publishAt) va moc do <= hien tai.
  /// Sap xep moi phat gan day len truoc.
  static List<Exam> _publishedExams(List<Exam> exams) {
    final now = DateTime.now();
    return exams
        .where((e) => e.publishAt != null && !e.publishAt!.isAfter(now))
        .toList()
      ..sort((a, b) => b.publishAt!.compareTo(a.publishAt!));
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      message,
      style: theme.textTheme.bodyMedium
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ),
      ],
    );
  }
}
