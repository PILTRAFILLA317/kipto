import 'package:kipto/core/domain/models/temporal_value.dart';

void requireKeys(
  Map<String, dynamic> json,
  Set<String> required, [
  Set<String> optional = const {},
]) {
  if (!json.keys.toSet().containsAll(required) ||
      json.keys.any(
        (key) => !required.contains(key) && !optional.contains(key),
      )) {
    throw const FormatException('Unexpected or missing fields');
  }
}

String boundedText(Object? value, int max, {bool allowEmpty = false}) {
  if (value is! String ||
      (!allowEmpty && value.trim().isEmpty) ||
      value.length > max) {
    throw const FormatException('Invalid text length');
  }
  return value;
}

sealed class FactValue {
  const FactValue();
  String get type;
  Map<String, Object?> toJson();
  factory FactValue.parse(String type, Map<String, dynamic> json) =>
      switch (type) {
        'text' => TextFactValue.parse(json),
        'date' => DateFactValue.parse(json),
        'datetime' => DateTimeFactValue.parse(json),
        'duration' => DurationFactValue.parse(json),
        'money' => MoneyFactValue.parse(json),
        _ => throw const FormatException('Unknown fact type'),
      };
}

final class TextFactValue extends FactValue {
  TextFactValue(String text) : text = boundedText(text, 2000);
  final String text;
  factory TextFactValue.parse(Map<String, dynamic> json) {
    requireKeys(json, {'text'});
    return TextFactValue(boundedText(json['text'], 2000));
  }
  @override
  String get type => 'text';
  @override
  Map<String, Object?> toJson() => {'text': text};
}

/// Null date is an explicit incomplete/ambiguous observation, not today's date.
final class DateFactValue extends FactValue {
  DateFactValue({required this.date, required String raw})
    : raw = boundedText(raw, 300);
  final CalendarDate? date;
  final String raw;
  factory DateFactValue.parse(Map<String, dynamic> json) {
    requireKeys(json, {'date', 'raw'});
    return DateFactValue(
      date: json['date'] == null
          ? null
          : CalendarDate.parse(json['date'] as String),
      raw: boundedText(json['raw'], 300),
    );
  }
  @override
  String get type => 'date';
  @override
  Map<String, Object?> toJson() => {'date': date?.toString(), 'raw': raw};
}

final class DateTimeFactValue extends FactValue {
  DateTimeFactValue({
    required this.date,
    required this.time,
    required this.zone,
    required String raw,
  }) : raw = boundedText(raw, 300) {
    if (zone != null) {
      boundedText(zone, 100);
      timeZoneLocation(zone!);
    }
  }
  final CalendarDate? date;
  final WallTime? time;
  final String? zone;
  final String raw;
  bool get isComplete => date != null && time != null && zone != null;
  LocalTimeResolution resolve() {
    if (!isComplete) {
      throw const FormatException('Confirm missing temporal fields');
    }
    return resolveLocalTime(date!, time!, zone!);
  }

  factory DateTimeFactValue.parse(Map<String, dynamic> json) {
    requireKeys(json, {'date', 'time', 'zone', 'raw'});
    return DateTimeFactValue(
      date: json['date'] == null
          ? null
          : CalendarDate.parse(json['date'] as String),
      time: json['time'] == null
          ? null
          : WallTime.parse(json['time'] as String),
      zone: json['zone'] as String?,
      raw: boundedText(json['raw'], 300),
    );
  }
  @override
  String get type => 'datetime';
  @override
  Map<String, Object?> toJson() => {
    'date': date?.toString(),
    'time': time?.toString(),
    'zone': zone,
    'raw': raw,
  };
}

enum CalendarDurationUnit { calendarDay, calendarMonth }

final class DurationFactValue extends FactValue {
  DurationFactValue(this.count, this.unit) {
    if (count < 1 || count > 36600) {
      throw const FormatException('Invalid duration');
    }
  }
  final int count;
  final CalendarDurationUnit unit;
  factory DurationFactValue.parse(Map<String, dynamic> json) {
    requireKeys(json, {'count', 'unit'});
    return DurationFactValue(
      json['count'] as int,
      CalendarDurationUnit.values.byName(json['unit'] as String),
    );
  }
  ({CalendarDate date, bool clamped}) before(CalendarDate anchor) =>
      unit == CalendarDurationUnit.calendarMonth
      ? anchor.addMonths(-count)
      : (date: anchor.addDays(-count), clamped: false);
  @override
  String get type => 'duration';
  @override
  Map<String, Object?> toJson() => {'count': count, 'unit': unit.name};
}

/// Decimal string avoids floating-point rounding of amounts.
final class MoneyFactValue extends FactValue {
  MoneyFactValue(this.amount, this.currency) {
    if (!RegExp(r'^-?\d{1,12}(\.\d{1,4})?$').hasMatch(amount) ||
        (currency != null && !RegExp(r'^[A-Z]{3}$').hasMatch(currency!))) {
      throw const FormatException('Invalid money value');
    }
  }
  final String amount;
  final String? currency;
  factory MoneyFactValue.parse(Map<String, dynamic> json) {
    requireKeys(json, {'amount', 'currency'});
    return MoneyFactValue(
      json['amount'] as String,
      json['currency'] as String?,
    );
  }
  @override
  String get type => 'money';
  @override
  Map<String, Object?> toJson() => {'amount': amount, 'currency': currency};
}
