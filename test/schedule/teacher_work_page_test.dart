import 'package:deca_mobile/core/theme/app_theme.dart';
import 'package:deca_mobile/schedule/data/attendance_repository.dart';
import 'package:deca_mobile/schedule/data/models/attendance_item.dart';
import 'package:deca_mobile/schedule/data/models/qr_token.dart';
import 'package:deca_mobile/schedule/data/models/teacher_work.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/view/teacher_work_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repo gia: tra bao cao co san 2 buoi.
class _FakeAttendanceRepository implements AttendanceRepository {
  const _FakeAttendanceRepository({this.empty = false});

  final bool empty;

  @override
  Future<TeacherWorkReport> myWorkReport(DateTime from, DateTime to) async {
    if (empty) {
      return const TeacherWorkReport(
        summary: TeacherWorkSummary(
          totalSessions: 0,
          dungGio: 0,
          vaoTre: 0,
          vang: 0,
          chuaCham: 0,
          totalTaughtMinutes: 0,
        ),
        items: [],
      );
    }
    return TeacherWorkReport(
      summary: const TeacherWorkSummary(
        totalSessions: 2,
        dungGio: 1,
        vaoTre: 0,
        vang: 1,
        chuaCham: 0,
        totalTaughtMinutes: 90,
      ),
      items: [
        TeacherWorkItem(
          sessionId: 1,
          date: DateTime(2026, 7, 1),
          startTime: '16:00',
          endTime: '17:30',
          className: 'Lớp bulk 3',
          roomName: 'Phòng 101',
          durationMinutes: 90,
          status: TeacherAttendanceStatus.dungGio,
        ),
        TeacherWorkItem(
          sessionId: 2,
          date: DateTime(2026, 6, 30),
          startTime: '16:00',
          endTime: '17:30',
          className: 'Lớp bulk 3',
          roomName: 'Phòng 101',
          durationMinutes: 90,
          status: TeacherAttendanceStatus.vang,
        ),
      ],
    );
  }

  // --- khong dung trong test nay ---
  @override
  Future<List<AttendanceItem>> list(int sessionId) async => const [];
  @override
  Future<void> setStatus(int s, int u, AttendanceStatus st) async {}
  @override
  Future<QrToken> qrToken(int sessionId) async =>
      const QrToken(token: 'x', ttlSeconds: 30);
  @override
  Future<void> teacherCheckin(int sessionId, String roomCode) async {}
  @override
  Future<void> teacherCheckout(int sessionId, String roomCode) async {}
}

// Dung AppTheme THAT de bat loi layout do theme (vd min-width vo han cua button).
Widget _wrap({bool empty = false}) => RepositoryProvider<AttendanceRepository>(
      create: (_) => _FakeAttendanceRepository(empty: empty),
      child: MaterialApp(
        theme: AppTheme.light,
        home: const TeacherWorkPage(),
      ),
    );

void main() {
  testWidgets('render tổng kết + danh sách buổi, không lỗi layout',
      (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    expect(find.text('Chấm công của tôi'), findsOneWidget);
    expect(find.text('Tổng kết'), findsOneWidget);
    expect(find.textContaining('Đúng giờ'), findsWidgets);
    expect(find.textContaining('Lớp bulk 3'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tháng trống hiện empty view', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(empty: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    expect(find.textContaining('Chưa có buổi dạy'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
