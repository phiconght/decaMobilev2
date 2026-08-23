import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/catalog/data/catalog_repository.dart';
import 'package:deca_mobile/catalog/view/catalog_page.dart'
    show CatalogPage, subjectColor, subjectIcon;
import 'package:deca_mobile/coin/data/coin_repository.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_dialogs.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/courses/data/models/course.dart';
import 'package:deca_mobile/home/data/marketing_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// 1 hang danh muc noi bat tren Trang chu: tieu de + banner mau (cosmetic,
/// admin soan) + cac the lop hoc THAT (loc theo khoi lop tu cung 1 nguon
/// voi "Khám phá khóa học" — xem marketing_repository.dart).
class MarketingCategoryRow extends StatelessWidget {
  const MarketingCategoryRow({
    required this.category,
    required this.onEnrolled,
    super.key,
  });

  final MarketingCategory category;

  /// Goi lai sau khi dang ky thanh cong — cho MarketingSection tai lai du
  /// lieu (cap nhat co "Đã tham gia" o moi noi, khong chi the vua bam).
  final VoidCallback onEnrolled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (category.courses.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: category.accentColor,
                  borderRadius: AppRadii.rsm,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.emoji != null
                      ? '${category.emoji} ${category.title}'
                      : category.title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => const CatalogPage()),
                ),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 204,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              _CategoryBanner(category: category),
              const SizedBox(width: AppSpacing.md),
              for (var i = 0; i < category.courses.length; i++) ...[
                _MarketingCourseCard(
                  course: category.courses[i],
                  onEnrolled: onEnrolled,
                ),
                if (i < category.courses.length - 1)
                  const SizedBox(width: AppSpacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryBanner extends StatelessWidget {
  const _CategoryBanner({required this.category});

  final MarketingCategory category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: InkWell(
        borderRadius: AppRadii.rlg,
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const CatalogPage()),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.rlg,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: category.bannerGradient,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                bottom: -18,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppRadii.rsm,
                    ),
                    child: Text(
                      category.bannerTag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                  Text(
                    category.bannerHeadline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.all(Radius.circular(AppRadii.pill)),
                    ),
                    child: Text(
                      'Xem ngay',
                      style: TextStyle(
                        color: category.accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The lop hoc THAT trong khoi marketing — hien gia Xu noi bat; HOC SINH
/// co the bam "Đăng ký" tru Xu + vao lop ngay (khong onTap mo chi tiet,
/// dung nguyen tac "chỉ xem" cua Khám phá khóa học, yeu cau 11/08/2026).
class _MarketingCourseCard extends StatefulWidget {
  const _MarketingCourseCard({required this.course, required this.onEnrolled});

  final Course course;
  final VoidCallback onEnrolled;

  @override
  State<_MarketingCourseCard> createState() => _MarketingCourseCardState();
}

class _MarketingCourseCardState extends State<_MarketingCourseCard> {
  bool _enrolling = false;
  static final _money = NumberFormat.decimalPattern('vi_VN');

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
    final ok = await AppDialogs.confirm(
      context,
      title: 'Đăng ký "${course.name}"',
      message: notEnough
          ? 'Cần ${_money.format(price)} Xu, bạn chỉ có ${_money.format(balance)} Xu — '
              'không đủ để đăng ký.'
          : 'Đăng ký khóa "${course.name}" sẽ trừ ${_money.format(price)} Xu'
              '${balance != null ? ' (số dư hiện tại: ${_money.format(balance)} Xu)' : ''}.'
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
        'Đã đăng ký "${result.className}" — còn ${_money.format(result.newBalance)} Xu.',
      );
      widget.onEnrolled();
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
    final teacher =
        course.teacherNames.isNotEmpty ? course.teacherNames.first : null;
    final purchasable = course.coinPrice != null && course.coinPrice! > 0;
    final showBuy = purchasable && !course.enrolled && _isStudent;

    return Container(
      width: 152,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.rlg,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: AppRadii.rsm,
            ),
            child: Icon(subjectIcon(course.subjectName), color: color, size: 15),
          ),
          const SizedBox(height: 8),
          Text(
            course.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            teacher ?? 'Chưa phân công',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 9.5,
            ),
          ),
          const SizedBox(height: 6),
          // Gia Xu — noi bat, gold, luon hien neu co (khong con chi hien
          // pricePerSession mo nhat nhu ban truoc).
          if (purchasable)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  size: 13,
                  color: AppColors.warningDark,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    '${_money.format(course.coinPrice)} Xu',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.warningDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              course.gradeLevel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
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
                        : const Text(
                            'Đăng ký',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                            ),
                          ),
                  ),
                ),
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
