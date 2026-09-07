import 'package:kipto/core/domain/models/temporal_value.dart';

import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/models/source.dart';
import 'package:kipto/core/repositories/drift_life_admin_repository.dart';
import 'package:kipto/core/repositories/drift_sources_repository.dart';
import 'package:kipto/features/analysis/application/analysis_preparer.dart';
import 'package:kipto/features/analysis/domain/analysis_contract.dart';

/// One foreground worker, backed by Drift. Network interruption reuses the
/// same request and payload. Changing account never reassigns a queued job.
class AnalysisQueue {
  AnalysisQueue({
    required this.database,
    required this.sources,
    required this.repository,
    required this.currentOwner,
    required this.consented,
    required this.prepare,
    required this.send,
    this.clock = const Clock(),
  });
  final AppDatabase database;
  final DriftSourcesRepository sources;
  final DriftLifeAdminRepository repository;
  final String? Function() currentOwner;
  final bool Function() consented;
  final Future<Map<String, Object?>> Function(Source) prepare;
  final Future<Map<String, dynamic>> Function(String owner, String payload)
  send;
  final Clock clock;
  Future<void>? _inFlight;
  Timer? _retryTimer;
  bool _foreground = true, _disposed = false;
  int _generation = 0;
  bool _runAgain = false;

  Stream<AnalysisJobRow?> watch(String sourceId) => (database.select(
    database.analysisJobs,
  )..where((j) => j.sourceId.equals(sourceId))).watchSingleOrNull();

  Future<void> enqueue(
    String sourceId, {
    required String locale,
    required String timeZone,
  }) async {
    if (!consented()) throw const AnalysisFailure('consentRequired');
    timeZoneLocation(timeZone);
    final owner = currentOwner();
    if (owner == null) throw const AnalysisFailure('authenticationRequired');
    await database.transaction(() async {
      final source = await sources.find(sourceId);
      final item = source == null
          ? null
          : await database.itemsDao.findById(source.itemId);
      if (source == null ||
          source.ownerId != owner ||
          source.deletedAt != null ||
          item == null ||
          item.ownerId != owner ||
          currentOwner() != owner) {
        throw const AnalysisFailure('stale');
      }
      final existing = await (database.select(
        database.analysisJobs,
      )..where((j) => j.sourceId.equals(sourceId))).getSingleOrNull();
      if (existing != null &&
          const {'queued', 'running', 'retry'}.contains(existing.state)) {
        return;
      }
      await database
          .into(database.analysisJobs)
          .insertOnConflictUpdate(
            AnalysisJobsCompanion.insert(
              sourceId: sourceId,
              requestId: const Uuid().v4(),
              ownerId: owner,
              revision: source.revision,
              locale: locale == 'en' ? 'en' : 'es',
              timeZone: timeZone,
              requestedAt: clock.now().toUtc(),
              state: const Value('queued'),
              payload: const Value(null),
              envelope: const Value(null),
              errorCode: const Value(null),
              nextAttemptAt: const Value(null),
              attempts: const Value(0),
            ),
          );
    });
    unawaited(wake());
  }

  void pause() {
    _foreground = false;
    _retryTimer?.cancel();
  }

  void invalidateAccountOrConsent() {
    _generation++;
    _retryTimer?.cancel();
  }

  void dispose() {
    _disposed = true;
    pause();
    _generation++;
  }

  bool _eligible(AnalysisJobRow job, int generation) =>
      !_disposed &&
      consented() &&
      currentOwner() == job.ownerId &&
      generation == _generation;

  Future<void> resume() {
    _foreground = true;
    return wake();
  }

  Future<void> wake() {
    if (_disposed || !_foreground) return Future.value();
    final active = _inFlight;
    if (active != null) {
      _runAgain = true;
      return active;
    }
    return _inFlight = _runSerial()
        .catchError((Object _, StackTrace _) {
          // A DB/storage failure leaves the durable job visible and recoverable.
        })
        .whenComplete(() => _inFlight = null);
  }

  Future<void> _runSerial() async {
    do {
      _runAgain = false;
      await _drain();
    } while (_runAgain && _foreground && !_disposed);
  }

