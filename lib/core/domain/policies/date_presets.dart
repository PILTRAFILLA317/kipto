enum DatePreset { laterToday, tomorrow, thisWeekend, nextWeek, custom }

abstract final class DatePresetPolicy {
  static DateTime resolve(DatePreset preset, DateTime now) {
    final local = now.toLocal();
    return switch (preset) {
      DatePreset.laterToday => local.add(const Duration(hours: 2)),
      DatePreset.tomorrow => DateTime(
        local.year,
        local.month,
        local.day + 1,
        9,
      ),
      DatePreset.thisWeekend => _nextSaturday(local),
      DatePreset.nextWeek => DateTime(
        local.year,
        local.month,
        local.day + (8 - local.weekday),
        9,
      ),
      DatePreset.custom => local,
    };
  }

  static DateTime _nextSaturday(DateTime now) {
    var days = DateTime.saturday - now.weekday;
    if (days <= 0) days += 7;
    return DateTime(now.year, now.month, now.day + days, 9);
  }
}
