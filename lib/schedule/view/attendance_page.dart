import 'dart:async';

import 'package:deca_mobile/auth/cubit/auth_cubit.dart';
import 'package:deca_mobile/core/widgets/app_bottom_sheet.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/schedule/data/attendance_repository.dart';
import 'package:deca_mobile/schedule/data/models/attendance_item.dart';
import 'package:deca_mobile/schedule/data/models/timetable_item.dart';
import 'package:deca_mobile/schedule/widgets/attendance_badge.dart';
import 'package:deca_mobile/schedule/widgets/qr_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diem danh hoc vien trong 1 buoi (danh cho giao vien).
class AttendancePage extends StatefulWidget {
  const AttendancePage({
    required this.sessionId,
    required this.sessionTitle,
    super.key,
  });

  final int sessionId;
  final String sessionTitle;

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late final AttendanceRepository _repo;
  List<AttendanceItem> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = context.read<AttendanceRepository>();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repo.list(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is Exception ? '$e'.replaceFirst('Exception: ', '') : '$e';
        _loading = false;
      });
    }
  }

  Future<void> _setStatus(AttendanceItem item, AttendanceStatus status) async {
    try {
      await _repo.setStatus(widget.sessionId, item.userId, status);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      AppSnackBar.success(context, 'Đã cập nhật điểm danh');
    } on Object catch (e) {
      if (!mounted) return;
      final message =
          e is Exception ? '$e'.replaceFirst('Exception: ', '') : '$e';
      AppSnackBar.error(context, message);
    }
  }

  void _showQr() {
    unawaited(
      AppBottomSheet.show<void>(
        context,
        child: QrView(
          sessionId: widget.sessionId,
          fetchToken: () => _repo.qrToken(widget.sessionId),
        ),
      ),
    );
  }

  Future<void> _pickStatus(AttendanceItem item) async {
    final picked = await AppBottomSheet.show<AttendanceStatus>(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              item.fullName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final status in AttendanceStatus.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Align(
                alignment: Alignment.centerLeft,
                child: AttendanceBadge(status: status),
              ),
              onTap: () => Navigator.of(context).pop(status),
            ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    await _setStatus(item, picked);
  }

  @override
  Widget build(BuildContext context) {
    final canWrite = context
            .read<AuthCubit>()
            .state
            .user
            ?.permissions
            .contains('CLASS:WRITE') ??
        false;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Điểm danh'),
            Text(
              widget.sessionTitle,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showQr,
            icon: const Icon(Icons.qr_code),
            tooltip: 'Mã QR điểm danh',
          ),
        ],
      ),
      body: _buildBody(canWrite: canWrite),
    );
  }

  Widget _buildBody({required bool canWrite}) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return AppErrorView(message: _error!, onRetry: _load);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final subtitle = item.phone != null
              ? '${item.username} · ${item.phone}'
              : item.username;
          return ListTile(
            title: Text(item.fullName),
            subtitle: Text(subtitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AttendanceBadge(status: item.status),
                if (canWrite) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _pickStatus(item),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Cập nhật điểm danh',
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
