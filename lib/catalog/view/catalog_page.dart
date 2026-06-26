import 'dart:async';

import 'package:deca_mobile/catalog/cubit/catalog_cubit.dart';
import 'package:deca_mobile/catalog/data/catalog_repository.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/widgets/async_list_view.dart';
import 'package:deca_mobile/courses/data/models/course.dart';
import 'package:deca_mobile/courses/view/course_detail_page.dart';
import 'package:deca_mobile/courses/widgets/course_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Man "Tat ca khoa hoc" — tai su dung CourseCard + CourseDetailPage,
/// chi khac o repository (CatalogRepository lay toan bo lop).
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = CatalogCubit(ctx.read<CatalogRepository>());
        unawaited(cubit.load());
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Tất cả khóa học')),
        body: BlocBuilder<CatalogCubit, DataState<List<Course>>>(
          builder: (context, state) {
            return AsyncListView<Course>(
              state: state,
              onRefresh: context.read<CatalogCubit>().refresh,
              emptyMessage: 'Chưa có khóa học nào.',
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
    );
  }
}
