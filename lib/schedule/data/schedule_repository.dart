import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/schedule/data/models/schedule_item.dart';

/// Hop dong du lieu thoi khoa bieu (Repository pattern).
// ignore: one_member_abstracts
abstract class ScheduleRepository {
  Future<List<ScheduleItem>> fetchSchedule();
}

class ScheduleRepositoryImpl implements ScheduleRepository {
  const ScheduleRepositoryImpl(this._api);

  // ignore: unused_field — se dung khi noi endpoint that
  final ApiClient _api;

  @override
  Future<List<ScheduleItem>> fetchSchedule() async {
    // TODO(be): thay bang GET /api/v1/me/schedule khi BE san sang.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _mock;
  }

  static const List<ScheduleItem> _mock = [
    ScheduleItem(
      id: 1,
      className: 'Toán 10A1',
      subjectName: 'Toán',
      gradeLevel: 'Khối 10',
      weekday: 2,
      startTime: '07:30',
      endTime: '09:00',
      room: 'P.201',
      teacherName: 'Nguyễn Văn A',
      status: 'ACTIVE',
    ),
    ScheduleItem(
      id: 2,
      className: 'Vật lý 11B',
      subjectName: 'Vật lý',
      gradeLevel: 'Khối 11',
      weekday: 3,
      startTime: '09:15',
      endTime: '10:45',
      room: 'P.305',
      teacherName: 'Trần Thị B',
      status: 'ACTIVE',
    ),
    ScheduleItem(
      id: 3,
      className: 'Toán 10A1',
      subjectName: 'Toán',
      gradeLevel: 'Khối 10',
      weekday: 5,
      startTime: '07:30',
      endTime: '09:00',
      room: 'P.201',
      teacherName: 'Nguyễn Văn A',
      status: 'ACTIVE',
    ),
    ScheduleItem(
      id: 4,
      className: 'Tiếng Anh 10C',
      subjectName: 'Tiếng Anh',
      gradeLevel: 'Khối 10',
      weekday: 6,
      startTime: '14:00',
      endTime: '15:30',
      room: 'P.102',
      teacherName: 'Lê Văn C',
      status: 'ACTIVE',
    ),
  ];
}
