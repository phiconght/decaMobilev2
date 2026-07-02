import 'package:deca_mobile/coin/data/models/coin.dart';
import 'package:deca_mobile/core/network/api_client.dart';

/// Hợp đồng dữ liệu Xu học viên — gọi các endpoint /api/v1/coins/** của BE.
abstract class CoinRepository {
  /// Số dư của mình (STUDENT) hoặc của con (PARENT truyền [studentId]).
  Future<CoinBalance> fetchBalance({int? studentId});

  /// Lịch sử giao dịch (mới nhất trước), phân trang phẳng.
  Future<List<CoinTransaction>> fetchTransactions({
    int? studentId,
    int page = 1,
    int pageSize = 20,
  });
}

/// Cài đặt — lấy Xu từ BE (vỏ ApiResponse<T> / paging phẳng {success,data,total}).
class CoinRepositoryImpl implements CoinRepository {
  const CoinRepositoryImpl(this._api);

  final ApiClient _api;

  static const _base = '/api/v1/coins';

  @override
  Future<CoinBalance> fetchBalance({int? studentId}) async {
    final data = await _api.get(
      '$_base/my',
      query: {if (studentId != null) 'studentId': studentId},
    );
    return CoinBalance.fromJson((data as Map<String, dynamic>?) ?? const {});
  }

  @override
  Future<List<CoinTransaction>> fetchTransactions({
    int? studentId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final data = await _api.get(
      '$_base/my/transactions',
      query: {
        if (studentId != null) 'studentId': studentId,
        'current': page,
        'pageSize': pageSize,
      },
    );
    final list = (data as List<dynamic>?) ?? const [];
    return list
        .map((e) => CoinTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
