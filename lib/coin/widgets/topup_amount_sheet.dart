import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const _presetsVnd = [50000, 100000, 200000, 500000];

/// Bottom sheet nhập số tiền (VND) muốn nạp Xu — tỷ lệ cố định 1.000đ = 1 Xu.
/// Trả về số tiền VND đã chọn, hoặc null nếu huỷ.
class TopupAmountSheet extends StatefulWidget {
  const TopupAmountSheet({super.key});

  @override
  State<TopupAmountSheet> createState() => _TopupAmountSheetState();
}

class _TopupAmountSheetState extends State<TopupAmountSheet> {
  final _ctrl = TextEditingController();
  static final _money = NumberFormat.decimalPattern('vi_VN');

  int? get _amount {
    final digits = _ctrl.text.replaceAll(RegExp('[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = _amount;
    final coins = amount != null ? amount ~/ 1000 : null;
    final valid = amount != null && amount >= 10000;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'Nạp Xu bằng chuyển khoản',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tỷ lệ 1.000đ = 1 Xu. Tối thiểu 10.000đ.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: '0',
            suffixText: 'đ',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: [
            for (final p in _presetsVnd)
              ActionChip(
                label: Text(_money.format(p)),
                onPressed: () => setState(() => _ctrl.text = p.toString()),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (coins != null)
          Text(
            'Nhận được: ${_money.format(coins)} Xu',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Tạo yêu cầu nạp Xu',
          onPressed: valid ? () => Navigator.pop(context, amount) : null,
        ),
      ],
    );
  }
}
