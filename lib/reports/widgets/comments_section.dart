import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _roleLabel = {
  'TEACHER': 'Giáo viên',
  'ASSISTANT': 'Trợ giảng',
  'PARENT': 'Phụ huynh',
  'ADMIN': 'Quản trị',
  'EMPLOYEE': 'Nhân viên',
};

/// Khối nhận xét: danh sách + form thêm (nếu canComment).
class CommentsSection extends StatefulWidget {
  const CommentsSection({
    required this.repository,
    required this.studentId,
    required this.classId,
    required this.canComment,
    this.showVisibilityToggle = false,
    super.key,
  });

  final ReportsRepository repository;
  final int studentId;
  final int classId;
  final bool canComment;
  final bool showVisibilityToggle;

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _controller = TextEditingController();
  late Future<List<ReportComment>> _future;
  bool _visible = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.comments(widget.studentId, widget.classId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = widget.repository.comments(widget.studentId, widget.classId);
    });
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await widget.repository.addComment(
        studentId: widget.studentId,
        classId: widget.classId,
        content: text,
        visibleToStudent: _visible,
      );
      _controller.clear();
      _visible = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm nhận xét')),
        );
      }
      _reload();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<ReportComment>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final items = snap.data ?? const <ReportComment>[];
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Chưa có nhận xét.'),
              );
            }
            return Column(
              children: items.map((c) {
                final role = _roleLabel[c.authorRole] ?? c.authorRole;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                            color: theme.colorScheme.primary, width: 3),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(c.authorName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            Chip(
                              label: Text(role,
                                  style: const TextStyle(fontSize: 10)),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            if (!c.visibleToStudent)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Text('(ẩn với HS)',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                              ),
                          ],
                        ),
                        if (c.createdAt != null)
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(c.createdAt!),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        const SizedBox(height: 4),
                        Text(c.content),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        if (widget.canComment) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 2000,
            decoration: const InputDecoration(
              hintText: 'Nhập nhận xét cho học viên...',
              border: OutlineInputBorder(),
            ),
          ),
          Row(
            children: [
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: const Text('Gửi nhận xét'),
              ),
              if (widget.showVisibilityToggle) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Cho học sinh xem',
                        style: TextStyle(fontSize: 13)),
                    value: _visible,
                    onChanged: (v) => setState(() => _visible = v),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
