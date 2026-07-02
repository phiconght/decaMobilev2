import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/fee/data/models/invoice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Card 1 đợt thu học phí. Nút "THANH TOÁN" chỉ hiện khi CONFIRMED;
/// khi PAID hiện chip "Đã thanh toán".
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    required this.invoice,
    required this.onPay,
    super.key,
  });

  final MyInvoiceItem invoice;
  final VoidCallback onPay;

  static final _money = NumberFormat.decimalPattern('vi_VN');
  static final _day = DateFormat('dd/MM/yyyy');

  String _period() {
    final from = invoice.periodFrom;
    final to = invoice.periodTo;
    if (from == null || to == null) return '';
    return 'Kỳ ${_day.format(from)} – ${_day.format(to)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoice.className,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _period(),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${invoice.sessionCount} buổi · '
              '${_money.format(invoice.amount)} ₫',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (invoice.isConfirmed)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onPay,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('THANH TOÁN'),
                    ),
                  ),
                ],
              )
            else if (invoice.isPaid)
              _PaidChip(paidAt: invoice.paidAt),
          ],
        ),
      ),
    );
  }
}

class _PaidChip extends StatelessWidget {
  const _PaidChip({this.paidAt});

  final DateTime? paidAt;

  static final _day = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final label = paidAt == null
        ? 'Đã thanh toán'
        : 'Đã thanh toán ${_day.format(paidAt!)}';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.14),
        borderRadius: AppRadii.rmd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
