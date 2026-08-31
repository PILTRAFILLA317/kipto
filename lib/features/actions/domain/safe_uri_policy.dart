final class SafeUriPolicy {
  const SafeUriPolicy();

  Uri? normalizeWebUri(Object? input) {
    if (input is! String) return null;
    var value = input.trim();
    if (value.isEmpty || value.length > 2048 || value.contains(RegExp(r'\s'))) {
      return null;
    }
    if (value.toLowerCase().startsWith('www.')) value = 'https://$value';
    final uri = Uri.tryParse(value);
    if (uri == null || !isAllowedWebUri(uri)) return null;
    return uri;
  }

  bool isAllowedWebUri(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    return (scheme == 'https' || scheme == 'http') &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty;
  }
}
