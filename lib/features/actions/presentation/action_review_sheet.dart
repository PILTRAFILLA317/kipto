import 'package:flutter/material.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/features/actions/presentation/action_feedback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/fact_value.dart';
import 'package:kipto/core/domain/models/item_action.dart';
import 'package:kipto/core/domain/models/temporal_value.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/app/theme/motion_preferences.dart';
import 'package:kipto/features/actions/application/action_service.dart';
import 'package:kipto/features/actions/presentation/action_providers.dart';
import 'package:kipto/features/notifications/presentation/notification_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

Future<DateTime> confirmWallTime(
  BuildContext context,
  CalendarDate date,
  WallTime time,
  String zone,
) async {
  final l = AppLocalizations.of(context);
  final resolved = resolveLocalTime(date, time, zone);
  if (resolved.status == LocalTimeStatus.nonexistent) {
    throw FormatException(l.nonexistentTime);
  }
  if (resolved.status == LocalTimeStatus.unique) return resolved.confirm();
  final choice = await showDialog<DateTime>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.ambiguousTime),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final instant in resolved.instants)
            ListTile(
              title: Text(
                '${DateFormat.Hm(l.localeName).format(tz.TZDateTime.from(instant, timeZoneLocation(zone)))} · UTC${_offset(tz.TZDateTime.from(instant, timeZoneLocation(zone)).timeZoneOffset)}',
              ),
              onTap: () => Navigator.pop(context, instant),
            ),
        ],
      ),
    ),
  );
  if (choice == null) throw FormatException(l.invalidTemporal);
  return resolved.confirm(chosenInstant: choice);
}

String _offset(Duration offset) =>
    '${offset.isNegative ? '-' : '+'}${(offset.inMinutes.abs() ~/ 60).toString().padLeft(2, '0')}:${(offset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';

class ActionReviewSheet extends ConsumerStatefulWidget {
  const ActionReviewSheet({
    super.key,
    required this.action,
    this.facts = const [],
  });
  final ItemAction action;
  final List<Fact> facts;
  @override
  ConsumerState<ActionReviewSheet> createState() => _ActionReviewSheetState();
}

