import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/features/analysis/domain/analysis_failure.dart';
import 'package:kipto/features/analysis/domain/analysis_queue_models.dart';

final class DriftAnalysisQueueRepository {
  DriftAnalysisQueueRepository(this._database);

  final AppDatabase _database;

  Future<void> initialize() => _database.transaction(() async {
    await _database.customStatement('''
      UPDATE saved_items SET analysis_status = 'unprocessed'
      WHERE analysis_status = 'processing'
        AND id IN (
          SELECT saved_item_id FROM analysis_queue WHERE state = 'processing'
        )
    ''');
    await _database.customStatement(
      "UPDATE analysis_queue SET state = 'queued', started_at = NULL "
      "WHERE state = 'processing'",
    );
  });

  Future<void> enqueue(
    String savedItemId, {
    int priority = 0,
    bool resetAttempts = false,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    if (resetAttempts) {
      await _database.customStatement(
        '''
        INSERT INTO analysis_queue (
          saved_item_id, state, priority, attempt_count, enqueued_at
        ) VALUES (?, 'queued', ?, 0, ?)
        ON CONFLICT(saved_item_id) DO UPDATE SET
          state = 'queued',
          priority = excluded.priority,
          attempt_count = 0,
          next_attempt_at = NULL,
          enqueued_at = excluded.enqueued_at,
          started_at = NULL,
          last_error_code = NULL
        ''',
        [savedItemId, priority, now],
      );
      return;
    }
    await _database.customStatement(
      '''
      INSERT OR IGNORE INTO analysis_queue (
        saved_item_id, state, priority, attempt_count, enqueued_at
      ) VALUES (?, 'queued', ?, 0, ?)
      ''',
      [savedItemId, priority, now],
    );
  }

  Future<void> enqueueMany(Iterable<String> savedItemIds) async {
    final ids = savedItemIds.toSet();
    if (ids.isEmpty) return;
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.transaction(() async {
      for (final id in ids) {
        await _database.customStatement(
          '''
          INSERT OR IGNORE INTO analysis_queue (
            saved_item_id, state, priority, attempt_count, enqueued_at
          ) VALUES (?, 'queued', 0, 0, ?)
          ''',
          [id, now],
        );
      }
    });
  }

  Future<AnalysisQueueEntry?> nextDue(DateTime now) async {
    final row = await _database
        .customSelect(
          '''
      SELECT * FROM analysis_queue
      WHERE state = 'queued'
         OR (state = 'retryScheduled' AND next_attempt_at <= ?)
      ORDER BY priority DESC, enqueued_at ASC
      LIMIT 1
      ''',
          variables: [Variable.withString(now.toUtc().toIso8601String())],
        )
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<DateTime?> nextRetryAt() async {
    final row = await _database.customSelect('''
      SELECT MIN(next_attempt_at) AS next_attempt_at
      FROM analysis_queue
      WHERE state = 'retryScheduled'
    ''').getSingle();
    final value = row.readNullable<String>('next_attempt_at');
    return value == null ? null : DateTime.tryParse(value)?.toUtc();
  }

  Future<AnalysisQueueEntry?> find(String savedItemId) async {
    final row = await _database
        .customSelect(
          'SELECT * FROM analysis_queue WHERE saved_item_id = ?',
          variables: [Variable.withString(savedItemId)],
        )
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<void> markProcessing(String savedItemId, DateTime startedAt) =>
      _database.customStatement(
        '''
        UPDATE analysis_queue SET
          state = 'processing',
          attempt_count = attempt_count + 1,
          started_at = ?,
          next_attempt_at = NULL
        WHERE saved_item_id = ?
        ''',
        [startedAt.toUtc().toIso8601String(), savedItemId],
      );

  Future<void> scheduleRetry(
    String savedItemId, {
    required DateTime nextAttemptAt,
    required AnalysisErrorCode errorCode,
    required bool paused,
  }) => _database.customStatement(
    '''
    UPDATE analysis_queue SET
      state = ?,
      next_attempt_at = ?,
      started_at = NULL,
      last_error_code = ?
    WHERE saved_item_id = ?
    ''',
    [
      paused ? 'paused' : 'retryScheduled',
      nextAttemptAt.toUtc().toIso8601String(),
      errorCode.wireValue,
      savedItemId,
    ],
  );

  Future<void> pausePending() => _database.customStatement(
    "UPDATE analysis_queue SET state = 'paused' "
    "WHERE state IN ('queued', 'retryScheduled')",
  );

  Future<void> resumePaused(DateTime now) => _database.customStatement(
    '''
    UPDATE analysis_queue SET state = CASE
      WHEN next_attempt_at IS NOT NULL AND next_attempt_at > ?
        THEN 'retryScheduled'
      ELSE 'queued'
    END
    WHERE state = 'paused'
    ''',
    [now.toUtc().toIso8601String()],
  );

  Future<void> remove(String savedItemId) => _database.customStatement(
    'DELETE FROM analysis_queue WHERE saved_item_id = ?',
    [savedItemId],
  );

  Future<List<String>> analyzableUnprocessedIds() async {
    final rows = await _database.customSelect('''
      SELECT id FROM saved_items
      WHERE deleted_at IS NULL
        AND analysis_status = 'unprocessed'
        AND original_available = 1
        AND local_asset_id IS NOT NULL
      ORDER BY captured_at DESC
    ''').get();
    return rows.map((row) => row.read<String>('id')).toList(growable: false);
  }

  Stream<AnalysisItemCounts> watchItemCounts() => _database
      .customSelect(
        '''
    SELECT
      SUM(CASE WHEN analysis_status = 'unprocessed' THEN 1 ELSE 0 END)
        AS unprocessed,
      SUM(CASE WHEN analysis_status = 'unprocessed'
                    AND original_available = 1
                    AND local_asset_id IS NOT NULL THEN 1 ELSE 0 END)
        AS analyzable_unprocessed,
      SUM(CASE WHEN analysis_status = 'processing' THEN 1 ELSE 0 END)
        AS processing,
      SUM(CASE WHEN analysis_status = 'processed' THEN 1 ELSE 0 END)
        AS processed,
      SUM(CASE WHEN analysis_status = 'needsReview' THEN 1 ELSE 0 END)
        AS needs_review,
      SUM(CASE WHEN analysis_status = 'failed' THEN 1 ELSE 0 END)
        AS failed
    FROM saved_items
    WHERE deleted_at IS NULL
    ''',
        readsFrom: {_database.savedItems},
      )
      .watchSingle()
      .map(
        (row) => AnalysisItemCounts(
          unprocessed: row.readNullable<int>('unprocessed') ?? 0,
          analyzableUnprocessed:
              row.readNullable<int>('analyzable_unprocessed') ?? 0,
          processing: row.readNullable<int>('processing') ?? 0,
          processed: row.readNullable<int>('processed') ?? 0,
          needsReview: row.readNullable<int>('needs_review') ?? 0,
          failed: row.readNullable<int>('failed') ?? 0,
        ),
      );

  Future<AnalysisQueueSnapshot> snapshot({
    required bool paused,
    int runCompleted = 0,
    int runTotal = 0,
    Duration? lastLatency,
    AnalysisErrorCode? lastErrorCode,
  }) async {
    final rows = await _database.customSelect('''
      SELECT state, COUNT(*) AS item_count
      FROM analysis_queue
      GROUP BY state
    ''').get();
    final counts = <String, int>{
      for (final row in rows)
        row.read<String>('state'): row.read<int>('item_count'),
    };
    return AnalysisQueueSnapshot(
      queued: (counts['queued'] ?? 0) + (counts['paused'] ?? 0),
      processing: counts['processing'] ?? 0,
      retryScheduled: counts['retryScheduled'] ?? 0,
      paused: paused,
      runCompleted: runCompleted,
      runTotal: runTotal,
      lastLatency: lastLatency,
      lastErrorCode: lastErrorCode,
    );
  }

  AnalysisQueueEntry _fromRow(QueryRow row) => AnalysisQueueEntry(
    savedItemId: row.read<String>('saved_item_id'),
    state: AnalysisQueueState.values.firstWhere(
      (state) => state.name == row.read<String>('state'),
    ),
    priority: row.read<int>('priority'),
    attemptCount: row.read<int>('attempt_count'),
    nextAttemptAt: _date(row.readNullable<String>('next_attempt_at')),
    enqueuedAt: DateTime.parse(row.read<String>('enqueued_at')).toUtc(),
    startedAt: _date(row.readNullable<String>('started_at')),
    lastErrorCode: row.readNullable<String>('last_error_code') == null
        ? null
        : AnalysisErrorCodeStorage.fromWire(
            row.read<String>('last_error_code'),
          ),
  );

  DateTime? _date(String? value) =>
      value == null ? null : DateTime.tryParse(value)?.toUtc();
}
