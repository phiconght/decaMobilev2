/// Trang thai cham cong day cua GV trong 1 buoi (khop TeacherAttendanceStatus BE
/// + CHUA_CHAM do BE tra khi chua co dong).
enum TeacherAttendanceStatus { dungGio, vaoTre, vang, chuaCham }

TeacherAttendanceStatus teacherAttendanceStatusFromString(String? s) =>
    switch (s) {
      'DUNG_GIO' => TeacherAttendanceStatus.dungGio,
      'VAO_TRE' => TeacherAttendanceStatus.vaoTre,
      'VANG' => TeacherAttendanceStatus.vang,
      _ => TeacherAttendanceStatus.chuaCham,
    };

/// Nhan tieng Viet ngan cho chip/badge.
String teacherAttendanceLabel(TeacherAttendanceStatus s) => switch (s) {
      TeacherAttendanceStatus.dungGio => 'Đúng giờ',
      TeacherAttendanceStatus.vaoTre => 'Vào trễ',
      TeacherAttendanceStatus.vang => 'Vắng',
      TeacherAttendanceStatus.chuaCham => 'Chưa chấm công',
    };

/// 1 dong bao cao cong: 1 buoi day (khop TeacherWorkItem.java).
class TeacherWorkItem {
  const TeacherWorkItem({
    required this.sessionId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.className,
    required this.status,
    this.roomName,
    this.durationMinutes,
    this.note,
  });

  factory TeacherWorkItem.fromJson(Map<String, dynamic> json) => TeacherWorkItem(
        sessionId: (json['sessionId'] as num).toInt(),
        date: DateTime.parse(json['date'] as String),
        startTime: _hhmm(json['startTime'] as String?),
        endTime: _hhmm(json['endTime'] as String?),
        className: json['className'] as String? ?? '',
        roomName: json['roomName'] as String?,
        durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
        status: teacherAttendanceStatusFromString(json['status'] as String?),
        note: json['note'] as String?,
      );

  final int sessionId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String className;
  final String? roomName;
  final int? durationMinutes;
  final TeacherAttendanceStatus status;
  final String? note;

  static String _hhmm(String? t) =>
      t == null ? '' : (t.length >= 5 ? t.substring(0, 5) : t);
}

/// Tong ket cong (khop TeacherWorkReport.Summary).
class TeacherWorkSummary {
  const TeacherWorkSummary({
    required this.totalSessions,
    required this.dungGio,
    required this.vaoTre,
    required this.vang,
    required this.chuaCham,
    required this.totalTaughtMinutes,
  });

  factory TeacherWorkSummary.fromJson(Map<String, dynamic> json) =>
      TeacherWorkSummary(
        totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
        dungGio: (json['dungGio'] as num?)?.toInt() ?? 0,
        vaoTre: (json['vaoTre'] as num?)?.toInt() ?? 0,
        vang: (json['vang'] as num?)?.toInt() ?? 0,
        chuaCham: (json['chuaCham'] as num?)?.toInt() ?? 0,
        totalTaughtMinutes: (json['totalTaughtMinutes'] as num?)?.toInt() ?? 0,
      );

  final int totalSessions;
  final int dungGio;
  final int vaoTre;
  final int vang;
  final int chuaCham;
  final int totalTaughtMinutes;

  /// Gio day dinh dang '25.5h' hoac '25h'.
  String get taughtHours {
    final h = totalTaughtMinutes / 60;
    return h == h.roundToDouble()
        ? '${h.toInt()}h'
        : '${h.toStringAsFixed(1)}h';
  }
}

/// Bao cao cong GV (khop TeacherWorkReport.java).
class TeacherWorkReport {
  const TeacherWorkReport({required this.summary, required this.items});

  factory TeacherWorkReport.fromJson(Map<String, dynamic> json) =>
      TeacherWorkReport(
        summary: TeacherWorkSummary.fromJson(
          json['summary'] as Map<String, dynamic>,
        ),
        items: ((json['items'] as List?) ?? const [])
            .map((e) => TeacherWorkItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final TeacherWorkSummary summary;
  final List<TeacherWorkItem> items;
}
