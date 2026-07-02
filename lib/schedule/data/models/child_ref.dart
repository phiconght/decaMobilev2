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

/// Bang mau gan cho tung con. Tranh dai do-hong de khong lan mau thuong hieu.
const List<Color> kChildColors = [
  Color(0xFF3949AB), // indigo
  Color(0xFF00897B), // teal
  Color(0xFFEF8F00), // amber
  Color(0xFF8E24AA), // tim
  Color(0xFF0288D1), // cyan
  Color(0xFF43A047), // la
  Color(0xFF6D4C41), // nau
  Color(0xFF546E7A), // xam xanh
];
