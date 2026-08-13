import 'package:deca_mobile/exams/data/models/exam.dart';
import 'package:deca_mobile/exams/view/exam_paper_page.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/reports/view/student_exam_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// "Bài phụ huynh giao" — TOÀN BỘ đề luyện tập được giao cho HV, gộp từ MỌI
/// khóa (không phải chỉ 1 khóa) — nguồn `GET /students/{id}/practice-assignments`.
///
/// Trước đây đề luyện tập chỉ nằm lẫn trong danh sách đề thi của TỪNG khóa
/// riêng lẻ nên rất khó tìm (phản hồi người dùng 11/08/2026: "vào tài khoản
/// học sinh rất khó tìm bài được phụ huynh giao"). Màn này gom 1 chỗ.
class PracticeAssignmentsPage extends StatefulWidget {
  const PracticeAssignmentsPage({
    required this.repository,
    required this.studentId,
    super.key,
  });

  final ReportsRepository repository;
  final int studentId;

  @override
  State<PracticeAssignmentsPage> createState() =>
      _PracticeAssignmentsPageState();
}

class _PracticeAssignmentsPageState extends State<PracticeAssignmentsPage> {
  late Future<List<PracticeAssignmentItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.myPracticeAssignments(widget.studentId);
  }

  Future<void> _refresh() async {
    final f = widget.repository.myPracticeAssignments(widget.studentId);
    setState(() => _future = f);
    await f;
  }

  void _open(PracticeAssignmentItem item) {
    if (item.isSubmitted) {
      // Da nop -> xem lai ket qua (dung man chi tiet bai thi co san).
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StudentExamDetailPage(
            repository: widget.repository,
            studentId: widget.studentId,
            classId: item.classId,
            exam: RecentExam(
              examStudentId: item.assignmentId,
              examId: item.examId,
              examCode: item.examCode,
              examName: item.examName,
              subjectName: '',
              submittedAt: null,
              score: null,
              maxScore: null,
              classId: item.classId,
              className: item.className,
            ),
          ),
        ),
      );
      return;
    }
    // Chua nop -> vao lam bai ngay.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExamPaperPage(
          exam: Exam(
            id: item.examId,
            code: item.examCode,
            name: item.examName,
            type: 'SUPPLEMENTARY',
            status: 'ACTIVE',
            durationMinutes: item.durationMinutes,
            endAt: item.deadline,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài phụ huynh giao')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<PracticeAssignmentItem>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('Không tải được danh sách bài tập.'),
                    ),
                  ),
                ],
              );
            }
            final items = snap.data ?? const <PracticeAssignmentItem>[];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Chưa có bài tập nào được giao.\nKhi phụ huynh giao '
                        'bài luyện tập, bài sẽ xuất hiện ở đây.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _AssignmentTile(
                item: items[i],
                onTap: () => _open(items[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({required this.item, required this.onTap});

  final PracticeAssignmentItem item;
  final VoidCallback onTap;

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submitted = item.isSubmitted;
    final overdue = !submitted &&
        item.deadline != null &&
        item.deadline!.isBefore(DateTime.now());

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          submitted ? Icons.task_alt : Icons.assignment_outlined,
          color: submitted
              ? theme.colorScheme.primary
              : (overdue ? theme.colorScheme.error : null),
        ),
        title: Text(item.examName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.className}'
              '${item.topicName != null ? ' · Chương: ${item.topicName}' : ''}',
            ),
            Text(
              '${item.numQuestions} câu'
              '${item.durationMinutes != null ? ' · ${item.durationMinutes} phút' : ''}'
              '${item.deadline != null ? ' · Hạn: ${_dateFmt.format(item.deadline!)}' : ''}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            submitted ? 'Đã nộp' : (overdue ? 'Quá hạn' : 'Chưa làm'),
          ),
          backgroundColor: submitted
              ? theme.colorScheme.primaryContainer
              : (overdue ? theme.colorScheme.errorContainer : null),
        ),
        isThreeLine: true,
      ),
    );
  }
}
