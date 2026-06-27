import 'dart:async';

import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/info_row.dart';
import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/core/widgets/status_chip.dart';
import 'package:deca_mobile/courses/data/models/course.dart';
import 'package:deca_mobile/exams/cubit/exams_cubit.dart';
import 'package:deca_mobile/exams/data/exams_repository.dart';
import 'package:deca_mobile/exams/data/models/exam.dart';
import 'package:deca_mobile/exams/widgets/exam_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Chi tiet khoa hoc — nhan [Course] tu danh sach (khong fetch lai),
/// nhung TAI danh sach de thi cua lop tu BE.
class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({required this.course, super.key});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = DateFormat('dd/MM/yyyy');
    final time = (course.startDate != null && course.endDate != null)
        ? '${f.format(course.startDate!)} – ${f.format(course.endDate!)}'
        : 'Chưa cập nhật';

    return BlocProvider(
      create: (ctx) {
        final cubit = ExamsCubit(ctx.read<ExamsRepository>(), course.id);
        unawaited(cubit.load());
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(course.name)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Card(
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
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        StatusChip(course.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${course.subjectName} — ${course.gradeLevel}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Mã: ${course.code}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              title: 'Thông tin',
              child: Column(
                children: [
                  InfoRow(label: 'Thời gian', value: time),
                  InfoRow(label: 'Môn học', value: course.subjectName),
                  InfoRow(label: 'Khối', value: course.gradeLevel),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              title: 'Đề thi',
              child: BlocBuilder<ExamsCubit, DataState<List<Exam>>>(
                builder: _buildExams,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExams(BuildContext context, DataState<List<Exam>> state) {
    final theme = Theme.of(context);
    final exams = state.data ?? const <Exam>[];

    if (state.isLoading && exams.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.isFailure && exams.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.error ?? 'Đã có lỗi xảy ra',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () =>
                  unawaited(context.read<ExamsCubit>().refresh()),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ),
        ],
      );
    }

    if (exams.isEmpty) {
      return Text(
        'Chưa có đề thi cho lớp này.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < exams.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          ExamListTile(exam: exams[i]),
        ],
      ],
    );
  }
}
