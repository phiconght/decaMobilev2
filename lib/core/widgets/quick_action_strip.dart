import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/quick_action.dart';
import 'package:deca_mobile/core/widgets/quick_action_button.dart';
import 'package:flutter/material.dart';

/// Khung tien ich cuon ngang — chua khong gioi han [QuickAction].
///
/// Them button moi chi can noi them 1 phan tu vao danh sach [actions];
/// widget tu render lai, khong can sua code UI.
class QuickActionStrip extends StatelessWidget {
  const QuickActionStrip({required this.actions, super.key});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Tiện ích',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: actions.length,
            separatorBuilder: (context, _) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) =>
                QuickActionButton(action: actions[i]),
          ),
        ),
      ],
    );
  }
}
