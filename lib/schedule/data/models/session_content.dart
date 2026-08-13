import 'package:deca_mobile/exams/data/models/exam.dart';

/// Video bai giang gan cho 1 buoi hoc — khop record SessionVideoItem.java.
class SessionVideoItem {
  const SessionVideoItem({
    required this.videoId,
    required this.title,
    required this.youtubeUrl,
    required this.sortOrder,
    this.thumbnailUrl,
    this.durationSeconds,
  });

  factory SessionVideoItem.fromJson(Map<String, dynamic> json) {
    return SessionVideoItem(
      videoId: (json['videoId'] as num).toInt(),
      title: json['title'] as String,
      youtubeUrl: json['youtubeUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  final int videoId;
  final String title;
  final String youtubeUrl;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final int sortOrder;
}

/// Link Zoom cua 1 buoi hoc — khop record ZoomLinkItem.java.
class ZoomLinkItem {
  const ZoomLinkItem({
    required this.id,
    required this.label,
    required this.zoomUrl,
    required this.sortOrder,
    this.meetingId,
    this.passcode,
  });

  factory ZoomLinkItem.fromJson(Map<String, dynamic> json) {
    return ZoomLinkItem(
      id: (json['id'] as num).toInt(),
      label: json['label'] as String,
      zoomUrl: json['zoomUrl'] as String,
      meetingId: json['meetingId'] as String?,
      passcode: json['passcode'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  final int id;
  final String label;
  final String zoomUrl;
  final String? meetingId;
  final String? passcode;
  final int sortOrder;
}

/// De thi gan RIENG 1 buoi hoc — khop record SessionExamItem.java.
class SessionExamItem {
  const SessionExamItem({
    required this.examId,
    required this.code,
    required this.name,
    required this.type,
    required this.status,
    this.publishAt,
    this.endAt,
    this.durationMinutes,
    this.studentStatus,
    this.score,
  });

  factory SessionExamItem.fromJson(Map<String, dynamic> json) {
    return SessionExamItem(
      examId: (json['examId'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'BY_CLASS',
      status: json['status'] as String? ?? 'ACTIVE',
      publishAt: _parseDate(json['publishAt']),
      endAt: _parseDate(json['endAt']),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      studentStatus: json['studentStatus'] as String?,
      score: (json['score'] as num?)?.toDouble(),
    );
  }

  final int examId;
  final String code;
  final String name;
  final String type;
  final String status;
  final DateTime? publishAt;
  final DateTime? endAt;
  final int? durationMinutes;
  final String? studentStatus;
  final double? score;

  bool get isSubmitted => studentStatus == 'DA_LAM';

  /// Dung lai model/man lam bai da co cua module De thi (ExamPaperPage) thay
  /// vi dung 1 luong rieng cho SessionDetailPage.
  Exam toExam() => Exam(
        id: examId,
        code: code,
        name: name,
        type: type,
        status: status,
        durationMinutes: durationMinutes,
        publishAt: publishAt,
        endAt: endAt,
      );

  static DateTime? _parseDate(Object? v) =>
      v == null ? null : DateTime.parse(v as String);
}
