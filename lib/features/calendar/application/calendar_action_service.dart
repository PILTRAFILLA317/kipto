// ignore_for_file: prefer_initializing_formals

import 'package:flutter/services.dart';

final class CalendarEventDraft {
  const CalendarEventDraft({
    required this.title,
    required this.startAt,
    required this.endAt,
    this.allDay = false,
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

enum CalendarActionResult {
  saved,
  launched,
  cancelled,
  permissionDenied,
  unavailable,
  failed,
}

abstract interface class CalendarActionService {
  Future<CalendarActionResult> present(CalendarEventDraft draft);
}

final class PlatformCalendarActionService implements CalendarActionService {
  const PlatformCalendarActionService({
    MethodChannel channel = const MethodChannel('app.kipto/calendar'),
  }) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<CalendarActionResult> present(CalendarEventDraft draft) async {
    if (draft.title.trim().isEmpty || !draft.endAt.isAfter(draft.startAt)) {
      return CalendarActionResult.failed;
    }
    try {
      return switch (await _channel.invokeMethod<String>(
        'presentCalendarEventDraft',
        draft.toPlatformArguments(),
      )) {
        'saved' => CalendarActionResult.saved,
        'launched' => CalendarActionResult.launched,
        'cancelled' => CalendarActionResult.cancelled,
        'permissionDenied' => CalendarActionResult.permissionDenied,
        'unavailable' => CalendarActionResult.unavailable,
        _ => CalendarActionResult.failed,
      };
    } on PlatformException {
      return CalendarActionResult.failed;
    } on MissingPluginException {
      return CalendarActionResult.unavailable;
    }
  }
}
