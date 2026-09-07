// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminders_dao.dart';

// ignore_for_file: type=lint
mixin _$RemindersDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItemsTable get items => attachedDatabase.items;
  $SourcesTable get sources => attachedDatabase.sources;
  $ItemActionsTable get itemActions => attachedDatabase.itemActions;
  $RemindersTable get reminders => attachedDatabase.reminders;
  RemindersDaoManager get managers => RemindersDaoManager(this);
}

class RemindersDaoManager {
  final _$RemindersDaoMixin _db;
  RemindersDaoManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db.attachedDatabase, _db.sources);
  $$ItemActionsTableTableManager get itemActions =>
      $$ItemActionsTableTableManager(_db.attachedDatabase, _db.itemActions);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db.attachedDatabase, _db.reminders);
}
