import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/files/original_store.dart';

import 'file_transport.dart';

class FileQueue {
  FileQueue({
    required this.database,
    required this.files,
    required this.owner,
    required this.canUpload,
    required this.transfer,
  });
  final AppDatabase database;
  final Future<OriginalStore> Function() files;
  final String? Function() owner;
  final bool Function() canUpload;
  final Future<void> Function(FileJobRow, File, void Function(int)) transfer;
  Future<void>? _working;
  int _generation = 0;
  bool _again = false;
  bool _paused = false;
  Timer? _retryTimer;
  Stream<List<FileJobRow>> watch() => (database.select(
    database.fileJobs,
  )..where((r) => _scope(r, owner() ?? 'local'))).watch();
  Expression<bool> _scope($FileJobsTable row, String user) =>
      row.ownerId.equals(user) |
      (row.ownerId.equals('local') & row.operation.equals('delete'));

  Future<void> pause() async {
    _paused = true;
    _retryTimer?.cancel();
    _generation++;
    await _working;
  }

  Future<void> resume() {
    _paused = false;
    return wake();
  }

  void invalidate() {
    _retryTimer?.cancel();
    _generation++;
  }

  void dispose() {
    _paused = true;
    invalidate();
  }

  Future<void> retryFailed() async {
    final user = owner() ?? 'local';
    await (database.update(
      database.fileJobs,
    )..where((j) => _scope(j, user) & j.state.isIn(['retry', 'failed']))).write(
      const FileJobsCompanion(
        state: Value('queued'),
        attempts: Value(0),
        errorCode: Value(null),
        nextAttemptAt: Value(null),
      ),
    );
    if ((owner() ?? 'local') == user) await wake();
  }

  Future<void> enqueue(String id, String operation) async {
    if (!{'upload', 'download', 'delete'}.contains(operation)) {
      throw ArgumentError.value(operation);
    }
    final user = owner();
    if (user == null) throw const FileTransferFailure('unauthorized');
    final source =
        await (database.select(database.sources)
              ..where((s) => s.id.equals(id) & s.ownerId.equals(user)))
            .getSingleOrNull();
    if (source == null ||
        owner() != user ||
        source.deletedAt != null && operation != 'delete') {
      throw const FileTransferFailure('sourceUnavailable');
    }
    if (operation == 'upload' && !canUpload()) {
      throw const FileTransferFailure('consentRequired');
    }
    await database
        .into(database.fileJobs)
        .insertOnConflictUpdate(
          FileJobsCompanion.insert(
            sourceId: id,
            ownerId: user,
            revision: source.revision,
            operation: operation,
            state: const Value('queued'),
            attempts: const Value(0),
            errorCode: const Value(null),
            nextAttemptAt: const Value(null),
          ),
        );
    unawaited(wake());
  }

  Future<void> enqueueLocalUploads() async {
    final user = owner();
    if (user == null || !canUpload()) return;
    final rows = await database
        .customSelect(
          '''SELECT s.id FROM sources s JOIN source_files f ON f.source_id=s.id
      WHERE s.owner_id=? AND s.deleted_at IS NULL AND f.original_relative_path IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM file_jobs j WHERE j.source_id=s.id AND j.owner_id=s.owner_id AND j.revision=s.revision)''',
          variables: [Variable(user)],
          readsFrom: {
            database.sources,
            database.sourceFiles,
            database.fileJobs,
          },
        )
        .get();
    for (final row in rows) {
      if (owner() != user || !canUpload()) return;
      await enqueue(row.read<String>('id'), 'upload');
    }
  }

  Future<void> wake() {
    if (_working != null) {
      _again = true;
      return _working!;
    }
    _retryTimer?.cancel();
    return _working = _drain().whenComplete(() => _working = null);
  }

