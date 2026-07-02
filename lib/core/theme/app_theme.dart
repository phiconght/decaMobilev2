import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Theme tap trung — Material 3, chu dao DO-TRANG (xem Mobile_MauSac_DoTrang.md).
///
/// KHONG dung fromSeed thuan (no khu bao hoa -> nhat): dung fromSeed lam nen
/// roi copyWith de HAM cac slot theo bang mau da chot. Doi giao dien toan app
/// chi sua o day (+ app_colors.dart).
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ColorScheme _lightScheme() =>
      ColorScheme.fromSeed(seedColor: AppColors.brand).copyWith(
        brightness: Brightness.light,
        primary: const Color(0xFFBE2A3D),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFFFE4E3),
        onPrimaryContainer: const Color(0xFF6E1420),
        secondary: const Color(0xFF8C5F5C),
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFF6DDDB),
        onSecondaryContainer: const Color(0xFF4C2B29),
        tertiary: AppColors.gold,
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFF7E7C3),
        onTertiaryContainer: const Color(0xFF4A3708),
        error: AppColors.danger,
        onError: Colors.white,
        errorContainer: const Color(0xFFF9DEDC),
        onErrorContainer: const Color(0xFF410E0B),
        surface: const Color(0xFFFFFBFA),
        onSurface: const Color(0xFF241A19),
        onSurfaceVariant: const Color(0xFF5F4F4E),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFF9F1F0),
        surfaceContainer: const Color(0xFFF7EEED),
        surfaceContainerHigh: const Color(0xFFF5EAE9),
        surfaceContainerHighest: const Color(0xFFF3E7E6),
        outline: const Color(0xFF9C8B8A),
        outlineVariant: const Color(0xFFE4D6D5),
      );

  static ColorScheme _darkScheme() =>
      ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        brightness: Brightness.dark,
      ).copyWith(
        brightness: Brightness.dark,
        primary: const Color(0xFFFFB3AE),
        onPrimary: const Color(0xFF5F1210),
        primaryContainer: const Color(0xFF8E0E23),
        onPrimaryContainer: const Color(0xFFFFDAD9),
        secondary: const Color(0xFFE0BBB8),
        onSecondary: const Color(0xFF422B29),
        secondaryContainer: const Color(0xFF5D403D),
        onSecondaryContainer: const Color(0xFFFFDAD6),
        tertiary: const Color(0xFFE3C077),
        onTertiary: const Color(0xFF3E2E00),
        tertiaryContainer: const Color(0xFF5A4419),
        onTertiaryContainer: const Color(0xFFF7E7C3),
        error: const Color(0xFFFFB4AB),
        onError: const Color(0xFF690005),
        errorContainer: const Color(0xFF8C1D18),
        onErrorContainer: const Color(0xFFFFDAD6),
        surface: const Color(0xFF1A1414),
        onSurface: const Color(0xFFF1E0DE),
        onSurfaceVariant: const Color(0xFFD3C0BE),
        surfaceContainerLowest: const Color(0xFF150F0F),
        surfaceContainerLow: const Color(0xFF241C1B),
        surfaceContainer: const Color(0xFF281F1E),
        surfaceContainerHigh: const Color(0xFF332827),
        surfaceContainerHighest: const Color(0xFF3A2E2D),
        outline: const Color(0xFFA08C8A),
        outlineVariant: const Color(0xFF52443F),
      );

  static ThemeData _build(Brightness brightness) {
    final scheme =
        brightness == Brightness.dark ? _darkScheme() : _lightScheme();
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = base.textTheme;
    final outline = scheme.outlineVariant.withValues(alpha: 0.5);

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rlg,
          side: BorderSide(color: outline),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // KHONG dung Size.fromHeight (min-width = infinity): button dat trong
          // Row/ngu canh khong gioi han be rong se lam sap layout ca man hinh.
          // Full-width do noi dat button quyet dinh (PrimaryButton/SizedBox).
          minimumSize: const Size(64, 50),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rmd),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rmd),
          // Vien do thuong hieu (thay outline xam cu).
          side: BorderSide(color: scheme.primary, width: 1.2),
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rsm),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? scheme.primary
                  : scheme.surface),
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? scheme.onPrimary
                  : scheme.onSurfaceVariant),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outlineVariant),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.rmd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.rmd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.rmd,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.rmd,
          borderSide: BorderSide(color: scheme.error),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: scheme.secondaryContainer,
        labelStyle: TextStyle(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),

      dialogTheme: DialogThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rxl),
        elevation: 1,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.rmd),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        // Indicator do nhat + icon/label chon mau do thuong hieu.
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
        elevation: 3,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer.withValues(alpha: 0.5),
        circularTrackColor: Colors.transparent,
      ),

      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
