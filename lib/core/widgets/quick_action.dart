import 'package:flutter/material.dart';

/// Mo ta mot nut tien ich trong QuickActionStrip.
///
/// [builder] la trang se duoc Navigator.push khi tap.
/// Khi [enabled] = false hoac [builder] = null, tap se hien trang "Sap ra mat".
class QuickAction {
  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    this.builder,
    this.enabled = true,
  });

  final String id;
  final String label;
  final IconData icon;
  final WidgetBuilder? builder;
  final bool enabled;
}
