// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/features/actions/domain/action_data_builders.dart';
import 'package:kipto/features/actions/domain/action_execution_result.dart';
import 'package:kipto/features/actions/domain/calendar_event_draft.dart';
import 'package:kipto/features/actions/domain/safe_uri_policy.dart';
import 'package:url_launcher/url_launcher.dart';

abstract interface class ExternalLauncher {
  Future<bool> launch(Uri uri);
}

final class UrlLauncherExternalLauncher implements ExternalLauncher {
  const UrlLauncherExternalLauncher();

  @override
  Future<bool> launch(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}

abstract interface class CalendarActionService {
  Future<ActionExecutionResult> present(CalendarEventDraft draft);
}

final class PlatformCalendarActionService implements CalendarActionService {
  const PlatformCalendarActionService({
    MethodChannel channel = const MethodChannel('app.kipto/calendar'),
  }) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<ActionExecutionResult> present(CalendarEventDraft draft) async {
    try {
      final value = await _channel.invokeMethod<String>(
        'presentCalendarEventDraft',
        draft.toPlatformArguments(),
      );
      return switch (value) {
        'saved' => const ActionExecutionResult.success('Added to Calendar'),
        'launched' => const ActionExecutionResult.launched(
          'Calendar editor opened',
        ),
        'cancelled' => const ActionExecutionResult.cancelled(),
        'permissionDenied' => const ActionExecutionResult.permissionDenied(
          'Calendar access is disabled.',
        ),
        'unavailable' => const ActionExecutionResult.unavailable(
          "Couldn't open Calendar",
        ),
        _ => const ActionExecutionResult.failed(
          message: "Couldn't open Calendar",
          errorCode: 'calendar_unknown_result',
        ),
      };
    } on MissingPluginException {
      return const ActionExecutionResult.unavailable(
        "Calendar isn't available on this device.",
      );
    } on PlatformException catch (error) {
      return ActionExecutionResult.failed(
        message: "Couldn't open Calendar",
        errorCode: error.code,
      );
    }
  }
}

final class ExternalUrlService {
  const ExternalUrlService({
    required ExternalLauncher launcher,
    SafeUriPolicy policy = const SafeUriPolicy(),
  }) : _launcher = launcher,
       _policy = policy;

  final ExternalLauncher _launcher;
  final SafeUriPolicy _policy;

  Uri? validatedUri(Object? value) => _policy.normalizeWebUri(value);

  Future<ActionExecutionResult> open(Object? value) async {
    final uri = validatedUri(value);
    if (uri == null) {
      return const ActionExecutionResult.invalidData("This link isn't valid");
    }
    return _launch(uri, failureMessage: "Couldn't open this link");
  }

  Future<ActionExecutionResult> openUri(Uri uri) async {
    if (!_policy.isAllowedWebUri(uri)) {
      return const ActionExecutionResult.invalidData("This link isn't valid");
    }
    return _launch(uri, failureMessage: "Couldn't open this link");
  }

  Future<ActionExecutionResult> _launch(
    Uri uri, {
    required String failureMessage,
  }) async {
    try {
      return await _launcher.launch(uri)
          ? const ActionExecutionResult.success()
          : ActionExecutionResult.unavailable(failureMessage);
    } on Object {
      return ActionExecutionResult.failed(
        message: failureMessage,
        errorCode: 'launch_failed',
      );
    }
  }
}

final class MapsActionService {
  const MapsActionService({
    required ExternalLauncher launcher,
    MapsQueryBuilder queryBuilder = const MapsQueryBuilder(),
  }) : _launcher = launcher,
       _queryBuilder = queryBuilder;

  final ExternalLauncher _launcher;
  final MapsQueryBuilder _queryBuilder;

  String? queryFor(SavedItem item) => _queryBuilder.fromSavedItem(item);

  Future<ActionExecutionResult> open(SavedItem item) async {
    final query = queryFor(item);
    if (query == null) {
      return const ActionExecutionResult.invalidData(
        'Kipto needs a location before Maps can open.',
      );
    }
    final native = Platform.isAndroid
        ? Uri(scheme: 'geo', path: '0,0', queryParameters: {'q': query})
        : Uri.https('maps.apple.com', '/', {'q': query});
    try {
      if (await _launcher.launch(native)) {
        return const ActionExecutionResult.success('Opened Maps');
      }
      final fallback = Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': query,
      });
      return await _launcher.launch(fallback)
          ? const ActionExecutionResult.success('Opened map search')
          : const ActionExecutionResult.unavailable("Couldn't open Maps");
    } on Object {
      return const ActionExecutionResult.failed(
        message: "Couldn't open Maps",
        errorCode: 'maps_launch_failed',
      );
    }
  }
}

final class WebSearchActionService {
  const WebSearchActionService({
    required ExternalUrlService urls,
    WebSearchQueryBuilder queryBuilder = const WebSearchQueryBuilder(),
  }) : _urls = urls,
       _queryBuilder = queryBuilder;

  final ExternalUrlService _urls;
  final WebSearchQueryBuilder _queryBuilder;

  String? queryFor(SavedItem item) => _queryBuilder.fromSavedItem(item);

  Future<ActionExecutionResult> search(SavedItem item) {
    final query = queryFor(item);
    if (query == null) {
      return Future.value(
        const ActionExecutionResult.invalidData(
          'Kipto needs something useful to search for.',
        ),
      );
    }
    return _urls.openUri(Uri.https('www.google.com', '/search', {'q': query}));
  }
}

abstract interface class ClipboardWriter {
  Future<void> write(String value);
}

final class FlutterClipboardWriter implements ClipboardWriter {
  const FlutterClipboardWriter();

  @override
  Future<void> write(String value) =>
      Clipboard.setData(ClipboardData(text: value));
}

final class ClipboardActionService {
  const ClipboardActionService({
    required ClipboardWriter clipboard,
    CopyCodeResolver resolver = const CopyCodeResolver(),
  }) : _clipboard = clipboard,
       _resolver = resolver;

  final ClipboardWriter _clipboard;
  final CopyCodeResolver _resolver;

  List<CopyCodeCandidate> candidates(SavedItem item) =>
      _resolver.candidates(item);

  Future<ActionExecutionResult> copy(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return const ActionExecutionResult.invalidData('No code to copy');
    }
    try {
      await _clipboard.write(normalized);
      return const ActionExecutionResult.success('Code copied');
    } on Object {
      return const ActionExecutionResult.failed(
        message: "Couldn't copy this code",
        errorCode: 'clipboard_failed',
      );
    }
  }
}

final class TrackingActionService {
  const TrackingActionService({required ExternalUrlService urls})
    : _urls = urls;

  final ExternalUrlService _urls;

  Future<ActionExecutionResult> open(SavedItem item) {
    final explicit = _urls.validatedUri(item.entities['primaryUrl']);
    if (explicit != null) return _urls.openUri(explicit);
    final code = _value(item.entities['trackingCode']);
    if (code == null) {
      return Future.value(
        const ActionExecutionResult.invalidData(
          'Kipto could not find tracking information.',
        ),
      );
    }
    final carrier = _value(item.entities['carrier']);
    final query = carrier == null
        ? '"$code" tracking'
        : '$carrier $code tracking';
    return _urls.openUri(Uri.https('www.google.com', '/search', {'q': query}));
  }

  String? _value(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }
}
