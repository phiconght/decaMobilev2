import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// SnackBar thong nhat: error / success / info — co icon + mau ngu nghia.
abstract final class AppSnackBar {
  static void error(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    _show(context, message, Icons.error_outline, scheme.error, scheme.onError);
  }

  static void success(BuildContext context, String message) {
    _show(context, message, Icons.check_circle_outline, AppColors.success,
        Colors.white);
  }

  static void info(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    _show(context, message, Icons.info_outline, scheme.inverseSurface,
        scheme.onInverseSurface);
  }

  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color background,
    Color foreground,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          content: Row(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: TextStyle(color: foreground)),
              ),
            ],
          ),
        ),
      );
  }
}
