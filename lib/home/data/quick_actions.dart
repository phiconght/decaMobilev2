import 'package:deca_mobile/catalog/view/catalog_page.dart';
import 'package:deca_mobile/coin/view/coin_page.dart';
import 'package:deca_mobile/core/widgets/quick_action.dart';
import 'package:deca_mobile/fee/view/fee_page.dart';
import 'package:deca_mobile/home/view/home_shell.dart';
import 'package:deca_mobile/payment/view/payment_page.dart';
import 'package:flutter/material.dart';

/// Danh sach tien ich hien thi trong QuickActionStrip tren Trang chu.
///
/// De them button moi: noi them 1 phan tu vao day.
/// enabled: false => tap hien SnackBar "Sap ra mat" (khong can tao page).
/// roles rong = hien voi moi vai tro; co roles = chi hien voi vai tro do.
const List<QuickAction> homeQuickActions = [
  QuickAction(
    id: 'all_courses',
    label: 'Tất cả\nkhóa học',
    icon: Icons.school_outlined,
    builder: _buildCatalog,
  ),
  QuickAction(
    id: 'payment',
    label: 'Thanh\ntoán',
    icon: Icons.payments_outlined,
    builder: _buildPayment,
  ),
  QuickAction(
    id: 'fee',
    label: 'Học\nphí',
    icon: Icons.account_balance_wallet_outlined,
    builder: _buildFee,
    roles: ['STUDENT', 'PARENT'],
  ),
  QuickAction(
    id: 'coin',
    label: 'Xu của\ntôi',
    icon: Icons.savings_outlined,
    builder: _buildCoin,
    roles: ['STUDENT', 'PARENT'],
  ),
  QuickAction(
    id: 'attendance',
    label: 'Điểm\ndanh',
    icon: Icons.how_to_reg_outlined,
    // Nhay sang tab TKB (index 1) — hub thao tac diem danh / cham cong.
    onTap: _goToTimetable,
  ),
];

/// Loc tien ich theo vai tro nguoi dung hien tai.
List<QuickAction> quickActionsFor(List<String> roles) =>
    homeQuickActions.where((a) => a.visibleFor(roles)).toList();

Widget _buildCatalog(BuildContext context) => const CatalogPage();
Widget _buildPayment(BuildContext context) => const PaymentPage();
Widget _buildFee(BuildContext context) => const FeePage();
Widget _buildCoin(BuildContext context) => const CoinPage();
void _goToTimetable(BuildContext context) =>
    HomeShellScope.of(context).switchTab(1);
