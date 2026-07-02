// Models học phí — mirror DTO ở BE (com.trungtam.payment.dto.response).

int _i(Object? v) => v == null ? 0 : (v as num).toInt();
num _n(Object? v) => v == null ? 0 : v as num;
DateTime? _dt(Object? v) =>
    v == null ? null : DateTime.tryParse(v as String)?.toLocal();
DateTime? _date(Object? v) => v == null ? null : DateTime.tryParse(v as String);

/// 1 đợt thu học phí hiển thị cho mobile — mirror `MyInvoiceItem`
/// {id, className, periodFrom, periodTo, sessionCount, amount, status, paidAt}.
class MyInvoiceItem {
  const MyInvoiceItem({
    required this.id,
    required this.className,
    required this.periodFrom,
    required this.periodTo,
    required this.sessionCount,
    required this.amount,
    required this.status,
    this.paidAt,
  });

  factory MyInvoiceItem.fromJson(Map<String, dynamic> j) => MyInvoiceItem(
        id: _i(j['id']),
        className: j['className'] as String? ?? '',
        periodFrom: _date(j['periodFrom']),
        periodTo: _date(j['periodTo']),
        sessionCount: _i(j['sessionCount']),
        amount: _n(j['amount']),
        status: j['status'] as String? ?? '',
        paidAt: _dt(j['paidAt']),
      );

  final int id;
  final String className;
  final DateTime? periodFrom;
  final DateTime? periodTo;
  final int sessionCount;
  final num amount;
  final String status;
  final DateTime? paidAt;

  /// Đợt thu đã xác nhận — nút "Thanh toán" sáng xanh.
  bool get isConfirmed => status == 'CONFIRMED';

  /// Đợt thu đã thu tiền.
  bool get isPaid => status == 'PAID';
}

/// Dữ liệu QR chuyển khoản — mirror `InvoiceQrResponse`
/// {qrPayload, bankName, accountNumber, accountName, amount, paymentCode}.
class InvoiceQr {
  const InvoiceQr({
    required this.qrPayload,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
    required this.paymentCode,
  });

  factory InvoiceQr.fromJson(Map<String, dynamic> j) => InvoiceQr(
        qrPayload: j['qrPayload'] as String? ?? '',
        bankName: j['bankName'] as String? ?? '',
        accountNumber: j['accountNumber'] as String? ?? '',
        accountName: j['accountName'] as String? ?? '',
        amount: _n(j['amount']),
        paymentCode: j['paymentCode'] as String? ?? '',
      );

  final String qrPayload;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final num amount;
  final String paymentCode;
}
