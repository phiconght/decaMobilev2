import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/fee/data/models/invoice.dart';

/// Hợp đồng dữ liệu học phí — gọi các endpoint /api/v1/invoices/** của BE.
abstract class FeeRepository {
  /// Đợt thu của mình (STUDENT) hoặc của con (PARENT truyền [studentId]).
  Future<List<MyInvoiceItem>> fetchMyInvoices({int? studentId});

  /// Dữ liệu QR chuyển khoản của 1 đợt thu đã CONFIRMED.
  Future<InvoiceQr> fetchQr(int invoiceId);
}

/// Cài đặt — lấy học phí từ BE (vỏ ApiResponse<T>).
class FeeRepositoryImpl implements FeeRepository {
  const FeeRepositoryImpl(this._api);

  final ApiClient _api;

  static const _base = '/api/v1/invoices';

  @override
  Future<List<MyInvoiceItem>> fetchMyInvoices({int? studentId}) async {
    final data = await _api.get(
      '$_base/my',
      query: {if (studentId != null) 'studentId': studentId},
    );
    final list = (data as List<dynamic>?) ?? const [];
    return list
        .map((e) => MyInvoiceItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InvoiceQr> fetchQr(int invoiceId) async {
    final data = await _api.get('$_base/$invoiceId/qr');
    return InvoiceQr.fromJson((data as Map<String, dynamic>?) ?? const {});
  }
}
