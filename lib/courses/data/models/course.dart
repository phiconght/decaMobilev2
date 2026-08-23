/// Khoa hoc / lop hoc. Khop `ClassListItem` (courses/khóa của tôi) va
/// `ClassCatalogItem` (danh muc toan he thong — GET /api/v1/classes/catalog,
/// dung chung cho "Khám phá khóa học" VA khoi marketing Trang chu, dam bao
/// 2 noi luon dong bo 1 nguon du lieu that).
class Course {
  const Course({
    required this.id,
    required this.code,
    required this.name,
    required this.subjectName,
    required this.gradeLevel,
    required this.status,
    this.startDate,
    this.endDate,
    this.pricePerSession,
    this.teacherNames = const [],
    this.coinPrice,
    this.enrolled = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        subjectName: json['subjectName'] as String,
        gradeLevel: json['gradeLevel'] as String,
        status: json['status'] as String,
        startDate: json['startDate'] == null
            ? null
            : DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] == null
            ? null
            : DateTime.parse(json['endDate'] as String),
        pricePerSession: (json['pricePerSession'] as num?)?.toDouble(),
        teacherNames: (json['teacherNames'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        coinPrice: (json['coinPrice'] as num?)?.toInt(),
        enrolled: json['enrolled'] as bool? ?? false,
      );

  final int id;
  final String code;
  final String name;
  final String subjectName;
  final String gradeLevel;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  /// Don gia moi buoi (VND) — null neu BE khong tra (vd nguon cu khong co).
  final double? pricePerSession;

  /// Ten GV phu trach lop (co the nhieu GV/tro giang). Rong = chua phan cong.
  final List<String> teacherNames;

  /// Gia Xu de HS tu dang ky. Null/0 = khong mo ban qua Xu.
  final int? coinPrice;

  /// Nguoi dang dang nhap (HS) da tham gia lop nay chua.
  final bool enrolled;
}
