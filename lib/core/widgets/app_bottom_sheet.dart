import 'package:flutter/material.dart';

/// Bottom sheet chuan (bo goc tren, drag handle tu theme).
abstract final class AppBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: child,
        ),
      ),
    );
  }
}
