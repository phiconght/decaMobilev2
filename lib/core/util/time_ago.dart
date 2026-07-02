import 'package:intl/intl.dart';

/// Thoi gian tuong doi tieng Viet: "Vừa xong", "5 phút trước", "3 giờ trước",
/// hoac ngay gio tuyet doi neu qua 1 ngay.
String timeAgo(DateTime? time) {
  if (time == null) return '';
  final now = DateTime.now();
  final diff = now.difference(time.toLocal());
  if (diff.inMinutes < 1) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  return DateFormat('dd/MM/yyyy HH:mm').format(time.toLocal());
}
