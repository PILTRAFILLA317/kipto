// ignore_for_file: prefer_initializing_formals, use_null_aware_elements

import 'package:flutter/foundation.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/repositories/saved_items_repository.dart';
import 'package:kipto/features/actions/application/device_action_services.dart';
import 'package:kipto/features/actions/application/reminder_action_service.dart';
import 'package:kipto/features/actions/domain/action_execution_result.dart';
import 'package:kipto/features/actions/domain/calendar_event_draft.dart';

final class SavedItemActionRequest {
  const SavedItemActionRequest({
    required this.item,
    required this.action,
    this.calendarDraft,
    this.remindAt,
    this.copyValue,
    this.allowCalendarDuplicate = false,
  });

  final SavedItem item;
  final SavedItemActionType action;
  final CalendarEventDraft? calendarDraft;
  final DateTime? remindAt;
  final String? copyValue;
  final bool allowCalendarDuplicate;
}

final class SavedItemActionExecutor {
  const SavedItemActionExecutor({
    required CalendarActionService calendar,
    required ReminderActionService reminders,
    required MapsActionService maps,
    required ExternalUrlService urls,
    required WebSearchActionService search,
    required ClipboardActionService clipboard,
    required TrackingActionService tracking,
    required SavedItemsRepository savedItems,
  }) : _calendar = calendar,
       _reminders = reminders,
       _maps = maps,
       _urls = urls,
       _search = search,
       _clipboard = clipboard,
       _tracking = tracking,
       _savedItems = savedItems;

  final CalendarActionService _calendar;
  final ReminderActionService _reminders;
  final MapsActionService _maps;
  final ExternalUrlService _urls;
  final WebSearchActionService _search;
  final ClipboardActionService _clipboard;
  final TrackingActionService _tracking;
  final SavedItemsRepository _savedItems;

  List<String> copyCandidates(SavedItem item) => _clipboard
      .candidates(item)
      .map((candidate) => candidate.value)
      .toList(growable: false);

  Future<ActionExecutionResult> execute(SavedItemActionRequest request) async {
    final stopwatch = Stopwatch()..start();
    _log('action.started', request);
    ActionExecutionResult result;
    try {
      result = await _execute(request);
    } on Object catch (error) {
      result = ActionExecutionResult.failed(
        message: 'That action could not be completed. Try again.',
        errorCode: error.runtimeType.toString(),
      );
    }
    stopwatch.stop();
    _log(
      switch (result.status) {
        ActionExecutionStatus.success ||
        ActionExecutionStatus.launched => 'action.completed',
        ActionExecutionStatus.cancelled => 'action.cancelled',
        _ => 'action.failed',
      },
      request,
      duration: stopwatch.elapsed,
      errorCode: result.errorCode ?? result.status.name,
    );
    return result;
  }

  Future<ActionExecutionResult> _execute(
    SavedItemActionRequest request,
  ) async => switch (request.action) {
    SavedItemActionType.addCalendar => _addCalendar(request),
    SavedItemActionType.createReminder => _createReminder(request),
    SavedItemActionType.openMaps => _maps.open(request.item),
    SavedItemActionType.openUrl => _urls.open(
      request.item.entities['primaryUrl'],
    ),
    SavedItemActionType.webSearch => _search.search(request.item),
    SavedItemActionType.copyCode => _copyCode(request),
    SavedItemActionType.trackPackage => _tracking.open(request.item),
    SavedItemActionType.save => _save(request.item),
    SavedItemActionType.none => const ActionExecutionResult.invalidData(
      'No action is available.',
    ),
  };

  Future<ActionExecutionResult> _addCalendar(
    SavedItemActionRequest request,
  ) async {
    final draft = request.calendarDraft;
    if (draft == null ||
        draft.title.trim().isEmpty ||
        !draft.endAt.isAfter(draft.startAt)) {
      return const ActionExecutionResult.invalidData(
        'Kipto needs valid event details before Calendar can open.',
      );
    }
    if (request.item.hasCompletedAction(SavedItemActionType.addCalendar) &&
        !request.allowCalendarDuplicate) {
      return const ActionExecutionResult.cancelled(
        "You've already added this from Kipto.",
      );
    }
    final result = await _calendar.present(draft);
    if (result.isSuccess) {
      await _savedItems.markActionCompleted(
        request.item.id,
        SavedItemActionType.addCalendar,
      );
    }
    return result;
  }

  Future<ActionExecutionResult> _createReminder(
    SavedItemActionRequest request,
  ) {
    final remindAt = request.remindAt;
    if (remindAt == null) {
      return Future.value(
        const ActionExecutionResult.invalidData(
          'Choose when Kipto should remind you.',
        ),
      );
    }
    return _reminders.create(item: request.item, remindAt: remindAt);
  }

  Future<ActionExecutionResult> _copyCode(SavedItemActionRequest request) {
    final candidates = _clipboard.candidates(request.item);
    final value =
        request.copyValue ??
        (candidates.length == 1 ? candidates.single.value : null);
    if (value == null) {
      return Future.value(
        ActionExecutionResult.invalidData(
          candidates.isEmpty ? 'No code to copy' : 'Choose a code to copy',
        ),
      );
    }
    return _clipboard.copy(value);
  }

  Future<ActionExecutionResult> _save(SavedItem item) async {
    try {
      await _savedItems.save(item.id);
      return const ActionExecutionResult.success('Saved');
    } on Object {
      return const ActionExecutionResult.failed(
        message: "Couldn't save this item",
        errorCode: 'save_failed',
      );
    }
  }

  void _log(
    String event,
    SavedItemActionRequest request, {
    Duration? duration,
    String? errorCode,
  }) {
    if (!kDebugMode) return;
    // Explicit conditionals keep sensitive optional fields out of the log.
    debugPrint(
      '$event ${{'savedItemId': request.item.id, 'actionType': request.action.storageValue, if (duration != null) 'durationMs': duration.inMilliseconds, if (errorCode != null) 'errorCode': errorCode}}',
    );
  }
}
