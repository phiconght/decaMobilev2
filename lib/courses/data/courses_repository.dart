import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/courses/data/models/course.dart';

/// Hop dong du lieu khoa hoc (Repository pattern — co the co nhieu cai dat).
// ignore: one_member_abstracts
abstract class CoursesRepository {
  Future<List<Course>> fetchCourses();
}

/// Cai dat — lay danh sach lop ma hoc vien dang dang nhap da duoc ghi danh
/// tu BE: GET /api/v1/classes/me (tra `ApiResponse` boc danh sach ClassListItem).
class CoursesRepositoryImpl implements CoursesRepository {
  const CoursesRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<Course>> fetchCourses() async {
    final data = await _api.get('/api/v1/classes/me');
    final list = (data as List<dynamic>?) ?? const [];
    return list
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
