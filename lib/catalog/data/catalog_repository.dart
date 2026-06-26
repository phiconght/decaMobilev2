import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/courses/data/models/course.dart';

/// Hop dong du lieu tat ca khoa hoc (Repository pattern).
// ignore: one_member_abstracts
abstract class CatalogRepository {
  Future<List<Course>> fetchAllCourses();
}

/// Cai dat — hien tra MOCK; khi BE san sang doi sang GET /api/v1/classes
class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._api);

  // ignore: unused_field — se dung khi noi endpoint that
  final ApiClient _api;

  @override
  Future<List<Course>> fetchAllCourses() async {
    // TODO(be): thay bang GET /api/v1/classes khi co endpoint.
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
    Course(
      id: 4,
      code: 'CHO12-00004L',
      name: 'Hóa học 12A',
      subjectName: 'Hóa học',
      gradeLevel: 'Khối 12',
      status: 'ACTIVE',
      startDate: DateTime(2026),
      endDate: DateTime(2026, 6, 30),
    ),
    const Course(
      id: 5,
      code: 'CSI11-00005L',
      name: 'Sinh học 11A',
      subjectName: 'Sinh học',
      gradeLevel: 'Khối 11',
      status: 'ACTIVE',
    ),
  ];
}
