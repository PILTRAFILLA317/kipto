import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/policies/completed_actions_merge.dart';
import 'package:kipto/core/sync/remote_models.dart';

RemoteSavedItem savedItemRowToRemote(
  SavedItemRow row, {
  required String userId,
  required String installationId,
}) => RemoteSavedItem(
  id: row.id,
  userId: userId,
  title: row.title,
  summary: row.summary,
  category: row.category,
  subtype: row.subtype,
  intent: row.intent,
  status: row.status,
  favorite: row.favorite,
  capturedAt: row.capturedAt.toUtc(),
  eventAt: row.eventAt?.toUtc(),
  expiresAt: row.expiresAt?.toUtc(),
  snoozedUntil: row.snoozedUntil?.toUtc(),
  location: row.location,
  entities: row.entities,
  availableActions: row.availableActions,
  cloudPreviewPath: row.cloudPreviewPath,
  imageHash: row.imageHash,
  analysisStatus: row.analysisStatus,
  analysisVersion: row.analysisVersion,
  confidence: row.confidence,
  clientUpdatedAt: row.updatedAt.toUtc(),
  serverUpdatedAt:
      row.remoteServerUpdatedAt?.toUtc() ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  sourceDeviceId: installationId,
  createdAt: row.createdAt.toUtc(),
  deletedAt: row.deletedAt?.toUtc(),
);

SavedItemsCompanion remoteSavedItemInsert(RemoteSavedItem remote) =>
    SavedItemsCompanion.insert(
      id: remote.id,
      ownerId: Value(remote.userId),
      title: remote.title,
      summary: Value(remote.summary),
      category: remote.category,
      subtype: Value(remote.subtype),
      intent: Value(remote.intent),
      status: remote.status,
      favorite: Value(remote.favorite),
      capturedAt: remote.capturedAt,
      eventAt: Value(remote.eventAt),
      expiresAt: Value(remote.expiresAt),
      snoozedUntil: Value(remote.snoozedUntil),
      location: Value(remote.location),
      entities: Value(remote.entities),
      availableActions: Value(remote.availableActions),
      cloudPreviewPath: Value(remote.cloudPreviewPath),
      imageHash: Value(remote.imageHash),
      analysisStatus: remote.analysisStatus,
      analysisVersion: Value(remote.analysisVersion ?? 0),
      confidence: Value(remote.confidence),
      createdAt: remote.createdAt,
      updatedAt: remote.clientUpdatedAt,
      deletedAt: Value(remote.deletedAt),
      localAssetId: const Value(null),
      originalAvailable: const Value(false),
      previewCachePath: const Value(null),
      syncStatus: SyncStatus.synced,
      lastSyncedAt: Value(remote.serverUpdatedAt),
      remoteServerUpdatedAt: Value(remote.serverUpdatedAt),
    );

SavedItemsCompanion remoteSavedItemUpdate(
  RemoteSavedItem remote, {
  Map<String, Object?> localEntities = const {},
}) => SavedItemsCompanion(
  ownerId: Value(remote.userId),
  title: Value(remote.title),
  summary: Value(remote.summary),
  category: Value(remote.category),
  subtype: Value(remote.subtype),
  intent: Value(remote.intent),
  status: Value(remote.status),
  favorite: Value(remote.favorite),
  capturedAt: Value(remote.capturedAt),
  eventAt: Value(remote.eventAt),
  expiresAt: Value(remote.expiresAt),
  snoozedUntil: Value(remote.snoozedUntil),
  location: Value(remote.location),
  entities: Value(mergeCompletedActions(localEntities, remote.entities)),
  availableActions: Value(remote.availableActions),
  cloudPreviewPath: Value(remote.cloudPreviewPath),
  imageHash: Value(remote.imageHash),
  analysisStatus: Value(remote.analysisStatus),
  analysisVersion: Value(remote.analysisVersion ?? 0),
  confidence: Value(remote.confidence),
  createdAt: Value(remote.createdAt),
  updatedAt: Value(remote.clientUpdatedAt),
  deletedAt: Value(remote.deletedAt),
  syncStatus: const Value(SyncStatus.synced),
  lastSyncedAt: Value(remote.serverUpdatedAt),
  remoteServerUpdatedAt: Value(remote.serverUpdatedAt),
);

RemoteReminder reminderRowToRemote(
  ReminderRow row, {
  required String userId,
  required String installationId,
}) => RemoteReminder(
  id: row.id,
  userId: userId,
  savedItemId: row.savedItemId,
  remindAt: row.remindAt.toUtc(),
  kind: row.kind,
  completedAt: row.completedAt?.toUtc(),
  clientUpdatedAt: row.updatedAt.toUtc(),
  serverUpdatedAt:
      row.remoteServerUpdatedAt?.toUtc() ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  sourceDeviceId: installationId,
  createdAt: row.createdAt.toUtc(),
  deletedAt: row.deletedAt?.toUtc(),
);

RemindersCompanion remoteReminderInsert(RemoteReminder remote) =>
    RemindersCompanion.insert(
      id: remote.id,
      ownerId: Value(remote.userId),
      savedItemId: remote.savedItemId,
      remindAt: remote.remindAt,
      kind: remote.kind,
      completedAt: Value(remote.completedAt),
      createdAt: remote.createdAt,
      updatedAt: remote.clientUpdatedAt,
      deletedAt: Value(remote.deletedAt),
      syncStatus: SyncStatus.synced,
      lastSyncedAt: Value(remote.serverUpdatedAt),
      remoteServerUpdatedAt: Value(remote.serverUpdatedAt),
    );

RemindersCompanion remoteReminderUpdate(RemoteReminder remote) =>
    RemindersCompanion(
      ownerId: Value(remote.userId),
      savedItemId: Value(remote.savedItemId),
      remindAt: Value(remote.remindAt),
      kind: Value(remote.kind),
      completedAt: Value(remote.completedAt),
      createdAt: Value(remote.createdAt),
      updatedAt: Value(remote.clientUpdatedAt),
      deletedAt: Value(remote.deletedAt),
      syncStatus: const Value(SyncStatus.synced),
      lastSyncedAt: Value(remote.serverUpdatedAt),
      remoteServerUpdatedAt: Value(remote.serverUpdatedAt),
    );
