import 'package:deca_mobile/exams/data/models/exam.dart';
import 'package:equatable/equatable.dart';

/// Trang thai buoi hoc — DUNG 3 gia tri, khop `SessionStatus` cua BE.
/// KHONG co `inProgress`: "buoi dang dien ra" duoc suy o client tu ngay,
/// khong phai trang thai trong DB (xem SPEC_KhoaHoc_NoiDung_Mobile §2.2).
enum OutlineSessionStatus { planned, done, cancelled }

OutlineSessionStatus _statusFrom(String? s) => switch (s) {
      'DONE' => OutlineSessionStatus.done,
      'CANCELLED' => OutlineSessionStatus.cancelled,
      _ => OutlineSessionStatus.planned,
    };

/// Cay noi dung khoa hoc: CHUYEN DE -> (buoi hoc + de thi).
/// Mirror `ClassOutlineResponse` cua BE.
class ClassOutline extends Equatable {
  const ClassOutline({
    required this.classId,
    required this.name,
    required this.progress,
    required this.groups,
    this.code,
    this.subjectName,
    this.gradeLevel,
    this.status,
    this.startDate,
    this.endDate,
  });

  factory ClassOutline.fromJson(Map<String, dynamic> json) {
    final rawGroups = (json['groups'] as List<dynamic>?) ?? const [];
    return ClassOutline(
      classId: (json['classId'] as num?)?.toInt() ?? 0,
      code: json['code'] as String?,
      name: json['name'] as String? ?? '',
      subjectName: json['subjectName'] as String?,
      gradeLevel: json['gradeLevel'] as String?,
      status: json['status'] as String?,
      startDate: DateTime.tryParse(json['startDate'] as String? ?? ''),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? ''),
      progress: OutlineProgress.fromJson(
        (json['progress'] as Map<String, dynamic>?) ?? const {},
      ),
      groups: rawGroups
          .map((e) => OutlineTopicGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int classId;
  final String? code;
  final String name;
  final String? subjectName;
  final String? gradeLevel;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final OutlineProgress progress;
  final List<OutlineTopicGroup> groups;

  /// Tong so buoi tren toan khoa (dung cho dong tien do).
  int get totalSessions => progress.totalSessions;

  /// Buoi ke tiep = buoi PLANNED som nhat tinh tu hom nay.
  /// Tra `null` khi khoa da ket thuc (khong con buoi nao phia truoc).
  OutlineSession? nextSession(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    OutlineSession? best;
    for (final g in groups) {
      for (final s in g.sessions) {
        if (s.status != OutlineSessionStatus.planned) continue;
        if (s.date.isBefore(today)) continue;
        if (best == null || s.date.isBefore(best.date)) best = s;
      }
    }
    return best;
  }

  /// Buoi cuoi cung cua khoa — dung lam neo khi khoa da ket thuc.
  OutlineSession? get lastSession {
    OutlineSession? best;
    for (final g in groups) {
      for (final s in g.sessions) {
        if (best == null || s.date.isAfter(best.date)) best = s;
      }
    }
    return best;
  }

  @override
  List<Object?> get props => [classId, name, progress, groups];
}

/// Tien do khoa hoc.
///
/// [attendanceScope] cho biet [attendanceRate] dang noi ve AI — thieu no thi
/// GV se thay "Chuyen can 87%" ma tuong la cua mot hoc vien nao do:
/// `STUDENT` = cua 1 hoc vien · `CLASS` = trung binh lop · `null` = chua tinh
/// duoc (chua co buoi DONE nao).
class OutlineProgress extends Equatable {
  const OutlineProgress({
    required this.totalSessions,
    required this.doneSessions,
    this.attendanceRate,
    this.attendanceScope,
  });

  factory OutlineProgress.fromJson(Map<String, dynamic> json) {
    return OutlineProgress(
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      doneSessions: (json['doneSessions'] as num?)?.toInt() ?? 0,
      attendanceRate: (json['attendanceRate'] as num?)?.toDouble(),
      attendanceScope: json['attendanceScope'] as String?,
    );
  }

  final int totalSessions;
  final int doneSessions;
  final double? attendanceRate;
  final String? attendanceScope;

  bool get isClassScope => attendanceScope == 'CLASS';
  bool get hasStarted => doneSessions > 0;

  @override
  List<Object?> get props =>
      [totalSessions, doneSessions, attendanceRate, attendanceScope];
}

/// [topicId] `null` => nhom "Chua phan chuyen de" (BE luon tra CUOI danh sach).
class OutlineTopicGroup extends Equatable {
  const OutlineTopicGroup({
    required this.sessions,
    required this.exams,
    this.topicId,
    this.topicName,
    this.sortOrder,
  });

  factory OutlineTopicGroup.fromJson(Map<String, dynamic> json) {
    final rawSessions = (json['sessions'] as List<dynamic>?) ?? const [];
    final rawExams = (json['exams'] as List<dynamic>?) ?? const [];
    return OutlineTopicGroup(
      topicId: (json['topicId'] as num?)?.toInt(),
      topicName: json['topicName'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      sessions: rawSessions
          .map((e) => OutlineSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      exams: rawExams
          .map((e) => OutlineExam.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int? topicId;
  final String? topicName;
  final int? sortOrder;
  final List<OutlineSession> sessions;
  final List<OutlineExam> exams;

  bool get isUnassigned => topicId == null;
  bool get isEmpty => sessions.isEmpty && exams.isEmpty;

  String get displayName =>
      isUnassigned ? 'Chưa phân chuyên đề' : (topicName ?? 'Chuyên đề');

  @override
  List<Object?> get props => [topicId, topicName, sessions, exams];
}

class OutlineSession extends Equatable {
  const OutlineSession({
    required this.sessionId,
    required this.date,
    required this.status,
    this.ordinal,
    this.title,
    this.startTime,
    this.endTime,
    this.roomName,
    this.teacherName,
    this.cancelReason,
    this.attendanceStatus,
    this.onLeave = false,
    this.materialCount = 0,
  });

  factory OutlineSession.fromJson(Map<String, dynamic> json) {
    return OutlineSession(
      sessionId: (json['sessionId'] as num?)?.toInt() ?? 0,
      ordinal: (json['ordinal'] as num?)?.toInt(),
      title: json['title'] as String?,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      roomName: json['roomName'] as String?,
      teacherName: json['teacherName'] as String?,
      status: _statusFrom(json['status'] as String?),
      cancelReason: json['cancelReason'] as String?,
      attendanceStatus: json['attendanceStatus'] as String?,
      onLeave: json['onLeave'] as bool? ?? false,
      materialCount: (json['materialCount'] as num?)?.toInt() ?? 0,
    );
  }

  final int sessionId;
  final int? ordinal;
  final String? title;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String? roomName;
  final String? teacherName;
  final OutlineSessionStatus status;
  final String? cancelReason;
  final String? attendanceStatus;
  final bool onLeave;
  final int materialCount;

  /// CHI buoi DONE moi duoc hien huy hieu diem danh.
  ///
  /// KHONG duoc dua vao `attendanceStatus == null` de an: BE tra
  /// `CHUA_CHECKIN` (khac null) cho ca buoi CHUA dien ra, nen loc theo null
  /// se hien "chua diem danh" cho buoi tuong lai. Xem SPEC §2.3.
  bool get showsAttendance =>
      status == OutlineSessionStatus.done && attendanceStatus != null;

  @override
  List<Object?> get props => [sessionId, date, status, attendanceStatus];
}

class OutlineExam extends Equatable {
  const OutlineExam({
    required this.examId,
    required this.name,
    this.code,
    this.type,
    this.status,
    this.publishAt,
    this.endAt,
    this.durationMinutes,
    this.studentStatus,
    this.score,
    this.maxScore,
  });

  factory OutlineExam.fromJson(Map<String, dynamic> json) {
    return OutlineExam(
      examId: (json['examId'] as num?)?.toInt() ?? 0,
      code: json['code'] as String?,
      name: json['name'] as String? ?? '',
      type: json['type'] as String?,
      status: json['status'] as String?,
      publishAt: DateTime.tryParse(json['publishAt'] as String? ?? ''),
      endAt: DateTime.tryParse(json['endAt'] as String? ?? ''),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      studentStatus: json['studentStatus'] as String?,
      score: (json['score'] as num?)?.toDouble(),
      maxScore: (json['maxScore'] as num?)?.toDouble(),
    );
  }

  final int examId;
  final String? code;
  final String name;
  final String? type;
  final String? status;
  final DateTime? publishAt;
  final DateTime? endAt;
  final int? durationMinutes;
  final String? studentStatus;
  final double? score;
  final double? maxScore;

  bool get isSubmitted => studentStatus == 'DA_LAM';

  /// Dung lai model/widget san co cua module De thi (ExamListTile,
  /// ExamPaperPage) thay vi dung mot loai the rieng cho man nay.
  Exam toExam() => Exam(
        id: examId,
        code: code ?? '',
        name: name,
        type: type ?? 'BY_CLASS',
        status: status ?? 'ACTIVE',
        durationMinutes: durationMinutes,
        publishAt: publishAt,
        endAt: endAt,
      );

  @override
  List<Object?> get props => [examId, name, studentStatus, score];
}
