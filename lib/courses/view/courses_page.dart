import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/async_list_view.dart';
import 'package:deca_mobile/courses/cubit/courses_cubit.dart';
import 'package:deca_mobile/courses/data/models/course.dart';
import 'package:deca_mobile/courses/view/course_detail_page.dart';
import 'package:deca_mobile/courses/widgets/course_card.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:deca_mobile/reports/view/practice_assignments_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Danh sach khoa hoc cua nguoi dung, co o tim kiem (loc cuc bo theo
/// ten / ma / mon / khoi).
class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Course> _filter(List<Course> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q) ||
              c.subjectName.toLowerCase().contains(q) ||
              c.gradeLevel.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.trim().isNotEmpty;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Tìm khóa học theo tên, mã, môn...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: hasQuery
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
        // The "khóa" mặc định gom TOÀN BỘ bài luyện tập phụ huynh giao, gộp
        // từ mọi khóa thật — trước đây phải mở đúng khóa rồi lục tìm trong
        // danh sách đề thi mới thấy, rất khó tìm (phản hồi 11/08/2026).
        // Chỉ hiện cho HV (PH/GV không có bài được giao cho chính họ), và
        // ẩn khi đang tìm kiếm (không phải khóa thật nên không lọc theo tên).
        if (!hasQuery) const _PracticeAssignmentsEntry(),
        Expanded(
          child: BlocBuilder<CoursesCubit, DataState<List<Course>>>(
            builder: (context, state) {
              final filtered = _filter(state.data ?? const []);
              final viewState = DataState<List<Course>>(
                status: state.status,
                data: filtered,
                error: state.error,
              );
              return AsyncListView<Course>(
                state: viewState,
                onRefresh: context.read<CoursesCubit>().refresh,
                emptyMessage: hasQuery
                    ? 'Không tìm thấy khóa học phù hợp.'
                    : 'Bạn chưa được ghi danh vào khóa học nào.',
                itemBuilder: (context, course) => CourseCard(
                  course: course,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CourseDetailPage(course: course),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Thẻ cố định "Bài phụ huynh giao" — chỉ hiện cho HV (người thực sự có bài
/// được giao). PH/GV/Admin xem tab này với dữ liệu khác (hoặc rỗng) nên
/// không có bài của "chính họ" để hiện.
class _PracticeAssignmentsEntry extends StatelessWidget {
  const _PracticeAssignmentsEntry();

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit c) => c.state.user);
    final roles = user?.roles ?? const <String>[];
    if (!roles.contains('STUDENT') || user == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: ListTile(
          leading: const Icon(Icons.assignment_outlined),
          title: const Text('Bài phụ huynh giao'),
          subtitle: const Text('Bài luyện tập được giao riêng cho bạn'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PracticeAssignmentsPage(
                repository: context.read<ReportsRepository>(),
                studentId: user.id,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
