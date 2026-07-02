import 'package:flutter/material.dart';

/// Bang mau thuong hieu + mau ngu nghia (semantic) dung toan he thong.
///
/// Chu dao DO ruby tren nen TRANG am (xem Mobile_MauSac_DoTrang.md).
/// Mau ngu nghia co dinh, KHONG sinh tu seed — de nhat quan trang thai
/// (dat/chua dat, dang hoc/ket thuc...) tren ca light & dark.
///
/// QUY TAC CHONG LAN MAU:
/// - [brand] do = HANH DONG & THUONG HIEU (nut chinh, link, tab chon).
/// - [danger] do-nau = TRANG THAI XAU (loi/vang/khoa) — luon kem icon.
/// Khong dung brand cho loi, khong dung danger cho nut/hanh dong.
abstract final class AppColors {
  /// Do brick-ruby (da giam bao hoa cho bot choi) — mau hat giong + primary.
  static const brand = Color(0xFFBE2A3D);

  static const success = Color(0xFF1E8E3E); // xanh la tram — dat / dang hoc
  static const warning = Color(0xFFB26A00); // amber dam — canh bao / trung binh
  static const danger = Color(0xFF8C1D18); // do-nau — loi / chua dat / khoa
  static const info = Color(0xFF3A5A80); // xanh thep tram — thong tin
  static const neutral = Color(0xFF7A6E6C); // xam am — khong hoat dong

  /// Vang dong — diem nhan quy (huy hieu diem cao, tag "Hom nay"). Dung < 2%.
  static const gold = Color(0xFFB98A2C);
}
