import 'package:kipto/core/domain/models/saved_item.dart';

final class MapsQueryBuilder {
  const MapsQueryBuilder();

  String? fromSavedItem(SavedItem item) {
    final structured = item.analysisMetadata['location'];
    final values = structured is Map ? structured : const <Object?, Object?>{};
    final name = _string(values['name']);
    final address = _string(values['address']);
    final city = _string(values['city']);
    final country = _string(values['country']);
    final query = _string(values['query']);
    final parts = <String>[
      // ignore: use_null_aware_elements
      if (name != null) name,
      // ignore: use_null_aware_elements
      if (address != null) address,
      if (city != null && !_contained(parts: [name, address], value: city))
        city,
      if (country != null &&
          !_contained(parts: [name, address, city], value: country))
        country,
    ];
    if (parts.isNotEmpty) return parts.join(', ');
    return query ?? _string(item.location);
  }

  bool _contained({required List<String?> parts, required String value}) =>
      parts.whereType<String>().any(
        (part) => part.toLowerCase().contains(value.toLowerCase()),
      );

  String? _string(Object? value) {
    if (value is! String) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}

final class WebSearchQueryBuilder {
  const WebSearchQueryBuilder({this.maxLength = 180});

  final int maxLength;

  String? fromSavedItem(SavedItem item) {
    final candidates = <String>[
      item.title,
      ...item.searchKeywords,
      for (final key in const [
        'productName',
        'artist',
        'merchant',
        'venue',
        'creator',
      ])
        if (item.entities[key] case final String value) value,
    ];
    final words = <String>[];
    final seen = <String>{};
    for (final candidate in candidates) {
      for (final word in candidate.trim().split(RegExp(r'\s+'))) {
        final normalized = word.toLowerCase();
        if (word.isEmpty || !seen.add(normalized)) continue;
        final next = [...words, word].join(' ');
        if (next.length > maxLength) {
          return words.isEmpty ? null : words.join(' ');
        }
        words.add(word);
      }
    }
    return words.isEmpty ? null : words.join(' ');
  }
}

final class CopyCodeResolver {
  const CopyCodeResolver();

  List<CopyCodeCandidate> candidates(SavedItem item) {
    final output = <CopyCodeCandidate>[];
    for (final entry in const [
      ('couponCode', 'Coupon code'),
      ('trackingCode', 'Tracking code'),
      ('orderNumber', 'Order number'),
    ]) {
      final value = item.entities[entry.$1];
      if (value is String && value.trim().isNotEmpty) {
        output.add(CopyCodeCandidate(label: entry.$2, value: value.trim()));
      }
    }
    return List.unmodifiable(output);
  }
}

final class CopyCodeCandidate {
  const CopyCodeCandidate({required this.label, required this.value});

  final String label;
  final String value;
}
