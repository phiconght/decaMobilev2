import 'dart:async';

import 'package:deca_mobile/catalog/cubit/catalog_cubit.dart';
import 'package:deca_mobile/catalog/data/catalog_repository.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_empty_view.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_loading_view.dart';
import 'package:deca_mobile/core/widgets/status_chip.dart';
import 'package:deca_mobile/courses/data/models/course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Man "Khám phá khóa học" — CHI XEM (khong bam vao tung khoa duoc nua, yeu
/// cau nguoi dung 11/08/2026). Day la danh muc toan he thong (moi lop, ke ca
/// lop nguoi dung khong ghi danh) nen khong mo duoc noi dung chi tiet
/// (buoi hoc/video/de thi...) — chi con y nghia "xem co nhung khoa nao".
///
/// Thiet ke theo ThietKe/Mobile/files/m-explore.html — GIU nguyen phan tim
/// kiem/loc/luoi the theo nhom mon, nhung BO phan gia/GV/khuyen mai vi
/// model Course khong co cac truong nay (khong bia du lieu).
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = CatalogCubit(ctx.read<CatalogRepository>());
        unawaited(cubit.load());
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Khám phá khóa học')),
        body: BlocBuilder<CatalogCubit, DataState<List<Course>>>(
          builder: (context, state) {
            if (state.isLoading && !state.hasData) {
              return const AppLoadingView();
            }
            if (state.isFailure && !state.hasData) {
              return AppErrorView(
                message: state.error ?? 'Đã có lỗi xảy ra',
                onRetry: context.read<CatalogCubit>().refresh,
              );
            }
            final courses = state.data ?? const <Course>[];
            if (courses.isEmpty) {
              return const AppEmptyView(message: 'Chưa có khóa học nào.');
            }
            return _ExploreBody(
              courses: courses,
              onRefresh: context.read<CatalogCubit>().refresh,
            );
          },
        ),
      ),
    );
  }
}

class _ExploreBody extends StatefulWidget {
  const _ExploreBody({required this.courses, required this.onRefresh});

  final List<Course> courses;
  final Future<void> Function() onRefresh;

  @override
  State<_ExploreBody> createState() => _ExploreBodyState();
}

class _ExploreBodyState extends State<_ExploreBody> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _subjectFilter; // null = "Tất cả"

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _subjects {
    final set = <String>{};
    for (final c in widget.courses) {
      if (c.subjectName.isNotEmpty) set.add(c.subjectName);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<Course> get _filtered {
    final q = _query.trim().toLowerCase();
    return widget.courses.where((c) {
      if (_subjectFilter != null && c.subjectName != _subjectFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q) ||
          c.subjectName.toLowerCase().contains(q);
    }).toList();
  }

  Map<String, List<Course>> _groupBySubject(List<Course> courses) {
    final map = <String, List<Course>>{};
    for (final c in courses) {
      map.putIfAbsent(c.subjectName, () => []).add(c);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final groups = _groupBySubject(filtered);
    final subjects = _subjects;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: AppSpacing.screen,
        children: [
          _SearchBox(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
          ),
          AppSpacing.gapLg,
          _SubjectChipRow(
            subjects: subjects,
            selected: _subjectFilter,
            onSelect: (s) => setState(() => _subjectFilter = s),
          ),
          AppSpacing.gapLg,
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: AppEmptyView(
                message: 'Không tìm thấy khóa học phù hợp.',
                icon: Icons.search_off,
              ),
            )
          else
            for (final entry in groups.entries) ...[
              _SectionHeader(
                subject: entry.key,
                count: entry.value.length,
              ),
              AppSpacing.gapMd,
              _CourseGrid(courses: entry.value),
              AppSpacing.gapXl,
            ],
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Tìm khóa học theo tên, mã, môn...',
        prefixIcon: const Icon(Icons.search, size: 20),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadii.rlg,
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.rlg,
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}

class _SubjectChipRow extends StatelessWidget {
  const _SubjectChipRow({
    required this.subjects,
    required this.selected,
    required this.onSelect,
  });

  final List<String> subjects;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          if (i == 0) {
            return _Chip(
              label: 'Tất cả',
              active: selected == null,
              onTap: () => onSelect(null),
              leadingIcon: Icons.apps_rounded,
            );
          }
          final subject = subjects[i - 1];
          return _Chip(
            label: subject,
            active: selected == subject,
            onTap: () => onSelect(subject),
            dotColor: subjectColor(subject),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.leadingIcon,
    this.dotColor,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.rmd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
          border: Border.all(
            color: active ? theme.colorScheme.primary : theme.colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 14, color: fg),
              const SizedBox(width: 6),
            ] else if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.subject, required this.count});

  final String subject;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: subjectColor(subject),
            borderRadius: AppRadii.rsm,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            subject,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '$count khóa',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CourseGrid extends StatelessWidget {
  const _CourseGrid({required this.courses});

  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, i) => _ExploreCourseCard(course: courses[i]),
    );
  }
}

/// The khoa hoc dang luoi — CHI XEM, khong co onTap (yeu cau 11/08/2026).
class _ExploreCourseCard extends StatelessWidget {
  const _ExploreCourseCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = subjectColor(course.subjectName);
    final dateRange = _dateRange(course);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.rlg,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: AppRadii.rmd,
                ),
                child: Icon(subjectIcon(course.subjectName), color: color, size: 19),
              ),
              const Spacer(),
              StatusChip(course.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            course.name,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            course.gradeLevel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            dateRange ?? 'Mã ${course.code}',
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static String? _dateRange(Course c) {
    if (c.startDate == null || c.endDate == null) return null;
    final f = DateFormat('dd/MM/yy');
    return '${f.format(c.startDate!)} – ${f.format(c.endDate!)}';
  }
}

// ---------------------------------------------------------------------------
// Mau/icon theo mon hoc — on dinh (hash ten mon), khong phu thuoc BE.

const _subjectPalette = [
  AppColors.brand,
  AppColors.success,
  AppColors.warningDark,
  AppColors.danger,
  Color(0xFF6B5B95),
  Color(0xFF00838F),
];

Color subjectColor(String subject) {
  if (subject.isEmpty) return AppColors.neutral;
  return _subjectPalette[subject.hashCode.abs() % _subjectPalette.length];
}

IconData subjectIcon(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('toán')) return Icons.percent_rounded;
  if (s.contains('lý') || s.contains('vật lí')) return Icons.hub_outlined;
  if (s.contains('hóa')) return Icons.science_outlined;
  if (s.contains('sinh')) return Icons.eco_outlined;
  if (s.contains('anh') || s.contains('ngoại ngữ')) return Icons.translate_rounded;
  if (s.contains('văn')) return Icons.menu_book_outlined;
  return Icons.school_outlined;
}
