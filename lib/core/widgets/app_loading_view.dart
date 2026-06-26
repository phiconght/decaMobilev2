import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Skeleton danh sach luc dang tai lan dau.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({this.itemCount = 5, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Container(
        height: 92,
        decoration: BoxDecoration(
          color: base,
          borderRadius: AppRadii.rlg,
        ),
      ),
    );
  }
}
