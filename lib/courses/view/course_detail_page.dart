import 'package:deca_mobile/core/widgets/info_row.dart';
import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/core/widgets/status_chip.dart';
import 'package:deca_mobile/courses/data/models/course.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Chi tiet khoa hoc — nhan [Course] tu danh sach (khong fetch lai).
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

    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          SectionCard(
            title: 'Bài tập / Đề thi',
            child: Text(
              'Sắp ra mắt',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
