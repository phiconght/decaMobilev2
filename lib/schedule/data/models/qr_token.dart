/// Token QR diem danh kem thoi gian song (giay).
class QrToken {
  const QrToken({required this.token, required this.ttlSeconds});

  factory QrToken.fromJson(Map<String, dynamic> json) => QrToken(
        token: json['token'] as String,
        ttlSeconds: (json['ttlSeconds'] as num).toInt(),
      );

  final String token;
  final int ttlSeconds;
}
