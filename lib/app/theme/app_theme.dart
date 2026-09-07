import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kipto/app/theme/app_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final colors = dark ? _darkScheme : _lightScheme;
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: 'Inter',
    );
    final textTheme = base.textTheme.apply(
      bodyColor: colors.onSurface,
      displayColor: colors.onSurface,
    );
    final hairline = colors.onSurface.withValues(alpha: dark ? 0.10 : 0.12);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      canvasColor: colors.surface,
      splashFactory: InkRipple.splashFactory,
      textTheme: textTheme.copyWith(
        displaySmall: textTheme.displaySmall?.copyWith(
          fontSize: 32,
          height: 37 / 32,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.4,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: 28,
          height: 1.10,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.4,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          height: 1.18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.35,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: 16,
          height: 1.28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.12,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: 15,
          height: 1.42,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.40,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: 12.5,
          height: 1.35,
          color: colors.onSurfaceVariant,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: 14,
          height: 1.15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.05,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontSize: 12,
          height: 1.15,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 68,
        titleSpacing: AppSpacing.ml,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: colors.onSurface,
          fontSize: 25,
          height: 1.1,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.65,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 64,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.onSurface.withValues(alpha: 0.09),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Inter',
            color: colors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 15,
        ),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          color: colors.onSurfaceVariant,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          color: colors.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.72)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.error.withValues(alpha: 0.7)),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          side: BorderSide(color: hairline),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: colors.onSurface,
          fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        modalElevation: 0,
        backgroundColor: colors.surfaceContainerLow,
        modalBackgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Colors.black.withValues(alpha: 0.62),
        showDragHandle: true,
        dragHandleColor: colors.onSurface.withValues(alpha: 0.22),
        dragHandleSize: const Size(38, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xxl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surfaceContainerHighest,
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: colors.onSurface,
        ),
        actionTextColor: colors.primary,
        insetPadding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: hairline),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: hairline),
        shape: const StadiumBorder(),
        backgroundColor: colors.surfaceContainer.withValues(alpha: 0.72),
        selectedColor: colors.onSurface.withValues(alpha: dark ? 0.13 : 0.09),
        disabledColor: colors.surfaceContainer.withValues(alpha: 0.40),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          color: colors.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: 'Inter',
          color: colors.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colors.onSurfaceVariant, size: 17),
        padding: const EdgeInsets.symmetric(horizontal: 7),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              elevation: 0,
              minimumSize: const Size(48, 56),
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 13),
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ).copyWith(
              overlayColor: WidgetStatePropertyAll(
                colors.onPrimary.withValues(alpha: 0.10),
              ),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(48, 56),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          side: BorderSide(color: hairline),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
          shape: const StadiumBorder(),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(48),
          iconSize: 20,
          foregroundColor: colors.onSurface,
          shape: const CircleBorder(),
        ),
      ),
      listTileTheme: ListTileThemeData(
        minTileHeight: 62,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 3,
        ),
        iconColor: colors.onSurfaceVariant,
        textColor: colors.onSurface,
        subtitleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: colors.onSurfaceVariant,
          fontSize: 12.5,
          height: 1.34,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(colors.surfaceContainer),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStatePropertyAll(BorderSide(color: hairline)),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        constraints: const BoxConstraints(minHeight: 52),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontFamily: 'Inter', color: colors.onSurface, fontSize: 15),
        ),
        hintStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Inter',
            color: colors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colors.onSurface.withValues(alpha: dark ? 0.12 : 0.08)
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colors.onSurface
                : colors.onSurfaceVariant,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: hairline)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.surfaceContainerHighest,
        ),
        thumbColor: WidgetStatePropertyAll(
          dark ? AppColors.textPrimary : AppColors.lightSurface,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.tertiary,
        linearTrackColor: colors.onSurface.withValues(alpha: 0.08),
        circularTrackColor: colors.onSurface.withValues(alpha: 0.08),
        linearMinHeight: 3,
      ),
      dividerTheme: DividerThemeData(color: hairline, thickness: 1, space: 1),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 0,
        color: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: hairline),
        ),
      ),
      visualDensity: VisualDensity.standard,
    );
  }

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryMauve,
    onPrimary: Color(0xFF24161D),
    primaryContainer: Color(0xFF49303C),
    onPrimaryContainer: Color(0xFFF8E8EF),
    secondary: AppColors.primaryRose,
    onSecondary: Color(0xFF2C1721),
    secondaryContainer: Color(0xFF432633),
    onSecondaryContainer: Color(0xFFF5E3EC),
    tertiary: AppColors.accentLime,
    onTertiary: Color(0xFF222A00),
    tertiaryContainer: Color(0xFF343E10),
    onTertiaryContainer: Color(0xFFF0FFAE),
    error: AppColors.error,
    onError: Color(0xFF3A0A12),
    errorContainer: Color(0xFF48242A),
    onErrorContainer: Color(0xFFFFD9DC),
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    surfaceContainerLowest: AppColors.backgroundDeep,
    surfaceContainerLow: AppColors.surface,
    surfaceContainer: AppColors.surfaceElevated,
    surfaceContainerHigh: AppColors.surfaceSoft,
    surfaceContainerHighest: Color(0xFF352B33),
    onSurfaceVariant: AppColors.textSecondary,
    outline: Color(0xFF675A62),
    outlineVariant: Color(0xFF3A3238),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.background,
    inversePrimary: AppColors.primaryDeep,
  );

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryDeep,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFEAD5DF),
    onPrimaryContainer: Color(0xFF351B27),
    secondary: Color(0xFF85516A),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF3DCE7),
    onSecondaryContainer: Color(0xFF351824),
    tertiary: Color(0xFF687A08),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFE4F58C),
    onTertiaryContainer: Color(0xFF202700),
    error: Color(0xFF9A4050),
    onError: Colors.white,
    errorContainer: Color(0xFFFFD9DE),
    onErrorContainer: Color(0xFF3F0712),
    surface: AppColors.lightBackground,
    onSurface: AppColors.lightText,
    surfaceContainerLowest: AppColors.lightSurface,
    surfaceContainerLow: AppColors.lightSurface,
    surfaceContainer: AppColors.lightSurfaceElevated,
    surfaceContainerHigh: Color(0xFFE4D8DE),
    surfaceContainerHighest: Color(0xFFD9CBD2),
    onSurfaceVariant: AppColors.lightTextSecondary,
    outline: Color(0xFF81737A),
    outlineVariant: Color(0xFFD4C7CD),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFF322A2F),
    onInverseSurface: Color(0xFFF8EFF3),
    inversePrimary: AppColors.primaryMauve,
  );
}
