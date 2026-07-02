import 'dart:async';

import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Dong ho dem nguoc thoi gian con lai.
///
/// Tu so huu [Timer]; moi tick tinh lai tu [deadline] co dinh nen dong ho van
/// dung du widget bi rebuild. Het gio goi [onExpire] dung 1 lan.
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    required this.deadline,
    required this.onExpire,
    super.key,
  });

  final DateTime deadline;
  final VoidCallback onExpire;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  late Duration _remaining;
  bool _fired = false;

  @override
  void initState() {
    super.initState();
    _remaining = _calc();
    if (_remaining <= Duration.zero) {
      _fire();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    }
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deadline != widget.deadline) {
      _fired = false;
      _timer?.cancel();
      _remaining = _calc();
      if (_remaining > Duration.zero) {
        _timer = Timer.periodic(const Duration(seconds: 1), _tick);
      } else {
        _fire();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _calc() {
    final d = widget.deadline.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  void _tick(Timer timer) {
    final next = _calc();
    if (next <= Duration.zero) {
      _fire();
    } else {
      setState(() => _remaining = next);
    }
  }

  void _fire() {
    if (_fired) return;
    _fired = true;
    _timer?.cancel();
    if (mounted) setState(() => _remaining = Duration.zero);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onExpire();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secs = _remaining.inSeconds;
    final danger = secs <= 60;
    final warn = secs <= 300;
    final color = danger
        ? AppColors.danger
        : warn
            ? AppColors.warning
            : theme.colorScheme.onSurface;
    final bg = danger
        ? AppColors.danger.withValues(alpha: 0.16)
        : warn
            ? AppColors.warning.withValues(alpha: 0.16)
            : theme.colorScheme.surfaceContainerHighest;

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: !reduceMotion && danger && secs.isOdd ? 0.45 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              _format(_remaining),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }
}
