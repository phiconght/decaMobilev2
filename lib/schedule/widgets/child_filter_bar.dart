import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/schedule/data/models/child_ref.dart';
import 'package:flutter/material.dart';

/// Thanh loc theo con (hoc vien) cua phu huynh.
class ChildFilterBar extends StatelessWidget {
  const ChildFilterBar({
    required this.children,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<ChildRef> children;
  final int? selected;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Tất cả'),
            selected: selected == null,
            onSelected: (_) => onSelect(null),
          ),
          for (final child in children) ...[
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              avatar: CircleAvatar(
                radius: 8,
                backgroundColor: child.color,
              ),
              label: Text(child.studentName),
              selected: selected == child.studentId,
              onSelected: (_) => onSelect(child.studentId),
            ),
          ],
        ],
      ),
    );
  }
}