  Future<void> _drain() async {
    do {
      _again = false;
      await _run();
    } while (_again && !_paused);
    if (_paused) return;
    final user = owner() ?? 'local';
    final jobs =
        await (database.select(database.fileJobs)..where(
              (j) =>
                  _scope(j, user) &
                  j.state.equals('retry') &
                  j.attempts.isSmallerThanValue(3),
            ))
            .get();
    if (_paused || (owner() ?? 'local') != user) return;
    final deadlines =
        jobs
            .where((j) => j.operation != 'upload' || canUpload())
            .map((j) => j.nextAttemptAt ?? DateTime.now().toUtc())
            .toList()
          ..sort();
    if (deadlines.isNotEmpty) {
      final delay = deadlines.first.difference(DateTime.now().toUtc());
      _retryTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
        unawaited(wake().catchError((Object _) {}));
      });
    }
  }

  Future<void> _run() async {
    final user = owner() ?? 'local', generation = _generation;
    bool valid() =>
        !_paused && generation == _generation && (owner() ?? 'local') == user;
    if (!valid()) return;
    final jobs =
        await (database.select(database.fileJobs)..where(
              (j) =>
                  _scope(j, user) &
                  j.state.isIn(['queued', 'running', 'retry']) &
                  j.attempts.isSmallerThanValue(3),
            ))
            .get();
    for (final job in jobs) {
      if (!valid()) return;
      if (job.nextAttemptAt?.isAfter(DateTime.now().toUtc()) == true) continue;
      if (job.operation == 'upload' && !canUpload()) continue;
      final selectJob = database.update(database.fileJobs)
        ..where(
          (j) =>
              j.sourceId.equals(job.sourceId) &
              j.ownerId.equals(job.ownerId) &
              j.revision.equals(job.revision) &
              j.operation.equals(job.operation),
        );
      File? temporary;
      try {
        if (!captureIdPattern.hasMatch(job.sourceId) ||
            job.ownerId == 'local' && job.operation != 'delete') {
          throw const FileTransferFailure('sourceUnavailable');
        }
        final source =
            await (database.select(database.sources)..where(
                  (s) =>
                      s.id.equals(job.sourceId) &
                      (job.ownerId == 'local'
                          ? s.ownerId.isNull()
                          : s.ownerId.equals(job.ownerId)),
                ))
                .getSingleOrNull();
        if (source == null ||
            source.revision != job.revision ||
            source.deletedAt != null && job.operation != 'delete') {
          throw const FileTransferFailure('sourceUnavailable');
        }
        final store = await files();
        final folder = Directory('${store.root.path}/${job.sourceId}');
        await folder.create(recursive: true);
        final rootPath = await store.root.resolveSymbolicLinks();
        if (!(await folder.resolveSymbolicLinks()).startsWith(
          '$rootPath${Platform.pathSeparator}',
        )) {
          throw const FileTransferFailure('contentMismatch');
        }
        final local = store.file('${job.sourceId}/original');
        final file = job.operation == 'download'
            ? File('${folder.path}/download.part')
            : local;
        if (job.operation == 'download') temporary = file;
        if (job.operation == 'upload' &&
            (!await local.exists() ||
                await local.length() != source.byteSize ||
                (await sha256.bind(local.openRead()).first).toString() !=
                    source.contentHash)) {
          throw const FileTransferFailure('contentMismatch');
        }
        if (!valid() || job.operation == 'upload' && !canUpload()) return;
        await selectJob.write(
          FileJobsCompanion(
            state: const Value('running'),
            attempts: Value(job.attempts + 1),
            transferredBytes: const Value(0),
          ),
        );
        var lastProgress = 0;
        if (job.ownerId != 'local') {
          await transfer(job, file, (bytes) {
            // Persist coarse byte progress, not filenames or payloads.
            if (valid() && bytes - lastProgress >= 256 * 1024) {
              lastProgress = bytes;
              unawaited(
                selectJob
                    .write(FileJobsCompanion(transferredBytes: Value(bytes)))
                    .then<void>((_) {}, onError: (Object _, StackTrace _) {}),
              );
            }
          });
        }
        if (!valid() || job.operation == 'upload' && !canUpload()) return;
        final current =
            await (database.select(database.sources)..where(
                  (s) =>
                      s.id.equals(job.sourceId) &
                      (job.ownerId == 'local'
                          ? s.ownerId.isNull()
                          : s.ownerId.equals(job.ownerId)),
                ))
                .getSingleOrNull();
        if (current == null ||
            current.revision != source.revision ||
            current.deletedAt != null && job.operation != 'delete') {
          throw const FileTransferFailure('sourceChanged');
        }
        if (job.operation == 'download') {
          if (await file.length() != source.byteSize ||
              (await sha256.bind(file.openRead()).first).toString() !=
                  source.contentHash) {
            throw const FileTransferFailure('contentMismatch');
          }
          // Never replace the user's only imported original with a cache copy.
          if (!await local.exists()) {
            await file.rename(local.path);
          } else if (await local.length() != source.byteSize ||
              (await sha256.bind(local.openRead()).first).toString() !=
                  source.contentHash) {
            throw const FileTransferFailure('contentMismatch');
          }
          if (!valid()) return;
          await database
              .into(database.sourceFiles)
              .insertOnConflictUpdate(
                SourceFilesCompanion.insert(
                  sourceId: source.id,
                  originalRelativePath: Value('${source.id}/original'),
                  availability: const Value('downloaded'),
                ),
              );
        }
        if (job.operation == 'delete') {
          if (await folder.exists()) await folder.delete(recursive: true);
        }
        await selectJob.write(
          FileJobsCompanion(
            state: const Value('done'),
            errorCode: const Value(null),
            transferredBytes: Value(source.byteSize),
          ),
        );
      } on Object catch (error) {
        if (valid()) {
          await selectJob.write(
            FileJobsCompanion(
              state: Value(job.attempts + 1 >= 3 ? 'failed' : 'retry'),
              errorCode: Value(
                error is FileTransferFailure ? error.code : 'unavailable',
              ),
              nextAttemptAt: Value(
                DateTime.now().toUtc().add(
                  Duration(
                    seconds:
                        error is FileTransferFailure &&
                            error.code == 'deletionPending'
                        ? 300
                        : 30 * (job.attempts + 1),
                  ),
                ),
              ),
            ),
          );
        }
      } finally {
        if (temporary != null && await temporary.exists()) {
          await temporary.delete();
        }
      }
    }
  }
}
