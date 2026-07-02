/// Ket qua parse chuoi QR quet duoc.
///
/// - `DECA-ROOM:{roomId}:{code}`  -> [RoomQr]        (cham cong GV)
/// - `DECA-ATT:{sessionId}:{token}` -> [AttendanceQr] (diem danh HV)
/// - chuoi khac (token tran cu)   -> [RawToken]      (tuong thich nguoc)
sealed class QrPayload {
  const QrPayload();

  static QrPayload parse(String raw) {
    final value = raw.trim();
    if (value.startsWith('DECA-ROOM:')) {
      final parts = value.split(':');
      if (parts.length >= 3) {
        final roomId = int.tryParse(parts[1]);
        // code co the chua dau ':' (UUID khong co, nhung an toan) -> ghep phan con lai
        final code = parts.sublist(2).join(':');
        if (roomId != null && code.isNotEmpty) {
          return RoomQr(roomId: roomId, code: code);
        }
      }
      return RawToken(value);
    }
    if (value.startsWith('DECA-ATT:')) {
      final parts = value.split(':');
      if (parts.length >= 3) {
        final sessionId = int.tryParse(parts[1]);
        final token = parts.sublist(2).join(':');
        if (sessionId != null && token.isNotEmpty) {
          return AttendanceQr(sessionId: sessionId, token: token);
        }
      }
      return RawToken(value);
    }
    return RawToken(value);
  }
}

/// QR tinh dan tai phong (cham cong GV).
class RoomQr extends QrPayload {
  const RoomQr({required this.roomId, required this.code});

  final int roomId;
  final String code;
}

/// QR diem danh HV do GV hien thi (token xoay).
class AttendanceQr extends QrPayload {
  const AttendanceQr({required this.sessionId, required this.token});

  final int sessionId;
  final String token;
}

/// Chuoi token tran khong prefix (QR cu) — dung truc tiep lam token.
class RawToken extends QrPayload {
  const RawToken(this.value);

  final String value;
}
