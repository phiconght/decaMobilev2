import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Nut "Giao bài tập" dung chung cho cap khóa/chương/buổi (§10, mở rộng
/// 11/08/2026) — khác voi dropdown "Chương giao bài" o man chi tiet 1 bài
/// thi (`StudentExamDetailPage`, van giu rieng vi co the doi chương): o day
/// pham vi CO DINH theo ngu canh dang xem (khong doi duoc), chi con 1 nut.
///
/// [topicId] null = giao theo "toàn khóa" (BE tu chon chương HV dang yeu
/// nhat). [examId] luon null o day (khong xuat phat tu 1 bài thi cụ thể).
class AssignPracticeButton extends StatefulWidget {
  const AssignPracticeButton({
    required this.repository,
    required this.studentId,
    required this.classId,
    required this.scopeLabel,
    this.topicId,
    this.enabled = true,
    this.disabledReason,
    super.key,
  });

  final ReportsRepository repository;
  final int studentId;
  final int classId;
  final int? topicId;

  /// Mo ta pham vi de hien trong hop thoai xac nhan, vd: "toàn khóa",
  /// 'chương "Khối lượng riêng"', 'buổi "Buổi 1 · Khái niệm..."'.
  final String scopeLabel;

  /// false = an nut thanh dang disabled kem ly do (vd buoi chua gan chuong).
  final bool enabled;
  final String? disabledReason;

  @override
  State<AssignPracticeButton> createState() => _AssignPracticeButtonState();
}

class _AssignPracticeButtonState extends State<AssignPracticeButton> {
  bool _assigning = false;

  Future<void> _assign() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Giao bài tập'),
        content: Text(
          'Hệ thống sẽ chọn 10 câu trong ${widget.scopeLabel} — độ khó/dạng '
          'bài nghiêng về phần con đang yếu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Giao bài'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _assigning = true);
    try {
      final r = await widget.repository.assignPractice(
        widget.studentId,
        widget.classId,
        topicId: widget.topicId,
      );
      if (mounted) _showResult(r);
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  void _showResult(PracticeAssignmentResult r) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đã giao bài tập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.examName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Chuyên đề: ${r.topicName ?? '—'}'),
            Text(
              'Số câu: ${r.numQuestions} — Dễ ${r.easy}/TB ${r.medium}/Khó ${r.hard}',
            ),
            Text('Dạng: TN ${r.multipleChoice}/ĐS ${r.trueFalse}'),
            if (r.deadline != null)
              Text('Hạn: ${DateFormat('dd/MM/yyyy').format(r.deadline!)}'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      final button = FilledButton.tonalIcon(
        onPressed: null,
        icon: const Icon(Icons.assignment_add),
        label: const Text('Giao bài tập'),
      );
      final reason = widget.disabledReason;
      return reason == null ? button : Tooltip(message: reason, child: button);
    }
    return FilledButton.icon(
      onPressed: _assigning ? null : _assign,
      icon: _assigning
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.assignment_add),
      label: const Text('Giao bài tập'),
    );
  }
}
