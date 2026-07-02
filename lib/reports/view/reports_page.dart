import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/reports/view/class_report_page.dart';
import 'package:deca_mobile/reports/view/student_report_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tab "Báo cáo" — điều hướng theo vai trò:
/// STUDENT → báo cáo của mình; PARENT → chọn con; TEACHER → danh sách lớp.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ReportsRepository>();
    final user = context.select((AuthCubit c) => c.state.user);
    final roles = user?.roles ?? const <String>[];

    if (roles.contains('TEACHER') || roles.contains('ASSISTANT')) {
      return _TeacherClasses(repository: repository);
    }
    if (roles.contains('PARENT')) {
      return _ParentReports(repository: repository);
    }
    // STUDENT (mặc định)
    return StudentReportView(
      repository: repository,
      studentId: user?.id ?? 0,
      canComment: false,
    );
  }
}

/// GV: danh sách lớp → mở báo cáo lớp.
class _TeacherClasses extends StatefulWidget {
  const _TeacherClasses({required this.repository});

  final ReportsRepository repository;

  @override
  State<_TeacherClasses> createState() => _TeacherClassesState();
}

class _TeacherClassesState extends State<_TeacherClasses> {
  late Future<List<StudentClassOption>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.myClasses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudentClassOption>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final classes = snap.data ?? const <StudentClassOption>[];
        if (classes.isEmpty) {
          return const Center(child: Text('Bạn chưa được phân công lớp nào.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: classes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final c = classes[i];
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(c.name),
                subtitle: Text('${c.code} · ${c.subjectName}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ClassReportPage(
                      repository: widget.repository,
                      clazz: c,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// PH: chọn con → xem báo cáo (được thêm nhận xét).
class _ParentReports extends StatefulWidget {
  const _ParentReports({required this.repository});

  final ReportsRepository repository;

  @override
  State<_ParentReports> createState() => _ParentReportsState();
}

class _ParentReportsState extends State<_ParentReports> {
  late Future<List<ChildOption>> _future;
  ChildOption? _selected;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.myChildren();
    _future.then((children) {
      if (mounted && children.isNotEmpty) {
        setState(() => _selected = children.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChildOption>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final children = snap.data ?? const <ChildOption>[];
        if (children.isEmpty) {
          return const Center(child: Text('Chưa liên kết học viên nào.'));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<int>(
                initialValue: _selected?.studentId,
                decoration: const InputDecoration(
                  labelText: 'Chọn con',
                  border: OutlineInputBorder(),
                ),
                items: children
                    .map((c) => DropdownMenuItem(
                          value: c.studentId,
                          child: Text(c.fullName),
                        ))
                    .toList(),
                onChanged: (v) => setState(
                  () => _selected =
                      children.firstWhere((c) => c.studentId == v),
                ),
              ),
            ),
            Expanded(
              child: _selected == null
                  ? const SizedBox.shrink()
                  : StudentReportView(
                      key: ValueKey(_selected!.studentId),
                      repository: widget.repository,
                      studentId: _selected!.studentId,
                      canComment: true,
                    ),
            ),
          ],
        );
      },
    );
  }
}