class _ActionReviewSheetState extends ConsumerState<ActionReviewSheet> {
  final _zone = TextEditingController(),
      _location = TextEditingController(),
      _title = TextEditingController();
  CalendarDate? _date, _endDate, _anchor;
  TimeOfDay? _time, _endTime;
  bool _allDay = false, _busy = false, _clamped = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title.text = widget.action.title;
    for (final fact in widget.facts.where(
      (f) => widget.action.evidenceFactIds.contains(f.id),
    )) {
      final value = fact.effectiveValue;
      if (value is DateFactValue && value.date != null) {
        _date = value.date;
        break;
      }
      if (value is DateTimeFactValue && value.date != null) {
        _date = value.date;
        if (value.time != null) {
          _time = TimeOfDay(hour: value.time!.hour, minute: value.time!.minute);
        }
        _zone.text = value.zone ?? '';
        break;
      }
    }
    _anchor = _date;
    final payload = widget.action.payload;
    if (payload is RemindPayload && payload.ready) {
      _zone.text = payload.zone!;
      _setStart(
        tz.TZDateTime.from(payload.instant!, timeZoneLocation(payload.zone!)),
      );
    }
    if (payload is EventPayload) {
      _allDay = payload.allDay;
      _zone.text = payload.zone ?? _zone.text;
      _location.text = payload.location ?? '';
      if (payload.allDay) {
        _date = payload.startDate;
        _endDate = payload.endDateExclusive;
      } else if (payload.ready) {
        final zone = timeZoneLocation(payload.zone!);
        _setStart(tz.TZDateTime.from(payload.start!, zone));
        final end = tz.TZDateTime.from(payload.end!, zone);
        _endDate = CalendarDate(end.year, end.month, end.day);
        _endTime = TimeOfDay.fromDateTime(end);
      }
    }
    if (_zone.text.isEmpty) _loadZone();
  }

  void _setStart(DateTime date) {
    _date = CalendarDate(date.year, date.month, date.day);
    _time = TimeOfDay.fromDateTime(date);
  }

  Future<void> _loadZone() async {
    try {
      final value = await FlutterTimezone.getLocalTimezone();
      if (mounted && _zone.text.isEmpty) {
        setState(() => _zone.text = value.identifier);
      }
    } on Object {
      /* Require an explicit zone; never silently substitute UTC. */
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _zone.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool end) async {
    final current = end ? _endDate : _date;
    final selected = await showDatePicker(
      context: context,
      initialDate: current == null
          ? DateTime.now()
          : DateTime(current.year, current.month, current.day),
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
    );
    if (selected != null && mounted) {
      setState(() {
        final date = CalendarDate(selected.year, selected.month, selected.day);
        if (end) {
          _endDate = date;
        } else {
          _date = date;
          _clamped = false;
        }
      });
    }
  }

  Future<void> _pickTime(bool end) async {
    final value = await showTimePicker(
      context: context,
      initialTime: (end ? _endTime : _time) ?? TimeOfDay.now(),
    );
    if (value != null && mounted) {
      setState(() {
        if (end) {
          _endTime = value;
        } else {
          _time = value;
        }
      });
    }
  }

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l = AppLocalizations.of(context);
    try {
      final kind = widget.action.payload.kind;
      ActionPayload payload;
      if (kind == ActionKind.keep) {
        payload = const KeepPayload();
      } else {
        if (_date == null) throw FormatException(l.invalidTemporal);
        if (kind == ActionKind.event && _allDay) {
          payload = EventPayload(
            allDay: true,
            startDate: _date,
            endDateExclusive: _endDate,
            location: _location.text.trim(),
          );
        } else {
          if (_time == null) throw FormatException(l.invalidTemporal);
          final start = await confirmWallTime(
            context,
            _date!,
            WallTime(_time!.hour, _time!.minute),
            _zone.text.trim(),
          );
          if (!mounted) return;
          if (kind == ActionKind.remind) {
            payload = RemindPayload(instant: start, zone: _zone.text.trim());
          } else {
            if (_endDate == null || _endTime == null) {
              throw FormatException(l.invalidTemporal);
            }
            final end = await confirmWallTime(
              context,
              _endDate!,
              WallTime(_endTime!.hour, _endTime!.minute),
              _zone.text.trim(),
            );
            if (!mounted) return;
            payload = EventPayload(
              allDay: false,
              start: start,
              end: end,
              zone: _zone.text.trim(),
              location: _location.text.trim(),
            );
          }
        }
      }
      if (!payload.ready) throw FormatException(l.invalidTemporal);
      if (widget.action.state == ActionState.proposed) {
        await ref
            .read(lifeAdminRepositoryProvider)
            .renameProposal(widget.action.id, _title.text.trim());
        if (!mounted) return;
      }
      final outcome = await ref
          .read(actionServiceProvider)
          .confirm(widget.action.id, payload);
      if (!mounted) return;
      ref.invalidate(notificationPermissionStatusProvider);
      ref.invalidate(scheduledReminderCountProvider);
      if (const {
        ActionOutcome.failed,
        ActionOutcome.unavailable,
        ActionOutcome.busy,
      }.contains(outcome)) {
        setState(() => _error = actionOutcomeText(l, outcome));
        return;
      }
      if (ref.read(motionPreferencesProvider).haptics &&
          const {
            ActionOutcome.scheduled,
            ActionOutcome.kept,
            ActionOutcome.calendarSaved,
          }.contains(outcome)) {
        try {
          await HapticFeedback.lightImpact();
        } on Object {
          /* Optional feedback. */
        }
      }
      if (mounted) Navigator.pop(context, outcome);
    } on Object catch (error) {
      if (mounted) {
        setState(
          () => _error =
              error is FormatException &&
                  [l.nonexistentTime, l.invalidTemporal].contains(error.message)
              ? error.message
              : l.invalidTemporal,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final kind = widget.action.payload.kind;
    String dateLabel(CalendarDate? d) => d == null
        ? l.chooseDate
        : DateFormat.yMMMMd(l.localeName)
              .format(DateTime(d.year, d.month, d.day));
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.reviewAction, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _title,
              maxLength: 100,
              enabled: !_busy && widget.action.state == ActionState.proposed,
              decoration: InputDecoration(labelText: l.actionTitle),
            ),
            const SizedBox(height: 16),
            if (kind == ActionKind.keep)
              Text(l.keepExplained)
            else ...[
              Text(l.confirmTemporal),
              const SizedBox(height: 12),
              if (kind == ActionKind.event)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.allDay),
                  value: _allDay,
                  onChanged: _busy ? null : (v) => setState(() => _allDay = v),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  kind == ActionKind.event ? l.startDate : l.chooseDate,
                ),
                subtitle: Text(dateLabel(_date)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _busy ? null : () => _pickDate(false),
              ),
              if (kind == ActionKind.remind && _anchor != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final preset in [
                      (0, l.sameDate),
                      (-1, l.dayBefore),
                      (-7, l.weekBefore),
                      (-30, l.monthBefore),
                    ])
                      ActionChip(
                        label: Text(preset.$2),
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                if (preset.$1 == -30) {
                                  final value = _anchor!.addMonths(-1);
                                  _date = value.date;
                                  _clamped = value.clamped;
                                } else {
                                  _date = _anchor!.addDays(preset.$1);
                                  _clamped = false;
                                }
                              }),
                      ),
                  ],
                ),
              if (_clamped) Text(l.monthClamped),
              if (!_allDay)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.startTime),
                  subtitle: Text(_time?.format(context) ?? l.chooseTime),
                  trailing: const Icon(Icons.schedule),
                  onTap: _busy ? null : () => _pickTime(false),
                ),
              if (kind == ActionKind.event) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.endDate),
                  subtitle: Text(dateLabel(_endDate)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _busy ? null : () => _pickDate(true),
                ),
                if (_allDay)
                  Text(l.endDateExclusive)
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.endTime),
                    subtitle: Text(_endTime?.format(context) ?? l.chooseTime),
                    trailing: const Icon(Icons.schedule),
                    onTap: _busy ? null : () => _pickTime(true),
                  ),
                TextField(
                  controller: _location,
                  maxLength: 500,
                  enabled: !_busy,
                  decoration: InputDecoration(labelText: l.locationOptional),
                ),
              ],
              if (!_allDay)
                TextField(
                  controller: _zone,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    labelText: l.timeZone,
                    hintText: 'Europe/Madrid',
                  ),
                ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _confirm,
              child: Semantics(
                liveRegion: true,
                child: AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AppDurations.fast,
                  layoutBuilder: (current, previous) =>
                      current ?? const SizedBox.shrink(),
                  child: _busy
                      ? Row(
                          key: const ValueKey('confirming-action'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!MediaQuery.disableAnimationsOf(context)) ...[
                              const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Flexible(child: Text(l.confirmingAction)),
                          ],
                        )
                      : Text(l.confirmAction),
                ),
              ),
            ),
            TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
