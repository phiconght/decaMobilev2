import 'dart:async';

import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Mo BottomSheet luoi so cau de nhay nhanh giua cac cau.
void showQuestionJumpSheet(
  BuildContext context, {
  required int total,
  required Set<int> answered,
  required ValueChanged<int> onSelect,
}) {
  unawaited(
    AppBottomSheet.show<void>(
      context,
      child: _JumpGrid(total: total, answered: answered, onSelect: onSelect),
    ),
  );
}

class _JumpGrid extends StatelessWidget {
  const _JumpGrid({
    required this.total,
    required this.answered,
    required this.onSelect,
  });

  final int total;
  final Set<int> answered;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text('Danh sách câu hỏi', style: theme.textTheme.titleMedium),
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < total; i++)
              _JumpCell(
                number: i + 1,
                answered: answered.contains(i),
                onTap: () {
                  Navigator.of(context).pop();
                  onSelect(i);
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const _LegendDot(color: AppColors.success),
            const SizedBox(width: 4),
            Text('Đã trả lời', style: theme.textTheme.labelSmall),
            const SizedBox(width: AppSpacing.lg),
            _LegendDot(color: theme.colorScheme.surfaceContainerHighest),
            const SizedBox(width: 4),
            Text('Chưa trả lời', style: theme.textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}

class _JumpCell extends StatelessWidget {
  const _JumpCell({
    required this.number,
    required this.answered,
    required this.onTap,
  });

  final int number;
  final bool answered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = answered
        ? AppColors.success.withValues(alpha: 0.16)
        : theme.colorScheme.surfaceContainerHighest;
    final fg = answered ? AppColors.success : theme.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.rmd,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.rmd,
          border: Border.all(
            color: answered
                ? AppColors.success.withValues(alpha: 0.4)
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          '$number',
          style: theme.textTheme.titleSmall
              ?.copyWith(color: fg, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
