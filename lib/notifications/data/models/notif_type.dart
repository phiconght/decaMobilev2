import 'package:flutter/material.dart';

/// Phan loai thong bao / tin nhan — dung chung cho ca 2 feature.
/// Khop enum NotificationType cua BE.
enum NotifType {
  missingCheckin,
  missingCheckout,
  checkinOk,
  checkoutOk,
  leaveSubmitted,
  leaveResult,
  scheduleChanged,
  sessionReminder,
  announcement,
  unknown;

  static NotifType fromString(String? s) => switch (s) {
        'MISSING_CHECKIN' => NotifType.missingCheckin,
        'MISSING_CHECKOUT' => NotifType.missingCheckout,
        'CHECKIN_OK' => NotifType.checkinOk,
        'CHECKOUT_OK' => NotifType.checkoutOk,
        'LEAVE_SUBMITTED' => NotifType.leaveSubmitted,
        'LEAVE_RESULT' => NotifType.leaveResult,
        'SCHEDULE_CHANGED' => NotifType.scheduleChanged,
        'SESSION_REMINDER' => NotifType.sessionReminder,
        'ANNOUNCEMENT' => NotifType.announcement,
        _ => NotifType.unknown,
      };

  /// Ten hien thi (dung cho chip loc trong hop thu).
  String get label => switch (this) {
        NotifType.missingCheckin => 'Chưa check-in',
        NotifType.missingCheckout => 'Chưa check-out',
        NotifType.checkinOk => 'Check-in',
        NotifType.checkoutOk => 'Check-out',
        NotifType.leaveSubmitted => 'Xin nghỉ',
        NotifType.leaveResult => 'Kết quả nghỉ',
        NotifType.scheduleChanged => 'Đổi lịch',
        NotifType.sessionReminder => 'Nhắc buổi học',
        NotifType.announcement => 'Trung tâm',
        NotifType.unknown => 'Khác',
      };

  IconData get icon => switch (this) {
        NotifType.missingCheckin => Icons.report_gmailerrorred_outlined,
        NotifType.missingCheckout => Icons.report_gmailerrorred_outlined,
        NotifType.checkinOk => Icons.login_outlined,
        NotifType.checkoutOk => Icons.logout_outlined,
        NotifType.leaveSubmitted => Icons.event_busy_outlined,
        NotifType.leaveResult => Icons.event_available_outlined,
        NotifType.scheduleChanged => Icons.edit_calendar_outlined,
        NotifType.sessionReminder => Icons.alarm_outlined,
        NotifType.announcement => Icons.campaign_outlined,
        NotifType.unknown => Icons.notifications_none_outlined,
      };
}
