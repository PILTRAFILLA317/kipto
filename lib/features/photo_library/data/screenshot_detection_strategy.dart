final class ScreenshotDetectionStrategy {
  const ScreenshotDetectionStrategy();

  static const _locationTokens = <String>[
    'screenshot',
    'screenshots',
    'screen shot',
    'screen shots',
    'captura de pantalla',
    'capturas de pantalla',
    'capture d ecran',
    'captures d ecran',
    'bildschirmfoto',
    'bildschirmfotos',
    'bildschirmaufnahme',
    'schermopname',
    'schermopnamen',
    'скриншот',
    'スクリーンショット',
    '截图',
    '스크린샷',
  ];

  bool isAndroidScreenshotLocation({
    required String albumName,
    String? relativePath,
  }) {
    final haystack = _normalize('$relativePath/$albumName');
    return _locationTokens.any(haystack.contains);
  }

  bool isAndroidScreenshotAsset({
    required String? title,
    required String? relativePath,
  }) {
    final haystack = _normalize('$relativePath/$title');
    return _locationTokens.any(haystack.contains);
  }

  String _normalize(String input) => input
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('â', 'a')
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('\\', '/')
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
}
