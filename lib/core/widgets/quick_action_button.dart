import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/quick_action.dart';
import 'package:flutter/material.dart';

/// Mot nut trong QuickActionStrip: icon tron + nhan ben duoi.
class QuickActionButton extends StatelessWidget {
  const QuickActionButton({required this.action, super.key});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = action.enabled && action.builder != null;
    final disabledFg =
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
    final color = isEnabled ? theme.colorScheme.primary : disabledFg;
    final bgColor = isEnabled
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;

    return SizedBox(
      width: 76,
      child: InkWell(
        onTap: isEnabled
            ? () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: action.builder!),
                )
            : () => _showComingSoon(context),
        borderRadius: AppRadii.rlg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: AppRadii.rlg,
              ),
              child: Icon(action.icon, color: color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isEnabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.55),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng đang phát triển')),
    );
  }
}
