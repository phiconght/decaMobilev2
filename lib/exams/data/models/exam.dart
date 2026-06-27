/// De thi gan cho 1 lop. Khop `ExamListItem` cua BE.
class Exam {
  const Exam({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.status,
    this.durationMinutes,
    this.publishAt,
    this.endAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) => Exam(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        status: json['status'] as String,
        durationMinutes: json['durationMinutes'] as int?,
        publishAt: _parseDate(json['publishAt']),
        endAt: _parseDate(json['endAt']),
      );

  final int id;
  final String code;
  final String name;
  final String type; // BY_CLASS | SUPPLEMENTARY
  final String status; // ACTIVE | INACTIVE
  final int? durationMinutes;
  final DateTime? publishAt; // thoi diem phat de (ngay bat dau)
  final DateTime? endAt;

  static DateTime? _parseDate(Object? v) =>
      v == null ? null : DateTime.parse(v as String);
}
