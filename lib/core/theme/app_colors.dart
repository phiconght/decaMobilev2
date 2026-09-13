import 'package:flutter/material.dart';

/// Bang mau thuong hieu + mau ngu nghia (semantic) dung toan he thong.
///
/// Chu dao COBALT tren nen GIAY AM (xem ThietKe/Mobile/KE_HOACH_TRIEN_KHAI.md §2).
/// Mau ngu nghia co dinh, KHONG sinh tu seed — de nhat quan trang thai
/// (dat/chua dat, dang hoc/ket thuc...) tren ca light & dark.
abstract final class AppColors {
  // Nen giay am + card. Sang hon ban goc 0xFFF7F4EC (phan hoi nguoi dung
  // 13/09/2026: nen qua toi) — khop voi WEB/theme/tokens.ts `paper`.
  static const paper = Color(0xFFFAFAF5);
  static const card = Color(0xFFFFFFFF);
  static const cardWarm = Color(0xFFFFFDF8);

  // Chu.
  static const ink = Color(0xFF1C1B2E);
  static const inkSoft = Color(0xFF6E6C82);
  static const inkFaint = Color(0xFFA7A4B8);

  // Vien.
  static const line = Color(0xFFE9E4D8);
  static const lineSoft = Color(0xFFEFEBE1);

  /// PRIMARY — nut chinh, active tab, link.
  static const brand = Color(0xFF2E43E8);
  static const brandDark = Color(0xFF1E2FB8);
  static const brandTint = Color(0xFFEBEDFC);

  /// DANGER/ACCENT — loi, vang, gia khuyen mai, nut "Thoat".
  static const danger = Color(0xFFFF5D6C);
  static const dangerTint = Color(0xFFFFEAEC);

  /// WARNING — cho duyet, canh bao, Xu/coin.
  static const warning = Color(0xFFF2A93B);
  static const warningDark = Color(0xFFC97F1B);
  static const warningTint = Color(0xFFFBF0DC);

  /// SUCCESS — dat/co mat/da thanh toan/dung.
  static const success = Color(0xFF2FAE7A);
  static const successTint = Color(0xFFE7F7EF);

  /// INFO — trung tinh, dung khi khong co semantic ro rang.
  static const info = brand;

  /// Khong hoat dong / trung lap.
  static const neutral = Color(0xFF7A6E6C);
}
