import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/core/widgets/status_chip.dart';
import 'package:deca_mobile/courses/cubit/course_outline_cubit.dart';
import 'package:deca_mobile/courses/data/courses_repository.dart';
import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:deca_mobile/courses/data/models/course.dart';
import 'package:deca_mobile/courses/widgets/course_progress_bar.dart';
import 'package:deca_mobile/courses/widgets/course_session_tile.dart';
import 'package:deca_mobile/courses/widgets/topic_group_tile.dart';
import 'package:deca_mobile/exams/data/exam_pdf_saver.dart';
import 'package:deca_mobile/exams/data/exams_repository.dart';
import 'package:deca_mobile/exams/view/exam_paper_page.dart';
import 'package:deca_mobile/exams/widgets/exam_list_tile.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart'
    as timetable;
import 'package:deca_mobile/schedule/view/session_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Chi tiet khoa hoc — MOT danh sach duy nhat, gom theo CHUYEN DE.
///
/// Truoc day man nay chia 2 bang roi rac ("Buoi hoc da qua" / "De thi da phat")
/// vi du lieu den tu 2 API khong lien quan nhau. Nay dung 1 endpoint
/// `/classes/{id}/outline` tra san cay chuyen de -> buoi hoc + de thi.
/// Xem SPEC_KhoaHoc_NoiDung_Mobile.md.
class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({required this.course, super.key});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = CourseOutlineCubit(
          ctx.read<CoursesRepository>(),
          course.id,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: _CourseDetailView(course: course),
    );
  }
}

class _CourseDetailView extends StatelessWidget {
  const _CourseDetailView({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: BlocBuilder<CourseOutlineCubit, DataState<ClassOutline>>(
        builder: (context, state) {
          final outline = state.data;

          if (state.isLoading && outline == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isFailure && outline == null) {
            return _ErrorView(
              message: state.error ?? 'Đã có lỗi xảy ra',
              onRetry: () =>
                  unawaited(context.read<CourseOutlineCubit>().refresh()),
            );
          }
          if (outline == null) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            onRefresh: () => context.read<CourseOutlineCubit>().refresh(),
            child: _OutlineList(course: course, outline: outline),
          );
        },
      ),
    );
  }
}

class _OutlineList extends StatefulWidget {
  const _OutlineList({required this.course, required this.outline});

  final Course course;
  final ClassOutline outline;

  @override
  State<_OutlineList> createState() => _OutlineListState();
}

