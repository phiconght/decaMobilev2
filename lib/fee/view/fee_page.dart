import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_bottom_sheet.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/core/widgets/async_list_view.dart';
import 'package:deca_mobile/fee/cubit/fee_cubit.dart';
import 'package:deca_mobile/fee/data/fee_repository.dart';
import 'package:deca_mobile/fee/data/models/invoice.dart';
import 'package:deca_mobile/fee/widgets/invoice_card.dart';
import 'package:deca_mobile/fee/widgets/payment_qr_sheet.dart';
import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/data/reports_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Màn "Học phí" — điều hướng theo vai trò:
/// STUDENT → đợt thu của mình; PARENT → gộp đợt thu của TẤT CẢ các con
/// (không còn chọn từng con — yêu cầu người dùng 11/08/2026), lấy danh sách
/// con qua /reports/my-children.
class FeePage extends StatelessWidget {
  const FeePage({super.key});

  @override
  Widget build(BuildContext context) {
    final roles =
        context.read<AuthCubit>().state.user?.roles ?? const <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Học phí')),
      body: roles.contains('PARENT')
          ? _ParentFee(
              reports: context.read<ReportsRepository>(),
              fee: context.read<FeeRepository>(),
            )
          : _StudentFee(studentId: null),
    );
  }
}

/// STUDENT: xem đợt thu của chính mình (BE suy ra từ token).
class _StudentFee extends StatelessWidget {
  const _StudentFee({required this.studentId});

  final int? studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = FeeCubit(
          ctx.read<FeeRepository>(),
          studentId: studentId,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const _FeeList(),
    );
  }
}

/// 1 con + đợt thu học phí của con đó (§ giao diện PH xem TẤT CẢ các con
/// cùng lúc, không phải chọn từng con — yêu cầu người dùng 11/08/2026).
class _ChildInvoices {
  const _ChildInvoices({required this.child, required this.invoices});
  final ChildOption child;
  final List<MyInvoiceItem> invoices;
}

/// PARENT: hiện GỘP học phí của TẤT CẢ các con (mỗi con 1 khối riêng),
/// không còn dropdown chọn từng con một.
class _ParentFee extends StatefulWidget {
  const _ParentFee({required this.reports, required this.fee});

  final ReportsRepository reports;
  final FeeRepository fee;

  @override
  State<_ParentFee> createState() => _ParentFeeState();
}

class _ParentFeeState extends State<_ParentFee> {
  late Future<List<_ChildInvoices>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_ChildInvoices>> _load() async {
    final children = await widget.reports.myChildren();
    return Future.wait(children.map((c) async {
      final invoices = await widget.fee.fetchMyInvoices(studentId: c.studentId);
      return _ChildInvoices(child: c, invoices: invoices);
    }));
  }

  Future<void> _refresh() async {
    final f = _load();
    setState(() => _future = f);
    await f;
  }

  Future<void> _pay(BuildContext context, MyInvoiceItem invoice) async {
    try {
      final qr = await widget.fee.fetchQr(invoice.id);
      if (!context.mounted) return;
      await AppBottomSheet.show<void>(context, child: PaymentQrSheet(qr: qr));
    } on ApiException catch (e) {
      if (context.mounted) AppSnackBar.error(context, e.message);
    } on Object catch (_) {
      if (context.mounted) AppSnackBar.error(context, 'Đã có lỗi xảy ra');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_ChildInvoices>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const Center(child: Text('Không tải được học phí.'));
        }
        final groups = snap.data ?? const <_ChildInvoices>[];
        if (groups.isEmpty) {
          return const Center(child: Text('Chưa liên kết học viên nào.'));
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              for (final g in groups) ...[
                Text(
                  g.child.fullName,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (g.invoices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Text('Chưa có khoản học phí nào cần thanh toán'),
                  )
                else
                  for (final invoice in g.invoices)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: InvoiceCard(
                        invoice: invoice,
                        onPay: () => _pay(context, invoice),
                      ),
                    ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Danh sách đợt thu — 4 trạng thái chuẩn + card THANH TOÁN.
class _FeeList extends StatelessWidget {
  const _FeeList();

  Future<void> _pay(BuildContext context, MyInvoiceItem invoice) async {
    final repo = context.read<FeeRepository>();
    try {
      final qr = await repo.fetchQr(invoice.id);
      if (!context.mounted) return;
      await AppBottomSheet.show<void>(
        context,
        child: PaymentQrSheet(qr: qr),
      );
    } on ApiException catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, e.message);
      }
    } on Object catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Đã có lỗi xảy ra');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeeCubit, DataState<List<MyInvoiceItem>>>(
      builder: (context, state) {
        return AsyncListView<MyInvoiceItem>(
          state: state,
          onRefresh: context.read<FeeCubit>().refresh,
          emptyMessage: 'Chưa có khoản học phí nào cần thanh toán',
          itemBuilder: (context, invoice) => InvoiceCard(
            invoice: invoice,
            onPay: () => _pay(context, invoice),
          ),
        );
      },
    );
  }
}
