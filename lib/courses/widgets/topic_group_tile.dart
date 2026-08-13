import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:flutter/material.dart';

/// Mot nhom CHUYEN DE trong cay noi dung khoa hoc: header in dam/in hoa,
/// mo ra la danh sach buoi hoc roi den de thi cua chuyen de do.
///
/// Dung [ExpansionTile] (khong phai GestureDetector tran) de screen reader
/// tu doc duoc trang thai dong/mo — SPEC §2.5-4.
class TopicGroupTile extends StatelessWidget {
  const TopicGroupTile({
    required this.group,
    required this.sessionBuilder,
    required this.examBuilder,
    this.initiallyExpanded = false,
    super.key,
  });

  final OutlineTopicGroup group;
  final Widget Function(OutlineSession session) sessionBuilder;
  final Widget Function(OutlineExam exam) examBuilder;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    // Tong so de thi = de gan RIENG tung buoi + de "roi" cap chuyen de.
    final totalExamCount = group.exams.length +
        group.sessions.fold<int>(0, (sum, s) => sum + s.exams.length);
    final counts = <String>[
      if (group.sessions.isNotEmpty) '${group.sessions.length} buổi',
      if (totalExamCount > 0) '$totalExamCount đề thi',
    ].join(' · ');

    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
      title: Text(
        // Nhom "Chua phan chuyen de" giu chu thuong: no la nhan he thong,
        // in hoa se lam no tranh chap thi giac voi cac chuyen de that.
        group.isUnassigned
            ? group.displayName
            : group.displayName.toUpperCase(),
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: group.isUnassigned ? muted : null,
        ),
      ),
      subtitle: counts.isEmpty
          ? null
          : Text(
              counts,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
      children: [
        // De thi cua RIENG 1 buoi da duoc ve GON ngay trong the buoi do
        // (ExamMiniRow, xem CourseSessionTile) — o day chi can render buoi.
        ...group.sessions.map(sessionBuilder),
        // De thi KHONG gan buoi cu the (legacy, chi thuoc chuyen de) van don
        // rieng cuoi nhom — khong the noi vao buoi nao.
        if (group.exams.isNotEmpty) ...[
          if (group.sessions.isNotEmpty) const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Text(
              // Trong nhom "chua phan chuyen de", buoi hoc va de thi la 2 loai
              // khac han nhau -> tach nhan de khong don chung mot ro (§3.3).
              group.isUnassigned ? 'Đề thi khác' : 'Đề thi',
              style: theme.textTheme.labelMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...group.exams.map(examBuilder),
        ],
      ],
    );
  }
}
