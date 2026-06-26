/// Khoa hoc / lop hoc cua hoc sinh. Khop `ClassListItem` cua BE.
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
      );

  final int id;
  final String code;
  final String name;
  final String subjectName;
  final String gradeLevel;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
}
