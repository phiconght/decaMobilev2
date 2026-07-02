import 'package:intl/intl.dart';

/// Pham vi don nghi phep.
enum LeaveScope { session, range }

/// Trang thai duyet don nghi phep.
enum LeaveStatus { pending, approved, rejected }

LeaveScope leaveScopeFromString(String? s) =>
    s == 'RANGE' ? LeaveScope.range : LeaveScope.session;

LeaveStatus leaveStatusFromString(String? s) => switch (s) {
      'APPROVED' => LeaveStatus.approved,
      'REJECTED' => LeaveStatus.rejected,
      _ => LeaveStatus.pending,
    };

/// Mot don nghi phep — khop record LeaveItem.java.
class LeaveItem {
  const LeaveItem({
    required this.id,
    required this.scope,
    required this.status,
    this.studentId,
    this.studentName,
    this.sessionId,
    this.sessionDate,
    this.classId,
    this.className,
    this.dateFrom,
    this.dateTo,
    this.reason,
    this.reviewedBy,
    this.reviewedAt,
    this.createdAt,
  });

  factory LeaveItem.fromJson(Map<String, dynamic> json) {
    return LeaveItem(
      id: json['id'] as int,
      studentId: json['studentId'] as int?,
      studentName: json['studentName'] as String?,
      scope: leaveScopeFromString(json['scope'] as String?),
      sessionId: json['sessionId'] as int?,
      sessionDate: _parseDate(json['sessionDate'] as String?),
      classId: json['classId'] as int?,
      className: json['className'] as String?,
      dateFrom: _parseDate(json['dateFrom'] as String?),
      dateTo: _parseDate(json['dateTo'] as String?),
      reason: json['reason'] as String?,
      status: leaveStatusFromString(json['status'] as String?),
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt:
          DateTime.tryParse(json['reviewedAt'] as String? ?? '')?.toLocal(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal(),
    );
  }

  final int id;
  final int? studentId;
  final String? studentName;
  final LeaveScope scope;
  final int? sessionId;
  final DateTime? sessionDate;
  final int? classId;
  final String? className;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? reason;
  final LeaveStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  static DateTime? _parseDate(String? s) =>
      (s == null || s.isEmpty) ? null : DateTime.parse(s);
}

/// Body tao don nghi phep.
class CreateLeaveRequest {
  const CreateLeaveRequest({
    required this.studentId,
    required this.scope,
    this.sessionId,
    this.classId,
    this.dateFrom,
    this.dateTo,
    this.reason,
  });

  final int studentId;
  final LeaveScope scope;
  final int? sessionId;
  final int? classId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? reason;

  Map<String, dynamic> toJson() {
    final fmt = DateFormat('yyyy-MM-dd');
    final json = <String, dynamic>{
      'studentId': studentId,
      'scope': scope == LeaveScope.range ? 'RANGE' : 'SESSION',
    };
    if (sessionId != null) json['sessionId'] = sessionId;
    if (classId != null) json['classId'] = classId;
    if (dateFrom != null) json['dateFrom'] = fmt.format(dateFrom!);
    if (dateTo != null) json['dateTo'] = fmt.format(dateTo!);
    final r = reason;
    if (r != null && r.isNotEmpty) json['reason'] = r;
    return json;
  }
}
