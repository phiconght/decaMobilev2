import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/courses/data/models/course.dart';

/// Ket qua dang ky khoa hoc bang Xu — xem [CatalogRepository.enroll].
class EnrollResult {
  const EnrollResult({
    required this.className,
    required this.coinSpent,
    required this.newBalance,
  });

  factory EnrollResult.fromJson(Map<String, dynamic> json) => EnrollResult(
        className: json['className'] as String,
        coinSpent: json['coinSpent'] as int,
        newBalance: json['newBalance'] as int,
      );

  final String className;
  final int coinSpent;
  final int newBalance;
}

/// Hop dong du lieu danh muc TOAN HE THONG (Repository pattern) — nguon
/// DUY NHAT cho man "Khám phá khóa học" VA khoi marketing Trang chu.
abstract class CatalogRepository {
  Future<List<Course>> fetchAllCourses();

  /// HOC SINH tu dang ky tham gia 1 lop bang Xu — tru Xu + vao lop NGAY.
  /// Nem [ApiException] (BusinessException) neu: khong mo ban qua Xu, da
  /// tham gia roi, khong du Xu, hoac lop khong con nhan dang ky.
  Future<EnrollResult> enroll(int classId);
}

/// GET/POST /api/v1/classes/** — BE module `schoolclass`
/// (xem ThietKe/Mobile/KE_HOACH_TRIEN_KHAI.md).
class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<Course>> fetchAllCourses() async {
    final data = await _api.get('/api/v1/classes/catalog');
    final list = (data as List<dynamic>?) ?? const [];
    return list
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EnrollResult> enroll(int classId) async {
    final data = await _api.post('/api/v1/classes/$classId/enroll');
    return EnrollResult.fromJson(data! as Map<String, dynamic>);
  }
}
