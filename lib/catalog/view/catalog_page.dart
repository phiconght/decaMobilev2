import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/catalog/cubit/catalog_cubit.dart';
import 'package:deca_mobile/catalog/data/catalog_repository.dart';
import 'package:deca_mobile/coin/data/coin_repository.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_dialogs.dart';
import 'package:deca_mobile/core/widgets/app_empty_view.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_loading_view.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
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
  String? _gradeFilter; // null = "Tất cả"

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

  List<String> get _grades {
    final set = <String>{};
    for (final c in widget.courses) {
      if (c.gradeLevel.isNotEmpty) set.add(c.gradeLevel);
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
      if (_gradeFilter != null && c.gradeLevel != _gradeFilter) {
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
          const _FilterLabel(text: 'Môn học'),
          const SizedBox(height: 6),
          _SubjectChipRow(
            subjects: subjects,
            selected: _subjectFilter,
            onSelect: (s) => setState(() => _subjectFilter = s),
          ),
          if (_grades.isNotEmpty) ...[
            AppSpacing.gapMd,
            const _FilterLabel(text: 'Khối lớp'),
            const SizedBox(height: 6),
            _GradeChipRow(
              grades: _grades,
              selected: _gradeFilter,
              onSelect: (g) => setState(() => _gradeFilter = g),
            ),
          ],
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

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _GradeChipRow extends StatelessWidget {
  const _GradeChipRow({
    required this.grades,
    required this.selected,
    required this.onSelect,
  });

  final List<String> grades;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: grades.length + 1,
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
          final grade = grades[i - 1];
          return _Chip(
            label: grade,
            active: selected == grade,
            onTap: () => onSelect(grade),
            leadingIcon: Icons.school_outlined,
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
    // Wrap (khong phai GridView 2 cot) — nhieu mon chi co 1 khoa, GridView
    // ep the do ra nua hang khien phan con lai trong rong rat xau. Wrap chi
    // chiem dung kich thuoc the can, tu xuong dong khi day.
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final course in courses) _ExploreCourseCard(course: course),
      ],
    );
  }
}

/// The khoa hoc — CHI XEM chi tiet (khong onTap mo trang rieng, yeu cau
/// 11/08/2026), NHUNG neu la HOC SINH va lop co mo ban qua Xu thi co nut
/// "Đăng ký" tru Xu + vao lop ngay (xem KE_HOACH_TRIEN_KHAI.md).
class _ExploreCourseCard extends StatefulWidget {
  const _ExploreCourseCard({required this.course});

  final Course course;

  @override
  State<_ExploreCourseCard> createState() => _ExploreCourseCardState();
}

class _ExploreCourseCardState extends State<_ExploreCourseCard> {
  bool _enrolling = false;

  static String? _dateRange(Course c) {
    if (c.startDate == null || c.endDate == null) return null;
    final f = DateFormat('dd/MM/yy');
    return '${f.format(c.startDate!)} – ${f.format(c.endDate!)}';
  }

  bool get _isStudent {
    final roles = context.read<AuthCubit>().state.user?.roles ?? const [];
    return roles.contains('STUDENT');
  }

  Future<void> _confirmAndEnroll(BuildContext context) async {
    final course = widget.course;
    final price = course.coinPrice;
    if (price == null || price <= 0) return;

    int? balance;
    try {
      balance = (await context.read<CoinRepository>().fetchBalance()).balance;
    } on ApiException catch (_) {
      balance = null;
    }
    if (!context.mounted) return;

    final notEnough = balance != null && balance < price;
    final money = NumberFormat.decimalPattern('vi_VN');
    final ok = await AppDialogs.confirm(
      context,
      title: 'Đăng ký "${course.name}"',
      message: notEnough
          ? 'Cần ${money.format(price)} Xu, bạn chỉ có ${money.format(balance)} Xu — '
              'không đủ để đăng ký.'
          : 'Đăng ký khóa "${course.name}" sẽ trừ ${money.format(price)} Xu'
              '${balance != null ? ' (số dư hiện tại: ${money.format(balance)} Xu)' : ''}.'
              ' Bạn có chắc chắn?',
      confirmText: notEnough ? 'Đã hiểu' : 'Đăng ký',
      danger: notEnough,
    );
    if (!ok || notEnough || !context.mounted) return;

    setState(() => _enrolling = true);
    try {
      final result =
          await context.read<CatalogRepository>().enroll(course.id);
      if (!context.mounted) return;
      AppSnackBar.success(
        context,
        'Đã đăng ký "${result.className}" — còn ${money.format(result.newBalance)} Xu.',
      );
      unawaited(context.read<CatalogCubit>().refresh());
    } on ApiException catch (e) {
      if (context.mounted) AppSnackBar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final course = widget.course;
    final color = subjectColor(course.subjectName);
    final dateRange = _dateRange(course);
    final money = NumberFormat.decimalPattern('vi_VN');
    final purchasable = course.coinPrice != null && course.coinPrice! > 0;
    final showBuy = purchasable && !course.enrolled && _isStudent;

    return Container(
      width: 148,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.rmd,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: AppRadii.rsm,
                ),
                child: Icon(subjectIcon(course.subjectName), color: color, size: 14),
              ),
              const Spacer(),
              _MiniStatusDot(status: course.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            course.name,
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            course.gradeLevel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateRange ?? 'Mã ${course.code}',
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 9.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (purchasable) ...[
            const SizedBox(height: 6),
            if (course.enrolled)
              const _MiniPill(
                label: 'Đã tham gia',
                color: AppColors.success,
                icon: Icons.check_circle_rounded,
              )
            else if (showBuy)
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: _enrolling ? null : () => _confirmAndEnroll(context),
                  borderRadius: AppRadii.rsm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: AppRadii.rsm,
                    ),
                    child: _enrolling
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.6,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Đăng ký · ${money.format(course.coinPrice)} Xu',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 9.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
              )
            else
              _MiniPill(
                label: '${money.format(course.coinPrice)} Xu',
                color: AppColors.warningDark,
                icon: Icons.monetization_on_outlined,
              ),
          ],
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadii.rsm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 9.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cham + nhan trang thai gon (thay StatusChip to — khong vua the nho 148px).
class _MiniStatusDot extends StatelessWidget {
  const _MiniStatusDot({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status.toUpperCase()) {
      'ACTIVE' => ('Đang học', AppColors.success),
      'INACTIVE' => ('Đã kết thúc', AppColors.neutral),
      'LOCKED' => ('Đã khóa', AppColors.danger),
      _ => (status, AppColors.neutral),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
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
