import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/core/widgets/info_row.dart';
import 'package:deca_mobile/core/widgets/primary_button.dart';
import 'package:deca_mobile/core/widgets/section_card.dart';
import 'package:deca_mobile/schedule/data/leave_repository.dart';
import 'package:deca_mobile/schedule/data/models/leave_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Man hinh tao don xin nghi phep cho hoc vien.
class LeaveFormPage extends StatefulWidget {
  const LeaveFormPage({
    required this.studentId,
    required this.studentName,
    this.sessionId,
    this.sessionLabel,
    super.key,
  });

  final int studentId;
  final String studentName;
  final int? sessionId;
  final String? sessionLabel;

  @override
  State<LeaveFormPage> createState() => _LeaveFormPageState();
}

class _LeaveFormPageState extends State<LeaveFormPage> {
  late LeaveScope _scope =
      widget.sessionId != null ? LeaveScope.session : LeaveScope.range;
  DateTime? _from;
  DateTime? _to;
  final _reason = TextEditingController();
  bool _submitting = false;

  static final _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = (isFrom ? _from : _to) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('vi'),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_scope == LeaveScope.range &&
        (_from == null || _to == null || _from!.isAfter(_to!))) {
      AppSnackBar.error(context, 'Vui lòng chọn khoảng ngày hợp lệ');
      return;
    }
    setState(() => _submitting = true);
    try {
      await context.read<LeaveRepository>().create(
            CreateLeaveRequest(
              studentId: widget.studentId,
              scope: _scope,
              sessionId:
                  _scope == LeaveScope.session ? widget.sessionId : null,
              dateFrom: _scope == LeaveScope.range ? _from : null,
              dateTo: _scope == LeaveScope.range ? _to : null,
              reason: _reason.text,
            ),
          );
      if (!mounted) return;
      AppSnackBar.success(context, 'Đã gửi đơn xin nghỉ');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSession = widget.sessionId != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Xin nghỉ phép')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoRow(label: 'Học viên', value: widget.studentName),
          const SizedBox(height: 16),
          SegmentedButton<LeaveScope>(
            segments: [
              ButtonSegment<LeaveScope>(
                value: LeaveScope.session,
                label: const Text('Một buổi'),
                enabled: hasSession,
              ),
              const ButtonSegment<LeaveScope>(
                value: LeaveScope.range,
                label: Text('Nhiều ngày'),
              ),
            ],
            selected: {_scope},
            onSelectionChanged: (selected) =>
                setState(() => _scope = selected.first),
          ),
          const SizedBox(height: 16),
          if (_scope == LeaveScope.session)
            SectionCard(
              title: 'Buổi học',
              child: Text(widget.sessionLabel ?? 'Buổi đã chọn'),
            )
          else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Từ ngày'),
              subtitle: Text(
                _from == null ? 'Chọn ngày' : _dateFmt.format(_from!),
              ),
              onTap: () => _pickDate(isFrom: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Đến ngày'),
              subtitle: Text(
                _to == null ? 'Chọn ngày' : _dateFmt.format(_to!),
              ),
              onTap: () => _pickDate(isFrom: false),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _reason,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Lý do (không bắt buộc)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Gửi đơn',
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
