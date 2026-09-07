import 'package:timezone/timezone.dart' as tz;

/// UTC is an IANA compatibility name but is not included in every compact
/// timezone data bundle. It must resolve explicitly, never through a fallback.
tz.Location timeZoneLocation(String zone) =>
    zone == 'UTC' ? tz.UTC : tz.getLocation(zone);

/// Calendar arithmetic uses UTC only as a Gregorian calculator, never as an
/// inferred notification instant. Call [resolveLocalTime] for a real instant.
final class CalendarDate {
  CalendarDate(this.year, this.month, this.day) {
    final normalized = DateTime.utc(year, month, day);
    if (year < 1 ||
        year > 9999 ||
        normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw const FormatException('Invalid calendar date');
    }
  }
  final int year, month, day;
  factory CalendarDate.parse(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      throw const FormatException('A complete ISO date is required');
    }
    final parts = value.split('-').map(int.parse).toList();
    return CalendarDate(parts[0], parts[1], parts[2]);
  }
  CalendarDate addDays(int days) {
    final result = DateTime.utc(year, month, day + days);
    return CalendarDate(result.year, result.month, result.day);
  }

  /// A calendar month is not a fixed number of days. Expose end-of-month
  /// clamping so a proposed advance can explain it before confirmation.
  ({CalendarDate date, bool clamped}) addMonths(int months) {
    final first = DateTime.utc(year, month + months);
    final lastDay = DateTime.utc(first.year, first.month + 1, 0).day;
    final newDay = day.clamp(1, lastDay);
    return (
      date: CalendarDate(first.year, first.month, newDay),
      clamped: newDay != day,
    );
  }

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

final class WallTime {
  WallTime(this.hour, this.minute) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw const FormatException('Invalid wall time');
    }
  }
  final int hour, minute;
  factory WallTime.parse(String value) {
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
      throw const FormatException('Invalid wall time');
    }
    final parts = value.split(':').map(int.parse).toList();
    return WallTime(parts[0], parts[1]);
  }
  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

enum LocalTimeStatus { unique, nonexistent, ambiguous }

final class LocalTimeResolution {
  LocalTimeResolution(List<DateTime> candidates)
    : instants = List.unmodifiable(candidates);
  final List<DateTime> instants;
  LocalTimeStatus get status => instants.isEmpty
      ? LocalTimeStatus.nonexistent
      : instants.length == 1
      ? LocalTimeStatus.unique
      : LocalTimeStatus.ambiguous;
  DateTime confirm({DateTime? chosenInstant}) {
    if (status == LocalTimeStatus.unique && chosenInstant == null) {
      return instants.single;
    }
    if (chosenInstant != null && instants.contains(chosenInstant.toUtc())) {
      return chosenInstant.toUtc();
    }
    throw const FormatException('Choose a valid occurrence of this local time');
  }
}

/// Enumerate actual offsets and round-trip each candidate. timezone's normal
/// constructor may silently normalize a DST gap; no such candidate is accepted.
LocalTimeResolution resolveLocalTime(
  CalendarDate date,
  WallTime time,
  String zone,
) {
  final location = timeZoneLocation(zone); // Unknown zones must not become UTC.
  final wall = DateTime.utc(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  final candidates = <DateTime>{};
  for (final offset in location.zones.map((z) => z.offset).toSet()) {
    final instant = wall.subtract(offset);
    final local = tz.TZDateTime.from(instant, location);
    if (local.year == date.year &&
        local.month == date.month &&
        local.day == date.day &&
        local.hour == time.hour &&
        local.minute == time.minute &&
        local.second == 0) {
      candidates.add(instant);
    }
  }
  return LocalTimeResolution(candidates.toList()..sort());
}

DateTime parseUtcInstant(Object? value) {
  if (value is! String ||
      !RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?Z$')
          .hasMatch(value)) {
    throw const FormatException('An explicit UTC instant is required');
  }
  CalendarDate.parse(value.substring(0, 10));
  WallTime.parse(value.substring(11, 16));
  if (int.parse(value.substring(17, 19)) > 59) {
    throw const FormatException('Invalid seconds');
  }
  return DateTime.parse(value).toUtc();
}
