import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/courses/data/models/course.dart';

/// Hop dong du lieu khoa hoc (Repository pattern — co the co nhieu cai dat).
// ignore: one_member_abstracts
abstract class CoursesRepository {
  Future<List<Course>> fetchCourses();
}

/// Cai dat — hien tra MOCK; doi sang BE khi co endpoint cho hoc sinh.
class CoursesRepositoryImpl implements CoursesRepository {
  const CoursesRepositoryImpl(this._api);

  // ignore: unused_field — se dung khi noi endpoint that
  final ApiClient _api;

  @override
  Future<List<Course>> fetchCourses() async {
    // TODO(be): thay mock bang GET /api/v1/me/courses khi BE san sang.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _mock;
  }

  static final List<Course> _mock = [
    Course(
      id: 1,
      code: 'CTO10-00001L',
      name: 'Toán 10A1',
      subjectName: 'Toán',
      gradeLevel: 'Khối 10',
      status: 'ACTIVE',
      startDate: DateTime(2026, 2),
      endDate: DateTime(2026, 5, 30),
    ),
    Course(
      id: 2,
      code: 'CLY11-00002L',
      name: 'Vật lý 11B',
      subjectName: 'Vật lý',
      gradeLevel: 'Khối 11',
      status: 'INACTIVE',
      startDate: DateTime(2025, 9),
      endDate: DateTime(2026, 1, 15),
    ),
    const Course(
      id: 3,
      code: 'CAN10-00003L',
      name: 'Tiếng Anh 10C',
      subjectName: 'Tiếng Anh',
      gradeLevel: 'Khối 10',
      status: 'ACTIVE',
    ),
  ];
}
