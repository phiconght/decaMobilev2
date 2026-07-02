import 'dart:async';

import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/schedule/data/models/qr_token.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Hien thi ma QR de hoc vien quet diem danh, tu lam moi khi het han.
class QrView extends StatefulWidget {
  const QrView({
    required this.sessionId,
    required this.fetchToken,
    super.key,
  });

  final int sessionId;
  final Future<QrToken> Function() fetchToken;

  @override
  State<QrView> createState() => _QrViewState();
}

class _QrViewState extends State<QrView> {
  QrToken? _token;
  int _remaining = 0;
  Timer? _timer;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    _timer?.cancel();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final t = await widget.fetchToken();
      if (!mounted) return;
      setState(() {
        _token = t;
        _remaining = t.ttlSeconds;
        _loading = false;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (_remaining <= 0) {
          unawaited(_load());
          return;
        }
        setState(() => _remaining--);
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tạo được mã QR, vui lòng thử lại.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading && _token == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, textAlign: TextAlign.center),
          AppSpacing.gapMd,
          TextButton(
            onPressed: _load,
            child: const Text('Thử lại'),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          data: _token!.token,
          size: 220,
        ),
        AppSpacing.gapMd,
        Text('Còn lại: ${_remaining}s'),
        Text(
          'Học viên quét mã này để điểm danh',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
