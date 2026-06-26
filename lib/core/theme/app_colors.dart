import 'package:flutter/material.dart';

/// Bang mau thuong hieu + mau ngu nghia (semantic) dung toan he thong.
///
/// Mau ngu nghia co dinh, KHONG sinh tu seed — de nhat quan trang thai
/// (dat/chua dat, dang hoc/ket thuc...) tren ca light & dark.
abstract final class AppColors {
  /// Mau hat giong sinh ColorScheme (Material 3).
  static const brand = Color(0xFF2563EB);

  static const success = Color(0xFF16A34A); // xanh — dat / dang hoc
  static const warning = Color(0xFFF59E0B); // cam — canh bao / trung binh
  static const danger = Color(0xFFDC2626); // do — loi / chua dat / khoa
  static const info = Color(0xFF2563EB); // xanh duong — thong tin
  static const neutral = Color(0xFF64748B); // xam — khong hoat dong
}
