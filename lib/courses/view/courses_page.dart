import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/widgets/async_list_view.dart';
import 'package:deca_mobile/courses/cubit/courses_cubit.dart';
import 'package:deca_mobile/courses/data/models/course.dart';
import 'package:deca_mobile/courses/view/course_detail_page.dart';
import 'package:deca_mobile/courses/widgets/course_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesCubit, DataState<List<Course>>>(
      builder: (context, state) {
        return AsyncListView<Course>(
          state: state,
          onRefresh: context.read<CoursesCubit>().refresh,
          emptyMessage: 'Bạn chưa được ghi danh vào khóa học nào.',
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
    );
  }
}
