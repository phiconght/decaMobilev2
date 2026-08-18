import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Chip mau theo trang thai (ACTIVE/INACTIVE/LOCKED/DISABLED).
///
/// Dung [StatusChip.new] cho ma trang thai co san (BE tra ve); dung
/// [StatusChip.tone] khi can 1 badge nhan tuy y voi mau ngu nghia ro rang
/// (vd "HOT", "Ghim", "Đã dạy"...) — cung 1 cong thuc thi giac (pill,
/// nen 14% + chu dac mau) de dong bo toan app, khong phai tao widget rieng.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key})
      : _label = null,
        _color = null;

  const StatusChip.tone(String label, Color color, {super.key})
      : status = '',
        _label = label,
        _color = color;

  final String status;
  final String? _label;
  final Color? _color;

  @override
  Widget build(BuildContext context) {
    final (label, color) =
        _label != null ? (_label, _color!) : _map(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  (String, Color) _map(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return ('Đang học', AppColors.success);
      case 'INACTIVE':
        return ('Đã kết thúc', AppColors.neutral);
      case 'LOCKED':
        return ('Đã khóa', AppColors.danger);
      case 'DISABLED':
        return ('Vô hiệu', AppColors.neutral);
      default:
        return (status, AppColors.info);
    }
  }
}
