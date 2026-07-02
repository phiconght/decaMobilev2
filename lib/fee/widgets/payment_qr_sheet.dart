import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/fee/data/models/invoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Bottom sheet hiển thị QR VietQR + thông tin chuyển khoản.
///
/// Mở qua [AppBottomSheet.show]. Nút copy = đường dự phòng khi app ngân hàng
/// không quét được QR.
class PaymentQrSheet extends StatelessWidget {
  const PaymentQrSheet({required this.qr, super.key});

  final InvoiceQr qr;

  static final _money = NumberFormat.decimalPattern('vi_VN');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'Quét mã để thanh toán',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.rlg,
                border: Border.all(color: theme.dividerColor),
              ),
              child: QrImageView(
                data: qr.qrPayload,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _QrRow(
            label: 'Ngân hàng',
            value: qr.bankName,
          ),
          _QrRow(
            label: 'Số TK',
            value: qr.accountNumber,
            copyable: true,
          ),
          _QrRow(
            label: 'Chủ TK',
            value: qr.accountName,
          ),
          _QrRow(
            label: 'Số tiền',
            value: '${_money.format(qr.amount)} ₫',
            copyValue: qr.amount.toString(),
            copyable: true,
          ),
          _QrRow(
            label: 'Nội dung CK',
            value: qr.paymentCode,
            copyable: true,
            highlight: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: AppRadii.rmd,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Giữ nguyên nội dung chuyển khoản để hệ thống đối chiếu.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _QrRow extends StatelessWidget {
  const _QrRow({
    required this.label,
    required this.value,
    this.copyValue,
    this.copyable = false,
    this.highlight = false,
  });

  final String label;
  final String value;

  /// Giá trị thực để copy (nếu khác [value] đã format).
  final String? copyValue;
  final bool copyable;
  final bool highlight;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: copyValue ?? value));
    if (context.mounted) {
      AppSnackBar.success(context, 'Đã sao chép');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? theme.colorScheme.primary : null,
              ),
            ),
          ),
          if (copyable)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Sao chép',
              onPressed: () => _copy(context),
            ),
        ],
      ),
    );
  }
}