  Future<void> retry(String sourceId) async {
    final job = await (database.select(
      database.analysisJobs,
    )..where((j) => j.sourceId.equals(sourceId))).getSingleOrNull();
    if (job == null ||
        !_eligible(job, _generation) ||
        job.state != 'failed' ||
        !const {
          'network',
          'busy',
          'providerRateLimited',
          'serviceUnavailable',
          'authenticationRequired',
        }.contains(job.errorCode)) {
      return;
    }
    // Explicit retry still observes the server's Retry-After.
    await _write(
      job,
      AnalysisJobsCompanion(
        state: const Value('retry'),
        attempts: const Value(0),
      ),
    );
    await wake();
  }

  Future<void> _drain() async {
    _retryTimer?.cancel();
    while (_foreground && !_disposed && consented()) {
      final owner = currentOwner();
      if (owner == null) return;
      final jobs =
          await (database.select(database.analysisJobs)
                ..where(
                  (j) =>
                      j.ownerId.equals(owner) &
                      j.state.isIn(['queued', 'running', 'retry']),
                )
                ..orderBy([(j) => OrderingTerm.asc(j.requestedAt)]))
              .get();
      AnalysisJobRow? next;
      DateTime? earliest;
      final now = clock.now().toUtc();
      for (final job in jobs) {
        if (job.nextAttemptAt == null || !job.nextAttemptAt!.isAfter(now)) {
          next = job;
          break;
        }
        if (earliest == null || job.nextAttemptAt!.isBefore(earliest)) {
          earliest = job.nextAttemptAt;
        }
      }
      if (next == null) {
        if (earliest != null) {
          _retryTimer = Timer(
            earliest.difference(now),
            () => unawaited(wake()),
          );
        }
        return;
      }
      await _process(next);
    }
  }

  Future<bool> _current(AnalysisJobRow job, int generation) async {
    if (!_eligible(job, generation)) return false;
    final source = await sources.find(job.sourceId);
    final item = source == null
        ? null
        : await database.itemsDao.findById(source.itemId);
    return _eligible(job, generation) &&
        source != null &&
        source.deletedAt == null &&
        source.ownerId == job.ownerId &&
        source.revision == job.revision &&
        item != null &&
        item.ownerId == job.ownerId;
  }

  Future<void> _process(AnalysisJobRow job) async {
    final generation = _generation;
    if (!await _current(job, generation)) {
      await _write(
        job,
        const AnalysisJobsCompanion(
          state: Value('stale'),
          payload: Value(null),
          errorCode: Value('stale'),
        ),
      );
      return;
    }
    await _write(
      job,
      AnalysisJobsCompanion(
        state: const Value('running'),
        attempts: Value(job.attempts + 1),
        errorCode: const Value(null),
      ),
    );
    try {
      String? payload = job.payload;
      if (payload == null) {
        final source = (await sources.find(job.sourceId))!;
        final prepared = await prepare(source);
        payload = jsonEncode({
          'requestVersion': 1,
          'requestId': job.requestId,
          'captureId': source.id,
          'sourceId': source.id,
          'sourceRevision': job.revision,
          'locale': job.locale,
          'userTimeZone': job.timeZone,
          'importedAt': source.createdAt.toUtc().toIso8601String(),
          'knownDocumentContext': null,
          ...prepared,
        });
        if (utf8.encode(payload).length > 8 * 1024 * 1024) {
          throw const AnalysisFailure('tooLarge');
        }
        await _write(job, AnalysisJobsCompanion(payload: Value(payload)));
      }
      if (!await _current(job, generation)) {
        throw const AnalysisFailure('stale');
      }
      if (!_foreground) {
        await _write(job, const AnalysisJobsCompanion(state: Value('queued')));
        return;
      }
      final envelope = await send(job.ownerId, payload);
      if (!await _current(job, generation)) {
        throw const AnalysisFailure('stale');
      }
      await _applyEnvelope(job, payload, envelope, generation);
    } on Object catch (error) {
      final code = error is AnalysisFailure ? error.code : 'invalidOutput';
      final retryable = const {
        'network',
        'busy',
        'providerRateLimited',
        'serviceUnavailable',
      }.contains(code);
      final delay = error is AnalysisFailure && error.retryAfter != null
          ? error.retryAfter!
          : Duration(seconds: 15 * (1 << job.attempts.clamp(0, 5)));
      await _write(
        job,
        AnalysisJobsCompanion(
          state: Value(
            code == 'stale'
                ? 'stale'
                : retryable && job.attempts < 2
                ? 'retry'
                : 'failed',
          ),
          errorCode: Value(code),
          nextAttemptAt: Value(clock.now().toUtc().add(delay)),
          payload: code == 'stale' ? const Value(null) : const Value.absent(),
        ),
      );
    }
  }

