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

/// Trang chi tiet khoa hoc CONG KHAI — GET /classes/{id}/public.
class ClassPublicDetail {
  const ClassPublicDetail({
    required this.id,
    required this.code,
    required this.name,
    required this.subjectName,
    required this.gradeLevel,
    required this.status,
    required this.deliveryMode,
    required this.paymentType,
    required this.teacherNames,
    required this.enrolled,
    this.startDate,
    this.endDate,
    this.pricePerSession,
    this.coinPrice,
    this.fullPrice,
    this.title,
    this.coverImageUrl,
    this.contentMd,
  });

  factory ClassPublicDetail.fromJson(Map<String, dynamic> json) =>
      ClassPublicDetail(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        subjectName: json['subjectName'] as String,
        gradeLevel: json['gradeLevel'] as String,
        status: json['status'] as String,
        deliveryMode: json['deliveryMode'] as String,
        paymentType: json['paymentType'] as String,
        teacherNames:
            (json['teacherNames'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        enrolled: json['enrolled'] as bool? ?? false,
        startDate: json['startDate'] == null
            ? null
            : DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] == null
            ? null
            : DateTime.parse(json['endDate'] as String),
        pricePerSession: (json['pricePerSession'] as num?)?.toDouble(),
        coinPrice: (json['coinPrice'] as num?)?.toInt(),
        fullPrice: (json['fullPrice'] as num?)?.toDouble(),
        title: json['title'] as String?,
        coverImageUrl: json['coverImageUrl'] as String?,
        contentMd: json['contentMd'] as String?,
      );

  final int id;
  final String code;
  final String name;
  final String subjectName;
  final String gradeLevel;
  final String status;
  final String deliveryMode;
  final String paymentType;
  final List<String> teacherNames;
  final bool enrolled;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? pricePerSession;
  final int? coinPrice;
  final double? fullPrice;
  final String? title;
  final String? coverImageUrl;
  final String? contentMd;

  String get displayTitle => title?.isNotEmpty == true ? title! : name;
}

/// Yeu cau dang ky khoa hoc bang chuyen khoan (khac EnrollResult bang Xu) —
/// xem [CatalogRepository.register]/[CatalogRepository.myRegistration].
class RegistrationResult {
  const RegistrationResult({
    required this.id,
    required this.classId,
    required this.className,
    required this.amount,
    required this.registrationCode,
    required this.status,
    required this.qrPayload,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  factory RegistrationResult.fromJson(Map<String, dynamic> json) =>
      RegistrationResult(
        id: json['id'] as int,
        classId: json['classId'] as int,
        className: json['className'] as String,
        amount: (json['amount'] as num).toDouble(),
        registrationCode: json['registrationCode'] as String,
        status: json['status'] as String,
        qrPayload: json['qrPayload'] as String,
        bankName: json['bankName'] as String,
        accountNumber: json['accountNumber'] as String,
        accountName: json['accountName'] as String,
      );

  final int id;
  final int classId;
  final String className;
  final double amount;
  final String registrationCode;
  final String status;
  final String qrPayload;
  final String bankName;
  final String accountNumber;
  final String accountName;
}

/// Hop dong du lieu danh muc TOAN HE THONG (Repository pattern) — nguon
/// DUY NHAT cho man "Khám phá khóa học" VA khoi marketing Trang chu.
abstract class CatalogRepository {
  Future<List<Course>> fetchAllCourses();

  /// HOC SINH tu dang ky tham gia 1 lop bang Xu — tru Xu + vao lop NGAY.
  /// Nem [ApiException] (BusinessException) neu: khong mo ban qua Xu, da
  /// tham gia roi, khong du Xu, hoac lop khong con nhan dang ky.
  Future<EnrollResult> enroll(int classId);

  /// Trang chi tiet khoa hoc cong khai — bam vao Card mo ra.
  Future<ClassPublicDetail> fetchPublicDetail(int classId);

  /// HOC SINH bam "Đăng ký khóa học" (chuyen khoan thu cong, khac Xu) — tra
  /// lai yeu cau PENDING da co neu bam nhieu lan (idempotent o BE).
  Future<RegistrationResult> register(int classId);

  /// Xem lai yeu cau dang ky (neu co) khi quay lai man chi tiet.
  Future<RegistrationResult?> myRegistration(int classId);
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
    return list.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<EnrollResult> enroll(int classId) async {
    final data = await _api.post('/api/v1/classes/$classId/enroll');
    return EnrollResult.fromJson(data! as Map<String, dynamic>);
  }

  @override
  Future<ClassPublicDetail> fetchPublicDetail(int classId) async {
    final data = await _api.get('/api/v1/classes/$classId/public');
    return ClassPublicDetail.fromJson(data! as Map<String, dynamic>);
  }

  @override
  Future<RegistrationResult> register(int classId) async {
    final data = await _api.post('/api/v1/classes/$classId/register');
    return RegistrationResult.fromJson(data! as Map<String, dynamic>);
  }

  @override
  Future<RegistrationResult?> myRegistration(int classId) async {
    final data = await _api.get('/api/v1/classes/$classId/register/my');
    if (data == null) return null;
    return RegistrationResult.fromJson(data as Map<String, dynamic>);
  }
}
