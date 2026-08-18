import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme tap trung — Material 3, chu dao COBALT tren nen GIAY AM.
/// Xem ThietKe/Mobile/KE_HOACH_TRIEN_KHAI.md §2 cho bang token day du.
///
/// KHONG dung fromSeed thuan (no khu bao hoa -> nhat): dung fromSeed lam nen
/// roi copyWith de HAM cac slot theo bang mau da chot. Doi giao dien toan app
/// chi sua o day (+ app_colors.dart).
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  // Sac dam cho chu tren nen container nhat (tinh tay, khong co trong
  // AppColors vi mock chi dinh nghia 1 sac coral — day la shade rieng cho
  // rieng onErrorContainer de dat tuong phan AA).
  static const _onDangerContainerLight = Color(0xFFB23A46);
  static const _onWarningContainerLight = AppColors.warningDark;

  static ColorScheme _lightScheme() =>
      ColorScheme.fromSeed(seedColor: AppColors.brand).copyWith(
        brightness: Brightness.light,
        primary: AppColors.brand,
        onPrimary: Colors.white,
        primaryContainer: AppColors.brandTint,
        onPrimaryContainer: AppColors.brandDark,
        secondary: AppColors.inkSoft,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.lineSoft,
        onSecondaryContainer: AppColors.ink,
        tertiary: AppColors.warningDark,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.warningTint,
        onTertiaryContainer: _onWarningContainerLight,
        error: AppColors.danger,
        onError: Colors.white,
        errorContainer: AppColors.dangerTint,
        onErrorContainer: _onDangerContainerLight,
        surface: AppColors.paper,
        onSurface: AppColors.ink,
        onSurfaceVariant: AppColors.inkSoft,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: AppColors.card,
        surfaceContainer: AppColors.cardWarm,
        surfaceContainerHigh: AppColors.lineSoft,
        surfaceContainerHighest: AppColors.lineSoft,
        outline: AppColors.line,
        outlineVariant: AppColors.lineSoft,
      );

  static ColorScheme _darkScheme() =>
      ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        brightness: Brightness.dark,
      ).copyWith(
        brightness: Brightness.dark,
        primary: const Color(0xFFB6C0FF),
        onPrimary: const Color(0xFF152088),
        primaryContainer: const Color(0xFF1E2FB8),
        onPrimaryContainer: const Color(0xFFDCE1FF),
        secondary: const Color(0xFFCBC4D6),
        onSecondary: const Color(0xFF322E3C),
        secondaryContainer: const Color(0xFF433F4E),
        onSecondaryContainer: const Color(0xFFE6E1F0),
        tertiary: const Color(0xFFF5C877),
        onTertiary: const Color(0xFF3E2E00),
        tertiaryContainer: const Color(0xFF6B4E12),
        onTertiaryContainer: const Color(0xFFFBF0DC),
        error: const Color(0xFFFFB3B8),
        onError: const Color(0xFF66000E),
        errorContainer: const Color(0xFF8E2A34),
        onErrorContainer: const Color(0xFFFFDADC),
        surface: const Color(0xFF17151C),
        onSurface: const Color(0xFFEAE7F0),
        onSurfaceVariant: const Color(0xFFC8C3D2),
        surfaceContainerLowest: const Color(0xFF100F14),
        surfaceContainerLow: const Color(0xFF201E27),
        surfaceContainer: const Color(0xFF25222C),
        surfaceContainerHigh: const Color(0xFF2E2B36),
        surfaceContainerHighest: const Color(0xFF393541),
        outline: const Color(0xFF948F9E),
        outlineVariant: const Color(0xFF454152),
      );

  static TextTheme _textTheme(TextTheme base) {
    final body = GoogleFonts.beVietnamProTextTheme(base);
    final display = GoogleFonts.plusJakartaSansTextTheme(base);
    return body.copyWith(
      displayLarge: display.displayLarge?.copyWith(fontWeight: FontWeight.w800),
      displayMedium:
          display.displayMedium?.copyWith(fontWeight: FontWeight.w800),
      displaySmall: display.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineLarge:
          display.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
      headlineMedium:
          display.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      headlineSmall:
          display.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: display.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: display.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final scheme =
        brightness == Brightness.dark ? _darkScheme() : _lightScheme();
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = _textTheme(base.textTheme);
    final outline = scheme.outlineVariant;

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
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
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rmd),
          side: BorderSide(color: scheme.primary, width: 1.2),
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rsm),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
          side: WidgetStatePropertyAll(BorderSide(color: outline)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),

      dialogTheme: DialogThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rxl),
        elevation: 1,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
                ? FontWeight.w700
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

/// Font mono (JetBrains Mono) cho so lieu/ngay/ma — M3 TextTheme khong co
/// slot san cho monospace nen tach rieng thanh helper.
abstract final class AppFonts {
  static TextStyle mono(
    BuildContext context, {
    TextStyle? base,
    FontWeight weight = FontWeight.w600,
  }) {
    final source = base ?? Theme.of(context).textTheme.bodyMedium!;
    return GoogleFonts.jetBrainsMono(textStyle: source, fontWeight: weight);
  }
}
