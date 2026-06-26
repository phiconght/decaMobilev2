import 'package:deca_mobile/core/widgets/app_empty_view.dart';
import 'package:flutter/material.dart';

/// Man Tin nhan — placeholder cho den khi BE co endpoint.
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tin nhắn')),
      body: const AppEmptyView(
        icon: Icons.chat_bubble_outline,
        message: 'Bạn chưa có tin nhắn nào.',
      ),
    );
  }
}
