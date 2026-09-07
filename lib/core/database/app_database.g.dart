// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ItemStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ItemStatus>($ItemsTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($ItemsTable.$convertersyncStatus);
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteServerUpdatedAtMeta =
      const VerificationMeta('remoteServerUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> remoteServerUpdatedAt =
      GeneratedColumn<DateTime>(
        'remote_server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceDeviceIdMeta = const VerificationMeta(
    'sourceDeviceId',
  );
  @override
  late final GeneratedColumn<String> sourceDeviceId = GeneratedColumn<String>(
    'source_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    title,
    summary,
    status,
    createdAt,
    updatedAt,
    resolvedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
    remoteServerUpdatedAt,
    sourceDeviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('remote_server_updated_at')) {
      context.handle(
        _remoteServerUpdatedAtMeta,
        remoteServerUpdatedAt.isAcceptableOrUnknown(
          data['remote_server_updated_at']!,
          _remoteServerUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('source_device_id')) {
      context.handle(
        _sourceDeviceIdMeta,
        sourceDeviceId.isAcceptableOrUnknown(
          data['source_device_id']!,
          _sourceDeviceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      status: $ItemsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $ItemsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      remoteServerUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remote_server_updated_at'],
      ),
      sourceDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device_id'],
      ),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<ItemStatus, String> $converterstatus =
      const ItemStatusConverter();
  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final String id;
  final String? ownerId;
  final String title;
  final String summary;
  final ItemStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime? remoteServerUpdatedAt;
  final String? sourceDeviceId;
  const ItemRow({
    required this.id,
    this.ownerId,
    required this.title,
    required this.summary,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.deletedAt,
    required this.syncStatus,
    this.lastSyncedAt,
    this.remoteServerUpdatedAt,
    this.sourceDeviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['title'] = Variable<String>(title);
    map['summary'] = Variable<String>(summary);
    {
      map['status'] = Variable<String>(
        $ItemsTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $ItemsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || remoteServerUpdatedAt != null) {
      map['remote_server_updated_at'] = Variable<DateTime>(
        remoteServerUpdatedAt,
      );
    }
    if (!nullToAbsent || sourceDeviceId != null) {
      map['source_device_id'] = Variable<String>(sourceDeviceId);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      title: Value(title),
      summary: Value(summary),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      remoteServerUpdatedAt: remoteServerUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteServerUpdatedAt),
      sourceDeviceId: sourceDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDeviceId),
    );
  }

  factory ItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String>(json['summary']),
      status: serializer.fromJson<ItemStatus>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      remoteServerUpdatedAt: serializer.fromJson<DateTime?>(
        json['remoteServerUpdatedAt'],
      ),
      sourceDeviceId: serializer.fromJson<String?>(json['sourceDeviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String?>(ownerId),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String>(summary),
      'status': serializer.toJson<ItemStatus>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'remoteServerUpdatedAt': serializer.toJson<DateTime?>(
        remoteServerUpdatedAt,
      ),
      'sourceDeviceId': serializer.toJson<String?>(sourceDeviceId),
    };
  }

  ItemRow copyWith({
    String? id,
    Value<String?> ownerId = const Value.absent(),
    String? title,
    String? summary,
    ItemStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
    Value<String?> sourceDeviceId = const Value.absent(),
  }) => ItemRow(
    id: id ?? this.id,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    title: title ?? this.title,
    summary: summary ?? this.summary,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    remoteServerUpdatedAt: remoteServerUpdatedAt.present
        ? remoteServerUpdatedAt.value
        : this.remoteServerUpdatedAt,
    sourceDeviceId: sourceDeviceId.present
        ? sourceDeviceId.value
        : this.sourceDeviceId,
  );
  ItemRow copyWithCompanion(ItemsCompanion data) {
    return ItemRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      remoteServerUpdatedAt: data.remoteServerUpdatedAt.present
          ? data.remoteServerUpdatedAt.value
          : this.remoteServerUpdatedAt,
      sourceDeviceId: data.sourceDeviceId.present
          ? data.sourceDeviceId.value
          : this.sourceDeviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
          ..write('sourceDeviceId: $sourceDeviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    title,
    summary,
    status,
    createdAt,
    updatedAt,
    resolvedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
    remoteServerUpdatedAt,
    sourceDeviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.resolvedAt == this.resolvedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.remoteServerUpdatedAt == this.remoteServerUpdatedAt &&
          other.sourceDeviceId == this.sourceDeviceId);
}

class ItemsCompanion extends UpdateCompanion<ItemRow> {
  final Value<String> id;
  final Value<String?> ownerId;
  final Value<String> title;
  final Value<String> summary;
  final Value<ItemStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> remoteServerUpdatedAt;
  final Value<String?> sourceDeviceId;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.remoteServerUpdatedAt = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    this.ownerId = const Value.absent(),
    required String title,
    this.summary = const Value.absent(),
    required ItemStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.resolvedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required SyncStatus syncStatus,
    this.lastSyncedAt = const Value.absent(),
    this.remoteServerUpdatedAt = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus);
  static Insertable<ItemRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? remoteServerUpdatedAt,
    Expression<String>? sourceDeviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (remoteServerUpdatedAt != null)
        'remote_server_updated_at': remoteServerUpdatedAt,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerId,
    Value<String>? title,
    Value<String>? summary,
    Value<ItemStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? resolvedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime?>? remoteServerUpdatedAt,
    Value<String?>? sourceDeviceId,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      remoteServerUpdatedAt:
          remoteServerUpdatedAt ?? this.remoteServerUpdatedAt,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ItemsTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $ItemsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (remoteServerUpdatedAt.present) {
      map['remote_server_updated_at'] = Variable<DateTime>(
        remoteServerUpdatedAt.value,
      );
    }
    if (sourceDeviceId.present) {
      map['source_device_id'] = Variable<String>(sourceDeviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourcesTable extends Sources with TableInfo<$SourcesTable, SourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteServerUpdatedAtMeta =
      const VerificationMeta('remoteServerUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> remoteServerUpdatedAt =
      GeneratedColumn<DateTime>(
        'remote_server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($SourcesTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    ownerId,
    kind,
    origin,
    originalName,
    mimeType,
    byteSize,
    contentHash,
    revision,
    textContent,
    pageCount,
    createdAt,
    updatedAt,
    remoteServerUpdatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('remote_server_updated_at')) {
      context.handle(
        _remoteServerUpdatedAtMeta,
        remoteServerUpdatedAt.isAcceptableOrUnknown(
          data['remote_server_updated_at']!,
          _remoteServerUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      remoteServerUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remote_server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $SourcesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
    );
  }

  @override
  $SourcesTable createAlias(String alias) {
    return $SourcesTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class SourceRow extends DataClass implements Insertable<SourceRow> {
  final String id;
  final String itemId;
  final String? ownerId;
  final String kind;
  final String origin;
  final String originalName;
  final String mimeType;
  final int byteSize;
  final String contentHash;
  final int revision;
  final String? textContent;
  final int? pageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? remoteServerUpdatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  const SourceRow({
    required this.id,
    required this.itemId,
    this.ownerId,
    required this.kind,
    required this.origin,
    required this.originalName,
    required this.mimeType,
    required this.byteSize,
    required this.contentHash,
    required this.revision,
    this.textContent,
    this.pageCount,
    required this.createdAt,
    required this.updatedAt,
    this.remoteServerUpdatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['kind'] = Variable<String>(kind);
    map['origin'] = Variable<String>(origin);
    map['original_name'] = Variable<String>(originalName);
    map['mime_type'] = Variable<String>(mimeType);
    map['byte_size'] = Variable<int>(byteSize);
    map['content_hash'] = Variable<String>(contentHash);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remoteServerUpdatedAt != null) {
      map['remote_server_updated_at'] = Variable<DateTime>(
        remoteServerUpdatedAt,
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $SourcesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    return map;
  }

  SourcesCompanion toCompanion(bool nullToAbsent) {
    return SourcesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      kind: Value(kind),
      origin: Value(origin),
      originalName: Value(originalName),
      mimeType: Value(mimeType),
      byteSize: Value(byteSize),
      contentHash: Value(contentHash),
      revision: Value(revision),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteServerUpdatedAt: remoteServerUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteServerUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory SourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceRow(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      kind: serializer.fromJson<String>(json['kind']),
      origin: serializer.fromJson<String>(json['origin']),
      originalName: serializer.fromJson<String>(json['originalName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      revision: serializer.fromJson<int>(json['revision']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remoteServerUpdatedAt: serializer.fromJson<DateTime?>(
        json['remoteServerUpdatedAt'],
      ),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'ownerId': serializer.toJson<String?>(ownerId),
      'kind': serializer.toJson<String>(kind),
      'origin': serializer.toJson<String>(origin),
      'originalName': serializer.toJson<String>(originalName),
      'mimeType': serializer.toJson<String>(mimeType),
      'byteSize': serializer.toJson<int>(byteSize),
      'contentHash': serializer.toJson<String>(contentHash),
      'revision': serializer.toJson<int>(revision),
      'textContent': serializer.toJson<String?>(textContent),
      'pageCount': serializer.toJson<int?>(pageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remoteServerUpdatedAt': serializer.toJson<DateTime?>(
        remoteServerUpdatedAt,
      ),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
    };
  }

  SourceRow copyWith({
    String? id,
    String? itemId,
    Value<String?> ownerId = const Value.absent(),
    String? kind,
    String? origin,
    String? originalName,
    String? mimeType,
    int? byteSize,
    String? contentHash,
    int? revision,
    Value<String?> textContent = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
  }) => SourceRow(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    kind: kind ?? this.kind,
    origin: origin ?? this.origin,
    originalName: originalName ?? this.originalName,
    mimeType: mimeType ?? this.mimeType,
    byteSize: byteSize ?? this.byteSize,
    contentHash: contentHash ?? this.contentHash,
    revision: revision ?? this.revision,
    textContent: textContent.present ? textContent.value : this.textContent,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteServerUpdatedAt: remoteServerUpdatedAt.present
        ? remoteServerUpdatedAt.value
        : this.remoteServerUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  SourceRow copyWithCompanion(SourcesCompanion data) {
    return SourceRow(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      kind: data.kind.present ? data.kind.value : this.kind,
      origin: data.origin.present ? data.origin.value : this.origin,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      revision: data.revision.present ? data.revision.value : this.revision,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteServerUpdatedAt: data.remoteServerUpdatedAt.present
          ? data.remoteServerUpdatedAt.value
          : this.remoteServerUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceRow(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ownerId: $ownerId, ')
          ..write('kind: $kind, ')
          ..write('origin: $origin, ')
          ..write('originalName: $originalName, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('contentHash: $contentHash, ')
          ..write('revision: $revision, ')
          ..write('textContent: $textContent, ')
          ..write('pageCount: $pageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    ownerId,
    kind,
    origin,
    originalName,
    mimeType,
    byteSize,
    contentHash,
    revision,
    textContent,
    pageCount,
    createdAt,
    updatedAt,
    remoteServerUpdatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceRow &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.ownerId == this.ownerId &&
          other.kind == this.kind &&
          other.origin == this.origin &&
          other.originalName == this.originalName &&
          other.mimeType == this.mimeType &&
          other.byteSize == this.byteSize &&
          other.contentHash == this.contentHash &&
          other.revision == this.revision &&
          other.textContent == this.textContent &&
          other.pageCount == this.pageCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteServerUpdatedAt == this.remoteServerUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class SourcesCompanion extends UpdateCompanion<SourceRow> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> ownerId;
  final Value<String> kind;
  final Value<String> origin;
  final Value<String> originalName;
  final Value<String> mimeType;
  final Value<int> byteSize;
  final Value<String> contentHash;
  final Value<int> revision;
  final Value<String?> textContent;
  final Value<int?> pageCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> remoteServerUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<int> rowid;
  const SourcesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.kind = const Value.absent(),
    this.origin = const Value.absent(),
    this.originalName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.revision = const Value.absent(),
    this.textContent = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteServerUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourcesCompanion.insert({
    required String id,
    required String itemId,
    this.ownerId = const Value.absent(),
    required String kind,
    required String origin,
    required String originalName,
    required String mimeType,
    required int byteSize,
    required String contentHash,
    this.revision = const Value.absent(),
    this.textContent = const Value.absent(),
    this.pageCount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.remoteServerUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required SyncStatus syncStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       kind = Value(kind),
       origin = Value(origin),
       originalName = Value(originalName),
       mimeType = Value(mimeType),
       byteSize = Value(byteSize),
       contentHash = Value(contentHash),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus);
  static Insertable<SourceRow> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? ownerId,
    Expression<String>? kind,
    Expression<String>? origin,
    Expression<String>? originalName,
    Expression<String>? mimeType,
    Expression<int>? byteSize,
    Expression<String>? contentHash,
    Expression<int>? revision,
    Expression<String>? textContent,
    Expression<int>? pageCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? remoteServerUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (ownerId != null) 'owner_id': ownerId,
      if (kind != null) 'kind': kind,
      if (origin != null) 'origin': origin,
      if (originalName != null) 'original_name': originalName,
      if (mimeType != null) 'mime_type': mimeType,
      if (byteSize != null) 'byte_size': byteSize,
      if (contentHash != null) 'content_hash': contentHash,
      if (revision != null) 'revision': revision,
      if (textContent != null) 'text_content': textContent,
      if (pageCount != null) 'page_count': pageCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteServerUpdatedAt != null)
        'remote_server_updated_at': remoteServerUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String?>? ownerId,
    Value<String>? kind,
    Value<String>? origin,
    Value<String>? originalName,
    Value<String>? mimeType,
    Value<int>? byteSize,
    Value<String>? contentHash,
    Value<int>? revision,
    Value<String?>? textContent,
    Value<int?>? pageCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? remoteServerUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<int>? rowid,
  }) {
    return SourcesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      ownerId: ownerId ?? this.ownerId,
      kind: kind ?? this.kind,
      origin: origin ?? this.origin,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      byteSize: byteSize ?? this.byteSize,
      contentHash: contentHash ?? this.contentHash,
      revision: revision ?? this.revision,
      textContent: textContent ?? this.textContent,
      pageCount: pageCount ?? this.pageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteServerUpdatedAt:
          remoteServerUpdatedAt ?? this.remoteServerUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remoteServerUpdatedAt.present) {
      map['remote_server_updated_at'] = Variable<DateTime>(
        remoteServerUpdatedAt.value,
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $SourcesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ownerId: $ownerId, ')
          ..write('kind: $kind, ')
          ..write('origin: $origin, ')
          ..write('originalName: $originalName, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('contentHash: $contentHash, ')
          ..write('revision: $revision, ')
          ..write('textContent: $textContent, ')
          ..write('pageCount: $pageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemActionsTable extends ItemActions
    with TableInfo<$ItemActionsTable, ItemActionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sources (id)',
    ),
  );
  static const VerificationMeta _analysisRevisionMeta = const VerificationMeta(
    'analysisRevision',
  );
  @override
  late final GeneratedColumn<int> analysisRevision = GeneratedColumn<int>(
    'analysis_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadVersionMeta = const VerificationMeta(
    'payloadVersion',
  );
  @override
  late final GeneratedColumn<int> payloadVersion = GeneratedColumn<int>(
    'payload_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceFactIdsMeta = const VerificationMeta(
    'evidenceFactIds',
  );
  @override
  late final GeneratedColumn<String> evidenceFactIds = GeneratedColumn<String>(
    'evidence_fact_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('proposed'),
  );
  static const VerificationMeta _executionStateMeta = const VerificationMeta(
    'executionState',
  );
  @override
  late final GeneratedColumn<String> executionState = GeneratedColumn<String>(
    'execution_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('notRequested'),
  );
  static const VerificationMeta _acceptedAtMeta = const VerificationMeta(
    'acceptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acceptedAt = GeneratedColumn<DateTime>(
    'accepted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteServerUpdatedAtMeta =
      const VerificationMeta('remoteServerUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> remoteServerUpdatedAt =
      GeneratedColumn<DateTime>(
        'remote_server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($ItemActionsTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    ownerId,
    sourceId,
    analysisRevision,
    kind,
    title,
    payloadVersion,
    payload,
    origin,
    evidenceFactIds,
    state,
    executionState,
    acceptedAt,
    createdAt,
    updatedAt,
    remoteServerUpdatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemActionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('analysis_revision')) {
      context.handle(
        _analysisRevisionMeta,
        analysisRevision.isAcceptableOrUnknown(
          data['analysis_revision']!,
          _analysisRevisionMeta,
        ),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('payload_version')) {
      context.handle(
        _payloadVersionMeta,
        payloadVersion.isAcceptableOrUnknown(
          data['payload_version']!,
          _payloadVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('evidence_fact_ids')) {
      context.handle(
        _evidenceFactIdsMeta,
        evidenceFactIds.isAcceptableOrUnknown(
          data['evidence_fact_ids']!,
          _evidenceFactIdsMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('execution_state')) {
      context.handle(
        _executionStateMeta,
        executionState.isAcceptableOrUnknown(
          data['execution_state']!,
          _executionStateMeta,
        ),
      );
    }
    if (data.containsKey('accepted_at')) {
      context.handle(
        _acceptedAtMeta,
        acceptedAt.isAcceptableOrUnknown(data['accepted_at']!, _acceptedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('remote_server_updated_at')) {
      context.handle(
        _remoteServerUpdatedAtMeta,
        remoteServerUpdatedAt.isAcceptableOrUnknown(
          data['remote_server_updated_at']!,
          _remoteServerUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemActionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemActionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      analysisRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}analysis_revision'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      payloadVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_version'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      evidenceFactIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_fact_ids'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      executionState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}execution_state'],
      )!,
      acceptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}accepted_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      remoteServerUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remote_server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $ItemActionsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
    );
  }

  @override
  $ItemActionsTable createAlias(String alias) {
    return $ItemActionsTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class ItemActionRow extends DataClass implements Insertable<ItemActionRow> {
  final String id;
  final String itemId;
  final String? ownerId;
  final String? sourceId;
  final int? analysisRevision;
  final String kind;
  final String title;
  final int payloadVersion;
  final String payload;
  final String origin;
  final String evidenceFactIds;
  final String state;
  final String executionState;
  final DateTime? acceptedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? remoteServerUpdatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  const ItemActionRow({
    required this.id,
    required this.itemId,
    this.ownerId,
    this.sourceId,
    this.analysisRevision,
    required this.kind,
    required this.title,
    required this.payloadVersion,
    required this.payload,
    required this.origin,
    required this.evidenceFactIds,
    required this.state,
    required this.executionState,
    this.acceptedAt,
    required this.createdAt,
    required this.updatedAt,
    this.remoteServerUpdatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    if (!nullToAbsent || analysisRevision != null) {
      map['analysis_revision'] = Variable<int>(analysisRevision);
    }
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['payload_version'] = Variable<int>(payloadVersion);
    map['payload'] = Variable<String>(payload);
    map['origin'] = Variable<String>(origin);
    map['evidence_fact_ids'] = Variable<String>(evidenceFactIds);
    map['state'] = Variable<String>(state);
    map['execution_state'] = Variable<String>(executionState);
    if (!nullToAbsent || acceptedAt != null) {
      map['accepted_at'] = Variable<DateTime>(acceptedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remoteServerUpdatedAt != null) {
      map['remote_server_updated_at'] = Variable<DateTime>(
        remoteServerUpdatedAt,
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $ItemActionsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    return map;
  }

  ItemActionsCompanion toCompanion(bool nullToAbsent) {
    return ItemActionsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      analysisRevision: analysisRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisRevision),
      kind: Value(kind),
      title: Value(title),
      payloadVersion: Value(payloadVersion),
      payload: Value(payload),
      origin: Value(origin),
      evidenceFactIds: Value(evidenceFactIds),
      state: Value(state),
      executionState: Value(executionState),
      acceptedAt: acceptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteServerUpdatedAt: remoteServerUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteServerUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ItemActionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemActionRow(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      analysisRevision: serializer.fromJson<int?>(json['analysisRevision']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      payloadVersion: serializer.fromJson<int>(json['payloadVersion']),
      payload: serializer.fromJson<String>(json['payload']),
      origin: serializer.fromJson<String>(json['origin']),
      evidenceFactIds: serializer.fromJson<String>(json['evidenceFactIds']),
      state: serializer.fromJson<String>(json['state']),
      executionState: serializer.fromJson<String>(json['executionState']),
      acceptedAt: serializer.fromJson<DateTime?>(json['acceptedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remoteServerUpdatedAt: serializer.fromJson<DateTime?>(
        json['remoteServerUpdatedAt'],
      ),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'ownerId': serializer.toJson<String?>(ownerId),
      'sourceId': serializer.toJson<String?>(sourceId),
      'analysisRevision': serializer.toJson<int?>(analysisRevision),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'payloadVersion': serializer.toJson<int>(payloadVersion),
      'payload': serializer.toJson<String>(payload),
      'origin': serializer.toJson<String>(origin),
      'evidenceFactIds': serializer.toJson<String>(evidenceFactIds),
      'state': serializer.toJson<String>(state),
      'executionState': serializer.toJson<String>(executionState),
      'acceptedAt': serializer.toJson<DateTime?>(acceptedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remoteServerUpdatedAt': serializer.toJson<DateTime?>(
        remoteServerUpdatedAt,
      ),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
    };
  }

  ItemActionRow copyWith({
    String? id,
    String? itemId,
    Value<String?> ownerId = const Value.absent(),
    Value<String?> sourceId = const Value.absent(),
    Value<int?> analysisRevision = const Value.absent(),
    String? kind,
    String? title,
    int? payloadVersion,
    String? payload,
    String? origin,
    String? evidenceFactIds,
    String? state,
    String? executionState,
    Value<DateTime?> acceptedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
  }) => ItemActionRow(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    analysisRevision: analysisRevision.present
        ? analysisRevision.value
        : this.analysisRevision,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    payloadVersion: payloadVersion ?? this.payloadVersion,
    payload: payload ?? this.payload,
    origin: origin ?? this.origin,
    evidenceFactIds: evidenceFactIds ?? this.evidenceFactIds,
    state: state ?? this.state,
    executionState: executionState ?? this.executionState,
    acceptedAt: acceptedAt.present ? acceptedAt.value : this.acceptedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteServerUpdatedAt: remoteServerUpdatedAt.present
        ? remoteServerUpdatedAt.value
        : this.remoteServerUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ItemActionRow copyWithCompanion(ItemActionsCompanion data) {
    return ItemActionRow(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      analysisRevision: data.analysisRevision.present
          ? data.analysisRevision.value
          : this.analysisRevision,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      payloadVersion: data.payloadVersion.present
          ? data.payloadVersion.value
          : this.payloadVersion,
      payload: data.payload.present ? data.payload.value : this.payload,
      origin: data.origin.present ? data.origin.value : this.origin,
      evidenceFactIds: data.evidenceFactIds.present
          ? data.evidenceFactIds.value
          : this.evidenceFactIds,
      state: data.state.present ? data.state.value : this.state,
      executionState: data.executionState.present
          ? data.executionState.value
          : this.executionState,
      acceptedAt: data.acceptedAt.present
          ? data.acceptedAt.value
          : this.acceptedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteServerUpdatedAt: data.remoteServerUpdatedAt.present
          ? data.remoteServerUpdatedAt.value
          : this.remoteServerUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemActionRow(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ownerId: $ownerId, ')
          ..write('sourceId: $sourceId, ')
          ..write('analysisRevision: $analysisRevision, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('payload: $payload, ')
          ..write('origin: $origin, ')
          ..write('evidenceFactIds: $evidenceFactIds, ')
          ..write('state: $state, ')
          ..write('executionState: $executionState, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    ownerId,
    sourceId,
    analysisRevision,
    kind,
    title,
    payloadVersion,
    payload,
    origin,
    evidenceFactIds,
    state,
    executionState,
    acceptedAt,
    createdAt,
    updatedAt,
    remoteServerUpdatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemActionRow &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.ownerId == this.ownerId &&
          other.sourceId == this.sourceId &&
          other.analysisRevision == this.analysisRevision &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.payloadVersion == this.payloadVersion &&
          other.payload == this.payload &&
          other.origin == this.origin &&
          other.evidenceFactIds == this.evidenceFactIds &&
          other.state == this.state &&
          other.executionState == this.executionState &&
          other.acceptedAt == this.acceptedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteServerUpdatedAt == this.remoteServerUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class ItemActionsCompanion extends UpdateCompanion<ItemActionRow> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> ownerId;
  final Value<String?> sourceId;
  final Value<int?> analysisRevision;
  final Value<String> kind;
  final Value<String> title;
  final Value<int> payloadVersion;
  final Value<String> payload;
  final Value<String> origin;
  final Value<String> evidenceFactIds;
  final Value<String> state;
  final Value<String> executionState;
  final Value<DateTime?> acceptedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> remoteServerUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<int> rowid;
  const ItemActionsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.analysisRevision = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.payloadVersion = const Value.absent(),
    this.payload = const Value.absent(),
    this.origin = const Value.absent(),
    this.evidenceFactIds = const Value.absent(),
    this.state = const Value.absent(),
    this.executionState = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteServerUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemActionsCompanion.insert({
    required String id,
    required String itemId,
    this.ownerId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.analysisRevision = const Value.absent(),
    required String kind,
    required String title,
    this.payloadVersion = const Value.absent(),
    required String payload,
    required String origin,
    this.evidenceFactIds = const Value.absent(),
    this.state = const Value.absent(),
    this.executionState = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.remoteServerUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required SyncStatus syncStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       kind = Value(kind),
       title = Value(title),
       payload = Value(payload),
       origin = Value(origin),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus);
  static Insertable<ItemActionRow> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? ownerId,
    Expression<String>? sourceId,
    Expression<int>? analysisRevision,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<int>? payloadVersion,
    Expression<String>? payload,
    Expression<String>? origin,
    Expression<String>? evidenceFactIds,
    Expression<String>? state,
    Expression<String>? executionState,
    Expression<DateTime>? acceptedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? remoteServerUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (ownerId != null) 'owner_id': ownerId,
      if (sourceId != null) 'source_id': sourceId,
      if (analysisRevision != null) 'analysis_revision': analysisRevision,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (payloadVersion != null) 'payload_version': payloadVersion,
      if (payload != null) 'payload': payload,
      if (origin != null) 'origin': origin,
      if (evidenceFactIds != null) 'evidence_fact_ids': evidenceFactIds,
      if (state != null) 'state': state,
      if (executionState != null) 'execution_state': executionState,
      if (acceptedAt != null) 'accepted_at': acceptedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteServerUpdatedAt != null)
        'remote_server_updated_at': remoteServerUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemActionsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String?>? ownerId,
    Value<String?>? sourceId,
    Value<int?>? analysisRevision,
    Value<String>? kind,
    Value<String>? title,
    Value<int>? payloadVersion,
    Value<String>? payload,
    Value<String>? origin,
    Value<String>? evidenceFactIds,
    Value<String>? state,
    Value<String>? executionState,
    Value<DateTime?>? acceptedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? remoteServerUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<int>? rowid,
  }) {
    return ItemActionsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      ownerId: ownerId ?? this.ownerId,
      sourceId: sourceId ?? this.sourceId,
      analysisRevision: analysisRevision ?? this.analysisRevision,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      payloadVersion: payloadVersion ?? this.payloadVersion,
      payload: payload ?? this.payload,
      origin: origin ?? this.origin,
      evidenceFactIds: evidenceFactIds ?? this.evidenceFactIds,
      state: state ?? this.state,
      executionState: executionState ?? this.executionState,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteServerUpdatedAt:
          remoteServerUpdatedAt ?? this.remoteServerUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (analysisRevision.present) {
      map['analysis_revision'] = Variable<int>(analysisRevision.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (payloadVersion.present) {
      map['payload_version'] = Variable<int>(payloadVersion.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (evidenceFactIds.present) {
      map['evidence_fact_ids'] = Variable<String>(evidenceFactIds.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (executionState.present) {
      map['execution_state'] = Variable<String>(executionState.value);
    }
    if (acceptedAt.present) {
      map['accepted_at'] = Variable<DateTime>(acceptedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remoteServerUpdatedAt.present) {
      map['remote_server_updated_at'] = Variable<DateTime>(
        remoteServerUpdatedAt.value,
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $ItemActionsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemActionsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ownerId: $ownerId, ')
          ..write('sourceId: $sourceId, ')
          ..write('analysisRevision: $analysisRevision, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('payload: $payload, ')
          ..write('origin: $origin, ')
          ..write('evidenceFactIds: $evidenceFactIds, ')
          ..write('state: $state, ')
          ..write('executionState: $executionState, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _actionIdMeta = const VerificationMeta(
    'actionId',
  );
  @override
  late final GeneratedColumn<String> actionId = GeneratedColumn<String>(
    'action_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES item_actions (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeZoneMeta = const VerificationMeta(
    'timeZone',
  );
  @override
  late final GeneratedColumn<String> timeZone = GeneratedColumn<String>(
    'time_zone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta(
    'remindAt',
  );
  @override
  late final GeneratedColumn<DateTime> remindAt = GeneratedColumn<DateTime>(
    'remind_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($RemindersTable.$convertersyncStatus);
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteServerUpdatedAtMeta =
      const VerificationMeta('remoteServerUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> remoteServerUpdatedAt =
      GeneratedColumn<DateTime>(
        'remote_server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceDeviceIdMeta = const VerificationMeta(
    'sourceDeviceId',
  );
  @override
  late final GeneratedColumn<String> sourceDeviceId = GeneratedColumn<String>(
    'source_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    itemId,
    actionId,
    title,
    timeZone,
    remindAt,
    completedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
    remoteServerUpdatedAt,
    sourceDeviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('action_id')) {
      context.handle(
        _actionIdMeta,
        actionId.isAcceptableOrUnknown(data['action_id']!, _actionIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('time_zone')) {
      context.handle(
        _timeZoneMeta,
        timeZone.isAcceptableOrUnknown(data['time_zone']!, _timeZoneMeta),
      );
    }
    if (data.containsKey('remind_at')) {
      context.handle(
        _remindAtMeta,
        remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta),
      );
    } else if (isInserting) {
      context.missing(_remindAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('remote_server_updated_at')) {
      context.handle(
        _remoteServerUpdatedAtMeta,
        remoteServerUpdatedAt.isAcceptableOrUnknown(
          data['remote_server_updated_at']!,
          _remoteServerUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('source_device_id')) {
      context.handle(
        _sourceDeviceIdMeta,
        sourceDeviceId.isAcceptableOrUnknown(
          data['source_device_id']!,
          _sourceDeviceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      actionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      timeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone'],
      ),
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remind_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $RemindersTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      remoteServerUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remote_server_updated_at'],
      ),
      sourceDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device_id'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String id;
  final String? ownerId;
  final String itemId;
  final String? actionId;
  final String? title;
  final String? timeZone;
  final DateTime remindAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime? remoteServerUpdatedAt;
  final String? sourceDeviceId;
  const ReminderRow({
    required this.id,
    this.ownerId,
    required this.itemId,
    this.actionId,
    this.title,
    this.timeZone,
    required this.remindAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    this.lastSyncedAt,
    this.remoteServerUpdatedAt,
    this.sourceDeviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || actionId != null) {
      map['action_id'] = Variable<String>(actionId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || timeZone != null) {
      map['time_zone'] = Variable<String>(timeZone);
    }
    map['remind_at'] = Variable<DateTime>(remindAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $RemindersTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || remoteServerUpdatedAt != null) {
      map['remote_server_updated_at'] = Variable<DateTime>(
        remoteServerUpdatedAt,
      );
    }
    if (!nullToAbsent || sourceDeviceId != null) {
      map['source_device_id'] = Variable<String>(sourceDeviceId);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      itemId: Value(itemId),
      actionId: actionId == null && nullToAbsent
          ? const Value.absent()
          : Value(actionId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      timeZone: timeZone == null && nullToAbsent
          ? const Value.absent()
          : Value(timeZone),
      remindAt: Value(remindAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      remoteServerUpdatedAt: remoteServerUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteServerUpdatedAt),
      sourceDeviceId: sourceDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDeviceId),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      actionId: serializer.fromJson<String?>(json['actionId']),
      title: serializer.fromJson<String?>(json['title']),
      timeZone: serializer.fromJson<String?>(json['timeZone']),
      remindAt: serializer.fromJson<DateTime>(json['remindAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      remoteServerUpdatedAt: serializer.fromJson<DateTime?>(
        json['remoteServerUpdatedAt'],
      ),
      sourceDeviceId: serializer.fromJson<String?>(json['sourceDeviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String?>(ownerId),
      'itemId': serializer.toJson<String>(itemId),
      'actionId': serializer.toJson<String?>(actionId),
      'title': serializer.toJson<String?>(title),
      'timeZone': serializer.toJson<String?>(timeZone),
      'remindAt': serializer.toJson<DateTime>(remindAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'remoteServerUpdatedAt': serializer.toJson<DateTime?>(
        remoteServerUpdatedAt,
      ),
      'sourceDeviceId': serializer.toJson<String?>(sourceDeviceId),
    };
  }

  ReminderRow copyWith({
    String? id,
    Value<String?> ownerId = const Value.absent(),
    String? itemId,
    Value<String?> actionId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> timeZone = const Value.absent(),
    DateTime? remindAt,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
    Value<String?> sourceDeviceId = const Value.absent(),
  }) => ReminderRow(
    id: id ?? this.id,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    itemId: itemId ?? this.itemId,
    actionId: actionId.present ? actionId.value : this.actionId,
    title: title.present ? title.value : this.title,
    timeZone: timeZone.present ? timeZone.value : this.timeZone,
    remindAt: remindAt ?? this.remindAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    remoteServerUpdatedAt: remoteServerUpdatedAt.present
        ? remoteServerUpdatedAt.value
        : this.remoteServerUpdatedAt,
    sourceDeviceId: sourceDeviceId.present
        ? sourceDeviceId.value
        : this.sourceDeviceId,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      actionId: data.actionId.present ? data.actionId.value : this.actionId,
      title: data.title.present ? data.title.value : this.title,
      timeZone: data.timeZone.present ? data.timeZone.value : this.timeZone,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      remoteServerUpdatedAt: data.remoteServerUpdatedAt.present
          ? data.remoteServerUpdatedAt.value
          : this.remoteServerUpdatedAt,
      sourceDeviceId: data.sourceDeviceId.present
          ? data.sourceDeviceId.value
          : this.sourceDeviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('itemId: $itemId, ')
          ..write('actionId: $actionId, ')
          ..write('title: $title, ')
          ..write('timeZone: $timeZone, ')
          ..write('remindAt: $remindAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
          ..write('sourceDeviceId: $sourceDeviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    itemId,
    actionId,
    title,
    timeZone,
    remindAt,
    completedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
    remoteServerUpdatedAt,
    sourceDeviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.itemId == this.itemId &&
          other.actionId == this.actionId &&
          other.title == this.title &&
          other.timeZone == this.timeZone &&
          other.remindAt == this.remindAt &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.remoteServerUpdatedAt == this.remoteServerUpdatedAt &&
          other.sourceDeviceId == this.sourceDeviceId);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<String?> ownerId;
  final Value<String> itemId;
  final Value<String?> actionId;
  final Value<String?> title;
  final Value<String?> timeZone;
  final Value<DateTime> remindAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> remoteServerUpdatedAt;
  final Value<String?> sourceDeviceId;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.actionId = const Value.absent(),
    this.title = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.remoteServerUpdatedAt = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    this.ownerId = const Value.absent(),
    required String itemId,
    this.actionId = const Value.absent(),
    this.title = const Value.absent(),
    this.timeZone = const Value.absent(),
    required DateTime remindAt,
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required SyncStatus syncStatus,
    this.lastSyncedAt = const Value.absent(),
    this.remoteServerUpdatedAt = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       remindAt = Value(remindAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? itemId,
    Expression<String>? actionId,
    Expression<String>? title,
    Expression<String>? timeZone,
    Expression<DateTime>? remindAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? remoteServerUpdatedAt,
    Expression<String>? sourceDeviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (itemId != null) 'item_id': itemId,
      if (actionId != null) 'action_id': actionId,
      if (title != null) 'title': title,
      if (timeZone != null) 'time_zone': timeZone,
      if (remindAt != null) 'remind_at': remindAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (remoteServerUpdatedAt != null)
        'remote_server_updated_at': remoteServerUpdatedAt,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerId,
    Value<String>? itemId,
    Value<String?>? actionId,
    Value<String?>? title,
    Value<String?>? timeZone,
    Value<DateTime>? remindAt,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime?>? remoteServerUpdatedAt,
    Value<String?>? sourceDeviceId,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      itemId: itemId ?? this.itemId,
      actionId: actionId ?? this.actionId,
      title: title ?? this.title,
      timeZone: timeZone ?? this.timeZone,
      remindAt: remindAt ?? this.remindAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      remoteServerUpdatedAt:
          remoteServerUpdatedAt ?? this.remoteServerUpdatedAt,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (actionId.present) {
      map['action_id'] = Variable<String>(actionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (timeZone.present) {
      map['time_zone'] = Variable<String>(timeZone.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<DateTime>(remindAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $RemindersTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (remoteServerUpdatedAt.present) {
      map['remote_server_updated_at'] = Variable<DateTime>(
        remoteServerUpdatedAt.value,
      );
    }
    if (sourceDeviceId.present) {
      map['source_device_id'] = Variable<String>(sourceDeviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('itemId: $itemId, ')
          ..write('actionId: $actionId, ')
          ..write('title: $title, ')
          ..write('timeZone: $timeZone, ')
          ..write('remindAt: $remindAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncEntityType, String>
  entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SyncEntityType>($SyncQueueTable.$converterentityType);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncOperation, String> operation =
      GeneratedColumn<String>(
        'operation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncOperation>($SyncQueueTable.$converteroperation);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    createdAt,
    attempts,
    lastAttemptAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: $SyncQueueTable.$converterentityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}entity_type'],
        )!,
      ),
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: $SyncQueueTable.$converteroperation.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}operation'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncEntityType, String> $converterentityType =
      const SyncEntityTypeConverter();
  static TypeConverter<SyncOperation, String> $converteroperation =
      const SyncOperationConverter();
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperation operation;
  final DateTime createdAt;
  final int attempts;
  final DateTime? lastAttemptAt;
  final String? lastError;
  const SyncQueueRow({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.createdAt,
    required this.attempts,
    this.lastAttemptAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['entity_type'] = Variable<String>(
        $SyncQueueTable.$converterentityType.toSql(entityType),
      );
    }
    map['entity_id'] = Variable<String>(entityId);
    {
      map['operation'] = Variable<String>(
        $SyncQueueTable.$converteroperation.toSql(operation),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<SyncEntityType>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<SyncOperation>(json['operation']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<SyncEntityType>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<SyncOperation>(operation),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueRow copyWith({
    String? id,
    SyncEntityType? entityType,
    String? entityId,
    SyncOperation? operation,
    DateTime? createdAt,
    int? attempts,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => SyncQueueRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncQueueRow copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueRow(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    createdAt,
    attempts,
    lastAttemptAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.lastError == this.lastError);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<String> id;
  final Value<SyncEntityType> entityType;
  final Value<String> entityId;
  final Value<SyncOperation> operation;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueRow> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? id,
    Value<SyncEntityType>? entityType,
    Value<String>? entityId,
    Value<SyncOperation>? operation,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(
        $SyncQueueTable.$converterentityType.toSql(entityType.value),
      );
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(
        $SyncQueueTable.$converteroperation.toSql(operation.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CloudSyncStatesTable extends CloudSyncStates
    with TableInfo<$CloudSyncStatesTable, CloudSyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CloudSyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFactsCursorMeta = const VerificationMeta(
    'lastFactsCursor',
  );
  @override
  late final GeneratedColumn<DateTime> lastFactsCursor =
      GeneratedColumn<DateTime>(
        'last_facts_cursor',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastActionsCursorMeta = const VerificationMeta(
    'lastActionsCursor',
  );
  @override
  late final GeneratedColumn<DateTime> lastActionsCursor =
      GeneratedColumn<DateTime>(
        'last_actions_cursor',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSourcesCursorMeta = const VerificationMeta(
    'lastSourcesCursor',
  );
  @override
  late final GeneratedColumn<DateTime> lastSourcesCursor =
      GeneratedColumn<DateTime>(
        'last_sources_cursor',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastItemsCursorMeta = const VerificationMeta(
    'lastItemsCursor',
  );
  @override
  late final GeneratedColumn<DateTime> lastItemsCursor =
      GeneratedColumn<DateTime>(
        'last_items_cursor',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastRemindersCursorMeta =
      const VerificationMeta('lastRemindersCursor');
  @override
  late final GeneratedColumn<DateTime> lastRemindersCursor =
      GeneratedColumn<DateTime>(
        'last_reminders_cursor',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSuccessfulSyncAtMeta =
      const VerificationMeta('lastSuccessfulSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSuccessfulSyncAt =
      GeneratedColumn<DateTime>(
        'last_successful_sync_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    installationId,
    userId,
    lastFactsCursor,
    lastActionsCursor,
    lastSourcesCursor,
    lastItemsCursor,
    lastRemindersCursor,
    lastSuccessfulSyncAt,
    lastAttemptAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cloud_sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<CloudSyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installationIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('last_facts_cursor')) {
      context.handle(
        _lastFactsCursorMeta,
        lastFactsCursor.isAcceptableOrUnknown(
          data['last_facts_cursor']!,
          _lastFactsCursorMeta,
        ),
      );
    }
    if (data.containsKey('last_actions_cursor')) {
      context.handle(
        _lastActionsCursorMeta,
        lastActionsCursor.isAcceptableOrUnknown(
          data['last_actions_cursor']!,
          _lastActionsCursorMeta,
        ),
      );
    }
    if (data.containsKey('last_sources_cursor')) {
      context.handle(
        _lastSourcesCursorMeta,
        lastSourcesCursor.isAcceptableOrUnknown(
          data['last_sources_cursor']!,
          _lastSourcesCursorMeta,
        ),
      );
    }
    if (data.containsKey('last_items_cursor')) {
      context.handle(
        _lastItemsCursorMeta,
        lastItemsCursor.isAcceptableOrUnknown(
          data['last_items_cursor']!,
          _lastItemsCursorMeta,
        ),
      );
    }
    if (data.containsKey('last_reminders_cursor')) {
      context.handle(
        _lastRemindersCursorMeta,
        lastRemindersCursor.isAcceptableOrUnknown(
          data['last_reminders_cursor']!,
          _lastRemindersCursorMeta,
        ),
      );
    }
    if (data.containsKey('last_successful_sync_at')) {
      context.handle(
        _lastSuccessfulSyncAtMeta,
        lastSuccessfulSyncAt.isAcceptableOrUnknown(
          data['last_successful_sync_at']!,
          _lastSuccessfulSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CloudSyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CloudSyncStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      lastFactsCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_facts_cursor'],
      ),
      lastActionsCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_actions_cursor'],
      ),
      lastSourcesCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sources_cursor'],
      ),
      lastItemsCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_items_cursor'],
      ),
      lastRemindersCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reminders_cursor'],
      ),
      lastSuccessfulSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_successful_sync_at'],
      ),
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $CloudSyncStatesTable createAlias(String alias) {
    return $CloudSyncStatesTable(attachedDatabase, alias);
  }
}

class CloudSyncStateRow extends DataClass
    implements Insertable<CloudSyncStateRow> {
  final String id;
  final String installationId;
  final String? userId;
  final DateTime? lastFactsCursor;
  final DateTime? lastActionsCursor;
  final DateTime? lastSourcesCursor;
  final DateTime? lastItemsCursor;
  final DateTime? lastRemindersCursor;
  final DateTime? lastSuccessfulSyncAt;
  final DateTime? lastAttemptAt;
  final String? lastError;
  const CloudSyncStateRow({
    required this.id,
    required this.installationId,
    this.userId,
    this.lastFactsCursor,
    this.lastActionsCursor,
    this.lastSourcesCursor,
    this.lastItemsCursor,
    this.lastRemindersCursor,
    this.lastSuccessfulSyncAt,
    this.lastAttemptAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['installation_id'] = Variable<String>(installationId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || lastFactsCursor != null) {
      map['last_facts_cursor'] = Variable<DateTime>(lastFactsCursor);
    }
    if (!nullToAbsent || lastActionsCursor != null) {
      map['last_actions_cursor'] = Variable<DateTime>(lastActionsCursor);
    }
    if (!nullToAbsent || lastSourcesCursor != null) {
      map['last_sources_cursor'] = Variable<DateTime>(lastSourcesCursor);
    }
    if (!nullToAbsent || lastItemsCursor != null) {
      map['last_items_cursor'] = Variable<DateTime>(lastItemsCursor);
    }
    if (!nullToAbsent || lastRemindersCursor != null) {
      map['last_reminders_cursor'] = Variable<DateTime>(lastRemindersCursor);
    }
    if (!nullToAbsent || lastSuccessfulSyncAt != null) {
      map['last_successful_sync_at'] = Variable<DateTime>(lastSuccessfulSyncAt);
    }
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  CloudSyncStatesCompanion toCompanion(bool nullToAbsent) {
    return CloudSyncStatesCompanion(
      id: Value(id),
      installationId: Value(installationId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      lastFactsCursor: lastFactsCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFactsCursor),
      lastActionsCursor: lastActionsCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActionsCursor),
      lastSourcesCursor: lastSourcesCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSourcesCursor),
      lastItemsCursor: lastItemsCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(lastItemsCursor),
      lastRemindersCursor: lastRemindersCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRemindersCursor),
      lastSuccessfulSyncAt: lastSuccessfulSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessfulSyncAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory CloudSyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CloudSyncStateRow(
      id: serializer.fromJson<String>(json['id']),
      installationId: serializer.fromJson<String>(json['installationId']),
      userId: serializer.fromJson<String?>(json['userId']),
      lastFactsCursor: serializer.fromJson<DateTime?>(json['lastFactsCursor']),
      lastActionsCursor: serializer.fromJson<DateTime?>(
        json['lastActionsCursor'],
      ),
      lastSourcesCursor: serializer.fromJson<DateTime?>(
        json['lastSourcesCursor'],
      ),
      lastItemsCursor: serializer.fromJson<DateTime?>(json['lastItemsCursor']),
      lastRemindersCursor: serializer.fromJson<DateTime?>(
        json['lastRemindersCursor'],
      ),
      lastSuccessfulSyncAt: serializer.fromJson<DateTime?>(
        json['lastSuccessfulSyncAt'],
      ),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'installationId': serializer.toJson<String>(installationId),
      'userId': serializer.toJson<String?>(userId),
      'lastFactsCursor': serializer.toJson<DateTime?>(lastFactsCursor),
      'lastActionsCursor': serializer.toJson<DateTime?>(lastActionsCursor),
      'lastSourcesCursor': serializer.toJson<DateTime?>(lastSourcesCursor),
      'lastItemsCursor': serializer.toJson<DateTime?>(lastItemsCursor),
      'lastRemindersCursor': serializer.toJson<DateTime?>(lastRemindersCursor),
      'lastSuccessfulSyncAt': serializer.toJson<DateTime?>(
        lastSuccessfulSyncAt,
      ),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  CloudSyncStateRow copyWith({
    String? id,
    String? installationId,
    Value<String?> userId = const Value.absent(),
    Value<DateTime?> lastFactsCursor = const Value.absent(),
    Value<DateTime?> lastActionsCursor = const Value.absent(),
    Value<DateTime?> lastSourcesCursor = const Value.absent(),
    Value<DateTime?> lastItemsCursor = const Value.absent(),
    Value<DateTime?> lastRemindersCursor = const Value.absent(),
    Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => CloudSyncStateRow(
    id: id ?? this.id,
    installationId: installationId ?? this.installationId,
    userId: userId.present ? userId.value : this.userId,
    lastFactsCursor: lastFactsCursor.present
        ? lastFactsCursor.value
        : this.lastFactsCursor,
    lastActionsCursor: lastActionsCursor.present
        ? lastActionsCursor.value
        : this.lastActionsCursor,
    lastSourcesCursor: lastSourcesCursor.present
        ? lastSourcesCursor.value
        : this.lastSourcesCursor,
    lastItemsCursor: lastItemsCursor.present
        ? lastItemsCursor.value
        : this.lastItemsCursor,
    lastRemindersCursor: lastRemindersCursor.present
        ? lastRemindersCursor.value
        : this.lastRemindersCursor,
    lastSuccessfulSyncAt: lastSuccessfulSyncAt.present
        ? lastSuccessfulSyncAt.value
        : this.lastSuccessfulSyncAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  CloudSyncStateRow copyWithCompanion(CloudSyncStatesCompanion data) {
    return CloudSyncStateRow(
      id: data.id.present ? data.id.value : this.id,
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      userId: data.userId.present ? data.userId.value : this.userId,
      lastFactsCursor: data.lastFactsCursor.present
          ? data.lastFactsCursor.value
          : this.lastFactsCursor,
      lastActionsCursor: data.lastActionsCursor.present
          ? data.lastActionsCursor.value
          : this.lastActionsCursor,
      lastSourcesCursor: data.lastSourcesCursor.present
          ? data.lastSourcesCursor.value
          : this.lastSourcesCursor,
      lastItemsCursor: data.lastItemsCursor.present
          ? data.lastItemsCursor.value
          : this.lastItemsCursor,
      lastRemindersCursor: data.lastRemindersCursor.present
          ? data.lastRemindersCursor.value
          : this.lastRemindersCursor,
      lastSuccessfulSyncAt: data.lastSuccessfulSyncAt.present
          ? data.lastSuccessfulSyncAt.value
          : this.lastSuccessfulSyncAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CloudSyncStateRow(')
          ..write('id: $id, ')
          ..write('installationId: $installationId, ')
          ..write('userId: $userId, ')
          ..write('lastFactsCursor: $lastFactsCursor, ')
          ..write('lastActionsCursor: $lastActionsCursor, ')
          ..write('lastSourcesCursor: $lastSourcesCursor, ')
          ..write('lastItemsCursor: $lastItemsCursor, ')
          ..write('lastRemindersCursor: $lastRemindersCursor, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    installationId,
    userId,
    lastFactsCursor,
    lastActionsCursor,
    lastSourcesCursor,
    lastItemsCursor,
    lastRemindersCursor,
    lastSuccessfulSyncAt,
    lastAttemptAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CloudSyncStateRow &&
          other.id == this.id &&
          other.installationId == this.installationId &&
          other.userId == this.userId &&
          other.lastFactsCursor == this.lastFactsCursor &&
          other.lastActionsCursor == this.lastActionsCursor &&
          other.lastSourcesCursor == this.lastSourcesCursor &&
          other.lastItemsCursor == this.lastItemsCursor &&
          other.lastRemindersCursor == this.lastRemindersCursor &&
          other.lastSuccessfulSyncAt == this.lastSuccessfulSyncAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.lastError == this.lastError);
}

class CloudSyncStatesCompanion extends UpdateCompanion<CloudSyncStateRow> {
  final Value<String> id;
  final Value<String> installationId;
  final Value<String?> userId;
  final Value<DateTime?> lastFactsCursor;
  final Value<DateTime?> lastActionsCursor;
  final Value<DateTime?> lastSourcesCursor;
  final Value<DateTime?> lastItemsCursor;
  final Value<DateTime?> lastRemindersCursor;
  final Value<DateTime?> lastSuccessfulSyncAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const CloudSyncStatesCompanion({
    this.id = const Value.absent(),
    this.installationId = const Value.absent(),
    this.userId = const Value.absent(),
    this.lastFactsCursor = const Value.absent(),
    this.lastActionsCursor = const Value.absent(),
    this.lastSourcesCursor = const Value.absent(),
    this.lastItemsCursor = const Value.absent(),
    this.lastRemindersCursor = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CloudSyncStatesCompanion.insert({
    this.id = const Value.absent(),
    required String installationId,
    this.userId = const Value.absent(),
    this.lastFactsCursor = const Value.absent(),
    this.lastActionsCursor = const Value.absent(),
    this.lastSourcesCursor = const Value.absent(),
    this.lastItemsCursor = const Value.absent(),
    this.lastRemindersCursor = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : installationId = Value(installationId);
  static Insertable<CloudSyncStateRow> custom({
    Expression<String>? id,
    Expression<String>? installationId,
    Expression<String>? userId,
    Expression<DateTime>? lastFactsCursor,
    Expression<DateTime>? lastActionsCursor,
    Expression<DateTime>? lastSourcesCursor,
    Expression<DateTime>? lastItemsCursor,
    Expression<DateTime>? lastRemindersCursor,
    Expression<DateTime>? lastSuccessfulSyncAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (installationId != null) 'installation_id': installationId,
      if (userId != null) 'user_id': userId,
      if (lastFactsCursor != null) 'last_facts_cursor': lastFactsCursor,
      if (lastActionsCursor != null) 'last_actions_cursor': lastActionsCursor,
      if (lastSourcesCursor != null) 'last_sources_cursor': lastSourcesCursor,
      if (lastItemsCursor != null) 'last_items_cursor': lastItemsCursor,
      if (lastRemindersCursor != null)
        'last_reminders_cursor': lastRemindersCursor,
      if (lastSuccessfulSyncAt != null)
        'last_successful_sync_at': lastSuccessfulSyncAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CloudSyncStatesCompanion copyWith({
    Value<String>? id,
    Value<String>? installationId,
    Value<String?>? userId,
    Value<DateTime?>? lastFactsCursor,
    Value<DateTime?>? lastActionsCursor,
    Value<DateTime?>? lastSourcesCursor,
    Value<DateTime?>? lastItemsCursor,
    Value<DateTime?>? lastRemindersCursor,
    Value<DateTime?>? lastSuccessfulSyncAt,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return CloudSyncStatesCompanion(
      id: id ?? this.id,
      installationId: installationId ?? this.installationId,
      userId: userId ?? this.userId,
      lastFactsCursor: lastFactsCursor ?? this.lastFactsCursor,
      lastActionsCursor: lastActionsCursor ?? this.lastActionsCursor,
      lastSourcesCursor: lastSourcesCursor ?? this.lastSourcesCursor,
      lastItemsCursor: lastItemsCursor ?? this.lastItemsCursor,
      lastRemindersCursor: lastRemindersCursor ?? this.lastRemindersCursor,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (lastFactsCursor.present) {
      map['last_facts_cursor'] = Variable<DateTime>(lastFactsCursor.value);
    }
    if (lastActionsCursor.present) {
      map['last_actions_cursor'] = Variable<DateTime>(lastActionsCursor.value);
    }
    if (lastSourcesCursor.present) {
      map['last_sources_cursor'] = Variable<DateTime>(lastSourcesCursor.value);
    }
    if (lastItemsCursor.present) {
      map['last_items_cursor'] = Variable<DateTime>(lastItemsCursor.value);
    }
    if (lastRemindersCursor.present) {
      map['last_reminders_cursor'] = Variable<DateTime>(
        lastRemindersCursor.value,
      );
    }
    if (lastSuccessfulSyncAt.present) {
      map['last_successful_sync_at'] = Variable<DateTime>(
        lastSuccessfulSyncAt.value,
      );
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CloudSyncStatesCompanion(')
          ..write('id: $id, ')
          ..write('installationId: $installationId, ')
          ..write('userId: $userId, ')
          ..write('lastFactsCursor: $lastFactsCursor, ')
          ..write('lastActionsCursor: $lastActionsCursor, ')
          ..write('lastSourcesCursor: $lastSourcesCursor, ')
          ..write('lastItemsCursor: $lastItemsCursor, ')
          ..write('lastRemindersCursor: $lastRemindersCursor, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourceFilesTable extends SourceFiles
    with TableInfo<$SourceFilesTable, SourceFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _originalRelativePathMeta =
      const VerificationMeta('originalRelativePath');
  @override
  late final GeneratedColumn<String> originalRelativePath =
      GeneratedColumn<String>(
        'original_relative_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _thumbnailRelativePathMeta =
      const VerificationMeta('thumbnailRelativePath');
  @override
  late final GeneratedColumn<String> thumbnailRelativePath =
      GeneratedColumn<String>(
        'thumbnail_relative_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _availabilityMeta = const VerificationMeta(
    'availability',
  );
  @override
  late final GeneratedColumn<String> availability = GeneratedColumn<String>(
    'availability',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    originalRelativePath,
    thumbnailRelativePath,
    availability,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceFileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('original_relative_path')) {
      context.handle(
        _originalRelativePathMeta,
        originalRelativePath.isAcceptableOrUnknown(
          data['original_relative_path']!,
          _originalRelativePathMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_relative_path')) {
      context.handle(
        _thumbnailRelativePathMeta,
        thumbnailRelativePath.isAcceptableOrUnknown(
          data['thumbnail_relative_path']!,
          _thumbnailRelativePathMeta,
        ),
      );
    }
    if (data.containsKey('availability')) {
      context.handle(
        _availabilityMeta,
        availability.isAcceptableOrUnknown(
          data['availability']!,
          _availabilityMeta,
        ),
      );
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId};
  @override
  SourceFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceFileRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      originalRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_relative_path'],
      ),
      thumbnailRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_relative_path'],
      ),
      availability: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}availability'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      ),
    );
  }

  @override
  $SourceFilesTable createAlias(String alias) {
    return $SourceFilesTable(attachedDatabase, alias);
  }
}

class SourceFileRow extends DataClass implements Insertable<SourceFileRow> {
  final String sourceId;
  final String? originalRelativePath;
  final String? thumbnailRelativePath;
  final String availability;
  final DateTime? lastAccessedAt;
  const SourceFileRow({
    required this.sourceId,
    this.originalRelativePath,
    this.thumbnailRelativePath,
    required this.availability,
    this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || originalRelativePath != null) {
      map['original_relative_path'] = Variable<String>(originalRelativePath);
    }
    if (!nullToAbsent || thumbnailRelativePath != null) {
      map['thumbnail_relative_path'] = Variable<String>(thumbnailRelativePath);
    }
    map['availability'] = Variable<String>(availability);
    if (!nullToAbsent || lastAccessedAt != null) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    }
    return map;
  }

  SourceFilesCompanion toCompanion(bool nullToAbsent) {
    return SourceFilesCompanion(
      sourceId: Value(sourceId),
      originalRelativePath: originalRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(originalRelativePath),
      thumbnailRelativePath: thumbnailRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailRelativePath),
      availability: Value(availability),
      lastAccessedAt: lastAccessedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccessedAt),
    );
  }

  factory SourceFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceFileRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      originalRelativePath: serializer.fromJson<String?>(
        json['originalRelativePath'],
      ),
      thumbnailRelativePath: serializer.fromJson<String?>(
        json['thumbnailRelativePath'],
      ),
      availability: serializer.fromJson<String>(json['availability']),
      lastAccessedAt: serializer.fromJson<DateTime?>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'originalRelativePath': serializer.toJson<String?>(originalRelativePath),
      'thumbnailRelativePath': serializer.toJson<String?>(
        thumbnailRelativePath,
      ),
      'availability': serializer.toJson<String>(availability),
      'lastAccessedAt': serializer.toJson<DateTime?>(lastAccessedAt),
    };
  }

  SourceFileRow copyWith({
    String? sourceId,
    Value<String?> originalRelativePath = const Value.absent(),
    Value<String?> thumbnailRelativePath = const Value.absent(),
    String? availability,
    Value<DateTime?> lastAccessedAt = const Value.absent(),
  }) => SourceFileRow(
    sourceId: sourceId ?? this.sourceId,
    originalRelativePath: originalRelativePath.present
        ? originalRelativePath.value
        : this.originalRelativePath,
    thumbnailRelativePath: thumbnailRelativePath.present
        ? thumbnailRelativePath.value
        : this.thumbnailRelativePath,
    availability: availability ?? this.availability,
    lastAccessedAt: lastAccessedAt.present
        ? lastAccessedAt.value
        : this.lastAccessedAt,
  );
  SourceFileRow copyWithCompanion(SourceFilesCompanion data) {
    return SourceFileRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      originalRelativePath: data.originalRelativePath.present
          ? data.originalRelativePath.value
          : this.originalRelativePath,
      thumbnailRelativePath: data.thumbnailRelativePath.present
          ? data.thumbnailRelativePath.value
          : this.thumbnailRelativePath,
      availability: data.availability.present
          ? data.availability.value
          : this.availability,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceFileRow(')
          ..write('sourceId: $sourceId, ')
          ..write('originalRelativePath: $originalRelativePath, ')
          ..write('thumbnailRelativePath: $thumbnailRelativePath, ')
          ..write('availability: $availability, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    originalRelativePath,
    thumbnailRelativePath,
    availability,
    lastAccessedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceFileRow &&
          other.sourceId == this.sourceId &&
          other.originalRelativePath == this.originalRelativePath &&
          other.thumbnailRelativePath == this.thumbnailRelativePath &&
          other.availability == this.availability &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class SourceFilesCompanion extends UpdateCompanion<SourceFileRow> {
  final Value<String> sourceId;
  final Value<String?> originalRelativePath;
  final Value<String?> thumbnailRelativePath;
  final Value<String> availability;
  final Value<DateTime?> lastAccessedAt;
  final Value<int> rowid;
  const SourceFilesCompanion({
    this.sourceId = const Value.absent(),
    this.originalRelativePath = const Value.absent(),
    this.thumbnailRelativePath = const Value.absent(),
    this.availability = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourceFilesCompanion.insert({
    required String sourceId,
    this.originalRelativePath = const Value.absent(),
    this.thumbnailRelativePath = const Value.absent(),
    this.availability = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId);
  static Insertable<SourceFileRow> custom({
    Expression<String>? sourceId,
    Expression<String>? originalRelativePath,
    Expression<String>? thumbnailRelativePath,
    Expression<String>? availability,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (originalRelativePath != null)
        'original_relative_path': originalRelativePath,
      if (thumbnailRelativePath != null)
        'thumbnail_relative_path': thumbnailRelativePath,
      if (availability != null) 'availability': availability,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourceFilesCompanion copyWith({
    Value<String>? sourceId,
    Value<String?>? originalRelativePath,
    Value<String?>? thumbnailRelativePath,
    Value<String>? availability,
    Value<DateTime?>? lastAccessedAt,
    Value<int>? rowid,
  }) {
    return SourceFilesCompanion(
      sourceId: sourceId ?? this.sourceId,
      originalRelativePath: originalRelativePath ?? this.originalRelativePath,
      thumbnailRelativePath:
          thumbnailRelativePath ?? this.thumbnailRelativePath,
      availability: availability ?? this.availability,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (originalRelativePath.present) {
      map['original_relative_path'] = Variable<String>(
        originalRelativePath.value,
      );
    }
    if (thumbnailRelativePath.present) {
      map['thumbnail_relative_path'] = Variable<String>(
        thumbnailRelativePath.value,
      );
    }
    if (availability.present) {
      map['availability'] = Variable<String>(availability.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceFilesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('originalRelativePath: $originalRelativePath, ')
          ..write('thumbnailRelativePath: $thumbnailRelativePath, ')
          ..write('availability: $availability, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FactsTable extends Facts with TableInfo<$FactsTable, FactRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sources (id)',
    ),
  );
  static const VerificationMeta _sourceRevisionMeta = const VerificationMeta(
    'sourceRevision',
  );
  @override
  late final GeneratedColumn<int> sourceRevision = GeneratedColumn<int>(
    'source_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueTypeMeta = const VerificationMeta(
    'valueType',
  );
  @override
  late final GeneratedColumn<String> valueType = GeneratedColumn<String>(
    'value_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userValueMeta = const VerificationMeta(
    'userValue',
  );
  @override
  late final GeneratedColumn<String> userValue = GeneratedColumn<String>(
    'user_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _provenanceMeta = const VerificationMeta(
    'provenance',
  );
  @override
  late final GeneratedColumn<String> provenance = GeneratedColumn<String>(
    'provenance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceMeta = const VerificationMeta(
    'evidence',
  );
  @override
  late final GeneratedColumn<String> evidence = GeneratedColumn<String>(
    'evidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteServerUpdatedAtMeta =
      const VerificationMeta('remoteServerUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> remoteServerUpdatedAt =
      GeneratedColumn<DateTime>(
        'remote_server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($FactsTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    ownerId,
    sourceId,
    sourceRevision,
    key,
    valueType,
    value,
    userValue,
    provenance,
    evidence,
    createdAt,
    updatedAt,
    remoteServerUpdatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'facts';
  @override
  VerificationContext validateIntegrity(
    Insertable<FactRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('source_revision')) {
      context.handle(
        _sourceRevisionMeta,
        sourceRevision.isAcceptableOrUnknown(
          data['source_revision']!,
          _sourceRevisionMeta,
        ),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_type')) {
      context.handle(
        _valueTypeMeta,
        valueType.isAcceptableOrUnknown(data['value_type']!, _valueTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_valueTypeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('user_value')) {
      context.handle(
        _userValueMeta,
        userValue.isAcceptableOrUnknown(data['user_value']!, _userValueMeta),
      );
    }
    if (data.containsKey('provenance')) {
      context.handle(
        _provenanceMeta,
        provenance.isAcceptableOrUnknown(data['provenance']!, _provenanceMeta),
      );
    } else if (isInserting) {
      context.missing(_provenanceMeta);
    }
    if (data.containsKey('evidence')) {
      context.handle(
        _evidenceMeta,
        evidence.isAcceptableOrUnknown(data['evidence']!, _evidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_evidenceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('remote_server_updated_at')) {
      context.handle(
        _remoteServerUpdatedAtMeta,
        remoteServerUpdatedAt.isAcceptableOrUnknown(
          data['remote_server_updated_at']!,
          _remoteServerUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FactRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FactRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      sourceRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_revision'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      userValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_value'],
      ),
      provenance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provenance'],
      )!,
      evidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      remoteServerUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remote_server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $FactsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
    );
  }

  @override
  $FactsTable createAlias(String alias) {
    return $FactsTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class FactRow extends DataClass implements Insertable<FactRow> {
  final String id;
  final String itemId;
  final String? ownerId;
  final String? sourceId;
  final int? sourceRevision;
  final String key;
  final String valueType;
  final String value;
  final String? userValue;
  final String provenance;
  final String evidence;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? remoteServerUpdatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  const FactRow({
    required this.id,
    required this.itemId,
    this.ownerId,
    this.sourceId,
    this.sourceRevision,
    required this.key,
    required this.valueType,
    required this.value,
    this.userValue,
    required this.provenance,
    required this.evidence,
    required this.createdAt,
    required this.updatedAt,
    this.remoteServerUpdatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    if (!nullToAbsent || sourceRevision != null) {
      map['source_revision'] = Variable<int>(sourceRevision);
    }
    map['key'] = Variable<String>(key);
    map['value_type'] = Variable<String>(valueType);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || userValue != null) {
      map['user_value'] = Variable<String>(userValue);
    }
    map['provenance'] = Variable<String>(provenance);
    map['evidence'] = Variable<String>(evidence);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remoteServerUpdatedAt != null) {
      map['remote_server_updated_at'] = Variable<DateTime>(
        remoteServerUpdatedAt,
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $FactsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    return map;
  }

  FactsCompanion toCompanion(bool nullToAbsent) {
    return FactsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      sourceRevision: sourceRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRevision),
      key: Value(key),
      valueType: Value(valueType),
      value: Value(value),
      userValue: userValue == null && nullToAbsent
          ? const Value.absent()
          : Value(userValue),
      provenance: Value(provenance),
      evidence: Value(evidence),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteServerUpdatedAt: remoteServerUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteServerUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory FactRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FactRow(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      sourceRevision: serializer.fromJson<int?>(json['sourceRevision']),
      key: serializer.fromJson<String>(json['key']),
      valueType: serializer.fromJson<String>(json['valueType']),
      value: serializer.fromJson<String>(json['value']),
      userValue: serializer.fromJson<String?>(json['userValue']),
      provenance: serializer.fromJson<String>(json['provenance']),
      evidence: serializer.fromJson<String>(json['evidence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remoteServerUpdatedAt: serializer.fromJson<DateTime?>(
        json['remoteServerUpdatedAt'],
      ),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'ownerId': serializer.toJson<String?>(ownerId),
      'sourceId': serializer.toJson<String?>(sourceId),
      'sourceRevision': serializer.toJson<int?>(sourceRevision),
      'key': serializer.toJson<String>(key),
      'valueType': serializer.toJson<String>(valueType),
      'value': serializer.toJson<String>(value),
      'userValue': serializer.toJson<String?>(userValue),
      'provenance': serializer.toJson<String>(provenance),
      'evidence': serializer.toJson<String>(evidence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remoteServerUpdatedAt': serializer.toJson<DateTime?>(
        remoteServerUpdatedAt,
      ),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
    };
  }

  FactRow copyWith({
    String? id,
    String? itemId,
    Value<String?> ownerId = const Value.absent(),
    Value<String?> sourceId = const Value.absent(),
    Value<int?> sourceRevision = const Value.absent(),
    String? key,
    String? valueType,
    String? value,
    Value<String?> userValue = const Value.absent(),
    String? provenance,
    String? evidence,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
  }) => FactRow(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    sourceRevision: sourceRevision.present
        ? sourceRevision.value
        : this.sourceRevision,
    key: key ?? this.key,
    valueType: valueType ?? this.valueType,
    value: value ?? this.value,
    userValue: userValue.present ? userValue.value : this.userValue,
    provenance: provenance ?? this.provenance,
    evidence: evidence ?? this.evidence,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteServerUpdatedAt: remoteServerUpdatedAt.present
        ? remoteServerUpdatedAt.value
        : this.remoteServerUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  FactRow copyWithCompanion(FactsCompanion data) {
    return FactRow(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourceRevision: data.sourceRevision.present
          ? data.sourceRevision.value
          : this.sourceRevision,
      key: data.key.present ? data.key.value : this.key,
      valueType: data.valueType.present ? data.valueType.value : this.valueType,
      value: data.value.present ? data.value.value : this.value,
      userValue: data.userValue.present ? data.userValue.value : this.userValue,
      provenance: data.provenance.present
          ? data.provenance.value
          : this.provenance,
      evidence: data.evidence.present ? data.evidence.value : this.evidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteServerUpdatedAt: data.remoteServerUpdatedAt.present
          ? data.remoteServerUpdatedAt.value
          : this.remoteServerUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FactRow(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ownerId: $ownerId, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceRevision: $sourceRevision, ')
          ..write('key: $key, ')
          ..write('valueType: $valueType, ')
          ..write('value: $value, ')
          ..write('userValue: $userValue, ')
          ..write('provenance: $provenance, ')
          ..write('evidence: $evidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    ownerId,
    sourceId,
    sourceRevision,
    key,
    valueType,
    value,
    userValue,
    provenance,
    evidence,
    createdAt,
    updatedAt,
    remoteServerUpdatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FactRow &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.ownerId == this.ownerId &&
          other.sourceId == this.sourceId &&
          other.sourceRevision == this.sourceRevision &&
          other.key == this.key &&
          other.valueType == this.valueType &&
          other.value == this.value &&
          other.userValue == this.userValue &&
          other.provenance == this.provenance &&
          other.evidence == this.evidence &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteServerUpdatedAt == this.remoteServerUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class FactsCompanion extends UpdateCompanion<FactRow> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> ownerId;
  final Value<String?> sourceId;
  final Value<int?> sourceRevision;
  final Value<String> key;
  final Value<String> valueType;
  final Value<String> value;
  final Value<String?> userValue;
  final Value<String> provenance;
  final Value<String> evidence;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> remoteServerUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<int> rowid;
  const FactsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceRevision = const Value.absent(),
    this.key = const Value.absent(),
    this.valueType = const Value.absent(),
    this.value = const Value.absent(),
    this.userValue = const Value.absent(),
    this.provenance = const Value.absent(),
    this.evidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteServerUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FactsCompanion.insert({
    required String id,
    required String itemId,
    this.ownerId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceRevision = const Value.absent(),
    required String key,
    required String valueType,
    required String value,
    this.userValue = const Value.absent(),
    required String provenance,
    required String evidence,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.remoteServerUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required SyncStatus syncStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       key = Value(key),
       valueType = Value(valueType),
       value = Value(value),
       provenance = Value(provenance),
       evidence = Value(evidence),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus);
  static Insertable<FactRow> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? ownerId,
    Expression<String>? sourceId,
    Expression<int>? sourceRevision,
    Expression<String>? key,
    Expression<String>? valueType,
    Expression<String>? value,
    Expression<String>? userValue,
    Expression<String>? provenance,
    Expression<String>? evidence,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? remoteServerUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (ownerId != null) 'owner_id': ownerId,
      if (sourceId != null) 'source_id': sourceId,
      if (sourceRevision != null) 'source_revision': sourceRevision,
      if (key != null) 'key': key,
      if (valueType != null) 'value_type': valueType,
      if (value != null) 'value': value,
      if (userValue != null) 'user_value': userValue,
      if (provenance != null) 'provenance': provenance,
      if (evidence != null) 'evidence': evidence,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteServerUpdatedAt != null)
        'remote_server_updated_at': remoteServerUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FactsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String?>? ownerId,
    Value<String?>? sourceId,
    Value<int?>? sourceRevision,
    Value<String>? key,
    Value<String>? valueType,
    Value<String>? value,
    Value<String?>? userValue,
    Value<String>? provenance,
    Value<String>? evidence,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? remoteServerUpdatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<int>? rowid,
  }) {
    return FactsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      ownerId: ownerId ?? this.ownerId,
      sourceId: sourceId ?? this.sourceId,
      sourceRevision: sourceRevision ?? this.sourceRevision,
      key: key ?? this.key,
      valueType: valueType ?? this.valueType,
      value: value ?? this.value,
      userValue: userValue ?? this.userValue,
      provenance: provenance ?? this.provenance,
      evidence: evidence ?? this.evidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteServerUpdatedAt:
          remoteServerUpdatedAt ?? this.remoteServerUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sourceRevision.present) {
      map['source_revision'] = Variable<int>(sourceRevision.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueType.present) {
      map['value_type'] = Variable<String>(valueType.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (userValue.present) {
      map['user_value'] = Variable<String>(userValue.value);
    }
    if (provenance.present) {
      map['provenance'] = Variable<String>(provenance.value);
    }
    if (evidence.present) {
      map['evidence'] = Variable<String>(evidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remoteServerUpdatedAt.present) {
      map['remote_server_updated_at'] = Variable<DateTime>(
        remoteServerUpdatedAt.value,
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $FactsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ownerId: $ownerId, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceRevision: $sourceRevision, ')
          ..write('key: $key, ')
          ..write('valueType: $valueType, ')
          ..write('value: $value, ')
          ..write('userValue: $userValue, ')
          ..write('provenance: $provenance, ')
          ..write('evidence: $evidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnalysisJobsTable extends AnalysisJobs
    with TableInfo<$AnalysisJobsTable, AnalysisJobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalysisJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeZoneMeta = const VerificationMeta(
    'timeZone',
  );
  @override
  late final GeneratedColumn<String> timeZone = GeneratedColumn<String>(
    'time_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _envelopeMeta = const VerificationMeta(
    'envelope',
  );
  @override
  late final GeneratedColumn<String> envelope = GeneratedColumn<String>(
    'envelope',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _requestedAtMeta = const VerificationMeta(
    'requestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> requestedAt = GeneratedColumn<DateTime>(
    'requested_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    requestId,
    ownerId,
    revision,
    locale,
    timeZone,
    state,
    payload,
    envelope,
    errorCode,
    attempts,
    nextAttemptAt,
    requestedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analysis_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnalysisJobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('time_zone')) {
      context.handle(
        _timeZoneMeta,
        timeZone.isAcceptableOrUnknown(data['time_zone']!, _timeZoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timeZoneMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('envelope')) {
      context.handle(
        _envelopeMeta,
        envelope.isAcceptableOrUnknown(data['envelope']!, _envelopeMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('requested_at')) {
      context.handle(
        _requestedAtMeta,
        requestedAt.isAcceptableOrUnknown(
          data['requested_at']!,
          _requestedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId};
  @override
  AnalysisJobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalysisJobRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      timeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      envelope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}envelope'],
      ),
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      requestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}requested_at'],
      )!,
    );
  }

  @override
  $AnalysisJobsTable createAlias(String alias) {
    return $AnalysisJobsTable(attachedDatabase, alias);
  }
}

class AnalysisJobRow extends DataClass implements Insertable<AnalysisJobRow> {
  final String sourceId;
  final String requestId;
  final String ownerId;
  final int revision;
  final String locale;
  final String timeZone;
  final String state;
  final String? payload;
  final String? envelope;
  final String? errorCode;
  final int attempts;
  final DateTime? nextAttemptAt;
  final DateTime requestedAt;
  const AnalysisJobRow({
    required this.sourceId,
    required this.requestId,
    required this.ownerId,
    required this.revision,
    required this.locale,
    required this.timeZone,
    required this.state,
    this.payload,
    this.envelope,
    this.errorCode,
    required this.attempts,
    this.nextAttemptAt,
    required this.requestedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['request_id'] = Variable<String>(requestId);
    map['owner_id'] = Variable<String>(ownerId);
    map['revision'] = Variable<int>(revision);
    map['locale'] = Variable<String>(locale);
    map['time_zone'] = Variable<String>(timeZone);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    if (!nullToAbsent || envelope != null) {
      map['envelope'] = Variable<String>(envelope);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    map['requested_at'] = Variable<DateTime>(requestedAt);
    return map;
  }

  AnalysisJobsCompanion toCompanion(bool nullToAbsent) {
    return AnalysisJobsCompanion(
      sourceId: Value(sourceId),
      requestId: Value(requestId),
      ownerId: Value(ownerId),
      revision: Value(revision),
      locale: Value(locale),
      timeZone: Value(timeZone),
      state: Value(state),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      envelope: envelope == null && nullToAbsent
          ? const Value.absent()
          : Value(envelope),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      requestedAt: Value(requestedAt),
    );
  }

  factory AnalysisJobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalysisJobRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      requestId: serializer.fromJson<String>(json['requestId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      revision: serializer.fromJson<int>(json['revision']),
      locale: serializer.fromJson<String>(json['locale']),
      timeZone: serializer.fromJson<String>(json['timeZone']),
      state: serializer.fromJson<String>(json['state']),
      payload: serializer.fromJson<String?>(json['payload']),
      envelope: serializer.fromJson<String?>(json['envelope']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      requestedAt: serializer.fromJson<DateTime>(json['requestedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'requestId': serializer.toJson<String>(requestId),
      'ownerId': serializer.toJson<String>(ownerId),
      'revision': serializer.toJson<int>(revision),
      'locale': serializer.toJson<String>(locale),
      'timeZone': serializer.toJson<String>(timeZone),
      'state': serializer.toJson<String>(state),
      'payload': serializer.toJson<String?>(payload),
      'envelope': serializer.toJson<String?>(envelope),
      'errorCode': serializer.toJson<String?>(errorCode),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'requestedAt': serializer.toJson<DateTime>(requestedAt),
    };
  }

  AnalysisJobRow copyWith({
    String? sourceId,
    String? requestId,
    String? ownerId,
    int? revision,
    String? locale,
    String? timeZone,
    String? state,
    Value<String?> payload = const Value.absent(),
    Value<String?> envelope = const Value.absent(),
    Value<String?> errorCode = const Value.absent(),
    int? attempts,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    DateTime? requestedAt,
  }) => AnalysisJobRow(
    sourceId: sourceId ?? this.sourceId,
    requestId: requestId ?? this.requestId,
    ownerId: ownerId ?? this.ownerId,
    revision: revision ?? this.revision,
    locale: locale ?? this.locale,
    timeZone: timeZone ?? this.timeZone,
    state: state ?? this.state,
    payload: payload.present ? payload.value : this.payload,
    envelope: envelope.present ? envelope.value : this.envelope,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    requestedAt: requestedAt ?? this.requestedAt,
  );
  AnalysisJobRow copyWithCompanion(AnalysisJobsCompanion data) {
    return AnalysisJobRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      revision: data.revision.present ? data.revision.value : this.revision,
      locale: data.locale.present ? data.locale.value : this.locale,
      timeZone: data.timeZone.present ? data.timeZone.value : this.timeZone,
      state: data.state.present ? data.state.value : this.state,
      payload: data.payload.present ? data.payload.value : this.payload,
      envelope: data.envelope.present ? data.envelope.value : this.envelope,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      requestedAt: data.requestedAt.present
          ? data.requestedAt.value
          : this.requestedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalysisJobRow(')
          ..write('sourceId: $sourceId, ')
          ..write('requestId: $requestId, ')
          ..write('ownerId: $ownerId, ')
          ..write('revision: $revision, ')
          ..write('locale: $locale, ')
          ..write('timeZone: $timeZone, ')
          ..write('state: $state, ')
          ..write('payload: $payload, ')
          ..write('envelope: $envelope, ')
          ..write('errorCode: $errorCode, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('requestedAt: $requestedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    requestId,
    ownerId,
    revision,
    locale,
    timeZone,
    state,
    payload,
    envelope,
    errorCode,
    attempts,
    nextAttemptAt,
    requestedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalysisJobRow &&
          other.sourceId == this.sourceId &&
          other.requestId == this.requestId &&
          other.ownerId == this.ownerId &&
          other.revision == this.revision &&
          other.locale == this.locale &&
          other.timeZone == this.timeZone &&
          other.state == this.state &&
          other.payload == this.payload &&
          other.envelope == this.envelope &&
          other.errorCode == this.errorCode &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.requestedAt == this.requestedAt);
}

class AnalysisJobsCompanion extends UpdateCompanion<AnalysisJobRow> {
  final Value<String> sourceId;
  final Value<String> requestId;
  final Value<String> ownerId;
  final Value<int> revision;
  final Value<String> locale;
  final Value<String> timeZone;
  final Value<String> state;
  final Value<String?> payload;
  final Value<String?> envelope;
  final Value<String?> errorCode;
  final Value<int> attempts;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime> requestedAt;
  final Value<int> rowid;
  const AnalysisJobsCompanion({
    this.sourceId = const Value.absent(),
    this.requestId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.revision = const Value.absent(),
    this.locale = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.state = const Value.absent(),
    this.payload = const Value.absent(),
    this.envelope = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.requestedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnalysisJobsCompanion.insert({
    required String sourceId,
    required String requestId,
    required String ownerId,
    required int revision,
    required String locale,
    required String timeZone,
    this.state = const Value.absent(),
    this.payload = const Value.absent(),
    this.envelope = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    required DateTime requestedAt,
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       requestId = Value(requestId),
       ownerId = Value(ownerId),
       revision = Value(revision),
       locale = Value(locale),
       timeZone = Value(timeZone),
       requestedAt = Value(requestedAt);
  static Insertable<AnalysisJobRow> custom({
    Expression<String>? sourceId,
    Expression<String>? requestId,
    Expression<String>? ownerId,
    Expression<int>? revision,
    Expression<String>? locale,
    Expression<String>? timeZone,
    Expression<String>? state,
    Expression<String>? payload,
    Expression<String>? envelope,
    Expression<String>? errorCode,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? requestedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (requestId != null) 'request_id': requestId,
      if (ownerId != null) 'owner_id': ownerId,
      if (revision != null) 'revision': revision,
      if (locale != null) 'locale': locale,
      if (timeZone != null) 'time_zone': timeZone,
      if (state != null) 'state': state,
      if (payload != null) 'payload': payload,
      if (envelope != null) 'envelope': envelope,
      if (errorCode != null) 'error_code': errorCode,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (requestedAt != null) 'requested_at': requestedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnalysisJobsCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? requestId,
    Value<String>? ownerId,
    Value<int>? revision,
    Value<String>? locale,
    Value<String>? timeZone,
    Value<String>? state,
    Value<String?>? payload,
    Value<String?>? envelope,
    Value<String?>? errorCode,
    Value<int>? attempts,
    Value<DateTime?>? nextAttemptAt,
    Value<DateTime>? requestedAt,
    Value<int>? rowid,
  }) {
    return AnalysisJobsCompanion(
      sourceId: sourceId ?? this.sourceId,
      requestId: requestId ?? this.requestId,
      ownerId: ownerId ?? this.ownerId,
      revision: revision ?? this.revision,
      locale: locale ?? this.locale,
      timeZone: timeZone ?? this.timeZone,
      state: state ?? this.state,
      payload: payload ?? this.payload,
      envelope: envelope ?? this.envelope,
      errorCode: errorCode ?? this.errorCode,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      requestedAt: requestedAt ?? this.requestedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (timeZone.present) {
      map['time_zone'] = Variable<String>(timeZone.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (envelope.present) {
      map['envelope'] = Variable<String>(envelope.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (requestedAt.present) {
      map['requested_at'] = Variable<DateTime>(requestedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalysisJobsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('requestId: $requestId, ')
          ..write('ownerId: $ownerId, ')
          ..write('revision: $revision, ')
          ..write('locale: $locale, ')
          ..write('timeZone: $timeZone, ')
          ..write('state: $state, ')
          ..write('payload: $payload, ')
          ..write('envelope: $envelope, ')
          ..write('errorCode: $errorCode, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FileJobsTable extends FileJobs
    with TableInfo<$FileJobsTable, FileJobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _transferredBytesMeta = const VerificationMeta(
    'transferredBytes',
  );
  @override
  late final GeneratedColumn<int> transferredBytes = GeneratedColumn<int>(
    'transferred_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    ownerId,
    revision,
    operation,
    state,
    attempts,
    transferredBytes,
    errorCode,
    nextAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileJobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('transferred_bytes')) {
      context.handle(
        _transferredBytesMeta,
        transferredBytes.isAcceptableOrUnknown(
          data['transferred_bytes']!,
          _transferredBytesMeta,
        ),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, ownerId, revision};
  @override
  FileJobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileJobRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      transferredBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transferred_bytes'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
    );
  }

  @override
  $FileJobsTable createAlias(String alias) {
    return $FileJobsTable(attachedDatabase, alias);
  }
}

class FileJobRow extends DataClass implements Insertable<FileJobRow> {
  final String sourceId;
  final String ownerId;
  final int revision;
  final String operation;
  final String state;
  final int attempts;
  final int transferredBytes;
  final String? errorCode;
  final DateTime? nextAttemptAt;
  const FileJobRow({
    required this.sourceId,
    required this.ownerId,
    required this.revision,
    required this.operation,
    required this.state,
    required this.attempts,
    required this.transferredBytes,
    this.errorCode,
    this.nextAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['owner_id'] = Variable<String>(ownerId);
    map['revision'] = Variable<int>(revision);
    map['operation'] = Variable<String>(operation);
    map['state'] = Variable<String>(state);
    map['attempts'] = Variable<int>(attempts);
    map['transferred_bytes'] = Variable<int>(transferredBytes);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    return map;
  }

  FileJobsCompanion toCompanion(bool nullToAbsent) {
    return FileJobsCompanion(
      sourceId: Value(sourceId),
      ownerId: Value(ownerId),
      revision: Value(revision),
      operation: Value(operation),
      state: Value(state),
      attempts: Value(attempts),
      transferredBytes: Value(transferredBytes),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
    );
  }

  factory FileJobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileJobRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      revision: serializer.fromJson<int>(json['revision']),
      operation: serializer.fromJson<String>(json['operation']),
      state: serializer.fromJson<String>(json['state']),
      attempts: serializer.fromJson<int>(json['attempts']),
      transferredBytes: serializer.fromJson<int>(json['transferredBytes']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'ownerId': serializer.toJson<String>(ownerId),
      'revision': serializer.toJson<int>(revision),
      'operation': serializer.toJson<String>(operation),
      'state': serializer.toJson<String>(state),
      'attempts': serializer.toJson<int>(attempts),
      'transferredBytes': serializer.toJson<int>(transferredBytes),
      'errorCode': serializer.toJson<String?>(errorCode),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
    };
  }

  FileJobRow copyWith({
    String? sourceId,
    String? ownerId,
    int? revision,
    String? operation,
    String? state,
    int? attempts,
    int? transferredBytes,
    Value<String?> errorCode = const Value.absent(),
    Value<DateTime?> nextAttemptAt = const Value.absent(),
  }) => FileJobRow(
    sourceId: sourceId ?? this.sourceId,
    ownerId: ownerId ?? this.ownerId,
    revision: revision ?? this.revision,
    operation: operation ?? this.operation,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    transferredBytes: transferredBytes ?? this.transferredBytes,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
  );
  FileJobRow copyWithCompanion(FileJobsCompanion data) {
    return FileJobRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      revision: data.revision.present ? data.revision.value : this.revision,
      operation: data.operation.present ? data.operation.value : this.operation,
      state: data.state.present ? data.state.value : this.state,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      transferredBytes: data.transferredBytes.present
          ? data.transferredBytes.value
          : this.transferredBytes,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileJobRow(')
          ..write('sourceId: $sourceId, ')
          ..write('ownerId: $ownerId, ')
          ..write('revision: $revision, ')
          ..write('operation: $operation, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('transferredBytes: $transferredBytes, ')
          ..write('errorCode: $errorCode, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    ownerId,
    revision,
    operation,
    state,
    attempts,
    transferredBytes,
    errorCode,
    nextAttemptAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileJobRow &&
          other.sourceId == this.sourceId &&
          other.ownerId == this.ownerId &&
          other.revision == this.revision &&
          other.operation == this.operation &&
          other.state == this.state &&
          other.attempts == this.attempts &&
          other.transferredBytes == this.transferredBytes &&
          other.errorCode == this.errorCode &&
          other.nextAttemptAt == this.nextAttemptAt);
}

class FileJobsCompanion extends UpdateCompanion<FileJobRow> {
  final Value<String> sourceId;
  final Value<String> ownerId;
  final Value<int> revision;
  final Value<String> operation;
  final Value<String> state;
  final Value<int> attempts;
  final Value<int> transferredBytes;
  final Value<String?> errorCode;
  final Value<DateTime?> nextAttemptAt;
  final Value<int> rowid;
  const FileJobsCompanion({
    this.sourceId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.revision = const Value.absent(),
    this.operation = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.transferredBytes = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileJobsCompanion.insert({
    required String sourceId,
    required String ownerId,
    required int revision,
    required String operation,
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.transferredBytes = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       ownerId = Value(ownerId),
       revision = Value(revision),
       operation = Value(operation);
  static Insertable<FileJobRow> custom({
    Expression<String>? sourceId,
    Expression<String>? ownerId,
    Expression<int>? revision,
    Expression<String>? operation,
    Expression<String>? state,
    Expression<int>? attempts,
    Expression<int>? transferredBytes,
    Expression<String>? errorCode,
    Expression<DateTime>? nextAttemptAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (ownerId != null) 'owner_id': ownerId,
      if (revision != null) 'revision': revision,
      if (operation != null) 'operation': operation,
      if (state != null) 'state': state,
      if (attempts != null) 'attempts': attempts,
      if (transferredBytes != null) 'transferred_bytes': transferredBytes,
      if (errorCode != null) 'error_code': errorCode,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileJobsCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? ownerId,
    Value<int>? revision,
    Value<String>? operation,
    Value<String>? state,
    Value<int>? attempts,
    Value<int>? transferredBytes,
    Value<String?>? errorCode,
    Value<DateTime?>? nextAttemptAt,
    Value<int>? rowid,
  }) {
    return FileJobsCompanion(
      sourceId: sourceId ?? this.sourceId,
      ownerId: ownerId ?? this.ownerId,
      revision: revision ?? this.revision,
      operation: operation ?? this.operation,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      errorCode: errorCode ?? this.errorCode,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (transferredBytes.present) {
      map['transferred_bytes'] = Variable<int>(transferredBytes.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileJobsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('ownerId: $ownerId, ')
          ..write('revision: $revision, ')
          ..write('operation: $operation, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('transferredBytes: $transferredBytes, ')
          ..write('errorCode: $errorCode, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $SourcesTable sources = $SourcesTable(this);
  late final $ItemActionsTable itemActions = $ItemActionsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $CloudSyncStatesTable cloudSyncStates = $CloudSyncStatesTable(
    this,
  );
  late final $SourceFilesTable sourceFiles = $SourceFilesTable(this);
  late final $FactsTable facts = $FactsTable(this);
  late final $AnalysisJobsTable analysisJobs = $AnalysisJobsTable(this);
  late final $FileJobsTable fileJobs = $FileJobsTable(this);
  late final Index itemsStatusIdx = Index(
    'items_status_idx',
    'CREATE INDEX items_status_idx ON items (status)',
  );
  late final Index itemsUpdatedAtIdx = Index(
    'items_updated_at_idx',
    'CREATE INDEX items_updated_at_idx ON items (updated_at)',
  );
  late final Index itemsDeletedAtIdx = Index(
    'items_deleted_at_idx',
    'CREATE INDEX items_deleted_at_idx ON items (deleted_at)',
  );
  late final Index remindersItemIdx = Index(
    'reminders_item_idx',
    'CREATE INDEX reminders_item_idx ON reminders (item_id)',
  );
  late final Index remindersRemindAtIdx = Index(
    'reminders_remind_at_idx',
    'CREATE INDEX reminders_remind_at_idx ON reminders (remind_at)',
  );
  late final Index remindersDeletedAtIdx = Index(
    'reminders_deleted_at_idx',
    'CREATE INDEX reminders_deleted_at_idx ON reminders (deleted_at)',
  );
  late final Index syncQueueCreatedAtIdx = Index(
    'sync_queue_created_at_idx',
    'CREATE INDEX sync_queue_created_at_idx ON sync_queue (created_at)',
  );
  late final Index syncQueueEntityIdx = Index(
    'sync_queue_entity_idx',
    'CREATE INDEX sync_queue_entity_idx ON sync_queue (entity_type, entity_id)',
  );
  late final Index sourcesItemIdx = Index(
    'sources_item_idx',
    'CREATE INDEX sources_item_idx ON sources (item_id)',
  );
  late final Index factsItemIdx = Index(
    'facts_item_idx',
    'CREATE INDEX facts_item_idx ON facts (item_id)',
  );
  late final Index itemActionsItemIdx = Index(
    'item_actions_item_idx',
    'CREATE INDEX item_actions_item_idx ON item_actions (item_id)',
  );
  late final ItemsDao itemsDao = ItemsDao(this as AppDatabase);
  late final RemindersDao remindersDao = RemindersDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    items,
    sources,
    itemActions,
    reminders,
    syncQueue,
    cloudSyncStates,
    sourceFiles,
    facts,
    analysisJobs,
    fileJobs,
    itemsStatusIdx,
    itemsUpdatedAtIdx,
    itemsDeletedAtIdx,
    remindersItemIdx,
    remindersRemindAtIdx,
    remindersDeletedAtIdx,
    syncQueueCreatedAtIdx,
    syncQueueEntityIdx,
    sourcesItemIdx,
    factsItemIdx,
    itemActionsItemIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sources', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('source_files', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('analysis_jobs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  Value<String?> ownerId,
  required String title,
  Value<String> summary,
  required ItemStatus status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> resolvedAt,
  Value<DateTime?> deletedAt,
  required SyncStatus syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<String?> sourceDeviceId,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<String?> ownerId,
  Value<String> title,
  Value<String> summary,
  Value<ItemStatus> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> resolvedAt,
  Value<DateTime?> deletedAt,
  Value<SyncStatus> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<String?> sourceDeviceId,
  Value<int> rowid,
});

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, ItemRow> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SourcesTable, List<SourceRow>> _sourcesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sources,
    aliasName: 'items__id__sources__item_id',
  );

  $$SourcesTableProcessedTableManager get sourcesRefs {
    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sourcesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ItemActionsTable, List<ItemActionRow>>
  _itemActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemActions,
    aliasName: 'items__id__item_actions__item_id',
  );

  $$ItemActionsTableProcessedTableManager get itemActionsRefs {
    final manager = $$ItemActionsTableTableManager(
      $_db,
      $_db.itemActions,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemActionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'items__id__reminders__item_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FactsTable, List<FactRow>> _factsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.facts,
    aliasName: 'items__id__facts__item_id',
  );

  $$FactsTableProcessedTableManager get factsRefs {
    final manager = $$FactsTableTableManager(
      $_db,
      $_db.facts,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_factsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ItemStatus, ItemStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sourcesRefs(
    Expression<bool> Function($$SourcesTableFilterComposer f) f,
  ) {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> itemActionsRefs(
    Expression<bool> Function($$ItemActionsTableFilterComposer f) f,
  ) {
    final $$ItemActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemActions,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemActionsTableFilterComposer(
            $db: $db,
            $table: $db.itemActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> factsRefs(
    Expression<bool> Function($$FactsTableFilterComposer f) f,
  ) {
    final $$FactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableFilterComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ItemStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => column,
  );

  Expression<T> sourcesRefs<T extends Object>(
    Expression<T> Function($$SourcesTableAnnotationComposer a) f,
  ) {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> itemActionsRefs<T extends Object>(
    Expression<T> Function($$ItemActionsTableAnnotationComposer a) f,
  ) {
    final $$ItemActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemActions,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> factsRefs<T extends Object>(
    Expression<T> Function($$FactsTableAnnotationComposer a) f,
  ) {
    final $$FactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableAnnotationComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          ItemRow,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (ItemRow, $$ItemsTableReferences),
          ItemRow,
          PrefetchHooks Function({
            bool sourcesRefs,
            bool itemActionsRefs,
            bool remindersRefs,
            bool factsRefs,
          })
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<ItemStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<String?> sourceDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                ownerId: ownerId,
                title: title,
                summary: summary,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                resolvedAt: resolvedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                sourceDeviceId: sourceDeviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ownerId = const Value.absent(),
                required String title,
                Value<String> summary = const Value.absent(),
                required ItemStatus status,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required SyncStatus syncStatus,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<String?> sourceDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                ownerId: ownerId,
                title: title,
                summary: summary,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                resolvedAt: resolvedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                sourceDeviceId: sourceDeviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ItemsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourcesRefs = false,
                itemActionsRefs = false,
                remindersRefs = false,
                factsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sourcesRefs) db.sources,
                    if (itemActionsRefs) db.itemActions,
                    if (remindersRefs) db.reminders,
                    if (factsRefs) db.facts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sourcesRefs)
                        await $_getPrefetchedData<
                          ItemRow,
                          $ItemsTable,
                          SourceRow
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._sourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(db, table, p0).sourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (itemActionsRefs)
                        await $_getPrefetchedData<
                          ItemRow,
                          $ItemsTable,
                          ItemActionRow
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._itemActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).itemActionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          ItemRow,
                          $ItemsTable,
                          ReminderRow
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (factsRefs)
                        await $_getPrefetchedData<
                          ItemRow,
                          $ItemsTable,
                          FactRow
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._factsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(db, table, p0).factsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      ItemRow,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (ItemRow, $$ItemsTableReferences),
      ItemRow,
      PrefetchHooks Function({
        bool sourcesRefs,
        bool itemActionsRefs,
        bool remindersRefs,
        bool factsRefs,
      })
    >;
typedef $$SourcesTableCreateCompanionBuilder = SourcesCompanion Function({
  required String id,
  required String itemId,
  Value<String?> ownerId,
  required String kind,
  required String origin,
  required String originalName,
  required String mimeType,
  required int byteSize,
  required String contentHash,
  Value<int> revision,
  Value<String?> textContent,
  Value<int?> pageCount,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<DateTime?> deletedAt,
  required SyncStatus syncStatus,
  Value<int> rowid,
});
typedef $$SourcesTableUpdateCompanionBuilder = SourcesCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> ownerId,
  Value<String> kind,
  Value<String> origin,
  Value<String> originalName,
  Value<String> mimeType,
  Value<int> byteSize,
  Value<String> contentHash,
  Value<int> revision,
  Value<String?> textContent,
  Value<int?> pageCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});

final class $$SourcesTableReferences
    extends BaseReferences<_$AppDatabase, $SourcesTable, SourceRow> {
  $$SourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) =>
      db.items.createAlias('sources__item_id__items__id');

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ItemActionsTable, List<ItemActionRow>>
  _itemActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemActions,
    aliasName: 'sources__id__item_actions__source_id',
  );

  $$ItemActionsTableProcessedTableManager get itemActionsRefs {
    final manager = $$ItemActionsTableTableManager(
      $_db,
      $_db.itemActions,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemActionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SourceFilesTable, List<SourceFileRow>>
  _sourceFilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sourceFiles,
    aliasName: 'sources__id__source_files__source_id',
  );

  $$SourceFilesTableProcessedTableManager get sourceFilesRefs {
    final manager = $$SourceFilesTableTableManager(
      $_db,
      $_db.sourceFiles,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sourceFilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FactsTable, List<FactRow>> _factsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.facts,
    aliasName: 'sources__id__facts__source_id',
  );

  $$FactsTableProcessedTableManager get factsRefs {
    final manager = $$FactsTableTableManager(
      $_db,
      $_db.facts,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_factsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AnalysisJobsTable, List<AnalysisJobRow>>
  _analysisJobsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.analysisJobs,
    aliasName: 'sources__id__analysis_jobs__source_id',
  );

  $$AnalysisJobsTableProcessedTableManager get analysisJobsRefs {
    final manager = $$AnalysisJobsTableTableManager(
      $_db,
      $_db.analysisJobs,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_analysisJobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourcesTableFilterComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> itemActionsRefs(
    Expression<bool> Function($$ItemActionsTableFilterComposer f) f,
  ) {
    final $$ItemActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemActions,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemActionsTableFilterComposer(
            $db: $db,
            $table: $db.itemActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sourceFilesRefs(
    Expression<bool> Function($$SourceFilesTableFilterComposer f) f,
  ) {
    final $$SourceFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sourceFiles,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceFilesTableFilterComposer(
            $db: $db,
            $table: $db.sourceFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> factsRefs(
    Expression<bool> Function($$FactsTableFilterComposer f) f,
  ) {
    final $$FactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableFilterComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> analysisJobsRefs(
    Expression<bool> Function($$AnalysisJobsTableFilterComposer f) f,
  ) {
    final $$AnalysisJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.analysisJobs,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnalysisJobsTableFilterComposer(
            $db: $db,
            $table: $db.analysisJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> itemActionsRefs<T extends Object>(
    Expression<T> Function($$ItemActionsTableAnnotationComposer a) f,
  ) {
    final $$ItemActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemActions,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sourceFilesRefs<T extends Object>(
    Expression<T> Function($$SourceFilesTableAnnotationComposer a) f,
  ) {
    final $$SourceFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sourceFiles,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> factsRefs<T extends Object>(
    Expression<T> Function($$FactsTableAnnotationComposer a) f,
  ) {
    final $$FactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableAnnotationComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> analysisJobsRefs<T extends Object>(
    Expression<T> Function($$AnalysisJobsTableAnnotationComposer a) f,
  ) {
    final $$AnalysisJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.analysisJobs,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnalysisJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.analysisJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourcesTable,
          SourceRow,
          $$SourcesTableFilterComposer,
          $$SourcesTableOrderingComposer,
          $$SourcesTableAnnotationComposer,
          $$SourcesTableCreateCompanionBuilder,
          $$SourcesTableUpdateCompanionBuilder,
          (SourceRow, $$SourcesTableReferences),
          SourceRow,
          PrefetchHooks Function({
            bool itemId,
            bool itemActionsRefs,
            bool sourceFilesRefs,
            bool factsRefs,
            bool analysisJobsRefs,
          })
        > {
  $$SourcesTableTableManager(_$AppDatabase db, $SourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourcesCompanion(
                id: id,
                itemId: itemId,
                ownerId: ownerId,
                kind: kind,
                origin: origin,
                originalName: originalName,
                mimeType: mimeType,
                byteSize: byteSize,
                contentHash: contentHash,
                revision: revision,
                textContent: textContent,
                pageCount: pageCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                Value<String?> ownerId = const Value.absent(),
                required String kind,
                required String origin,
                required String originalName,
                required String mimeType,
                required int byteSize,
                required String contentHash,
                Value<int> revision = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required SyncStatus syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => SourcesCompanion.insert(
                id: id,
                itemId: itemId,
                ownerId: ownerId,
                kind: kind,
                origin: origin,
                originalName: originalName,
                mimeType: mimeType,
                byteSize: byteSize,
                contentHash: contentHash,
                revision: revision,
                textContent: textContent,
                pageCount: pageCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                itemId = false,
                itemActionsRefs = false,
                sourceFilesRefs = false,
                factsRefs = false,
                analysisJobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (itemActionsRefs) db.itemActions,
                    if (sourceFilesRefs) db.sourceFiles,
                    if (factsRefs) db.facts,
                    if (analysisJobsRefs) db.analysisJobs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (itemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$SourcesTableReferences
                                ._itemIdTable(db),
                            referencedColumn: $$SourcesTableReferences
                                ._itemIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (itemActionsRefs)
                        await $_getPrefetchedData<
                          SourceRow,
                          $SourcesTable,
                          ItemActionRow
                        >(
                          currentTable: table,
                          referencedTable: $$SourcesTableReferences
                              ._itemActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).itemActionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sourceFilesRefs)
                        await $_getPrefetchedData<
                          SourceRow,
                          $SourcesTable,
                          SourceFileRow
                        >(
                          currentTable: table,
                          referencedTable: $$SourcesTableReferences
                              ._sourceFilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).sourceFilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (factsRefs)
                        await $_getPrefetchedData<
                          SourceRow,
                          $SourcesTable,
                          FactRow
                        >(
                          currentTable: table,
                          referencedTable: $$SourcesTableReferences
                              ._factsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourcesTableReferences(db, table, p0).factsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (analysisJobsRefs)
                        await $_getPrefetchedData<
                          SourceRow,
                          $SourcesTable,
                          AnalysisJobRow
                        >(
                          currentTable: table,
                          referencedTable: $$SourcesTableReferences
                              ._analysisJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).analysisJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourcesTable,
      SourceRow,
      $$SourcesTableFilterComposer,
      $$SourcesTableOrderingComposer,
      $$SourcesTableAnnotationComposer,
      $$SourcesTableCreateCompanionBuilder,
      $$SourcesTableUpdateCompanionBuilder,
      (SourceRow, $$SourcesTableReferences),
      SourceRow,
      PrefetchHooks Function({
        bool itemId,
        bool itemActionsRefs,
        bool sourceFilesRefs,
        bool factsRefs,
        bool analysisJobsRefs,
      })
    >;
typedef $$ItemActionsTableCreateCompanionBuilder =
    ItemActionsCompanion Function({
      required String id,
      required String itemId,
      Value<String?> ownerId,
      Value<String?> sourceId,
      Value<int?> analysisRevision,
      required String kind,
      required String title,
      Value<int> payloadVersion,
      required String payload,
      required String origin,
      Value<String> evidenceFactIds,
      Value<String> state,
      Value<String> executionState,
      Value<DateTime?> acceptedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> remoteServerUpdatedAt,
      Value<DateTime?> deletedAt,
      required SyncStatus syncStatus,
      Value<int> rowid,
    });
typedef $$ItemActionsTableUpdateCompanionBuilder =
    ItemActionsCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String?> ownerId,
      Value<String?> sourceId,
      Value<int?> analysisRevision,
      Value<String> kind,
      Value<String> title,
      Value<int> payloadVersion,
      Value<String> payload,
      Value<String> origin,
      Value<String> evidenceFactIds,
      Value<String> state,
      Value<String> executionState,
      Value<DateTime?> acceptedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> remoteServerUpdatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<int> rowid,
    });

final class $$ItemActionsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemActionsTable, ItemActionRow> {
  $$ItemActionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) =>
      db.items.createAlias('item_actions__item_id__items__id');

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.sources.createAlias('item_actions__source_id__sources__id');

  $$SourcesTableProcessedTableManager? get sourceId {
    final $_column = $_itemColumn<String>('source_id');
    if ($_column == null) return null;
    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'item_actions__id__reminders__action_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.actionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItemActionsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemActionsTable> {
  $$ItemActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get analysisRevision => $composableBuilder(
    column: $table.analysisRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceFactIds => $composableBuilder(
    column: $table.evidenceFactIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get executionState => $composableBuilder(
    column: $table.executionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.actionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemActionsTable> {
  $$ItemActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get analysisRevision => $composableBuilder(
    column: $table.analysisRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceFactIds => $composableBuilder(
    column: $table.evidenceFactIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get executionState => $composableBuilder(
    column: $table.executionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemActionsTable> {
  $$ItemActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get analysisRevision => $composableBuilder(
    column: $table.analysisRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get evidenceFactIds => $composableBuilder(
    column: $table.evidenceFactIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get executionState => $composableBuilder(
    column: $table.executionState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.actionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemActionsTable,
          ItemActionRow,
          $$ItemActionsTableFilterComposer,
          $$ItemActionsTableOrderingComposer,
          $$ItemActionsTableAnnotationComposer,
          $$ItemActionsTableCreateCompanionBuilder,
          $$ItemActionsTableUpdateCompanionBuilder,
          (ItemActionRow, $$ItemActionsTableReferences),
          ItemActionRow,
          PrefetchHooks Function({
            bool itemId,
            bool sourceId,
            bool remindersRefs,
          })
        > {
  $$ItemActionsTableTableManager(_$AppDatabase db, $ItemActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<int?> analysisRevision = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> evidenceFactIds = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> executionState = const Value.absent(),
                Value<DateTime?> acceptedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemActionsCompanion(
                id: id,
                itemId: itemId,
                ownerId: ownerId,
                sourceId: sourceId,
                analysisRevision: analysisRevision,
                kind: kind,
                title: title,
                payloadVersion: payloadVersion,
                payload: payload,
                origin: origin,
                evidenceFactIds: evidenceFactIds,
                state: state,
                executionState: executionState,
                acceptedAt: acceptedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                Value<String?> ownerId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<int?> analysisRevision = const Value.absent(),
                required String kind,
                required String title,
                Value<int> payloadVersion = const Value.absent(),
                required String payload,
                required String origin,
                Value<String> evidenceFactIds = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> executionState = const Value.absent(),
                Value<DateTime?> acceptedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required SyncStatus syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => ItemActionsCompanion.insert(
                id: id,
                itemId: itemId,
                ownerId: ownerId,
                sourceId: sourceId,
                analysisRevision: analysisRevision,
                kind: kind,
                title: title,
                payloadVersion: payloadVersion,
                payload: payload,
                origin: origin,
                evidenceFactIds: evidenceFactIds,
                state: state,
                executionState: executionState,
                acceptedAt: acceptedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ItemActionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({itemId = false, sourceId = false, remindersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (remindersRefs) db.reminders],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (itemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$ItemActionsTableReferences
                                ._itemIdTable(db),
                            referencedColumn: $$ItemActionsTableReferences
                                ._itemIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (sourceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceId,
                            referencedTable: $$ItemActionsTableReferences
                                ._sourceIdTable(db),
                            referencedColumn: $$ItemActionsTableReferences
                                ._sourceIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          ItemActionRow,
                          $ItemActionsTable,
                          ReminderRow
                        >(
                          currentTable: table,
                          referencedTable: $$ItemActionsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemActionsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.actionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ItemActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemActionsTable,
      ItemActionRow,
      $$ItemActionsTableFilterComposer,
      $$ItemActionsTableOrderingComposer,
      $$ItemActionsTableAnnotationComposer,
      $$ItemActionsTableCreateCompanionBuilder,
      $$ItemActionsTableUpdateCompanionBuilder,
      (ItemActionRow, $$ItemActionsTableReferences),
      ItemActionRow,
      PrefetchHooks Function({bool itemId, bool sourceId, bool remindersRefs})
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  Value<String?> ownerId,
  required String itemId,
  Value<String?> actionId,
  Value<String?> title,
  Value<String?> timeZone,
  required DateTime remindAt,
  Value<DateTime?> completedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required SyncStatus syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<String?> sourceDeviceId,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<String?> ownerId,
  Value<String> itemId,
  Value<String?> actionId,
  Value<String?> title,
  Value<String?> timeZone,
  Value<DateTime> remindAt,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<SyncStatus> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<String?> sourceDeviceId,
  Value<int> rowid,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) =>
      db.items.createAlias('reminders__item_id__items__id');

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemActionsTable _actionIdTable(_$AppDatabase db) =>
      db.itemActions.createAlias('reminders__action_id__item_actions__id');

  $$ItemActionsTableProcessedTableManager? get actionId {
    final $_column = $_itemColumn<String>('action_id');
    if ($_column == null) return null;
    final manager = $$ItemActionsTableTableManager(
      $_db,
      $_db.itemActions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_actionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemActionsTableFilterComposer get actionId {
    final $$ItemActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.itemActions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemActionsTableFilterComposer(
            $db: $db,
            $table: $db.itemActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemActionsTableOrderingComposer get actionId {
    final $$ItemActionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.itemActions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemActionsTableOrderingComposer(
            $db: $db,
            $table: $db.itemActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get timeZone =>
      $composableBuilder(column: $table.timeZone, builder: (column) => column);

  GeneratedColumn<DateTime> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDeviceId => $composableBuilder(
    column: $table.sourceDeviceId,
    builder: (column) => column,
  );

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemActionsTableAnnotationComposer get actionId {
    final $$ItemActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.itemActions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (ReminderRow, $$RemindersTableReferences),
          ReminderRow,
          PrefetchHooks Function({bool itemId, bool actionId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> actionId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> timeZone = const Value.absent(),
                Value<DateTime> remindAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<String?> sourceDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                ownerId: ownerId,
                itemId: itemId,
                actionId: actionId,
                title: title,
                timeZone: timeZone,
                remindAt: remindAt,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                sourceDeviceId: sourceDeviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ownerId = const Value.absent(),
                required String itemId,
                Value<String?> actionId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> timeZone = const Value.absent(),
                required DateTime remindAt,
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required SyncStatus syncStatus,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<String?> sourceDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                ownerId: ownerId,
                itemId: itemId,
                actionId: actionId,
                title: title,
                timeZone: timeZone,
                remindAt: remindAt,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                sourceDeviceId: sourceDeviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false, actionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$RemindersTableReferences
                            ._itemIdTable(db),
                        referencedColumn: $$RemindersTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (actionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.actionId,
                        referencedTable: $$RemindersTableReferences
                            ._actionIdTable(db),
                        referencedColumn: $$RemindersTableReferences
                            ._actionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (ReminderRow, $$RemindersTableReferences),
      ReminderRow,
      PrefetchHooks Function({bool itemId, bool actionId})
    >;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  required String id,
  required SyncEntityType entityType,
  required String entityId,
  required SyncOperation operation,
  required DateTime createdAt,
  Value<int> attempts,
  Value<DateTime?> lastAttemptAt,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<String> id,
  Value<SyncEntityType> entityType,
  Value<String> entityId,
  Value<SyncOperation> operation,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<DateTime?> lastAttemptAt,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncEntityType, SyncEntityType, String>
  get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncOperation, SyncOperation, String>
  get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncEntityType, String> get entityType =>
      $composableBuilder(
        column: $table.entityType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncOperation, String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueRow,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueRow,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
          ),
          SyncQueueRow,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<SyncEntityType> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<SyncOperation> operation = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                createdAt: createdAt,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required SyncEntityType entityType,
                required String entityId,
                required SyncOperation operation,
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                createdAt: createdAt,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueRow,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueRow,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
      ),
      SyncQueueRow,
      PrefetchHooks Function()
    >;
typedef $$CloudSyncStatesTableCreateCompanionBuilder =
    CloudSyncStatesCompanion Function({
      Value<String> id,
      required String installationId,
      Value<String?> userId,
      Value<DateTime?> lastFactsCursor,
      Value<DateTime?> lastActionsCursor,
      Value<DateTime?> lastSourcesCursor,
      Value<DateTime?> lastItemsCursor,
      Value<DateTime?> lastRemindersCursor,
      Value<DateTime?> lastSuccessfulSyncAt,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$CloudSyncStatesTableUpdateCompanionBuilder =
    CloudSyncStatesCompanion Function({
      Value<String> id,
      Value<String> installationId,
      Value<String?> userId,
      Value<DateTime?> lastFactsCursor,
      Value<DateTime?> lastActionsCursor,
      Value<DateTime?> lastSourcesCursor,
      Value<DateTime?> lastItemsCursor,
      Value<DateTime?> lastRemindersCursor,
      Value<DateTime?> lastSuccessfulSyncAt,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$CloudSyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $CloudSyncStatesTable> {
  $$CloudSyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFactsCursor => $composableBuilder(
    column: $table.lastFactsCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActionsCursor => $composableBuilder(
    column: $table.lastActionsCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSourcesCursor => $composableBuilder(
    column: $table.lastSourcesCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastItemsCursor => $composableBuilder(
    column: $table.lastItemsCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRemindersCursor => $composableBuilder(
    column: $table.lastRemindersCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CloudSyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CloudSyncStatesTable> {
  $$CloudSyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFactsCursor => $composableBuilder(
    column: $table.lastFactsCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActionsCursor => $composableBuilder(
    column: $table.lastActionsCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSourcesCursor => $composableBuilder(
    column: $table.lastSourcesCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastItemsCursor => $composableBuilder(
    column: $table.lastItemsCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRemindersCursor => $composableBuilder(
    column: $table.lastRemindersCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CloudSyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CloudSyncStatesTable> {
  $$CloudSyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFactsCursor => $composableBuilder(
    column: $table.lastFactsCursor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActionsCursor => $composableBuilder(
    column: $table.lastActionsCursor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSourcesCursor => $composableBuilder(
    column: $table.lastSourcesCursor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastItemsCursor => $composableBuilder(
    column: $table.lastItemsCursor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastRemindersCursor => $composableBuilder(
    column: $table.lastRemindersCursor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$CloudSyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CloudSyncStatesTable,
          CloudSyncStateRow,
          $$CloudSyncStatesTableFilterComposer,
          $$CloudSyncStatesTableOrderingComposer,
          $$CloudSyncStatesTableAnnotationComposer,
          $$CloudSyncStatesTableCreateCompanionBuilder,
          $$CloudSyncStatesTableUpdateCompanionBuilder,
          (
            CloudSyncStateRow,
            BaseReferences<
              _$AppDatabase,
              $CloudSyncStatesTable,
              CloudSyncStateRow
            >,
          ),
          CloudSyncStateRow,
          PrefetchHooks Function()
        > {
  $$CloudSyncStatesTableTableManager(
    _$AppDatabase db,
    $CloudSyncStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CloudSyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CloudSyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CloudSyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> installationId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime?> lastFactsCursor = const Value.absent(),
                Value<DateTime?> lastActionsCursor = const Value.absent(),
                Value<DateTime?> lastSourcesCursor = const Value.absent(),
                Value<DateTime?> lastItemsCursor = const Value.absent(),
                Value<DateTime?> lastRemindersCursor = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CloudSyncStatesCompanion(
                id: id,
                installationId: installationId,
                userId: userId,
                lastFactsCursor: lastFactsCursor,
                lastActionsCursor: lastActionsCursor,
                lastSourcesCursor: lastSourcesCursor,
                lastItemsCursor: lastItemsCursor,
                lastRemindersCursor: lastRemindersCursor,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String installationId,
                Value<String?> userId = const Value.absent(),
                Value<DateTime?> lastFactsCursor = const Value.absent(),
                Value<DateTime?> lastActionsCursor = const Value.absent(),
                Value<DateTime?> lastSourcesCursor = const Value.absent(),
                Value<DateTime?> lastItemsCursor = const Value.absent(),
                Value<DateTime?> lastRemindersCursor = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CloudSyncStatesCompanion.insert(
                id: id,
                installationId: installationId,
                userId: userId,
                lastFactsCursor: lastFactsCursor,
                lastActionsCursor: lastActionsCursor,
                lastSourcesCursor: lastSourcesCursor,
                lastItemsCursor: lastItemsCursor,
                lastRemindersCursor: lastRemindersCursor,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CloudSyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CloudSyncStatesTable,
      CloudSyncStateRow,
      $$CloudSyncStatesTableFilterComposer,
      $$CloudSyncStatesTableOrderingComposer,
      $$CloudSyncStatesTableAnnotationComposer,
      $$CloudSyncStatesTableCreateCompanionBuilder,
      $$CloudSyncStatesTableUpdateCompanionBuilder,
      (
        CloudSyncStateRow,
        BaseReferences<_$AppDatabase, $CloudSyncStatesTable, CloudSyncStateRow>,
      ),
      CloudSyncStateRow,
      PrefetchHooks Function()
    >;
typedef $$SourceFilesTableCreateCompanionBuilder =
    SourceFilesCompanion Function({
      required String sourceId,
      Value<String?> originalRelativePath,
      Value<String?> thumbnailRelativePath,
      Value<String> availability,
      Value<DateTime?> lastAccessedAt,
      Value<int> rowid,
    });
typedef $$SourceFilesTableUpdateCompanionBuilder =
    SourceFilesCompanion Function({
      Value<String> sourceId,
      Value<String?> originalRelativePath,
      Value<String?> thumbnailRelativePath,
      Value<String> availability,
      Value<DateTime?> lastAccessedAt,
      Value<int> rowid,
    });

final class $$SourceFilesTableReferences
    extends BaseReferences<_$AppDatabase, $SourceFilesTable, SourceFileRow> {
  $$SourceFilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.sources.createAlias('source_files__source_id__sources__id');

  $$SourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SourceFilesTableFilterComposer
    extends Composer<_$AppDatabase, $SourceFilesTable> {
  $$SourceFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get originalRelativePath => $composableBuilder(
    column: $table.originalRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailRelativePath => $composableBuilder(
    column: $table.thumbnailRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get availability => $composableBuilder(
    column: $table.availability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SourceFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $SourceFilesTable> {
  $$SourceFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get originalRelativePath => $composableBuilder(
    column: $table.originalRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailRelativePath => $composableBuilder(
    column: $table.thumbnailRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get availability => $composableBuilder(
    column: $table.availability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SourceFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourceFilesTable> {
  $$SourceFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get originalRelativePath => $composableBuilder(
    column: $table.originalRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailRelativePath => $composableBuilder(
    column: $table.thumbnailRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get availability => $composableBuilder(
    column: $table.availability,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SourceFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourceFilesTable,
          SourceFileRow,
          $$SourceFilesTableFilterComposer,
          $$SourceFilesTableOrderingComposer,
          $$SourceFilesTableAnnotationComposer,
          $$SourceFilesTableCreateCompanionBuilder,
          $$SourceFilesTableUpdateCompanionBuilder,
          (SourceFileRow, $$SourceFilesTableReferences),
          SourceFileRow,
          PrefetchHooks Function({bool sourceId})
        > {
  $$SourceFilesTableTableManager(_$AppDatabase db, $SourceFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String?> originalRelativePath = const Value.absent(),
                Value<String?> thumbnailRelativePath = const Value.absent(),
                Value<String> availability = const Value.absent(),
                Value<DateTime?> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceFilesCompanion(
                sourceId: sourceId,
                originalRelativePath: originalRelativePath,
                thumbnailRelativePath: thumbnailRelativePath,
                availability: availability,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                Value<String?> originalRelativePath = const Value.absent(),
                Value<String?> thumbnailRelativePath = const Value.absent(),
                Value<String> availability = const Value.absent(),
                Value<DateTime?> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceFilesCompanion.insert(
                sourceId: sourceId,
                originalRelativePath: originalRelativePath,
                thumbnailRelativePath: thumbnailRelativePath,
                availability: availability,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SourceFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$SourceFilesTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$SourceFilesTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SourceFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourceFilesTable,
      SourceFileRow,
      $$SourceFilesTableFilterComposer,
      $$SourceFilesTableOrderingComposer,
      $$SourceFilesTableAnnotationComposer,
      $$SourceFilesTableCreateCompanionBuilder,
      $$SourceFilesTableUpdateCompanionBuilder,
      (SourceFileRow, $$SourceFilesTableReferences),
      SourceFileRow,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $$FactsTableCreateCompanionBuilder = FactsCompanion Function({
  required String id,
  required String itemId,
  Value<String?> ownerId,
  Value<String?> sourceId,
  Value<int?> sourceRevision,
  required String key,
  required String valueType,
  required String value,
  Value<String?> userValue,
  required String provenance,
  required String evidence,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<DateTime?> deletedAt,
  required SyncStatus syncStatus,
  Value<int> rowid,
});
typedef $$FactsTableUpdateCompanionBuilder = FactsCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> ownerId,
  Value<String?> sourceId,
  Value<int?> sourceRevision,
  Value<String> key,
  Value<String> valueType,
  Value<String> value,
  Value<String?> userValue,
  Value<String> provenance,
  Value<String> evidence,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});

final class $$FactsTableReferences
    extends BaseReferences<_$AppDatabase, $FactsTable, FactRow> {
  $$FactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) =>
      db.items.createAlias('facts__item_id__items__id');

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.sources.createAlias('facts__source_id__sources__id');

  $$SourcesTableProcessedTableManager? get sourceId {
    final $_column = $_itemColumn<String>('source_id');
    if ($_column == null) return null;
    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FactsTableFilterComposer extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceRevision => $composableBuilder(
    column: $table.sourceRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userValue => $composableBuilder(
    column: $table.userValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidence => $composableBuilder(
    column: $table.evidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactsTableOrderingComposer
    extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceRevision => $composableBuilder(
    column: $table.sourceRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userValue => $composableBuilder(
    column: $table.userValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidence => $composableBuilder(
    column: $table.evidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get sourceRevision => $composableBuilder(
    column: $table.sourceRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueType =>
      $composableBuilder(column: $table.valueType, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get userValue =>
      $composableBuilder(column: $table.userValue, builder: (column) => column);

  GeneratedColumn<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidence =>
      $composableBuilder(column: $table.evidence, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get remoteServerUpdatedAt => $composableBuilder(
    column: $table.remoteServerUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FactsTable,
          FactRow,
          $$FactsTableFilterComposer,
          $$FactsTableOrderingComposer,
          $$FactsTableAnnotationComposer,
          $$FactsTableCreateCompanionBuilder,
          $$FactsTableUpdateCompanionBuilder,
          (FactRow, $$FactsTableReferences),
          FactRow,
          PrefetchHooks Function({bool itemId, bool sourceId})
        > {
  $$FactsTableTableManager(_$AppDatabase db, $FactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<int?> sourceRevision = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> valueType = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String?> userValue = const Value.absent(),
                Value<String> provenance = const Value.absent(),
                Value<String> evidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactsCompanion(
                id: id,
                itemId: itemId,
                ownerId: ownerId,
                sourceId: sourceId,
                sourceRevision: sourceRevision,
                key: key,
                valueType: valueType,
                value: value,
                userValue: userValue,
                provenance: provenance,
                evidence: evidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                Value<String?> ownerId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<int?> sourceRevision = const Value.absent(),
                required String key,
                required String valueType,
                required String value,
                Value<String?> userValue = const Value.absent(),
                required String provenance,
                required String evidence,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required SyncStatus syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => FactsCompanion.insert(
                id: id,
                itemId: itemId,
                ownerId: ownerId,
                sourceId: sourceId,
                sourceRevision: sourceRevision,
                key: key,
                valueType: valueType,
                value: value,
                userValue: userValue,
                provenance: provenance,
                evidence: evidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$FactsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false, sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$FactsTableReferences._itemIdTable(
                          db,
                        ),
                        referencedColumn: $$FactsTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$FactsTableReferences._sourceIdTable(
                          db,
                        ),
                        referencedColumn: $$FactsTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FactsTable,
      FactRow,
      $$FactsTableFilterComposer,
      $$FactsTableOrderingComposer,
      $$FactsTableAnnotationComposer,
      $$FactsTableCreateCompanionBuilder,
      $$FactsTableUpdateCompanionBuilder,
      (FactRow, $$FactsTableReferences),
      FactRow,
      PrefetchHooks Function({bool itemId, bool sourceId})
    >;
typedef $$AnalysisJobsTableCreateCompanionBuilder =
    AnalysisJobsCompanion Function({
      required String sourceId,
      required String requestId,
      required String ownerId,
      required int revision,
      required String locale,
      required String timeZone,
      Value<String> state,
      Value<String?> payload,
      Value<String?> envelope,
      Value<String?> errorCode,
      Value<int> attempts,
      Value<DateTime?> nextAttemptAt,
      required DateTime requestedAt,
      Value<int> rowid,
    });
typedef $$AnalysisJobsTableUpdateCompanionBuilder =
    AnalysisJobsCompanion Function({
      Value<String> sourceId,
      Value<String> requestId,
      Value<String> ownerId,
      Value<int> revision,
      Value<String> locale,
      Value<String> timeZone,
      Value<String> state,
      Value<String?> payload,
      Value<String?> envelope,
      Value<String?> errorCode,
      Value<int> attempts,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime> requestedAt,
      Value<int> rowid,
    });

final class $$AnalysisJobsTableReferences
    extends BaseReferences<_$AppDatabase, $AnalysisJobsTable, AnalysisJobRow> {
  $$AnalysisJobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.sources.createAlias('analysis_jobs__source_id__sources__id');

  $$SourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnalysisJobsTableFilterComposer
    extends Composer<_$AppDatabase, $AnalysisJobsTable> {
  $$AnalysisJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get envelope => $composableBuilder(
    column: $table.envelope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnalysisJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalysisJobsTable> {
  $$AnalysisJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get envelope => $composableBuilder(
    column: $table.envelope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnalysisJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalysisJobsTable> {
  $$AnalysisJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get timeZone =>
      $composableBuilder(column: $table.timeZone, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get envelope =>
      $composableBuilder(column: $table.envelope, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => column,
  );

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnalysisJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnalysisJobsTable,
          AnalysisJobRow,
          $$AnalysisJobsTableFilterComposer,
          $$AnalysisJobsTableOrderingComposer,
          $$AnalysisJobsTableAnnotationComposer,
          $$AnalysisJobsTableCreateCompanionBuilder,
          $$AnalysisJobsTableUpdateCompanionBuilder,
          (AnalysisJobRow, $$AnalysisJobsTableReferences),
          AnalysisJobRow,
          PrefetchHooks Function({bool sourceId})
        > {
  $$AnalysisJobsTableTableManager(_$AppDatabase db, $AnalysisJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalysisJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnalysisJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnalysisJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> timeZone = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<String?> envelope = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime> requestedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnalysisJobsCompanion(
                sourceId: sourceId,
                requestId: requestId,
                ownerId: ownerId,
                revision: revision,
                locale: locale,
                timeZone: timeZone,
                state: state,
                payload: payload,
                envelope: envelope,
                errorCode: errorCode,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                requestedAt: requestedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String requestId,
                required String ownerId,
                required int revision,
                required String locale,
                required String timeZone,
                Value<String> state = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<String?> envelope = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                required DateTime requestedAt,
                Value<int> rowid = const Value.absent(),
              }) => AnalysisJobsCompanion.insert(
                sourceId: sourceId,
                requestId: requestId,
                ownerId: ownerId,
                revision: revision,
                locale: locale,
                timeZone: timeZone,
                state: state,
                payload: payload,
                envelope: envelope,
                errorCode: errorCode,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                requestedAt: requestedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AnalysisJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$AnalysisJobsTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$AnalysisJobsTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AnalysisJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnalysisJobsTable,
      AnalysisJobRow,
      $$AnalysisJobsTableFilterComposer,
      $$AnalysisJobsTableOrderingComposer,
      $$AnalysisJobsTableAnnotationComposer,
      $$AnalysisJobsTableCreateCompanionBuilder,
      $$AnalysisJobsTableUpdateCompanionBuilder,
      (AnalysisJobRow, $$AnalysisJobsTableReferences),
      AnalysisJobRow,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $$FileJobsTableCreateCompanionBuilder = FileJobsCompanion Function({
  required String sourceId,
  required String ownerId,
  required int revision,
  required String operation,
  Value<String> state,
  Value<int> attempts,
  Value<int> transferredBytes,
  Value<String?> errorCode,
  Value<DateTime?> nextAttemptAt,
  Value<int> rowid,
});
typedef $$FileJobsTableUpdateCompanionBuilder = FileJobsCompanion Function({
  Value<String> sourceId,
  Value<String> ownerId,
  Value<int> revision,
  Value<String> operation,
  Value<String> state,
  Value<int> attempts,
  Value<int> transferredBytes,
  Value<String?> errorCode,
  Value<DateTime?> nextAttemptAt,
  Value<int> rowid,
});

class $$FileJobsTableFilterComposer
    extends Composer<_$AppDatabase, $FileJobsTable> {
  $$FileJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transferredBytes => $composableBuilder(
    column: $table.transferredBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FileJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $FileJobsTable> {
  $$FileJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transferredBytes => $composableBuilder(
    column: $table.transferredBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FileJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FileJobsTable> {
  $$FileJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get transferredBytes => $composableBuilder(
    column: $table.transferredBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );
}

class $$FileJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FileJobsTable,
          FileJobRow,
          $$FileJobsTableFilterComposer,
          $$FileJobsTableOrderingComposer,
          $$FileJobsTableAnnotationComposer,
          $$FileJobsTableCreateCompanionBuilder,
          $$FileJobsTableUpdateCompanionBuilder,
          (
            FileJobRow,
            BaseReferences<_$AppDatabase, $FileJobsTable, FileJobRow>,
          ),
          FileJobRow,
          PrefetchHooks Function()
        > {
  $$FileJobsTableTableManager(_$AppDatabase db, $FileJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FileJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FileJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FileJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> transferredBytes = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileJobsCompanion(
                sourceId: sourceId,
                ownerId: ownerId,
                revision: revision,
                operation: operation,
                state: state,
                attempts: attempts,
                transferredBytes: transferredBytes,
                errorCode: errorCode,
                nextAttemptAt: nextAttemptAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String ownerId,
                required int revision,
                required String operation,
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> transferredBytes = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileJobsCompanion.insert(
                sourceId: sourceId,
                ownerId: ownerId,
                revision: revision,
                operation: operation,
                state: state,
                attempts: attempts,
                transferredBytes: transferredBytes,
                errorCode: errorCode,
                nextAttemptAt: nextAttemptAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FileJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FileJobsTable,
      FileJobRow,
      $$FileJobsTableFilterComposer,
      $$FileJobsTableOrderingComposer,
      $$FileJobsTableAnnotationComposer,
      $$FileJobsTableCreateCompanionBuilder,
      $$FileJobsTableUpdateCompanionBuilder,
      (FileJobRow, BaseReferences<_$AppDatabase, $FileJobsTable, FileJobRow>),
      FileJobRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db, _db.sources);
  $$ItemActionsTableTableManager get itemActions =>
      $$ItemActionsTableTableManager(_db, _db.itemActions);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$CloudSyncStatesTableTableManager get cloudSyncStates =>
      $$CloudSyncStatesTableTableManager(_db, _db.cloudSyncStates);
  $$SourceFilesTableTableManager get sourceFiles =>
      $$SourceFilesTableTableManager(_db, _db.sourceFiles);
  $$FactsTableTableManager get facts =>
      $$FactsTableTableManager(_db, _db.facts);
  $$AnalysisJobsTableTableManager get analysisJobs =>
      $$AnalysisJobsTableTableManager(_db, _db.analysisJobs);
  $$FileJobsTableTableManager get fileJobs =>
      $$FileJobsTableTableManager(_db, _db.fileJobs);
}
