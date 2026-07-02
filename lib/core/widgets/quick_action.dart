import 'package:flutter/material.dart';

/// Mo ta mot nut tien ich trong QuickActionStrip.
///
/// Thu tu xu ly khi tap: [onTap] (neu co) > [builder] (Navigator.push) >
/// SnackBar "Sap ra mat". [enabled] = false luon hien "Sap ra mat".
class QuickAction {
  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    this.builder,
    this.onTap,
    this.enabled = true,
  });

  final String id;
  final String label;
  final IconData icon;
  final WidgetBuilder? builder;

  /// Hanh dong tuy chinh (vd doi tab). Uu tien truoc [builder].
  final void Function(BuildContext context)? onTap;
  final bool enabled;
}
