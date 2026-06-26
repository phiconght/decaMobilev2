import 'package:deca_mobile/core/widgets/app_empty_view.dart';
import 'package:flutter/material.dart';

/// Man Thong bao — placeholder cho den khi BE co endpoint.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: const AppEmptyView(
        icon: Icons.notifications_none,
        message: 'Bạn chưa có thông báo nào.',
      ),
    );
  }
}
