import 'package:deca_mobile/catalog/data/catalog_repository.dart';
import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Bottom sheet QR đăng ký khóa học bằng chuyển khoản — cùng mẫu với
/// [PaymentQrSheet] của module Học phí, khác ở chỗ nội dung CK là mã đăng ký
/// (chưa gắn với 1 đợt thu/học viên đã ghi danh nào).
class RegistrationQrSheet extends StatelessWidget {
  const RegistrationQrSheet({required this.registration, super.key});

  final RegistrationResult registration;

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
            'Quét mã để đăng ký',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
                data: registration.qrPayload,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _QrRow(label: 'Ngân hàng', value: registration.bankName),
          _QrRow(
            label: 'Số TK',
            value: registration.accountNumber,
            copyable: true,
          ),
          _QrRow(label: 'Chủ TK', value: registration.accountName),
          _QrRow(
            label: 'Số tiền',
            value: '${_money.format(registration.amount)} ₫',
            copyValue: registration.amount.toStringAsFixed(0),
            copyable: true,
          ),
          _QrRow(
            label: 'Nội dung CK',
            value: registration.registrationCode,
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
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Giữ nguyên nội dung chuyển khoản để Admin đối chiếu và '
                    'ghi danh trong 24h.',
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
