import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/fact_value.dart';
import 'package:kipto/core/domain/models/temporal_value.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

class FactEditSheet extends ConsumerStatefulWidget {
  const FactEditSheet({super.key, required this.fact});
  final Fact fact;
  @override
  ConsumerState<FactEditSheet> createState() => _FactEditSheetState();
}

class _FactEditSheetState extends ConsumerState<FactEditSheet> {
  final _value = TextEditingController(),
      _currency = TextEditingController(),
      _zone = TextEditingController();
  CalendarDate? _date;
  WallTime? _time;
  CalendarDurationUnit _unit = CalendarDurationUnit.calendarDay;
  bool _busy = false, _error = false;
  @override
  void initState() {
    super.initState();
    final value = widget.fact.effectiveValue;
    switch (value) {
      case TextFactValue():
        _value.text = value.text;
      case MoneyFactValue():
        _value.text = value.amount;
        _currency.text = value.currency ?? '';
      case DurationFactValue():
        _value.text = value.count.toString();
        _unit = value.unit;
      case DateFactValue():
        _value.text = value.raw;
        _date = value.date;
      case DateTimeFactValue():
        _value.text = value.raw;
        _date = value.date;
        _time = value.time;
        _zone.text = value.zone ?? '';
    }
  }

  @override
  void dispose() {
    _value.dispose();
    _currency.dispose();
    _zone.dispose();
    super.dispose();
  }

  Future<void> _datePicker() async {
    final current = _date;
    final chosen = await showDatePicker(
      context: context,
      initialDate: current == null
          ? DateTime.now()
          : DateTime(current.year, current.month, current.day),
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
    );
    if (chosen != null && mounted) {
      setState(
        () => _date = CalendarDate(chosen.year, chosen.month, chosen.day),
      );
    }
  }

  Future<void> _timePicker() async {
    final time = _time;
    final chosen = await showTimePicker(
      context: context,
      initialTime: time == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: time.hour, minute: time.minute),
    );
    if (chosen != null && mounted) {
      setState(() => _time = WallTime(chosen.hour, chosen.minute));
    }
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      if (_zone.text.trim().isNotEmpty) timeZoneLocation(_zone.text.trim());
      final value = switch (widget.fact.value) {
        TextFactValue() => TextFactValue(_value.text),
        MoneyFactValue() => MoneyFactValue(
          _value.text.trim().replaceAll(',', '.'),
          _currency.text.trim().isEmpty
              ? null
              : _currency.text.trim().toUpperCase(),
        ),
        DurationFactValue() => DurationFactValue(int.parse(_value.text), _unit),
        DateFactValue() => DateFactValue(date: _date, raw: _value.text),
        DateTimeFactValue() => DateTimeFactValue(
          date: _date,
          time: _time,
          zone: _zone.text.trim().isEmpty ? null : _zone.text.trim(),
          raw: _value.text,
        ),
      };
      await ref
          .read(lifeAdminRepositoryProvider)
          .correctFact(widget.fact.id, value);
      if (mounted) Navigator.pop(context);
    } on Object {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final original = widget.fact.value;
    final temporal = original is DateFactValue || original is DateTimeFactValue;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.edit, style: Theme.of(context).textTheme.titleLarge),
            Text(l.factCorrectionBody),
            const SizedBox(height: 16),
            TextField(
              controller: _value,
              enabled: !_busy,
              maxLength: temporal
                  ? 300
                  : original is TextFactValue
                  ? 2000
                  : 30,
              decoration: InputDecoration(
                labelText: temporal
                    ? l.rawDate
                    : original is DurationFactValue
                    ? l.durationCount
                    : l.factValue,
              ),
            ),
            if (temporal) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.chooseDate),
                subtitle: Text(
                  _date == null
                      ? l.clearDate
                      : DateFormat.yMMMMd(l.localeName).format(
                          DateTime(_date!.year, _date!.month, _date!.day),
                        ),
                ),
                onTap: _busy ? null : _datePicker,
                trailing: IconButton(
                  tooltip: l.clearDate,
                  onPressed: _busy ? null : () => setState(() => _date = null),
                  icon: const Icon(Icons.clear),
                ),
              ),
            ],
            if (original is DateTimeFactValue) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.chooseTime),
                subtitle: Text(_time?.toString() ?? l.clearTime),
                onTap: _busy ? null : _timePicker,
                trailing: IconButton(
                  tooltip: l.clearTime,
                  onPressed: _busy ? null : () => setState(() => _time = null),
                  icon: const Icon(Icons.clear),
                ),
              ),
              TextField(
                controller: _zone,
                enabled: !_busy,
                decoration: InputDecoration(labelText: l.timeZone),
              ),
            ],
            if (original is MoneyFactValue)
              TextField(
                controller: _currency,
                maxLength: 3,
                enabled: !_busy,
                decoration: InputDecoration(labelText: l.currency),
              ),
            if (original is DurationFactValue)
              Wrap(
                spacing: 8,
                children: [
                  for (final unit in CalendarDurationUnit.values)
                    ChoiceChip(
                      label: Text(
                        unit == CalendarDurationUnit.calendarDay
                            ? l.calendarDayUnit
                            : l.calendarMonthUnit,
                      ),
                      selected: _unit == unit,
                      onSelected: _busy
                          ? null
                          : (_) => setState(() => _unit = unit),
                    ),
                ],
              ),
            if (_error) Text(l.operationFailed),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(l.confirmAction),
            ),
          ],
        ),
      ),
    );
  }
}
