import 'package:flutter/material.dart';

/// Mot con (hoc vien) cua phu huynh — dung de loc TKB.
class ChildRef {
  const ChildRef({
    required this.studentId,
    required this.studentName,
    required this.color,
  });

  final int studentId;
  final String studentName;
  final Color color;
}

/// Bang mau gan cho tung con. Tranh dai xanh-cobalt de khong lan mau
/// thuong hieu (brand = cobalt #2E43E8 — xem KE_HOACH_TRIEN_KHAI.md §2).
const List<Color> kChildColors = [
  Color(0xFF7C4DFF), // tim
  Color(0xFF00897B), // teal
  Color(0xFFEF8F00), // amber
  Color(0xFFAD1457), // hong dam
  Color(0xFF00ACC1), // cyan (ngha xanh-luc, khac cobalt)
  Color(0xFF43A047), // la
  Color(0xFF6D4C41), // nau
  Color(0xFF8D6E63), // nau am
];
