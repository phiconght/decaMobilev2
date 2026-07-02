import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/auth/data/auth_repository.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/widgets/app_bottom_sheet.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/core/widgets/info_row.dart';
import 'package:deca_mobile/core/widgets/primary_button.dart';
import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/schedule/cubit/timetable_cubit.dart';
import 'package:deca_mobile/schedule/data/attendance_repository.dart';
import 'package:deca_mobile/schedule/data/models/qr_payload.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/data/timetable_repository.dart';
import 'package:deca_mobile/schedule/view/attendance_page.dart';
import 'package:deca_mobile/schedule/view/leave_form_page.dart';
import 'package:deca_mobile/schedule/view/qr_scan_page.dart';
import 'package:deca_mobile/schedule/widgets/qr_view.dart';
import 'package:deca_mobile/schedule/widgets/status_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Chi tiet mot buoi hoc — thong tin va hanh dong theo view.
class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({required this.item, required this.view, super.key});

  final TimetableItem item;
  final String view;

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');

  /// Thu trong tuan tieng Viet tu DateTime.weekday.
  static String _weekdayLabel(int weekday) => switch (weekday) {
        DateTime.monday => 'Thứ Hai',
        DateTime.tuesday => 'Thứ Ba',
        DateTime.wednesday => 'Thứ Tư',
        DateTime.thursday => 'Thứ Năm',
        DateTime.friday => 'Thứ Sáu',
        DateTime.saturday => 'Thứ Bảy',
        _ => 'Chủ Nhật',
      };

  /// Nhan tieng Viet cho trang thai diem danh cua HV.
  static String _attendanceLabel(AttendanceStatus? status) => switch (status) {
        AttendanceStatus.coMat => 'Có mặt',
        AttendanceStatus.tre => 'Trễ',
        AttendanceStatus.vang => 'Vắng',
        AttendanceStatus.coPhep => 'Có phép',
        AttendanceStatus.chuaCheckin => 'Chưa điểm danh',
        null => 'Chưa điểm danh',
      };

  String get _dayLabel =>
      '${_weekdayLabel(item.date.weekday)}, ${_dateFmt.format(item.date)}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// HV quet QR diem danh: chan neu quet nham QR phong / QR buoi khac.
  Future<void> _scanAndDo(
    BuildContext context, {
    required bool isCheckout,
  }) async {
    final raw = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => QrScanPage(isCheckout: isCheckout),
      ),
    );
    if (raw == null || !context.mounted) return;

    final String token;
    switch (QrPayload.parse(raw)) {
      case AttendanceQr(sessionId: final sid, token: final t):
        if (sid != item.sessionId) {
          AppSnackBar.error(context, 'Mã QR của buổi học khác.');
          return;
        }
        token = t;
      case RawToken(value: final v):
        token = v; // QR cu (token tran)
      case RoomQr():
        AppSnackBar.error(
          context,
          'Đây là mã chấm công của giáo viên, không dùng để điểm danh.',
        );
        return;
    }

    try {
      final repo = context.read<TimetableRepository>();
      if (isCheckout) {
        await repo.checkout(item.sessionId, token);
      } else {
        await repo.checkin(item.sessionId, token);
      }
      if (!context.mounted) return;
      AppSnackBar.success(
        context,
        isCheckout ? 'Đã check-out' : 'Đã check-in',
      );
      unawaited(context.read<TimetableCubit>().refresh());
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (context.mounted) AppSnackBar.error(context, e.message);
    }
  }

  /// GV quet QR phong de cham cong day. Chi chap nhan QR phong (DECA-ROOM).
  Future<void> _scanTeacher(
    BuildContext context, {
    required bool isCheckout,
  }) async {
    final raw = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => QrScanPage(
          isCheckout: isCheckout,
          title: isCheckout
              ? 'Quét QR phòng — chấm công ra'
              : 'Quét QR phòng — chấm công vào',
        ),
      ),
    );
    if (raw == null || !context.mounted) return;

    final payload = QrPayload.parse(raw);
    if (payload is! RoomQr) {
      AppSnackBar.error(context, 'Hãy quét mã QR dán tại phòng học.');
      return;
    }

    try {
      final repo = context.read<AttendanceRepository>();
      if (isCheckout) {
        await repo.teacherCheckout(item.sessionId, payload.code);
      } else {
        await repo.teacherCheckin(item.sessionId, payload.code);
      }
      if (!context.mounted) return;
      AppSnackBar.success(
        context,
        isCheckout ? 'Đã chấm công ra' : 'Đã chấm công vào',
      );
      unawaited(context.read<TimetableCubit>().refresh());
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (context.mounted) AppSnackBar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.read<AuthCubit>().state.user;
    final perms = user?.permissions ?? const <String>[];
    final isCancelled = item.status == SessionStatus.cancelled;

    final roomText = item.roomName ?? 'Chưa xếp phòng';
    final branch = item.branchName;
    final roomValue = branch != null ? '$roomText — $branch' : roomText;

    final subjectLine = [
      if (item.subjectName != null && item.subjectName!.isNotEmpty)
        item.subjectName,
      if (item.gradeLevel != null && item.gradeLevel!.isNotEmpty)
        item.gradeLevel,
    ].whereType<String>().join(' — ');

    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.className,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        SessionStatusChip(status: item.status),
                      ],
                    ),
                    if (subjectLine.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(subjectLine, style: theme.textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Thông tin buổi',
              child: Column(
                children: [
                  InfoRow(label: 'Ngày', value: _dayLabel),
                  InfoRow(
                    label: 'Giờ',
                    value: '${item.startTime} – ${item.endTime}',
                  ),
                  InfoRow(label: 'Phòng', value: roomValue),
                  InfoRow(
                    label: 'Giáo viên',
                    value: item.teacherName ?? '—',
                  ),
                  if (view == 'STUDENT' || view == 'PARENT') ...[
                    InfoRow(
                      label: 'Điểm danh',
                      value: _attendanceLabel(item.attendanceStatus),
                    ),
                    InfoRow(
                      label: 'Nghỉ phép',
                      value: item.onLeave ? 'Có' : 'Không',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._buildActions(context, user, perms, isCancelled: isCancelled),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    AuthUser? user,
    List<String> perms, {
    required bool isCancelled,
  }) {
    final now = DateTime.now();
    final today = _isSameDay(item.date, now);
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final itemMidnight = DateTime(
      item.date.year,
      item.date.month,
      item.date.day,
    );
    final future = !itemMidnight.isBefore(todayMidnight);

    switch (view) {
      case 'STUDENT':
        return _studentActions(
          context,
          user,
          isCancelled: isCancelled,
          today: today,
          future: future,
        );
      case 'PARENT':
        return _parentActions(
          context,
          isCancelled: isCancelled,
          future: future,
        );
      case 'TEACHER':
        return _teacherActions(
          context,
          perms,
          isCancelled: isCancelled,
          today: today,
        );
      default:
        return const [];
    }
  }

  List<Widget> _studentActions(
    BuildContext context,
    AuthUser? user, {
    required bool isCancelled,
    required bool today,
    required bool future,
  }) {
    final attendance = item.attendanceStatus;
    final actions = <Widget>[];

    final canCheckin = !isCancelled &&
        today &&
        item.status == SessionStatus.planned &&
        (attendance == null || attendance == AttendanceStatus.chuaCheckin);
    if (canCheckin) {
      actions.add(
        PrimaryButton(
          label: 'Check-in',
          icon: Icons.qr_code,
          onPressed: () => _scanAndDo(context, isCheckout: false),
        ),
      );
    }

    final canCheckout = !isCancelled &&
        today &&
        (attendance == AttendanceStatus.coMat ||
            attendance == AttendanceStatus.tre);
    if (canCheckout) {
      actions.add(
        PrimaryButton(
          label: 'Check-out',
          icon: Icons.qr_code,
          onPressed: () => _scanAndDo(context, isCheckout: true),
        ),
      );
    }

    final canLeave =
        !isCancelled && future && item.status == SessionStatus.planned;
    if (canLeave) {
      if (actions.isNotEmpty) actions.add(const SizedBox(height: 12));
      actions.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.event_busy),
            label: const Text('Xin nghỉ buổi này'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LeaveFormPage(
                  studentId: user!.id,
                  studentName: user.fullName,
                  sessionId: item.sessionId,
                  sessionLabel:
                      '${item.title} · $_dayLabel ${item.startTime}',
                ),
              ),
            ),
          ),
        ),
      );
    }

    return actions;
  }

  List<Widget> _parentActions(
    BuildContext context, {
    required bool isCancelled,
    required bool future,
  }) {
    if (isCancelled || item.status != SessionStatus.planned || !future) {
      return const [];
    }
    return [
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.event_busy),
          label: const Text('Xin nghỉ cho con'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => LeaveFormPage(
                studentId: item.studentId!,
                studentName: item.studentName ?? 'con',
                sessionId: item.sessionId,
                sessionLabel: '${item.title} · $_dayLabel ${item.startTime}',
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _teacherActions(
    BuildContext context,
    List<String> perms, {
    required bool isCancelled,
    required bool today,
  }) {
    if (isCancelled || !perms.contains('CLASS:READ')) return const [];

    final actions = <Widget>[
      // Hang 1: quan ly diem danh HV.
      Row(
        children: [
          Expanded(
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.list),
              label: const Text('Điểm danh'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AttendancePage(
                    sessionId: item.sessionId,
                    sessionTitle: item.title,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.qr_code),
              label: const Text('Hiện QR'),
              onPressed: () => AppBottomSheet.show<void>(
                context,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: QrView(
                    sessionId: item.sessionId,
                    fetchToken: () => context
                        .read<AttendanceRepository>()
                        .qrToken(item.sessionId),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ];

    // Hang 2: cham cong day cua GV (chi buoi hom nay).
    if (today) {
      final tStatus = item.teacherAttendanceStatus;
      final checkedIn = tStatus == 'DUNG_GIO' || tStatus == 'VAO_TRE';
      actions.add(const SizedBox(height: 12));
      actions.add(
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Chấm công vào'),
                onPressed: checkedIn
                    ? null
                    : () => _scanTeacher(context, isCheckout: false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Chấm công ra'),
                onPressed: checkedIn
                    ? () => _scanTeacher(context, isCheckout: true)
                    : null,
              ),
            ),
          ],
        ),
      );
      if (checkedIn) {
        actions.add(const SizedBox(height: 8));
        actions.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              tStatus == 'VAO_TRE'
                  ? 'Đã chấm công vào (Vào trễ)'
                  : 'Đã chấm công vào (Đúng giờ)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
    }

    return actions;
  }
}
