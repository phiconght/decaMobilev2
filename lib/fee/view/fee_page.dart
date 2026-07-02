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
/// STUDENT → đợt thu của mình; PARENT → chọn con (qua /reports/my-children).
class FeePage extends StatelessWidget {
  const FeePage({super.key});

  @override
  Widget build(BuildContext context) {
    final roles =
        context.read<AuthCubit>().state.user?.roles ?? const <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Học phí')),
      body: roles.contains('PARENT')
          ? _ParentFee(reports: context.read<ReportsRepository>())
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

/// PARENT: chọn con → danh sách đợt thu của con.
class _ParentFee extends StatefulWidget {
  const _ParentFee({required this.reports});

  final ReportsRepository reports;

  @override
  State<_ParentFee> createState() => _ParentFeeState();
}

class _ParentFeeState extends State<_ParentFee> {
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
                        final cubit = FeeCubit(
                          ctx.read<FeeRepository>(),
                          studentId: _selected!.studentId,
                        );
                        unawaited(cubit.load());
                        return cubit;
                      },
                      child: const _FeeList(),
                    ),
            ),
          ],
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
