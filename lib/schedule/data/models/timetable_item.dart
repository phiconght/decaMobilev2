/// Trang thai buoi hoc (khop SessionStatus BE).
enum SessionStatus { planned, cancelled, done }

/// Trang thai diem danh cua HV trong 1 buoi (khop AttendanceStatus BE).
enum AttendanceStatus { chuaCheckin, coMat, tre, vang, coPhep }

SessionStatus sessionStatusFromString(String? s) => switch (s) {
      'CANCELLED' => SessionStatus.cancelled,
      'DONE' => SessionStatus.done,
      _ => SessionStatus.planned,
    };

AttendanceStatus? attendanceStatusFromString(String? s) => switch (s) {
      'CO_MAT' => AttendanceStatus.coMat,
      'TRE' => AttendanceStatus.tre,
      'VANG' => AttendanceStatus.vang,
      'CO_PHEP' => AttendanceStatus.coPhep,
      'CHUA_CHECKIN' => AttendanceStatus.chuaCheckin,
      _ => null,
    };

/// Ma BE cho PATCH /attendance.
String attendanceStatusToApi(AttendanceStatus s) => switch (s) {
      AttendanceStatus.coMat => 'CO_MAT',
      AttendanceStatus.tre => 'TRE',
      AttendanceStatus.vang => 'VANG',
      AttendanceStatus.coPhep => 'CO_PHEP',
      AttendanceStatus.chuaCheckin => 'CHUA_CHECKIN',
    };

/// Mot buoi trong thoi khoa bieu — khop record TimetableItem.java.
class TimetableItem {
  const TimetableItem({
    required this.sessionId,
    required this.classId,
    required this.className,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.subjectName,
    this.gradeLevel,
    this.roomId,
    this.roomName,
    this.branchName,
    this.teacherId,
    this.teacherName,
    this.studentId,
    this.studentName,
    this.attendanceStatus,
    this.onLeave = false,
    this.teacherAttendanceStatus,
  });

  factory TimetableItem.fromJson(Map<String, dynamic> json) {
    return TimetableItem(
      sessionId: json['sessionId'] as int,
      classId: json['classId'] as int,
      className: json['className'] as String,
      subjectName: json['subjectName'] as String?,
      gradeLevel: json['gradeLevel'] as String?,
      date: DateTime.parse(json['date'] as String),
      startTime: _hhmm(json['startTime'] as String),
      endTime: _hhmm(json['endTime'] as String),
      roomId: json['roomId'] as int?,
      roomName: json['roomName'] as String?,
      branchName: json['branchName'] as String?,
      teacherId: json['teacherId'] as int?,
      teacherName: json['teacherName'] as String?,
      status: sessionStatusFromString(json['status'] as String?),
      studentId: json['studentId'] as int?,
      studentName: json['studentName'] as String?,
      attendanceStatus:
          attendanceStatusFromString(json['attendanceStatus'] as String?),
      onLeave: (json['onLeave'] as bool?) ?? false,
      teacherAttendanceStatus: json['teacherAttendanceStatus'] as String?,
    );
  }

  final int sessionId;
  final int classId;
  final String className;
  final String? subjectName;
  final String? gradeLevel;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int? roomId;
  final String? roomName;
  final String? branchName;
  final int? teacherId;
  final String? teacherName;
  final SessionStatus status;
  final int? studentId;
  final String? studentName;
  final AttendanceStatus? attendanceStatus;
  final bool onLeave;

  /// Trang thai cham cong GV (view TEACHER): 'DUNG_GIO'|'VAO_TRE'|'VANG', null neu chua cham.
  final String? teacherAttendanceStatus;

  /// 'mon khoi' (vd 'Toan 10') hoac fallback ten lop.
  String get title {
    final subject = subjectName;
    if (subject != null && subject.isNotEmpty) {
      final grade = gradeLevel;
      return (grade != null && grade.isNotEmpty) ? '$subject $grade' : subject;
    }
    return className;
  }

  static String _hhmm(String t) => t.length >= 5 ? t.substring(0, 5) : t;
}