  Future<void> _applyEnvelope(
    AnalysisJobRow job,
    String payload,
    Map<String, dynamic> envelope,
    int generation,
  ) async {
    if (envelope['requestId'] != job.requestId ||
        envelope['schemaVersion'] != 1 ||
        envelope['model'] is! String ||
        envelope['promptVersion'] is! String ||
        DateTime.tryParse(envelope['analyzedAt'] as String? ?? '') == null) {
      throw const AnalysisFailure('invalidOutput');
    }
    final request = jsonDecode(payload) as Map<String, dynamic>;
    final input = request['input'] as Map;
    final coverage = request['coverage'] as Map;
    final output = AnalysisOutput.parse(
      Map<String, dynamic>.from(envelope['output'] as Map),
      expectedRevision: job.revision,
      expectedPages: (coverage['analyzedPages'] as List).cast<int>(),
      expectedPartial: coverage['isPartial'] as bool,
      imageInput: input['type'] == 'imagePages',
      textPages: {
        for (final p in input['textPages'] as List)
          p['page'] as int: p['text'] as String,
      },
    );
    await repository.applyAnalysis(
      job,
      output,
      envelope,
      isCurrent: () => _eligible(job, generation),
    );
  }

  Future<void> importSharedResult(
    String payload,
    Map<String, dynamic>? envelope,
  ) async {
    if (!consented() || currentOwner() == null) return;
    if (utf8.encode(payload).length > 8 * 1024 * 1024) {
      throw const AnalysisFailure('tooLarge');
    }
    final request = jsonDecode(payload) as Map<String, dynamic>;
    final sourceId = request['sourceId'] as String;
    final source = await sources.find(sourceId);
    final owner = currentOwner();
    final generation = _generation;
    if (source == null ||
        source.ownerId != owner ||
        source.revision != request['sourceRevision']) {
      throw const AnalysisFailure('stale');
    }
    final existing = await (database.select(
      database.analysisJobs,
    )..where((j) => j.sourceId.equals(sourceId))).getSingleOrNull();
    if (existing != null) return; // A newer local decision always wins.
    final requestId = request['requestId'] as String;
    if (!RegExp(r'^[a-f0-9-]{36}$', caseSensitive: false).hasMatch(requestId) ||
        request['requestVersion'] != 1) {
      throw const AnalysisFailure('invalidOutput');
    }
    await database
        .into(database.analysisJobs)
        .insert(
          AnalysisJobsCompanion.insert(
            sourceId: sourceId,
            requestId: requestId,
            ownerId: owner!,
            revision: source.revision,
            locale: request['locale'] as String,
            timeZone: request['userTimeZone'] as String,
            requestedAt: DateTime.parse(request['importedAt'] as String),
            payload: Value(payload),
            state: const Value('failed'),
            errorCode: const Value('network'),
          ),
        );
    final job = await (database.select(
      database.analysisJobs,
    )..where((j) => j.sourceId.equals(sourceId))).getSingle();
    if (envelope != null && await _current(job, generation)) {
      await _applyEnvelope(job, payload, envelope, generation);
    }
  }

  Future<void> _write(AnalysisJobRow job, AnalysisJobsCompanion change) async {
    await (database.update(database.analysisJobs)..where(
          (j) =>
              j.sourceId.equals(job.sourceId) &
              j.requestId.equals(job.requestId),
        ))
        .write(change);
  }
}
