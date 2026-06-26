import 'package:bloc_test/bloc_test.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/state/view_status.dart';
import 'package:deca_mobile/courses/cubit/courses_cubit.dart';
import 'package:deca_mobile/courses/data/courses_repository.dart';
import 'package:deca_mobile/courses/data/models/course.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCoursesRepository extends Mock implements CoursesRepository {}

void main() {
  late CoursesRepository repository;

  setUp(() => repository = _MockCoursesRepository());

  const course = Course(
    id: 1,
    code: 'CTO10-00001L',
    name: 'Toán 10A1',
    subjectName: 'Toán',
    gradeLevel: 'Khối 10',
    status: 'ACTIVE',
  );

  group('CoursesCubit', () {
    blocTest<CoursesCubit, DataState<List<Course>>>(
      'emits [loading, success] when load succeeds',
      build: () {
        when(() => repository.fetchCourses())
            .thenAnswer((_) async => [course]);
        return CoursesCubit(repository);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<DataState<List<Course>>>()
            .having((s) => s.status, 'status', ViewStatus.loading),
        isA<DataState<List<Course>>>()
            .having((s) => s.status, 'status', ViewStatus.success)
            .having((s) => s.data, 'data', [course]),
      ],
    );

    blocTest<CoursesCubit, DataState<List<Course>>>(
      'emits [loading, failure] when repository throws ApiException',
      build: () {
        when(() => repository.fetchCourses())
            .thenThrow(const NetworkException());
        return CoursesCubit(repository);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<DataState<List<Course>>>()
            .having((s) => s.status, 'status', ViewStatus.loading),
        isA<DataState<List<Course>>>()
            .having((s) => s.status, 'status', ViewStatus.failure)
            .having((s) => s.error, 'error', 'Không kết nối được máy chủ'),
      ],
    );
  });
}
