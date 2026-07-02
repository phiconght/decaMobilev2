import 'dart:async';

import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Trang quet QR de lay token check-in/check-out.
///
/// Tra ve `String?` token qua [Navigator.pop]. Khong tu goi checkin/checkout.
class QrScanPage extends StatefulWidget {
  const QrScanPage({required this.isCheckout, this.title, super.key});

  /// `true` neu dang quet de check-out, `false` cho check-in.
  final bool isCheckout;

  /// Tieu de tuy chinh (vd 'Quét QR phòng — chấm công'); null -> mac dinh theo [isCheckout].
  final String? title;

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    _handled = true;
    Navigator.pop(context, code);
  }

  Future<void> _enterManually() async {
    final controller = TextEditingController();
    final token = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nhập mã thủ công'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Dán hoặc nhập mã token',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();
                Navigator.pop(context, value.isEmpty ? null : value);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (!mounted || token == null || _handled) return;
    _handled = true;
    Navigator.pop(context, token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ??
              (widget.isCheckout ? 'Quét QR check-out' : 'Quét QR check-in'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard),
            tooltip: 'Nhập mã thủ công',
            onPressed: _enterManually,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: AppRadii.rlg,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.xxl,
            child: Padding(
              padding: AppSpacing.screen,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral.withValues(alpha: 0.7),
                  borderRadius: AppRadii.rmd,
                ),
                child: const Text(
                  'Đưa mã QR tại phòng vào khung',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
