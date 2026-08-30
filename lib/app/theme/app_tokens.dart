import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 999.0;
}

abstract final class AppThumbnailSize {
  static const compactWidth = 58.0;
  static const compactHeight = 72.0;
  static const standardWidth = 76.0;
  static const standardHeight = 96.0;
  static const detailMaxHeight = 420.0;
}

abstract final class AppLayout {
  static const contentMaxWidth = 760.0;

  static EdgeInsets screenPadding({double bottom = AppSpacing.xl}) =>
      EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, bottom);
}
