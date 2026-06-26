import 'package:deca_mobile/core/cubit/collection_cubit.dart';
import 'package:deca_mobile/courses/data/courses_repository.dart';
import 'package:deca_mobile/courses/data/models/course.dart';

class CoursesCubit extends CollectionCubit<Course> {
  CoursesCubit(this._repository);

  final CoursesRepository _repository;

  @override
  Future<List<Course>> readAll() => _repository.fetchCourses();
}
