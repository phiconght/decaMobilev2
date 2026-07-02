// Models Xu học viên — mirror DTO ở BE (com.trungtam.coin.dto.response).

int _i(Object? v) => v == null ? 0 : (v as num).toInt();
DateTime? _dt(Object? v) =>
    v == null ? null : DateTime.tryParse(v as String)?.toLocal();

/// Số dư Xu — mirror `CoinBalanceResponse`
/// {userId, fullName, username, balance}.
class CoinBalance {
  const CoinBalance({
    required this.userId,
    required this.fullName,
    required this.username,
    required this.balance,
  });

  factory CoinBalance.fromJson(Map<String, dynamic> j) => CoinBalance(
        userId: _i(j['userId']),
        fullName: j['fullName'] as String? ?? '',
        username: j['username'] as String? ?? '',
        balance: _i(j['balance']),
      );

  final int userId;
  final String fullName;
  final String username;
  final int balance;
}

/// 1 giao dịch Xu — mirror `CoinTransactionItem`
/// {id, amount, balanceAfter, reason, createdBy, createdAt}.
class CoinTransaction {
  const CoinTransaction({
    required this.id,
    required this.amount,
    required this.balanceAfter,
    required this.reason,
    required this.createdBy,
    required this.createdAt,
  });

  factory CoinTransaction.fromJson(Map<String, dynamic> j) => CoinTransaction(
        id: _i(j['id']),
        amount: _i(j['amount']),
        balanceAfter: _i(j['balanceAfter']),
        reason: j['reason'] as String? ?? '',
        createdBy: j['createdBy'] as String? ?? '',
        createdAt: _dt(j['createdAt']),
      );

  final int id;
  final int amount;
  final int balanceAfter;
  final String reason;
  final String createdBy;
  final DateTime? createdAt;

  bool get isCredit => amount >= 0;
}
