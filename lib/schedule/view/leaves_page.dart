import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/core/widgets/async_list_view.dart';
import 'package:deca_mobile/schedule/cubit/leaves_cubit.dart';
import 'package:deca_mobile/schedule/data/leave_repository.dart';
import 'package:deca_mobile/schedule/data/models/leave_item.dart';
import 'package:deca_mobile/schedule/widgets/status_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Trang danh sach don nghi phep (hoc vien tu xem) hoac duyet don (giao vien).
class LeavesPage extends StatelessWidget {
  const LeavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions =
        context.read<AuthCubit>().state.user?.permissions ?? const [];
    final isApprover = permissions.contains('LEAVE:APPROVE');
    // Phụ huynh xác nhận đơn xin nghỉ của con — bắt buộc trước khi GV/nhân
    // viên duyệt được (yêu cầu người dùng 13/08/2026).
    final canConfirmParent = permissions.contains('LEAVE:CONFIRM');
    return BlocProvider(
      create: (ctx) {
        final cubit = LeavesCubit(
          ctx.read<LeaveRepository>(),
          statusFilter: isApprover ? 'PENDING' : null,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: _LeavesView(
        isApprover: isApprover,
        canConfirmParent: canConfirmParent,
      ),
    );
  }
}

class _LeavesView extends StatelessWidget {
  const _LeavesView({required this.isApprover, required this.canConfirmParent});

  final bool isApprover;
  final bool canConfirmParent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isApprover ? 'Duyệt đơn nghỉ' : 'Đơn xin nghỉ'),
      ),
      body: BlocBuilder<LeavesCubit, DataState<List<LeaveItem>>>(
        builder: (context, state) {
          return AsyncListView<LeaveItem>(
            state: state,
            onRefresh: context.read<LeavesCubit>().refresh,
            emptyMessage: isApprover
                ? 'Không có đơn chờ duyệt.'
                : 'Bạn chưa có đơn xin nghỉ nào.',
            itemBuilder: (ctx, item) => _LeaveCard(
              item: item,
              isApprover: isApprover,
              canConfirmParent: canConfirmParent,
            ),
          );
        },
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({
    required this.item,
    required this.isApprover,
    required this.canConfirmParent,
  });

  final LeaveItem item;
  final bool isApprover;
  final bool canConfirmParent;

  static final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  String _scopeText() {
    if (item.scope == LeaveScope.session) {
      final date = item.sessionDate;
      final dateLabel = date != null ? _fmt.format(date) : '';
      return 'Buổi: ${item.className ?? ''} · $dateLabel';
    }
    final from = item.dateFrom;
    final to = item.dateTo;
    final fromLabel = from != null ? _fmt.format(from) : '';
    final toLabel = to != null ? _fmt.format(to) : '';
    final classLabel =
        item.className != null ? ' · ${item.className}' : ' · Tất cả lớp';
    return 'Từ $fromLabel đến $toLabel$classLabel';
  }

  Future<void> _act(
    BuildContext context,
    Future<void> Function(int id) action,
  ) async {
    try {
      await action(item.id);
      if (!context.mounted) return;
      AppSnackBar.success(context, 'Đã cập nhật');
    } on ApiException catch (e) {
      if (!context.mounted) return;
      AppSnackBar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reason = item.reason;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.studentName ?? 'Học viên',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                LeaveStatusChip(status: item.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(_scopeText()),
            if (reason != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Lý do: $reason'),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.parentConfirmedBy != null
                  ? 'PH đã xác nhận: ${item.parentConfirmedBy}'
                  : 'Phụ huynh chưa xác nhận',
              style: TextStyle(
                fontSize: 12,
                color: item.parentConfirmedBy != null
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
            if (canConfirmParent &&
                item.parentConfirmedBy == null &&
                item.status == LeaveStatus.pending) ...[
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: () => _act(
                    context,
                    context.read<LeavesCubit>().confirmByParent,
                  ),
                  child: const Text('Xác nhận (phụ huynh)'),
                ),
              ),
            ],
            if (isApprover && item.status == LeaveStatus.pending) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        _act(context, context.read<LeavesCubit>().reject),
                    child: const Text('Từ chối'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: item.parentConfirmedBy == null
                        ? null
                        : () => _act(
                              context,
                              context.read<LeavesCubit>().approve,
                            ),
                    child: const Text('Duyệt'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
