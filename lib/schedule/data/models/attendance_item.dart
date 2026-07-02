import 'package:deca_mobile/schedule/data/models/timetable_item.dart';

/// Mot dong diem danh cua hoc vien trong 1 buoi.
class AttendanceItem {
  const AttendanceItem({
    required this.userId,
    required this.fullName,
    required this.username,
    required this.status,
    this.phone,
    this.checkInAt,
    this.checkOutAt,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      userId: json['userId'] as int,
      fullName: (json['fullName'] ?? json['username']) as String,
      username: json['username'] as String,
      phone: json['phone'] as String?,
      status: attendanceStatusFromString(json['status'] as String?) ??
          AttendanceStatus.chuaCheckin,
      checkInAt:
          DateTime.tryParse(json['checkInAt'] as String? ?? '')?.toLocal(),
      checkOutAt:
          DateTime.tryParse(json['checkOutAt'] as String? ?? '')?.toLocal(),
    );
  }

  final int userId;
  final String fullName;
  final String username;
  final String? phone;
  final AttendanceStatus status;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
}
