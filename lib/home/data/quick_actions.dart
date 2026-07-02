import 'package:deca_mobile/catalog/view/catalog_page.dart';
import 'package:deca_mobile/core/widgets/quick_action.dart';
import 'package:deca_mobile/home/view/home_shell.dart';
import 'package:deca_mobile/payment/view/payment_page.dart';
import 'package:flutter/material.dart';

/// Danh sach tien ich hien thi trong QuickActionStrip tren Trang chu.
///
/// De them button moi: noi them 1 phan tu vao day.
/// enabled: false => tap hien SnackBar "Sap ra mat" (khong can tao page).
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
    id: 'exam_schedule',
    label: 'Lịch\nthi',
    icon: Icons.event_note_outlined,
    // Chua co page — se mo khoa khi san sang
    enabled: false,
  ),
  QuickAction(
    id: 'documents',
    label: 'Tài\nliệu',
    icon: Icons.folder_open_outlined,
    enabled: false,
  ),
  QuickAction(
    id: 'attendance',
    label: 'Điểm\ndanh',
    icon: Icons.how_to_reg_outlined,
    // Nhay sang tab TKB (index 1) — hub thao tac diem danh / cham cong.
    onTap: _goToTimetable,
  ),
];

Widget _buildCatalog(BuildContext context) => const CatalogPage();
Widget _buildPayment(BuildContext context) => const PaymentPage();
void _goToTimetable(BuildContext context) =>
    HomeShellScope.of(context).switchTab(1);
