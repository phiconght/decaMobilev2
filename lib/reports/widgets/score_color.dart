import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Mau diem theo ti le 0..1: >=0.8 dat (sage), >=0.5 trung binh (gold),
/// con lai (coral).
Color scoreColor(double ratio) {
  if (ratio >= 0.8) return AppColors.success;
  if (ratio >= 0.5) return AppColors.warningDark;
  return AppColors.danger;
}
