import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:deca_mobile/courses/data/models/course.dart';

/// Hop dong du lieu khoa hoc (Repository pattern — co the co nhieu cai dat).
abstract class CoursesRepository {
  Future<List<Course>> fetchCourses();

  /// Cay noi dung 1 khoa: chuyen de -> buoi hoc + de thi.
  /// [studentId] BAT BUOC voi PARENT (co the co nhieu con); STUDENT bo qua.
  Future<ClassOutline> fetchOutline(int classId, {int? studentId});
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

  @override
  Future<ClassOutline> fetchOutline(int classId, {int? studentId}) async {
    final data = await _api.get(
      '/api/v1/classes/$classId/outline',
      query: studentId == null ? null : {'studentId': '$studentId'},
    );
    return ClassOutline.fromJson(data! as Map<String, dynamic>);
  }
}
