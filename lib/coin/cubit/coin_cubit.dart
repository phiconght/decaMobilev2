import 'package:bloc/bloc.dart';
import 'package:deca_mobile/coin/data/coin_repository.dart';
import 'package:deca_mobile/coin/data/models/coin.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/state/view_status.dart';
import 'package:equatable/equatable.dart';

/// Gói dữ liệu màn Xu: số dư + lịch sử giao dịch (load-more theo trang).
class CoinData extends Equatable {
  const CoinData({
    required this.balance,
    required this.transactions,
    this.hasMore = true,
    this.loadingMore = false,
  });

  final CoinBalance balance;
  final List<CoinTransaction> transactions;
  final bool hasMore;
  final bool loadingMore;

  CoinData copyWith({
    CoinBalance? balance,
    List<CoinTransaction>? transactions,
    bool? hasMore,
    bool? loadingMore,
  }) =>
      CoinData(
        balance: balance ?? this.balance,
        transactions: transactions ?? this.transactions,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );

  @override
  List<Object?> get props => [balance, transactions, hasMore, loadingMore];
}

/// Tải số dư + lịch sử Xu.
///
/// STUDENT: [studentId] = null → BE trả của chính mình.
/// PARENT: truyền [studentId] là con đang chọn (đổi con → cubit mới).
class CoinCubit extends Cubit<DataState<CoinData>> {
  CoinCubit(this._repo, {this.studentId, this.pageSize = 20})
      : super(const DataState<CoinData>());

  final CoinRepository _repo;
  final int? studentId;
  final int pageSize;

  int _page = 1;

  /// Tải lần đầu (số dư + trang 1 lịch sử).
  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    _page = 1;
    try {
      final balance = await _repo.fetchBalance(studentId: studentId);
      final txns = await _repo.fetchTransactions(
        studentId: studentId,
        page: _page,
        pageSize: pageSize,
      );
      emit(
        state.copyWith(
          status: ViewStatus.success,
          data: CoinData(
            balance: balance,
            transactions: txns,
            hasMore: txns.length >= pageSize,
          ),
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: e.message));
    } on Object catch (_) {
      emit(
        state.copyWith(status: ViewStatus.failure, error: 'Đã có lỗi xảy ra'),
      );
    }
  }

  Future<void> refresh() => load();

  /// Tải thêm trang lịch sử tiếp theo.
  Future<void> loadMore() async {
    final data = state.data;
    if (data == null || !data.hasMore || data.loadingMore) return;
    emit(state.copyWith(data: data.copyWith(loadingMore: true)));
    try {
      final next = await _repo.fetchTransactions(
        studentId: studentId,
        page: _page + 1,
        pageSize: pageSize,
      );
      _page += 1;
      emit(
        state.copyWith(
          data: data.copyWith(
            transactions: [...data.transactions, ...next],
            hasMore: next.length >= pageSize,
            loadingMore: false,
          ),
        ),
      );
    } on Object catch (_) {
      emit(state.copyWith(data: data.copyWith(loadingMore: false)));
    }
  }
}