class _OutlineListState extends State<_OutlineList> {
  @override
  Widget build(BuildContext context) {
    final outline = widget.outline;
    final groups = outline.groups.where((g) => !g.isEmpty).toList();

    final now = DateTime.now();
    final next = outline.nextSession(now) ?? outline.lastSession;
    // Chi buoi PLANNED moi duoc danh dau "ke tiep"; neu khoa da ket thuc thi
    // `next` la buoi cuoi, khong danh dau (khong con gi "ke tiep").
    final nextId = outline.nextSession(now)?.sessionId;
    final today = DateTime(now.year, now.month, now.day);

    // Nhom mo san = nhom chua buoi ke tiep; khoa da ket thuc -> nhom buoi cuoi.
    final anchorGroupId = _groupIdOf(groups, next?.sessionId);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _header(context, outline),
        const SizedBox(height: AppSpacing.lg),
        CourseProgressBar(progress: outline.progress),
        const SizedBox(height: AppSpacing.lg),
        if (groups.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Text('Khóa học chưa có buổi học nào.'),
          )
        else
          ...groups.map((g) {
            final key = g.topicId ?? -1;
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              clipBehavior: Clip.antiAlias,
              child: TopicGroupTile(
                group: g,
                initiallyExpanded: key == anchorGroupId,
                sessionBuilder: (s) => CourseSessionTile(
                  session: s,
                  isNext: s.sessionId == nextId,
                  isToday: s.sessionId == nextId &&
                      DateTime(s.date.year, s.date.month, s.date.day) == today,
                  onTap: () => _openSessionDetail(context, outline, s),
                  onExamTap: (e) => _openExam(context, e),
                ),
                examBuilder: (e) => _examTile(context, e),
              ),
            );
          }),
      ],
    );
  }

  /// Mo chi tiet buoi hoc (video bai giang, link Zoom...) — tai dung
  /// SessionDetailPage cua Timetable, dung du lieu da co san trong outline
  /// (khong goi them API). Xem SPEC_VideoBaiGiang_Zoom.md §5.1.
  void _openSessionDetail(
    BuildContext context,
    ClassOutline outline,
    OutlineSession s,
  ) {
    final user = context.read<AuthCubit>().state.user;
    final roles = user?.roles ?? const <String>[];
    final view = roles.contains('TEACHER') || roles.contains('ASSISTANT')
        ? 'TEACHER'
        : roles.contains('PARENT')
            ? 'PARENT'
            : 'STUDENT';

    final status = switch (s.status) {
      OutlineSessionStatus.done => timetable.SessionStatus.done,
      OutlineSessionStatus.cancelled => timetable.SessionStatus.cancelled,
      OutlineSessionStatus.planned => timetable.SessionStatus.planned,
    };

    final item = timetable.TimetableItem(
      sessionId: s.sessionId,
      classId: outline.classId,
      className: outline.name.isEmpty ? widget.course.name : outline.name,
      subjectName: outline.subjectName,
      gradeLevel: outline.gradeLevel,
      date: s.date,
      startTime: s.startTime ?? '00:00',
      endTime: s.endTime ?? '00:00',
      roomName: s.roomName,
      teacherName: s.teacherName,
      status: status,
      attendanceStatus: timetable.attendanceStatusFromString(
        s.attendanceStatus,
      ),
      onLeave: s.onLeave,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionDetailPage(item: item, view: view),
      ),
    );
  }

  /// Id nhom (topicId, -1 cho nhom chua phan) chua buoi [sessionId].
  int? _groupIdOf(List<OutlineTopicGroup> groups, int? sessionId) {
    if (sessionId == null) return null;
    for (final g in groups) {
      if (g.sessions.any((s) => s.sessionId == sessionId)) {
        return g.topicId ?? -1;
      }
    }
    return null;
  }

  /// Mo bai lam cua 1 de thi (dung chung cho ExamMiniRow gan buoi va
  /// ExamListTile day du o nhom "de roi").
  void _openExam(BuildContext context, OutlineExam e) {
    final exam = e.toExam();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ExamPaperPage(exam: exam)),
    );
  }

  Widget _examTile(BuildContext context, OutlineExam e) {
    final exam = e.toExam();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExamListTile(
          exam: exam,
          onTap: () => _openExam(context, e),
          onDownloadPdf: () =>
              unawaited(_downloadPdf(context, exam.id, exam.code)),
        ),
        if (e.isSubmitted && e.score != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              'Đã nộp · ${_formatScore(e.score!)} điểm',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _header(BuildContext context, ClassOutline outline) {
    final theme = Theme.of(context);
    final onContainer = theme.colorScheme.onPrimaryContainer;
    final f = DateFormat('dd/MM/yyyy');
    final start = outline.startDate ?? widget.course.startDate;
    final end = outline.endDate ?? widget.course.endDate;
    final time = (start != null && end != null)
        ? '${f.format(start)} – ${f.format(end)}'
        : 'Chưa cập nhật';

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
                    outline.name.isEmpty ? widget.course.name : outline.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: onContainer),
                  ),
                ),
                StatusChip(outline.status ?? widget.course.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${outline.subjectName ?? widget.course.subjectName} — '
              '${outline.gradeLevel ?? widget.course.gradeLevel}',
              style: theme.textTheme.bodyMedium?.copyWith(color: onContainer),
            ),
            Text(
              'Mã: ${outline.code ?? widget.course.code}',
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

  /// 8.0 -> "8"; 8.5 -> "8.5".
  static String _formatScore(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  /// Tai de thi PDF (bien the DE) va luu/mo theo nen tang.
  Future<void> _downloadPdf(
    BuildContext context,
    int examId,
    String code,
  ) async {
    try {
      final bytes = await context.read<ExamsRepository>().examPdf(examId);
      await savePdf(bytes, 'De-thi_$code.pdf');
      if (context.mounted) {
        AppSnackBar.success(context, 'Đã tải đề thi PDF');
      }
    } on ApiException catch (e) {
      if (context.mounted) AppSnackBar.error(context, e.message);
    } on Object {
      if (context.mounted) AppSnackBar.error(context, 'Tải file thất bại');
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
