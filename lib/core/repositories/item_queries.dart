import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/models/temporal_value.dart';

class ItemSignal {
  const ItemSignal({
    this.proposals = 0,
    this.analysisState,
    this.nextReminder,
    this.explicitDate,
  });
  final int proposals;
  final String? analysisState;
  final DateTime? nextReminder;
  final CalendarDate? explicitDate;
  bool get needsReview => proposals > 0 || analysisState == 'failed';
}

/// Read models use only domain fields. Prepared AI payloads, paths and session
/// data are deliberately absent from search.
class ItemQueries {
  const ItemQueries(this.database);
  final AppDatabase database;
  Stream<Map<String, ItemSignal>> watchSignals(String? owner) => database
      .customSelect(
        '''
    SELECT i.id,
      (SELECT COUNT(*) FROM item_actions a WHERE a.item_id=i.id AND a.state='proposed' AND a.deleted_at IS NULL) AS proposals,
      (SELECT j.state FROM analysis_jobs j JOIN sources s ON s.id=j.source_id WHERE s.item_id=i.id AND s.deleted_at IS NULL ORDER BY j.requested_at DESC LIMIT 1) AS analysis_state,
      (SELECT MIN(r.remind_at) FROM reminders r WHERE r.item_id=i.id AND r.deleted_at IS NULL AND r.completed_at IS NULL) AS next_reminder,
      (SELECT MIN(json_extract(COALESCE(f.user_value,f.value),'\$.date')) FROM facts f WHERE f.item_id=i.id AND f.deleted_at IS NULL AND f.value_type IN ('date','datetime')) AS explicit_date
    FROM items i WHERE i.deleted_at IS NULL AND i.owner_id IS ?
  ''',
        variables: [Variable<String>(owner)],
        readsFrom: {
          database.items,
          database.itemActions,
          database.analysisJobs,
          database.sources,
          database.reminders,
          database.facts,
        },
      )
      .watch()
      .map(
        (rows) => {
          for (final row in rows)
            row.read<String>('id'): ItemSignal(
              proposals: row.read<int>('proposals'),
              analysisState: row.readNullable<String>('analysis_state'),
              nextReminder: DateTime.tryParse(
                row.readNullable<String>('next_reminder') ?? '',
              )?.toUtc(),
              explicitDate: row.readNullable<String>('explicit_date') == null
                  ? null
                  : CalendarDate.parse(row.read<String>('explicit_date')),
            ),
        },
      );

  Stream<Set<String>> search(
    String query,
    String? owner, {
    bool archiveOnly = false,
  }) {
    final literal = query
        .trim()
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
    final pattern = '%$literal%';
    return database
        .customSelect(
          '''
      SELECT i.id FROM items i WHERE i.deleted_at IS NULL AND i.owner_id IS ?
      ${archiveOnly ? "AND i.status <> 'active'" : ''}
      AND (i.title LIKE ? ESCAPE '\\' OR i.summary LIKE ? ESCAPE '\\' OR EXISTS (
        SELECT 1 FROM sources s WHERE s.item_id=i.id AND s.owner_id IS i.owner_id AND s.deleted_at IS NULL
        AND s.text_content LIKE ? ESCAPE '\\'))
      ORDER BY i.updated_at DESC, i.id ASC
    ''',
          variables: [
            Variable<String>(owner),
            Variable.withString(pattern),
            Variable.withString(pattern),
            Variable.withString(pattern),
          ],
          readsFrom: {database.items, database.sources},
        )
        .watch()
        .map((rows) => rows.map((r) => r.read<String>('id')).toSet());
  }
}
