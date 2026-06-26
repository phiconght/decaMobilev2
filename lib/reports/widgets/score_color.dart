import 'package:flutter/material.dart';

/// Mau diem theo ti le 0..1: >=0.8 dat (xanh), >=0.5 trung binh (cam),
/// con lai (do).
Color scoreColor(double ratio) {
  if (ratio >= 0.8) return Colors.green;
  if (ratio >= 0.5) return Colors.orange;
  return Colors.red;
}
