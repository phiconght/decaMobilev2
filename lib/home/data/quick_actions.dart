import 'package:deca_mobile/account/view/account_fee_page.dart';
import 'package:deca_mobile/catalog/view/catalog_page.dart';
import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/widgets/quick_action.dart';
import 'package:deca_mobile/home/view/home_shell.dart';
import 'package:flutter/material.dart';

/// Danh sach tien ich hien thi trong QuickActionStrip tren Trang chu.
///
/// De them button moi: noi them 1 phan tu vao day.
/// enabled: false => tap hien SnackBar "Sap ra mat" (khong can tao page).
/// roles rong = hien voi moi vai tro; co roles = chi hien voi vai tro do.
/// [tint]: mau icon rieng theo token — xem KE_HOACH_TRIEN_KHAI.md §0.2/§5.1
/// (giu nguyen 5 hanh vi cu, chi doi mau/icon theo mockup moi).
const List<QuickAction> homeQuickActions = [
  QuickAction(
    id: 'all_courses',
    label: 'Khám phá\nkhóa học',
    icon: Icons.explore_outlined,
    builder: _buildCatalog,
    tint: AppColors.brand,
  ),
  QuickAction(
    id: 'account_fee',
    label: 'Tài khoản\nvà học phí',
    icon: Icons.account_balance_wallet_outlined,
    builder: _buildAccountFee,
    roles: ['STUDENT', 'PARENT'],
    tint: AppColors.success,
  ),
  QuickAction(
    id: 'attendance',
    label: 'Điểm\ndanh',
    icon: Icons.how_to_reg_outlined,
    // Nhay sang tab TKB (index 1) — hub thao tac diem danh / cham cong.
    onTap: _goToTimetable,
    tint: AppColors.danger,
  ),
];

/// Loc tien ich theo vai tro nguoi dung hien tai.
List<QuickAction> quickActionsFor(List<String> roles) =>
    homeQuickActions.where((a) => a.visibleFor(roles)).toList();

Widget _buildCatalog(BuildContext context) => const CatalogPage();
Widget _buildAccountFee(BuildContext context) => const AccountFeePage();
void _goToTimetable(BuildContext context) =>
    HomeShellScope.of(context).switchTab(1);
