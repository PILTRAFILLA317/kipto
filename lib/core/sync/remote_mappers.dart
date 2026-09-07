import 'package:drift/drift.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/sync/remote_models.dart';

RemoteItem itemRowToRemote(
  ItemRow row, {
  required String userId,
  required String installationId,
}) => RemoteItem(
  id: row.id,
  userId: userId,
  title: row.title,
  summary: row.summary,
  status: row.status,
  createdAt: row.createdAt.toUtc(),
  clientUpdatedAt: row.updatedAt.toUtc(),
  serverUpdatedAt:
      row.remoteServerUpdatedAt?.toUtc() ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  resolvedAt: row.resolvedAt?.toUtc(),
  deletedAt: row.deletedAt?.toUtc(),
  sourceDeviceId: installationId,
);

ItemsCompanion remoteItemInsert(RemoteItem remote) => ItemsCompanion.insert(
  id: remote.id,
  ownerId: Value(remote.userId),
  title: remote.title,
  summary: Value(remote.summary),
  status: remote.status,
  createdAt: remote.createdAt,
  updatedAt: remote.clientUpdatedAt,
  resolvedAt: Value(remote.resolvedAt),
  deletedAt: Value(remote.deletedAt),
  syncStatus: SyncStatus.synced,
  lastSyncedAt: Value(remote.serverUpdatedAt),
  remoteServerUpdatedAt: Value(remote.serverUpdatedAt),
  sourceDeviceId: Value(remote.sourceDeviceId),
);

ItemsCompanion remoteItemUpdate(RemoteItem remote) => ItemsCompanion(
  ownerId: Value(remote.userId),
  title: Value(remote.title),
  summary: Value(remote.summary),
  status: Value(remote.status),
  createdAt: Value(remote.createdAt),
  updatedAt: Value(remote.clientUpdatedAt),
  resolvedAt: Value(remote.resolvedAt),
  deletedAt: Value(remote.deletedAt),
  syncStatus: const Value(SyncStatus.synced),
  lastSyncedAt: Value(remote.serverUpdatedAt),
  remoteServerUpdatedAt: Value(remote.serverUpdatedAt),
  sourceDeviceId: Value(remote.sourceDeviceId),
);

RemoteReminder reminderRowToRemote(
  ReminderRow row, {
  required String userId,
  required String installationId,
}) => RemoteReminder(
  id: row.id,
  userId: userId,
  itemId: row.itemId,
  actionId: row.actionId,
  title: row.title,
  timeZone: row.timeZone,
  remindAt: row.remindAt.toUtc(),
  createdAt: row.createdAt.toUtc(),
  clientUpdatedAt: row.updatedAt.toUtc(),
  serverUpdatedAt:
      row.remoteServerUpdatedAt?.toUtc() ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  completedAt: row.completedAt?.toUtc(),
  deletedAt: row.deletedAt?.toUtc(),
  sourceDeviceId: installationId,
);

RemindersCompanion remoteReminderInsert(RemoteReminder remote) =>
    RemindersCompanion.insert(
      id: remote.id,
      ownerId: Value(remote.userId),
      itemId: remote.itemId,
      actionId: Value(remote.actionId),
      title: Value(remote.title),
      timeZone: Value(remote.timeZone),
      remindAt: remote.remindAt,
      createdAt: remote.createdAt,
      updatedAt: remote.clientUpdatedAt,
      completedAt: Value(remote.completedAt),
      deletedAt: Value(remote.deletedAt),
      syncStatus: SyncStatus.synced,
      lastSyncedAt: Value(remote.serverUpdatedAt),
      remoteServerUpdatedAt: Value(remote.serverUpdatedAt),
      sourceDeviceId: Value(remote.sourceDeviceId),
    );

RemindersCompanion remoteReminderUpdate(RemoteReminder remote) =>
    RemindersCompanion(
      ownerId: Value(remote.userId),
      itemId: Value(remote.itemId),
      actionId: Value(remote.actionId),
      title: Value(remote.title),
      timeZone: Value(remote.timeZone),
      remindAt: Value(remote.remindAt),
      createdAt: Value(remote.createdAt),
      updatedAt: Value(remote.clientUpdatedAt),
      completedAt: Value(remote.completedAt),
      deletedAt: Value(remote.deletedAt),
      syncStatus: const Value(SyncStatus.synced),
      lastSyncedAt: Value(remote.serverUpdatedAt),
      remoteServerUpdatedAt: Value(remote.serverUpdatedAt),
      sourceDeviceId: Value(remote.sourceDeviceId),
    );
