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

/// Bang mau gan cho tung con.
const List<Color> kChildColors = [
  Color(0xFF2563EB),
  Color(0xFF16A34A),
  Color(0xFFF59E0B),
  Color(0xFF7C3AED),
  Color(0xFFDB2777),
  Color(0xFF0891B2),
  Color(0xFFCA8A04),
  Color(0xFFDC2626),
];
