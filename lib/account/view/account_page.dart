import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/auth/data/auth_repository.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_bottom_sheet.dart';
import 'package:deca_mobile/core/widgets/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tab Tai khoan — DOC thang AuthCubit.user (khong goi /auth/me lan nua).
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthCubit, AuthUser?>(
      (cubit) => cubit.state.user,
    );
    if (user == null) return const SizedBox.shrink();

    return ListView(
      padding: AppSpacing.screen,
      children: [
        _ProfileHeader(user: user),
        AppSpacing.gapXl,
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Đổi mật khẩu'),
                subtitle: Text('Chức năng đang phát triển'),
                trailing: Icon(Icons.chevron_right),
                enabled: false,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Giới thiệu'),
                subtitle: const Text('Phiên bản 1.0.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAbout(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Đăng xuất',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await AppDialogs.confirm(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất?',
      confirmText: 'Đăng xuất',
      danger: true,
    );
    if (ok && context.mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  void _showAbout(BuildContext context) {
    final theme = Theme.of(context);
    unawaited(
      AppBottomSheet.show<void>(
        context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trung tâm đào tạo', style: theme.textTheme.titleLarge),
            AppSpacing.gapXs,
            Text(
              'Phiên bản 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.gapMd,
            Text(
              'Ứng dụng học tập dành cho học sinh và phụ huynh của hệ thống '
              'quản lý trung tâm đào tạo.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = user.fullName.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            initial,
            style: theme.textTheme.headlineMedium
                ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
          ),
        ),
        AppSpacing.gapMd,
        Text(user.fullName, style: theme.textTheme.titleLarge),
        AppSpacing.gapXs,
        Text(
          '@${user.username}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        AppSpacing.gapMd,
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          children: [
            for (final role in user.roles) Chip(label: Text(role)),
          ],
        ),
      ],
    );
  }
}
