/// Mot buoi hoc trong thoi khoa bieu. Khop DTO BE (khi co endpoint).
class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.className,
    required this.subjectName,
    required this.gradeLevel,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.teacherName,
    required this.status,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
        id: json['id'] as int,
        className: json['className'] as String,
        subjectName: json['subjectName'] as String,
        gradeLevel: json['gradeLevel'] as String,
        weekday: json['weekday'] as int,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
        room: json['room'] as String,
        teacherName: json['teacherName'] as String,
        status: json['status'] as String,
      );

  final int id;
  final String className;
  final String subjectName;
  final String gradeLevel;
  final int weekday; // 1=T2 ... 7=CN
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final String room;
  final String teacherName;
  final String status; // ACTIVE | INACTIVE

  static String weekdayLabel(int w) {
    const labels = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return (w >= 1 && w <= 7) ? labels[w] : '?';
  }
}
