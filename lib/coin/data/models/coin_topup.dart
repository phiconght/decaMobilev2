// Model nạp Xu bằng chuyển khoản — mirror `CoinTopupResponse` (BE).

int _i(Object? v) => v == null ? 0 : (v as num).toInt();
num _n(Object? v) => v == null ? 0 : v as num;
DateTime? _dt(Object? v) =>
    v == null ? null : DateTime.tryParse(v as String)?.toLocal();

/// 1 yêu cầu nạp Xu — {id, amountVnd, coinAmount, paymentCode, status,
/// confirmedAt, createdAt, qrPayload, bankName, accountNumber, accountName}.
class CoinTopup {
  const CoinTopup({
    required this.id,
    required this.amountVnd,
    required this.coinAmount,
    required this.paymentCode,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.qrPayload,
    this.bankName,
    this.accountNumber,
    this.accountName,
  });

  factory CoinTopup.fromJson(Map<String, dynamic> j) => CoinTopup(
        id: _i(j['id']),
        amountVnd: _n(j['amountVnd']),
        coinAmount: _i(j['coinAmount']),
        paymentCode: j['paymentCode'] as String? ?? '',
        status: j['status'] as String? ?? '',
        createdAt: _dt(j['createdAt']),
        confirmedAt: _dt(j['confirmedAt']),
        qrPayload: j['qrPayload'] as String?,
        bankName: j['bankName'] as String?,
        accountNumber: j['accountNumber'] as String?,
        accountName: j['accountName'] as String?,
      );

  final int id;
  final num amountVnd;
  final int coinAmount;
  final String paymentCode;
  final String status;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
  final String? qrPayload;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;

  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
}
