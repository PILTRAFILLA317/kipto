import 'package:flutter/material.dart';

abstract final class AppColors {
  static const backgroundDeep = Color(0xFF0C0B0E);
  static const background = Color(0xFF111013);
  static const surface = Color(0xFF181519);
  static const surfaceElevated = Color(0xFF211C21);
  static const surfaceSoft = Color(0xFF292229);

  static const primaryMauve = Color(0xFFC091A7);
  static const primaryRose = Color(0xFFB66F91);
  static const primaryDeep = Color(0xFF71445E);
  static const accentLime = Color(0xFFDAF264);

  static const textPrimary = Color(0xFFF8F5F7);
  static const textSecondary = Color(0xFFB7ADB4);
  static const textTertiary = Color(0xFF827981);
  static const error = Color(0xFFE6A2A8);

  static const lightBackground = Color(0xFFF4EFF1);
  static const lightSurface = Color(0xFFFFFAFC);
  static const lightSurfaceElevated = Color(0xFFEDE3E8);
  static const lightText = Color(0xFF241C21);
  static const lightTextSecondary = Color(0xFF665A61);

  static const divider = Color(0x14FFFFFF);
  static const glassBorder = Color(0x1FFFFFFF);
  static const glassHighlight = Color(0x12FFFFFF);
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const ml = 20.0;
  static const lg = 24.0;
  static const section = 28.0;
  static const xl = 32.0;
  static const xxl = 40.0;
  static const xxxl = 48.0;
}

abstract final class AppRadii {
  static const xs = 10.0;
  static const sm = 14.0;
  static const md = 18.0;
  static const lg = 22.0;
  static const xl = 26.0;
  static const xxl = 32.0;
  static const pill = 999.0;
}

abstract final class AppThumbnailSize {
  static const compactWidth = 62.0;
  static const compactHeight = 76.0;
  static const standardWidth = 78.0;
  static const standardHeight = 102.0;
  static const heroHeight = 310.0;
  static const detailMaxHeight = 520.0;
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 140);
  static const normal = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 320);
}

abstract final class AppShadows {
  static const floating = [
    BoxShadow(color: Color(0x73000000), blurRadius: 28, offset: Offset(0, 12)),
  ];

  static const soft = [
    BoxShadow(color: Color(0x42000000), blurRadius: 20, offset: Offset(0, 9)),
  ];
}

abstract final class AppLayout {
  static const contentMaxWidth = 760.0;
  static const screenHorizontal = AppSpacing.ml;
  static const navClearance = 112.0;

  static EdgeInsets screenPadding({double bottom = navClearance}) =>
      EdgeInsets.fromLTRB(
        screenHorizontal,
        AppSpacing.xs,
        screenHorizontal,
        bottom,
      );
}
