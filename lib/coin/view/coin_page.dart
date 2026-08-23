import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/coin/cubit/coin_cubit.dart';
import 'package:deca_mobile/coin/data/coin_repository.dart';
import 'package:deca_mobile/coin/data/models/coin.dart';
import 'package:deca_mobile/coin/data/models/coin_topup.dart';
import 'package:deca_mobile/coin/widgets/coin_transaction_tile.dart';
import 'package:deca_mobile/coin/widgets/topup_amount_sheet.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_bottom_sheet.dart';
import 'package:deca_mobile/core/widgets/app_empty_view.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_loading_view.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/core/widgets/primary_button.dart';
import 'package:deca_mobile/fee/data/models/invoice.dart';
import 'package:deca_mobile/fee/widgets/payment_qr_sheet.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Màn "Xu của tôi" — điều hướng theo vai trò:
/// STUDENT → Xu của mình; PARENT → chọn con (qua /reports/my-children).
/// [embedded]: true khi nhúng trong tab của "Tài khoản và học phí"
/// (bỏ Scaffold/AppBar riêng).
class CoinPage extends StatelessWidget {
  const CoinPage({this.embedded = false, super.key});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final roles =
        context.read<AuthCubit>().state.user?.roles ?? const <String>[];

    final body = roles.contains('PARENT')
        ? _ParentCoin(reports: context.read<ReportsRepository>())
        : const _StudentCoin(studentId: null);

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Xu của tôi')),
      body: body,
    );
  }
}

/// STUDENT: xem Xu của chính mình (BE suy ra từ token).
class _StudentCoin extends StatelessWidget {
  const _StudentCoin({required this.studentId});

  final int? studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = CoinCubit(
          ctx.read<CoinRepository>(),
          studentId: studentId,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const _CoinBody(),
    );
  }
}

/// PARENT: chọn con → Xu của con.
class _ParentCoin extends StatefulWidget {
  const _ParentCoin({required this.reports});

  final ReportsRepository reports;

  @override
  State<_ParentCoin> createState() => _ParentCoinState();
}

class _ParentCoinState extends State<_ParentCoin> {
  late Future<List<ChildOption>> _future;
  ChildOption? _selected;

