import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/catalog/data/catalog_repository.dart';
import 'package:deca_mobile/catalog/widgets/registration_qr_sheet.dart';
import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/network/url_helper.dart';
import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_bottom_sheet.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_loading_view.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/settings/cubit/app_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Trang chi tiết khóa học (marketing, công khai) — bấm vào Card ở Trang chủ
/// hoặc Khám phá khóa học mở ra. Khác `CourseOutlinePage` (dành cho HS đã
/// ghi danh xem buổi học/đề thi) — trang này chỉ giới thiệu + đăng ký.
class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({required this.classId, super.key});

  final int classId;

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late Future<ClassPublicDetail> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<CatalogRepository>().fetchPublicDetail(
      widget.classId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết khóa học')),
      body: FutureBuilder<ClassPublicDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoadingView(itemCount: 4);
          }
          if (snapshot.hasError) {
            return AppErrorView(
              message: 'Không tải được khóa học',
              onRetry: () => setState(_load),
            );
          }
          final klass = snapshot.data!;
          return _CourseDetailBody(klass: klass);
        },
      ),
    );
  }
}

class _CourseDetailBody extends StatelessWidget {
  const _CourseDetailBody({required this.klass});

  final ClassPublicDetail klass;

  static final _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = context.read<ApiClient>().config;
    final registrable = (klass.fullPrice ?? 0) > 0;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              if (klass.coverImageUrl != null &&
                  klass.coverImageUrl!.isNotEmpty)
                Image.network(
                  config.toAbsoluteUrl(klass.coverImageUrl),
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _HeroPlaceholder(theme: theme),
                )
              else
                _HeroPlaceholder(theme: theme),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      klass.displayTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (klass.teacherNames.isNotEmpty)
                          _MetaChip(
                            icon: Icons.person_outline,
                            text: klass.teacherNames.join(', '),
                          ),
                        if (klass.startDate != null && klass.endDate != null)
                          _MetaChip(
                            icon: Icons.calendar_today_outlined,
                            text:
                                '${_dateFmt.format(klass.startDate!)} – ${_dateFmt.format(klass.endDate!)}',
                          ),
                        _MetaChip(
                          icon: klass.deliveryMode == 'ONLINE'
                              ? Icons.videocam_outlined
                              : Icons.location_on_outlined,
                          text: klass.deliveryMode == 'ONLINE'
                              ? 'Trực tuyến'
                              : 'Trực tiếp tại lớp',
                        ),
                        Chip(
                          label: Text(
                            '${klass.subjectName} · ${klass.gradeLevel}',
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    if (klass.contentMd != null &&
                        klass.contentMd!.isNotEmpty) ...[
                      const Divider(height: AppSpacing.xl * 2),
                      Text(
                        'GIỚI THIỆU KHÓA HỌC',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      MarkdownBody(
                        data: klass.contentMd!,
                        sizedImageBuilder: (imgConfig) => Image.network(
                          config.toAbsoluteUrl(imgConfig.uri.toString()),
                          width: imgConfig.width,
                          height: imgConfig.height,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (registrable) _RegisterBar(klass: klass),
      ],
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E43E8), Color(0xFF5B6CFF)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.menu_book_outlined, size: 56, color: Colors.white70),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: muted),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Khối "Đăng ký khóa học" cố định dưới cùng — giá + QR (ONLINE) hoặc chỉ
/// hotline (OFFLINE, đăng ký qua điện thoại thay vì tự chuyển khoản).
class _RegisterBar extends StatefulWidget {
  const _RegisterBar({required this.klass});

  final ClassPublicDetail klass;

  @override
  State<_RegisterBar> createState() => _RegisterBarState();
}

class _RegisterBarState extends State<_RegisterBar> {
  RegistrationResult? _registration;
  bool _loading = false;
  bool _checkedExisting = false;

  static final _money = NumberFormat.decimalPattern('vi_VN');

  bool get _isStudent {
    final roles = context.read<AuthCubit>().state.user?.roles ?? const [];
    return roles.contains('STUDENT');
  }

  bool get _canSelfRegister =>
      _isStudent &&
      widget.klass.deliveryMode == 'ONLINE' &&
      !widget.klass.enrolled;

  @override
  void initState() {
    super.initState();
    if (_canSelfRegister) {
      unawaited(_loadExisting());
    } else {
      _checkedExisting = true;
    }
  }

  Future<void> _loadExisting() async {
    try {
      final r = await context.read<CatalogRepository>().myRegistration(
        widget.klass.id,
      );
      if (mounted) setState(() => _registration = r);
    } on Object catch (_) {
      // Bo qua: khong co yeu cau nao la binh thuong.
    } finally {
      if (mounted) setState(() => _checkedExisting = true);
    }
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      final r = await context.read<CatalogRepository>().register(
        widget.klass.id,
      );
      if (!mounted) return;
      setState(() => _registration = r);
      unawaited(
        AppBottomSheet.show<void>(
          context,
          child: RegistrationQrSheet(registration: r),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) AppSnackBar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _callHotline(String hotline) async {
    final uri = Uri(scheme: 'tel', path: hotline.replaceAll(' ', ''));
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final klass = widget.klass;
    final hotline = context.watch<AppSettingsCubit>().state.supportHotline;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_money.format(klass.fullPrice)} ₫',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Trọn khóa',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (klass.enrolled)
              const Chip(
                label: Text('Đã tham gia'),
                backgroundColor: AppColors.successTint,
                labelStyle: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              )
            else ...[
              if (hotline != null)
                IconButton.filledTonal(
                  onPressed: () => _callHotline(hotline),
                  icon: const Icon(Icons.call_outlined),
                  tooltip: 'Gọi $hotline',
                ),
              const SizedBox(width: AppSpacing.sm),
              if (_canSelfRegister)
                FilledButton(
                  onPressed: !_checkedExisting || _loading
                      ? null
                      : (_registration != null
                            ? () => AppBottomSheet.show<void>(
                                context,
                                child: RegistrationQrSheet(
                                  registration: _registration!,
                                ),
                              )
                            : _register),
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_registration != null ? 'Xem mã QR' : 'Đăng ký'),
                )
              else if (klass.deliveryMode == 'OFFLINE' && hotline != null)
                Text(
                  'Gọi hotline để đăng ký',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
