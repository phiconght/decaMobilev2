import 'package:deca_mobile/coin/view/coin_page.dart';
import 'package:deca_mobile/fee/view/fee_page.dart';
import 'package:flutter/material.dart';

/// Màn "Tài khoản và học phí" — gộp "Thanh toán"/"Học phí" (chuyển khoản
/// hàng tháng cho lớp offline) và "Xu của tôi" (số dư, nạp Xu, lịch sử biến
/// động Xu) vào 1 button duy nhất trên Trang chủ (yêu cầu người dùng).
class AccountFeePage extends StatelessWidget {
  const AccountFeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tài khoản và học phí'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Xu của tôi'),
              Tab(text: 'Học phí'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CoinPage(embedded: true),
            FeePage(embedded: true),
          ],
        ),
      ),
    );
  }
}