  @override
  void initState() {
    super.initState();
    _future = widget.reports.myChildren();
    _future.then((children) {
      if (mounted && children.isNotEmpty) {
        setState(() => _selected = children.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChildOption>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final children = snap.data ?? const <ChildOption>[];
        if (children.isEmpty) {
          return const Center(child: Text('Chưa liên kết học viên nào.'));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: DropdownButtonFormField<int>(
                initialValue: _selected?.studentId,
                decoration: const InputDecoration(
                  labelText: 'Chọn con',
                  border: OutlineInputBorder(),
                ),
                items: children
                    .map((c) => DropdownMenuItem(
                          value: c.studentId,
                          child: Text(c.fullName),
                        ))
                    .toList(),
                onChanged: (v) => setState(
                  () => _selected =
                      children.firstWhere((c) => c.studentId == v),
                ),
              ),
            ),
            Expanded(
              child: _selected == null
                  ? const SizedBox.shrink()
                  : BlocProvider(
                      key: ValueKey(_selected!.studentId),
                      create: (ctx) {
                        final cubit = CoinCubit(
                          ctx.read<CoinRepository>(),
                          studentId: _selected!.studentId,
                        );
                        unawaited(cubit.load());
                        return cubit;
                      },
                      child: const _CoinBody(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Thân màn: card số dư + lịch sử — 4 trạng thái chuẩn + load-more.
class _CoinBody extends StatefulWidget {
  const _CoinBody();

  @override
  State<_CoinBody> createState() => _CoinBodyState();
}

class _CoinBodyState extends State<_CoinBody> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 200) {
      unawaited(context.read<CoinCubit>().loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinCubit, DataState<CoinData>>(
      builder: (context, state) {
        final data = state.data;

        if (state.isLoading && data == null) {
          return const AppLoadingView();
        }
        if (state.isFailure && data == null) {
          return AppErrorView(
            message: state.error ?? 'Đã có lỗi xảy ra',
            onRetry: context.read<CoinCubit>().refresh,
          );
        }
        if (data == null) {
          return const SizedBox.shrink();
        }

        final txns = data.transactions;
        // Card số dư + khối nạp Xu + tiêu đề "Lịch sử" + (list HOẶC empty).
        final rowCount = 3 + (txns.isEmpty ? 1 : txns.length);
        return RefreshIndicator(
          onRefresh: context.read<CoinCubit>().refresh,
          child: ListView.separated(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: rowCount,
            separatorBuilder: (context, i) =>
                SizedBox(height: i == 0 ? AppSpacing.lg : AppSpacing.md),
            itemBuilder: (context, i) {
              if (i == 0) {
                return _BalanceCard(balance: data.balance);
              }
              if (i == 1) {
                return const _TopupSection();
              }
              if (i == 2) {
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    'Lịch sử biến động Xu',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              }
              if (txns.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xl),
                  child: AppEmptyView(
                    message: 'Chưa có giao dịch Xu nào',
                    icon: Icons.savings_outlined,
                  ),
                );
              }
              final idx = i - 3;
              final tile = CoinTransactionTile(transaction: txns[idx]);
              // Loader ở cuối khi còn trang.
              if (idx == txns.length - 1 && data.loadingMore) {
                return Column(
                  children: [
                    tile,
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                );
              }
              return tile;
            },
          ),
        );
      },
    );
  }
}

/// Card số dư Xu — số to, màu amber.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final CoinBalance balance;

  static final _money = NumberFormat.decimalPattern('vi_VN');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.warning.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.monetization_on,
              color: AppColors.warning,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${_money.format(balance.balance)} Xu',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Số dư hiện tại',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nút "Nạp Xu" + danh sách yêu cầu nạp đang chờ đối soát (PENDING).
class _TopupSection extends StatefulWidget {
  const _TopupSection();

  @override
  State<_TopupSection> createState() => _TopupSectionState();
}

class _TopupSectionState extends State<_TopupSection> {
  late Future<List<CoinTopup>> _future;
  static final _money = NumberFormat.decimalPattern('vi_VN');

  @override
  void initState() {
    super.initState();
    _future = context.read<CoinRepository>().fetchTopups();
  }

  void _refresh() {
    setState(() => _future = context.read<CoinRepository>().fetchTopups());
  }

  Future<void> _openTopup(BuildContext context) async {
    final amount = await AppBottomSheet.show<int>(
      context,
      child: const TopupAmountSheet(),
    );
    if (amount == null || !context.mounted) return;
    try {
      final topup = await context.read<CoinRepository>().createTopup(amount);
      if (!context.mounted) return;
      _refresh();
      await _showQr(context, topup);
    } on ApiException catch (e) {
      if (context.mounted) AppSnackBar.error(context, e.message);
    }
  }

  Future<void> _showQr(BuildContext context, CoinTopup topup) async {
    if (topup.qrPayload == null) return;
    await AppBottomSheet.show<void>(
      context,
      child: PaymentQrSheet(
        qr: InvoiceQr(
          qrPayload: topup.qrPayload!,
          bankName: topup.bankName ?? '',
          accountNumber: topup.accountNumber ?? '',
          accountName: topup.accountName ?? '',
          amount: topup.amountVnd,
          paymentCode: topup.paymentCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: 'Nạp Xu bằng chuyển khoản',
          icon: Icons.qr_code_2,
          onPressed: () => _openTopup(context),
        ),
        FutureBuilder<List<CoinTopup>>(
          future: _future,
          builder: (context, snap) {
            final pending =
                (snap.data ?? const <CoinTopup>[]).where((t) => t.isPending).toList();
            if (pending.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Yêu cầu nạp Xu đang chờ đối soát',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  for (final t in pending)
                    Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: ListTile(
                        leading: const Icon(Icons.hourglass_top, color: AppColors.warning),
                        title: Text('${_money.format(t.amountVnd)} đ · ${_money.format(t.coinAmount)} Xu'),
                        subtitle: Text('Mã CK: ${t.paymentCode}'),
                        trailing: TextButton(
                          onPressed: () => _showQr(context, t),
                          child: const Text('Xem QR'),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
