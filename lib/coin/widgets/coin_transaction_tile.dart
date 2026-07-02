import 'package:deca_mobile/coin/data/models/coin.dart';
import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 1 dòng lịch sử Xu: ngày · +/− Xu (xanh/đỏ) · lý do · số dư sau.
class CoinTransactionTile extends StatelessWidget {
  const CoinTransactionTile({required this.transaction, super.key});

  final CoinTransaction transaction;

  static final _money = NumberFormat.decimalPattern('vi_VN');
  static final _day = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final credit = transaction.isCredit;
    final color = credit ? AppColors.success : AppColors.danger;
    final sign = credit ? '+' : '−';
    final magnitude = _money.format(transaction.amount.abs());
    final date =
        transaction.createdAt == null ? '' : _day.format(transaction.createdAt!);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: AppRadii.rmd,
              ),
              child: Icon(
                credit ? Icons.add : Icons.remove,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.reason,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$date · Số dư: ${_money.format(transaction.balanceAfter)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$sign$magnitude',
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
