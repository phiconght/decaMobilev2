import 'package:flutter/widgets.dart';

/// Thang khoang cach (4/8/12/16/24/32) — dung thay cho so le.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Padding mep man hinh mac dinh.
  static const screen = EdgeInsets.all(lg);

  // Khoang trong dung san.
  static const gapXs = SizedBox(height: xs, width: xs);
  static const gapSm = SizedBox(height: sm, width: sm);
  static const gapMd = SizedBox(height: md, width: md);
  static const gapLg = SizedBox(height: lg, width: lg);
  static const gapXl = SizedBox(height: xl, width: xl);
}

/// Bo goc chuan.
abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  static const BorderRadius rsm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rmd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rlg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rxl = BorderRadius.all(Radius.circular(xl));
}

/// Thoi luong animation chuan.
abstract final class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
}
