import 'package:deca_mobile/schedule/data/models/qr_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrPayload.parse', () {
    test('DECA-ROOM -> RoomQr', () {
      final p = QrPayload.parse('DECA-ROOM:5:0b6c33d1-abcd');
      expect(p, isA<RoomQr>());
      final r = p as RoomQr;
      expect(r.roomId, 5);
      expect(r.code, '0b6c33d1-abcd');
    });

    test('DECA-ATT -> AttendanceQr', () {
      final p = QrPayload.parse('DECA-ATT:120:ABCD1234');
      expect(p, isA<AttendanceQr>());
      final a = p as AttendanceQr;
      expect(a.sessionId, 120);
      expect(a.token, 'ABCD1234');
    });

    test('token trần -> RawToken (tương thích ngược)', () {
      final p = QrPayload.parse('ABCD1234');
      expect(p, isA<RawToken>());
      expect((p as RawToken).value, 'ABCD1234');
    });

    test('chuỗi rác / thiếu phần -> RawToken', () {
      expect(QrPayload.parse('DECA-ROOM:abc'), isA<RawToken>());
      expect(QrPayload.parse('DECA-ROOM:5:'), isA<RawToken>());
      expect(QrPayload.parse('random-junk'), isA<RawToken>());
    });

    test('cắt khoảng trắng thừa', () {
      final p = QrPayload.parse('  DECA-ROOM:9:xyz  ');
      expect(p, isA<RoomQr>());
      expect((p as RoomQr).roomId, 9);
    });
  });
}
