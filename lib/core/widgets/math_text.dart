import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Tach 1 chuoi hon hop text thuong + LaTeX theo cu phap `$...$` (inline)
/// hoac `$$...$$` (khoi, tach dong rieng). Non-greedy, ho tro xuong dong
/// ben trong `$$...$$` (dotAll) nhung KHONG cho `$...$` inline vuot qua dong.
final RegExp _mathPattern = RegExp(
  r'\$\$[\s\S]+?\$\$|\$[^\n$]+?\$',
);

/// Render 1 chuoi hon hop text thuong + cong thuc LaTeX (`$...$`/`$$...$$`)
/// dung `flutter_math_fork` (khong WebView — xem
/// SPEC_CongThucToan_NhapHangLoat.md §8.3/§15.3). Cong thuc loi cu phap se
/// fallback hien lai text tho (khong crash man hinh lam bai).
class MathText extends StatelessWidget {
  const MathText(
    this.data, {
    this.style,
    super.key,
  });

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (!data.contains(r'$')) {
      return Text(data, style: style);
    }

    final theme = Theme.of(context);
    final baseStyle = style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final match in _mathPattern.allMatches(data)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: data.substring(lastEnd, match.start)));
      }
      final raw = match.group(0)!;
      final isBlock = raw.startsWith(r'$$');
      final expr = isBlock
          ? raw.substring(2, raw.length - 2).trim()
          : raw.substring(1, raw.length - 1).trim();
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            expr,
            mathStyle: isBlock ? MathStyle.display : MathStyle.text,
            textStyle: baseStyle,
            onErrorFallback: (_) => Text(
              raw,
              style: baseStyle.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < data.length) {
      spans.add(TextSpan(text: data.substring(lastEnd)));
    }

    return Text.rich(TextSpan(style: baseStyle, children: spans));
  }
}
