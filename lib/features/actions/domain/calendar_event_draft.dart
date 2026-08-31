import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/features/actions/domain/safe_uri_policy.dart';

final class CalendarEventDraft {
  const CalendarEventDraft({
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.allDay,
    this.location,
    this.notes,
    this.url,
  });

  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final bool allDay;
  final String? location;
  final String? notes;
  final Uri? url;

  CalendarEventDraft copyWith({
    String? title,
    DateTime? startAt,
    DateTime? endAt,
    bool? allDay,
    String? location,
    String? notes,
    Uri? url,
  }) => CalendarEventDraft(
    title: title ?? this.title,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    allDay: allDay ?? this.allDay,
    location: location ?? this.location,
    notes: notes ?? this.notes,
    url: url ?? this.url,
  );

  Map<String, Object?> toPlatformArguments() => {
    'title': title,
    'startAtMilliseconds': startAt.millisecondsSinceEpoch,
    'endAtMilliseconds': endAt.millisecondsSinceEpoch,
    'allDay': allDay,
    'location': location,
    'notes': notes,
    'url': url?.toString(),
  };
}

final class CalendarEventDraftBuilder {
  const CalendarEventDraftBuilder({
    this.defaultDuration = const Duration(hours: 1),
  });

  final Duration defaultDuration;

  CalendarEventDraft? fromSavedItem(SavedItem item) {
    final start = item.eventAt;
    if (start == null) return null;
    return CalendarEventDraft(
      title: item.title.trim(),
      startAt: start.toLocal(),
      endAt: start.toLocal().add(defaultDuration),
      allDay: false,
      location: _nonEmpty(item.location),
      notes: _nonEmpty(item.summary),
      url: _safeUrl(item.entities['primaryUrl']),
    );
  }

  String? _nonEmpty(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  Uri? _safeUrl(Object? value) {
    return const SafeUriPolicy().normalizeWebUri(value);
  }
}
