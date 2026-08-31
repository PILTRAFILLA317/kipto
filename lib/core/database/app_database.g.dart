// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SavedItemsTable extends SavedItems
    with TableInfo<$SavedItemsTable, SavedItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedItemsTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumnWithTypeConverter<SavedItemCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SavedItemCategory>($SavedItemsTable.$convertercategory);
  static const VerificationMeta _subtypeMeta = const VerificationMeta(
    'subtype',
  );
  @override
  late final GeneratedColumn<String> subtype = GeneratedColumn<String>(
    'subtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intentMeta = const VerificationMeta('intent');
  @override
  late final GeneratedColumn<String> intent = GeneratedColumn<String>(
    'intent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SavedItemStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SavedItemStatus>($SavedItemsTable.$converterstatus);
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventAtMeta = const VerificationMeta(
    'eventAt',
  );
  @override
  late final GeneratedColumn<DateTime> eventAt = GeneratedColumn<DateTime>(
    'event_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozedUntil = GeneratedColumn<DateTime>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>, String>
  entities = GeneratedColumn<String>(
    'entities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  ).withConverter<Map<String, Object?>>($SavedItemsTable.$converterentities);
  @override
  late final GeneratedColumnWithTypeConverter<List<SavedItemActionType>, String>
  availableActions =
      GeneratedColumn<String>(
        'available_actions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<SavedItemActionType>>(
        $SavedItemsTable.$converteravailableActions,
      );
  static const VerificationMeta _cloudPreviewPathMeta = const VerificationMeta(
    'cloudPreviewPath',
  );
  @override
  late final GeneratedColumn<String> cloudPreviewPath = GeneratedColumn<String>(
    'cloud_preview_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageHashMeta = const VerificationMeta(
    'imageHash',
  );
  @override
  late final GeneratedColumn<String> imageHash = GeneratedColumn<String>(
    'image_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AnalysisStatus, String>
  analysisStatus = GeneratedColumn<String>(
    'analysis_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<AnalysisStatus>($SavedItemsTable.$converteranalysisStatus);
  static const VerificationMeta _analysisVersionMeta = const VerificationMeta(
    'analysisVersion',
  );
  @override
  late final GeneratedColumn<int> analysisVersion = GeneratedColumn<int>(
    'analysis_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
  static const VerificationMeta _localAssetIdMeta = const VerificationMeta(
    'localAssetId',
  );
  @override
  late final GeneratedColumn<String> localAssetId = GeneratedColumn<String>(
    'local_asset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalAvailableMeta = const VerificationMeta(
    'originalAvailable',
  );
  @override
  late final GeneratedColumn<bool> originalAvailable = GeneratedColumn<bool>(
    'original_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("original_available" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _previewCachePathMeta = const VerificationMeta(
    'previewCachePath',
  );
  @override
  late final GeneratedColumn<String> previewCachePath = GeneratedColumn<String>(
    'preview_cache_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
      ).withConverter<SyncStatus>($SavedItemsTable.$convertersyncStatus);
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    title,
    summary,
    category,
    subtype,
    intent,
    status,
    favorite,
    capturedAt,
    eventAt,
    expiresAt,
    snoozedUntil,
    location,
    entities,
    availableActions,
    cloudPreviewPath,
    imageHash,
    analysisStatus,
    analysisVersion,
    confidence,
    createdAt,
    updatedAt,
    deletedAt,
    localAssetId,
    originalAvailable,
    previewCachePath,
    syncStatus,
    lastSyncedAt,
    remoteServerUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedItemRow> instance, {
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
    if (data.containsKey('subtype')) {
      context.handle(
        _subtypeMeta,
        subtype.isAcceptableOrUnknown(data['subtype']!, _subtypeMeta),
      );
    }
    if (data.containsKey('intent')) {
      context.handle(
        _intentMeta,
        intent.isAcceptableOrUnknown(data['intent']!, _intentMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('event_at')) {
      context.handle(
        _eventAtMeta,
        eventAt.isAcceptableOrUnknown(data['event_at']!, _eventAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('cloud_preview_path')) {
      context.handle(
        _cloudPreviewPathMeta,
        cloudPreviewPath.isAcceptableOrUnknown(
          data['cloud_preview_path']!,
          _cloudPreviewPathMeta,
        ),
      );
    }
    if (data.containsKey('image_hash')) {
      context.handle(
        _imageHashMeta,
        imageHash.isAcceptableOrUnknown(data['image_hash']!, _imageHashMeta),
      );
    }
    if (data.containsKey('analysis_version')) {
      context.handle(
        _analysisVersionMeta,
        analysisVersion.isAcceptableOrUnknown(
          data['analysis_version']!,
          _analysisVersionMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
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
    if (data.containsKey('local_asset_id')) {
      context.handle(
        _localAssetIdMeta,
        localAssetId.isAcceptableOrUnknown(
          data['local_asset_id']!,
          _localAssetIdMeta,
        ),
      );
    }
    if (data.containsKey('original_available')) {
      context.handle(
        _originalAvailableMeta,
        originalAvailable.isAcceptableOrUnknown(
          data['original_available']!,
          _originalAvailableMeta,
        ),
      );
    }
    if (data.containsKey('preview_cache_path')) {
      context.handle(
        _previewCachePathMeta,
        previewCachePath.isAcceptableOrUnknown(
          data['preview_cache_path']!,
          _previewCachePathMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedItemRow(
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
      category: $SavedItemsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      subtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtype'],
      ),
      intent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intent'],
      ),
      status: $SavedItemsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      eventAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_at'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snoozed_until'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      entities: $SavedItemsTable.$converterentities.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}entities'],
        )!,
      ),
      availableActions: $SavedItemsTable.$converteravailableActions.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}available_actions'],
        )!,
      ),
      cloudPreviewPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_preview_path'],
      ),
      imageHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_hash'],
      ),
      analysisStatus: $SavedItemsTable.$converteranalysisStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}analysis_status'],
        )!,
      ),
      analysisVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}analysis_version'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
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
      localAssetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_asset_id'],
      ),
      originalAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}original_available'],
      )!,
      previewCachePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preview_cache_path'],
      ),
      syncStatus: $SavedItemsTable.$convertersyncStatus.fromSql(
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
    );
  }

  @override
  $SavedItemsTable createAlias(String alias) {
    return $SavedItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<SavedItemCategory, String> $convertercategory =
      const SavedItemCategoryConverter();
  static TypeConverter<SavedItemStatus, String> $converterstatus =
      const SavedItemStatusConverter();
  static TypeConverter<Map<String, Object?>, String> $converterentities =
      const JsonMapConverter();
  static TypeConverter<List<SavedItemActionType>, String>
  $converteravailableActions = const SavedItemActionsConverter();
  static TypeConverter<AnalysisStatus, String> $converteranalysisStatus =
      const AnalysisStatusConverter();
  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class SavedItemRow extends DataClass implements Insertable<SavedItemRow> {
  final String id;
  final String? ownerId;
  final String title;
  final String summary;
  final SavedItemCategory category;
  final String? subtype;
  final String? intent;
  final SavedItemStatus status;
  final bool favorite;
  final DateTime capturedAt;
  final DateTime? eventAt;
  final DateTime? expiresAt;
  final DateTime? snoozedUntil;
  final String? location;
  final Map<String, Object?> entities;
  final List<SavedItemActionType> availableActions;
  final String? cloudPreviewPath;
  final String? imageHash;
  final AnalysisStatus analysisStatus;
  final int analysisVersion;
  final double? confidence;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? localAssetId;
  final bool originalAvailable;
  final String? previewCachePath;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime? remoteServerUpdatedAt;
  const SavedItemRow({
    required this.id,
    this.ownerId,
    required this.title,
    required this.summary,
    required this.category,
    this.subtype,
    this.intent,
    required this.status,
    required this.favorite,
    required this.capturedAt,
    this.eventAt,
    this.expiresAt,
    this.snoozedUntil,
    this.location,
    required this.entities,
    required this.availableActions,
    this.cloudPreviewPath,
    this.imageHash,
    required this.analysisStatus,
    required this.analysisVersion,
    this.confidence,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.localAssetId,
    required this.originalAvailable,
    this.previewCachePath,
    required this.syncStatus,
    this.lastSyncedAt,
    this.remoteServerUpdatedAt,
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
      map['category'] = Variable<String>(
        $SavedItemsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || subtype != null) {
      map['subtype'] = Variable<String>(subtype);
    }
    if (!nullToAbsent || intent != null) {
      map['intent'] = Variable<String>(intent);
    }
    {
      map['status'] = Variable<String>(
        $SavedItemsTable.$converterstatus.toSql(status),
      );
    }
    map['favorite'] = Variable<bool>(favorite);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || eventAt != null) {
      map['event_at'] = Variable<DateTime>(eventAt);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    {
      map['entities'] = Variable<String>(
        $SavedItemsTable.$converterentities.toSql(entities),
      );
    }
    {
      map['available_actions'] = Variable<String>(
        $SavedItemsTable.$converteravailableActions.toSql(availableActions),
      );
    }
    if (!nullToAbsent || cloudPreviewPath != null) {
      map['cloud_preview_path'] = Variable<String>(cloudPreviewPath);
    }
    if (!nullToAbsent || imageHash != null) {
      map['image_hash'] = Variable<String>(imageHash);
    }
    {
      map['analysis_status'] = Variable<String>(
        $SavedItemsTable.$converteranalysisStatus.toSql(analysisStatus),
      );
    }
    map['analysis_version'] = Variable<int>(analysisVersion);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || localAssetId != null) {
      map['local_asset_id'] = Variable<String>(localAssetId);
    }
    map['original_available'] = Variable<bool>(originalAvailable);
    if (!nullToAbsent || previewCachePath != null) {
      map['preview_cache_path'] = Variable<String>(previewCachePath);
    }
    {
      map['sync_status'] = Variable<String>(
        $SavedItemsTable.$convertersyncStatus.toSql(syncStatus),
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
    return map;
  }

  SavedItemsCompanion toCompanion(bool nullToAbsent) {
    return SavedItemsCompanion(
      id: Value(id),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      title: Value(title),
      summary: Value(summary),
      category: Value(category),
      subtype: subtype == null && nullToAbsent
          ? const Value.absent()
          : Value(subtype),
      intent: intent == null && nullToAbsent
          ? const Value.absent()
          : Value(intent),
      status: Value(status),
      favorite: Value(favorite),
      capturedAt: Value(capturedAt),
      eventAt: eventAt == null && nullToAbsent
          ? const Value.absent()
          : Value(eventAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      entities: Value(entities),
      availableActions: Value(availableActions),
      cloudPreviewPath: cloudPreviewPath == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudPreviewPath),
      imageHash: imageHash == null && nullToAbsent
          ? const Value.absent()
          : Value(imageHash),
      analysisStatus: Value(analysisStatus),
      analysisVersion: Value(analysisVersion),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localAssetId: localAssetId == null && nullToAbsent
          ? const Value.absent()
          : Value(localAssetId),
      originalAvailable: Value(originalAvailable),
      previewCachePath: previewCachePath == null && nullToAbsent
          ? const Value.absent()
          : Value(previewCachePath),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      remoteServerUpdatedAt: remoteServerUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteServerUpdatedAt),
    );
  }

  factory SavedItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedItemRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String>(json['summary']),
      category: serializer.fromJson<SavedItemCategory>(json['category']),
      subtype: serializer.fromJson<String?>(json['subtype']),
      intent: serializer.fromJson<String?>(json['intent']),
      status: serializer.fromJson<SavedItemStatus>(json['status']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      eventAt: serializer.fromJson<DateTime?>(json['eventAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      location: serializer.fromJson<String?>(json['location']),
      entities: serializer.fromJson<Map<String, Object?>>(json['entities']),
      availableActions: serializer.fromJson<List<SavedItemActionType>>(
        json['availableActions'],
      ),
      cloudPreviewPath: serializer.fromJson<String?>(json['cloudPreviewPath']),
      imageHash: serializer.fromJson<String?>(json['imageHash']),
      analysisStatus: serializer.fromJson<AnalysisStatus>(
        json['analysisStatus'],
      ),
      analysisVersion: serializer.fromJson<int>(json['analysisVersion']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localAssetId: serializer.fromJson<String?>(json['localAssetId']),
      originalAvailable: serializer.fromJson<bool>(json['originalAvailable']),
      previewCachePath: serializer.fromJson<String?>(json['previewCachePath']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      remoteServerUpdatedAt: serializer.fromJson<DateTime?>(
        json['remoteServerUpdatedAt'],
      ),
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
      'category': serializer.toJson<SavedItemCategory>(category),
      'subtype': serializer.toJson<String?>(subtype),
      'intent': serializer.toJson<String?>(intent),
      'status': serializer.toJson<SavedItemStatus>(status),
      'favorite': serializer.toJson<bool>(favorite),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'eventAt': serializer.toJson<DateTime?>(eventAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'location': serializer.toJson<String?>(location),
      'entities': serializer.toJson<Map<String, Object?>>(entities),
      'availableActions': serializer.toJson<List<SavedItemActionType>>(
        availableActions,
      ),
      'cloudPreviewPath': serializer.toJson<String?>(cloudPreviewPath),
      'imageHash': serializer.toJson<String?>(imageHash),
      'analysisStatus': serializer.toJson<AnalysisStatus>(analysisStatus),
      'analysisVersion': serializer.toJson<int>(analysisVersion),
      'confidence': serializer.toJson<double?>(confidence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localAssetId': serializer.toJson<String?>(localAssetId),
      'originalAvailable': serializer.toJson<bool>(originalAvailable),
      'previewCachePath': serializer.toJson<String?>(previewCachePath),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'remoteServerUpdatedAt': serializer.toJson<DateTime?>(
        remoteServerUpdatedAt,
      ),
    };
  }

  SavedItemRow copyWith({
    String? id,
    Value<String?> ownerId = const Value.absent(),
    String? title,
    String? summary,
    SavedItemCategory? category,
    Value<String?> subtype = const Value.absent(),
    Value<String?> intent = const Value.absent(),
    SavedItemStatus? status,
    bool? favorite,
    DateTime? capturedAt,
    Value<DateTime?> eventAt = const Value.absent(),
    Value<DateTime?> expiresAt = const Value.absent(),
    Value<DateTime?> snoozedUntil = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Map<String, Object?>? entities,
    List<SavedItemActionType>? availableActions,
    Value<String?> cloudPreviewPath = const Value.absent(),
    Value<String?> imageHash = const Value.absent(),
    AnalysisStatus? analysisStatus,
    int? analysisVersion,
    Value<double?> confidence = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> localAssetId = const Value.absent(),
    bool? originalAvailable,
    Value<String?> previewCachePath = const Value.absent(),
    SyncStatus? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
  }) => SavedItemRow(
    id: id ?? this.id,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    title: title ?? this.title,
    summary: summary ?? this.summary,
    category: category ?? this.category,
    subtype: subtype.present ? subtype.value : this.subtype,
    intent: intent.present ? intent.value : this.intent,
    status: status ?? this.status,
    favorite: favorite ?? this.favorite,
    capturedAt: capturedAt ?? this.capturedAt,
    eventAt: eventAt.present ? eventAt.value : this.eventAt,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    location: location.present ? location.value : this.location,
    entities: entities ?? this.entities,
    availableActions: availableActions ?? this.availableActions,
    cloudPreviewPath: cloudPreviewPath.present
        ? cloudPreviewPath.value
        : this.cloudPreviewPath,
    imageHash: imageHash.present ? imageHash.value : this.imageHash,
    analysisStatus: analysisStatus ?? this.analysisStatus,
    analysisVersion: analysisVersion ?? this.analysisVersion,
    confidence: confidence.present ? confidence.value : this.confidence,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localAssetId: localAssetId.present ? localAssetId.value : this.localAssetId,
    originalAvailable: originalAvailable ?? this.originalAvailable,
    previewCachePath: previewCachePath.present
        ? previewCachePath.value
        : this.previewCachePath,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    remoteServerUpdatedAt: remoteServerUpdatedAt.present
        ? remoteServerUpdatedAt.value
        : this.remoteServerUpdatedAt,
  );
  SavedItemRow copyWithCompanion(SavedItemsCompanion data) {
    return SavedItemRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      category: data.category.present ? data.category.value : this.category,
      subtype: data.subtype.present ? data.subtype.value : this.subtype,
      intent: data.intent.present ? data.intent.value : this.intent,
      status: data.status.present ? data.status.value : this.status,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      eventAt: data.eventAt.present ? data.eventAt.value : this.eventAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      location: data.location.present ? data.location.value : this.location,
      entities: data.entities.present ? data.entities.value : this.entities,
      availableActions: data.availableActions.present
          ? data.availableActions.value
          : this.availableActions,
      cloudPreviewPath: data.cloudPreviewPath.present
          ? data.cloudPreviewPath.value
          : this.cloudPreviewPath,
      imageHash: data.imageHash.present ? data.imageHash.value : this.imageHash,
      analysisStatus: data.analysisStatus.present
          ? data.analysisStatus.value
          : this.analysisStatus,
      analysisVersion: data.analysisVersion.present
          ? data.analysisVersion.value
          : this.analysisVersion,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localAssetId: data.localAssetId.present
          ? data.localAssetId.value
          : this.localAssetId,
      originalAvailable: data.originalAvailable.present
          ? data.originalAvailable.value
          : this.originalAvailable,
      previewCachePath: data.previewCachePath.present
          ? data.previewCachePath.value
          : this.previewCachePath,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      remoteServerUpdatedAt: data.remoteServerUpdatedAt.present
          ? data.remoteServerUpdatedAt.value
          : this.remoteServerUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedItemRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('category: $category, ')
          ..write('subtype: $subtype, ')
          ..write('intent: $intent, ')
          ..write('status: $status, ')
          ..write('favorite: $favorite, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('eventAt: $eventAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('location: $location, ')
          ..write('entities: $entities, ')
          ..write('availableActions: $availableActions, ')
          ..write('cloudPreviewPath: $cloudPreviewPath, ')
          ..write('imageHash: $imageHash, ')
          ..write('analysisStatus: $analysisStatus, ')
          ..write('analysisVersion: $analysisVersion, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localAssetId: $localAssetId, ')
          ..write('originalAvailable: $originalAvailable, ')
          ..write('previewCachePath: $previewCachePath, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ownerId,
    title,
    summary,
    category,
    subtype,
    intent,
    status,
    favorite,
    capturedAt,
    eventAt,
    expiresAt,
    snoozedUntil,
    location,
    entities,
    availableActions,
    cloudPreviewPath,
    imageHash,
    analysisStatus,
    analysisVersion,
    confidence,
    createdAt,
    updatedAt,
    deletedAt,
    localAssetId,
    originalAvailable,
    previewCachePath,
    syncStatus,
    lastSyncedAt,
    remoteServerUpdatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedItemRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.category == this.category &&
          other.subtype == this.subtype &&
          other.intent == this.intent &&
          other.status == this.status &&
          other.favorite == this.favorite &&
          other.capturedAt == this.capturedAt &&
          other.eventAt == this.eventAt &&
          other.expiresAt == this.expiresAt &&
          other.snoozedUntil == this.snoozedUntil &&
          other.location == this.location &&
          other.entities == this.entities &&
          other.availableActions == this.availableActions &&
          other.cloudPreviewPath == this.cloudPreviewPath &&
          other.imageHash == this.imageHash &&
          other.analysisStatus == this.analysisStatus &&
          other.analysisVersion == this.analysisVersion &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localAssetId == this.localAssetId &&
          other.originalAvailable == this.originalAvailable &&
          other.previewCachePath == this.previewCachePath &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.remoteServerUpdatedAt == this.remoteServerUpdatedAt);
}

class SavedItemsCompanion extends UpdateCompanion<SavedItemRow> {
  final Value<String> id;
  final Value<String?> ownerId;
  final Value<String> title;
  final Value<String> summary;
  final Value<SavedItemCategory> category;
  final Value<String?> subtype;
  final Value<String?> intent;
  final Value<SavedItemStatus> status;
  final Value<bool> favorite;
  final Value<DateTime> capturedAt;
  final Value<DateTime?> eventAt;
  final Value<DateTime?> expiresAt;
  final Value<DateTime?> snoozedUntil;
  final Value<String?> location;
  final Value<Map<String, Object?>> entities;
  final Value<List<SavedItemActionType>> availableActions;
  final Value<String?> cloudPreviewPath;
  final Value<String?> imageHash;
  final Value<AnalysisStatus> analysisStatus;
  final Value<int> analysisVersion;
  final Value<double?> confidence;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> localAssetId;
  final Value<bool> originalAvailable;
  final Value<String?> previewCachePath;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> remoteServerUpdatedAt;
  final Value<int> rowid;
  const SavedItemsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.category = const Value.absent(),
    this.subtype = const Value.absent(),
    this.intent = const Value.absent(),
    this.status = const Value.absent(),
    this.favorite = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.eventAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.location = const Value.absent(),
    this.entities = const Value.absent(),
    this.availableActions = const Value.absent(),
    this.cloudPreviewPath = const Value.absent(),
    this.imageHash = const Value.absent(),
    this.analysisStatus = const Value.absent(),
    this.analysisVersion = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localAssetId = const Value.absent(),
    this.originalAvailable = const Value.absent(),
    this.previewCachePath = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.remoteServerUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedItemsCompanion.insert({
    required String id,
    this.ownerId = const Value.absent(),
    required String title,
    this.summary = const Value.absent(),
    required SavedItemCategory category,
    this.subtype = const Value.absent(),
    this.intent = const Value.absent(),
    required SavedItemStatus status,
    this.favorite = const Value.absent(),
    required DateTime capturedAt,
    this.eventAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.location = const Value.absent(),
    this.entities = const Value.absent(),
    this.availableActions = const Value.absent(),
    this.cloudPreviewPath = const Value.absent(),
    this.imageHash = const Value.absent(),
    required AnalysisStatus analysisStatus,
    this.analysisVersion = const Value.absent(),
    this.confidence = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localAssetId = const Value.absent(),
    this.originalAvailable = const Value.absent(),
    this.previewCachePath = const Value.absent(),
    required SyncStatus syncStatus,
    this.lastSyncedAt = const Value.absent(),
    this.remoteServerUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       category = Value(category),
       status = Value(status),
       capturedAt = Value(capturedAt),
       analysisStatus = Value(analysisStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus);
  static Insertable<SavedItemRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? category,
    Expression<String>? subtype,
    Expression<String>? intent,
    Expression<String>? status,
    Expression<bool>? favorite,
    Expression<DateTime>? capturedAt,
    Expression<DateTime>? eventAt,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? snoozedUntil,
    Expression<String>? location,
    Expression<String>? entities,
    Expression<String>? availableActions,
    Expression<String>? cloudPreviewPath,
    Expression<String>? imageHash,
    Expression<String>? analysisStatus,
    Expression<int>? analysisVersion,
    Expression<double>? confidence,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? localAssetId,
    Expression<bool>? originalAvailable,
    Expression<String>? previewCachePath,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? remoteServerUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (category != null) 'category': category,
      if (subtype != null) 'subtype': subtype,
      if (intent != null) 'intent': intent,
      if (status != null) 'status': status,
      if (favorite != null) 'favorite': favorite,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (eventAt != null) 'event_at': eventAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (location != null) 'location': location,
      if (entities != null) 'entities': entities,
      if (availableActions != null) 'available_actions': availableActions,
      if (cloudPreviewPath != null) 'cloud_preview_path': cloudPreviewPath,
      if (imageHash != null) 'image_hash': imageHash,
      if (analysisStatus != null) 'analysis_status': analysisStatus,
      if (analysisVersion != null) 'analysis_version': analysisVersion,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localAssetId != null) 'local_asset_id': localAssetId,
      if (originalAvailable != null) 'original_available': originalAvailable,
      if (previewCachePath != null) 'preview_cache_path': previewCachePath,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (remoteServerUpdatedAt != null)
        'remote_server_updated_at': remoteServerUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedItemsCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerId,
    Value<String>? title,
    Value<String>? summary,
    Value<SavedItemCategory>? category,
    Value<String?>? subtype,
    Value<String?>? intent,
    Value<SavedItemStatus>? status,
    Value<bool>? favorite,
    Value<DateTime>? capturedAt,
    Value<DateTime?>? eventAt,
    Value<DateTime?>? expiresAt,
    Value<DateTime?>? snoozedUntil,
    Value<String?>? location,
    Value<Map<String, Object?>>? entities,
    Value<List<SavedItemActionType>>? availableActions,
    Value<String?>? cloudPreviewPath,
    Value<String?>? imageHash,
    Value<AnalysisStatus>? analysisStatus,
    Value<int>? analysisVersion,
    Value<double?>? confidence,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? localAssetId,
    Value<bool>? originalAvailable,
    Value<String?>? previewCachePath,
    Value<SyncStatus>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime?>? remoteServerUpdatedAt,
    Value<int>? rowid,
  }) {
    return SavedItemsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      subtype: subtype ?? this.subtype,
      intent: intent ?? this.intent,
      status: status ?? this.status,
      favorite: favorite ?? this.favorite,
      capturedAt: capturedAt ?? this.capturedAt,
      eventAt: eventAt ?? this.eventAt,
      expiresAt: expiresAt ?? this.expiresAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      location: location ?? this.location,
      entities: entities ?? this.entities,
      availableActions: availableActions ?? this.availableActions,
      cloudPreviewPath: cloudPreviewPath ?? this.cloudPreviewPath,
      imageHash: imageHash ?? this.imageHash,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      analysisVersion: analysisVersion ?? this.analysisVersion,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localAssetId: localAssetId ?? this.localAssetId,
      originalAvailable: originalAvailable ?? this.originalAvailable,
      previewCachePath: previewCachePath ?? this.previewCachePath,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      remoteServerUpdatedAt:
          remoteServerUpdatedAt ?? this.remoteServerUpdatedAt,
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
    if (category.present) {
      map['category'] = Variable<String>(
        $SavedItemsTable.$convertercategory.toSql(category.value),
      );
    }
    if (subtype.present) {
      map['subtype'] = Variable<String>(subtype.value);
    }
    if (intent.present) {
      map['intent'] = Variable<String>(intent.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SavedItemsTable.$converterstatus.toSql(status.value),
      );
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (eventAt.present) {
      map['event_at'] = Variable<DateTime>(eventAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (entities.present) {
      map['entities'] = Variable<String>(
        $SavedItemsTable.$converterentities.toSql(entities.value),
      );
    }
    if (availableActions.present) {
      map['available_actions'] = Variable<String>(
        $SavedItemsTable.$converteravailableActions.toSql(
          availableActions.value,
        ),
      );
    }
    if (cloudPreviewPath.present) {
      map['cloud_preview_path'] = Variable<String>(cloudPreviewPath.value);
    }
    if (imageHash.present) {
      map['image_hash'] = Variable<String>(imageHash.value);
    }
    if (analysisStatus.present) {
      map['analysis_status'] = Variable<String>(
        $SavedItemsTable.$converteranalysisStatus.toSql(analysisStatus.value),
      );
    }
    if (analysisVersion.present) {
      map['analysis_version'] = Variable<int>(analysisVersion.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
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
    if (localAssetId.present) {
      map['local_asset_id'] = Variable<String>(localAssetId.value);
    }
    if (originalAvailable.present) {
      map['original_available'] = Variable<bool>(originalAvailable.value);
    }
    if (previewCachePath.present) {
      map['preview_cache_path'] = Variable<String>(previewCachePath.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $SavedItemsTable.$convertersyncStatus.toSql(syncStatus.value),
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedItemsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('category: $category, ')
          ..write('subtype: $subtype, ')
          ..write('intent: $intent, ')
          ..write('status: $status, ')
          ..write('favorite: $favorite, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('eventAt: $eventAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('location: $location, ')
          ..write('entities: $entities, ')
          ..write('availableActions: $availableActions, ')
          ..write('cloudPreviewPath: $cloudPreviewPath, ')
          ..write('imageHash: $imageHash, ')
          ..write('analysisStatus: $analysisStatus, ')
          ..write('analysisVersion: $analysisVersion, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localAssetId: $localAssetId, ')
          ..write('originalAvailable: $originalAvailable, ')
          ..write('previewCachePath: $previewCachePath, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
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
  static const VerificationMeta _savedItemIdMeta = const VerificationMeta(
    'savedItemId',
  );
  @override
  late final GeneratedColumn<String> savedItemId = GeneratedColumn<String>(
    'saved_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saved_items (id)',
    ),
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
  @override
  late final GeneratedColumnWithTypeConverter<ReminderKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderKind>($RemindersTable.$converterkind);
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    savedItemId,
    remindAt,
    kind,
    completedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
    remoteServerUpdatedAt,
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
    if (data.containsKey('saved_item_id')) {
      context.handle(
        _savedItemIdMeta,
        savedItemId.isAcceptableOrUnknown(
          data['saved_item_id']!,
          _savedItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savedItemIdMeta);
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
      savedItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saved_item_id'],
      )!,
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remind_at'],
      )!,
      kind: $RemindersTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
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
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static TypeConverter<ReminderKind, String> $converterkind =
      const ReminderKindConverter();
  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String id;
  final String? ownerId;
  final String savedItemId;
  final DateTime remindAt;
  final ReminderKind kind;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime? remoteServerUpdatedAt;
  const ReminderRow({
    required this.id,
    this.ownerId,
    required this.savedItemId,
    required this.remindAt,
    required this.kind,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    this.lastSyncedAt,
    this.remoteServerUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['saved_item_id'] = Variable<String>(savedItemId);
    map['remind_at'] = Variable<DateTime>(remindAt);
    {
      map['kind'] = Variable<String>(
        $RemindersTable.$converterkind.toSql(kind),
      );
    }
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
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      savedItemId: Value(savedItemId),
      remindAt: Value(remindAt),
      kind: Value(kind),
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
      savedItemId: serializer.fromJson<String>(json['savedItemId']),
      remindAt: serializer.fromJson<DateTime>(json['remindAt']),
      kind: serializer.fromJson<ReminderKind>(json['kind']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      remoteServerUpdatedAt: serializer.fromJson<DateTime?>(
        json['remoteServerUpdatedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String?>(ownerId),
      'savedItemId': serializer.toJson<String>(savedItemId),
      'remindAt': serializer.toJson<DateTime>(remindAt),
      'kind': serializer.toJson<ReminderKind>(kind),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'remoteServerUpdatedAt': serializer.toJson<DateTime?>(
        remoteServerUpdatedAt,
      ),
    };
  }

  ReminderRow copyWith({
    String? id,
    Value<String?> ownerId = const Value.absent(),
    String? savedItemId,
    DateTime? remindAt,
    ReminderKind? kind,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
  }) => ReminderRow(
    id: id ?? this.id,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    savedItemId: savedItemId ?? this.savedItemId,
    remindAt: remindAt ?? this.remindAt,
    kind: kind ?? this.kind,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    remoteServerUpdatedAt: remoteServerUpdatedAt.present
        ? remoteServerUpdatedAt.value
        : this.remoteServerUpdatedAt,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      savedItemId: data.savedItemId.present
          ? data.savedItemId.value
          : this.savedItemId,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      kind: data.kind.present ? data.kind.value : this.kind,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('savedItemId: $savedItemId, ')
          ..write('remindAt: $remindAt, ')
          ..write('kind: $kind, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    savedItemId,
    remindAt,
    kind,
    completedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
    remoteServerUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.savedItemId == this.savedItemId &&
          other.remindAt == this.remindAt &&
          other.kind == this.kind &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.remoteServerUpdatedAt == this.remoteServerUpdatedAt);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<String?> ownerId;
  final Value<String> savedItemId;
  final Value<DateTime> remindAt;
  final Value<ReminderKind> kind;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> remoteServerUpdatedAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.savedItemId = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.remoteServerUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    this.ownerId = const Value.absent(),
    required String savedItemId,
    required DateTime remindAt,
    required ReminderKind kind,
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required SyncStatus syncStatus,
    this.lastSyncedAt = const Value.absent(),
    this.remoteServerUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       savedItemId = Value(savedItemId),
       remindAt = Value(remindAt),
       kind = Value(kind),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? savedItemId,
    Expression<DateTime>? remindAt,
    Expression<String>? kind,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? remoteServerUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (savedItemId != null) 'saved_item_id': savedItemId,
      if (remindAt != null) 'remind_at': remindAt,
      if (kind != null) 'kind': kind,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (remoteServerUpdatedAt != null)
        'remote_server_updated_at': remoteServerUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerId,
    Value<String>? savedItemId,
    Value<DateTime>? remindAt,
    Value<ReminderKind>? kind,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime?>? remoteServerUpdatedAt,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      savedItemId: savedItemId ?? this.savedItemId,
      remindAt: remindAt ?? this.remindAt,
      kind: kind ?? this.kind,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      remoteServerUpdatedAt:
          remoteServerUpdatedAt ?? this.remoteServerUpdatedAt,
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
    if (savedItemId.present) {
      map['saved_item_id'] = Variable<String>(savedItemId.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<DateTime>(remindAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $RemindersTable.$converterkind.toSql(kind.value),
      );
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
          ..write('savedItemId: $savedItemId, ')
          ..write('remindAt: $remindAt, ')
          ..write('kind: $kind, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('remoteServerUpdatedAt: $remoteServerUpdatedAt, ')
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

class $ScreenshotImportStatesTable extends ScreenshotImportStates
    with TableInfo<$ScreenshotImportStatesTable, ScreenshotImportStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreenshotImportStatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _initialImportCompletedMeta =
      const VerificationMeta('initialImportCompleted');
  @override
  late final GeneratedColumn<bool> initialImportCompleted =
      GeneratedColumn<bool>(
        'initial_import_completed',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("initial_import_completed" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _lastScanAtMeta = const VerificationMeta(
    'lastScanAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastScanAt = GeneratedColumn<DateTime>(
    'last_scan_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastKnownScreenshotCountMeta =
      const VerificationMeta('lastKnownScreenshotCount');
  @override
  late final GeneratedColumn<int> lastKnownScreenshotCount =
      GeneratedColumn<int>(
        'last_known_screenshot_count',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _lastSuccessfulScanAtMeta =
      const VerificationMeta('lastSuccessfulScanAt');
  @override
  late final GeneratedColumn<DateTime> lastSuccessfulScanAt =
      GeneratedColumn<DateTime>(
        'last_successful_scan_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _importScopeMeta = const VerificationMeta(
    'importScope',
  );
  @override
  late final GeneratedColumn<String> importScope = GeneratedColumn<String>(
    'import_scope',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scanVersionMeta = const VerificationMeta(
    'scanVersion',
  );
  @override
  late final GeneratedColumn<int> scanVersion = GeneratedColumn<int>(
    'scan_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastReconciledAtMeta = const VerificationMeta(
    'lastReconciledAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReconciledAt =
      GeneratedColumn<DateTime>(
        'last_reconciled_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    initialImportCompleted,
    lastScanAt,
    lastKnownScreenshotCount,
    lastSuccessfulScanAt,
    importScope,
    scanVersion,
    lastReconciledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screenshot_import_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreenshotImportStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('initial_import_completed')) {
      context.handle(
        _initialImportCompletedMeta,
        initialImportCompleted.isAcceptableOrUnknown(
          data['initial_import_completed']!,
          _initialImportCompletedMeta,
        ),
      );
    }
    if (data.containsKey('last_scan_at')) {
      context.handle(
        _lastScanAtMeta,
        lastScanAt.isAcceptableOrUnknown(
          data['last_scan_at']!,
          _lastScanAtMeta,
        ),
      );
    }
    if (data.containsKey('last_known_screenshot_count')) {
      context.handle(
        _lastKnownScreenshotCountMeta,
        lastKnownScreenshotCount.isAcceptableOrUnknown(
          data['last_known_screenshot_count']!,
          _lastKnownScreenshotCountMeta,
        ),
      );
    }
    if (data.containsKey('last_successful_scan_at')) {
      context.handle(
        _lastSuccessfulScanAtMeta,
        lastSuccessfulScanAt.isAcceptableOrUnknown(
          data['last_successful_scan_at']!,
          _lastSuccessfulScanAtMeta,
        ),
      );
    }
    if (data.containsKey('import_scope')) {
      context.handle(
        _importScopeMeta,
        importScope.isAcceptableOrUnknown(
          data['import_scope']!,
          _importScopeMeta,
        ),
      );
    }
    if (data.containsKey('scan_version')) {
      context.handle(
        _scanVersionMeta,
        scanVersion.isAcceptableOrUnknown(
          data['scan_version']!,
          _scanVersionMeta,
        ),
      );
    }
    if (data.containsKey('last_reconciled_at')) {
      context.handle(
        _lastReconciledAtMeta,
        lastReconciledAt.isAcceptableOrUnknown(
          data['last_reconciled_at']!,
          _lastReconciledAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScreenshotImportStateRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreenshotImportStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      initialImportCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}initial_import_completed'],
      )!,
      lastScanAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_scan_at'],
      ),
      lastKnownScreenshotCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_known_screenshot_count'],
      )!,
      lastSuccessfulScanAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_successful_scan_at'],
      ),
      importScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_scope'],
      ),
      scanVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scan_version'],
      )!,
      lastReconciledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reconciled_at'],
      ),
    );
  }

  @override
  $ScreenshotImportStatesTable createAlias(String alias) {
    return $ScreenshotImportStatesTable(attachedDatabase, alias);
  }
}

class ScreenshotImportStateRow extends DataClass
    implements Insertable<ScreenshotImportStateRow> {
  final String id;
  final bool initialImportCompleted;
  final DateTime? lastScanAt;
  final int lastKnownScreenshotCount;
  final DateTime? lastSuccessfulScanAt;
  final String? importScope;
  final int scanVersion;
  final DateTime? lastReconciledAt;
  const ScreenshotImportStateRow({
    required this.id,
    required this.initialImportCompleted,
    this.lastScanAt,
    required this.lastKnownScreenshotCount,
    this.lastSuccessfulScanAt,
    this.importScope,
    required this.scanVersion,
    this.lastReconciledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['initial_import_completed'] = Variable<bool>(initialImportCompleted);
    if (!nullToAbsent || lastScanAt != null) {
      map['last_scan_at'] = Variable<DateTime>(lastScanAt);
    }
    map['last_known_screenshot_count'] = Variable<int>(
      lastKnownScreenshotCount,
    );
    if (!nullToAbsent || lastSuccessfulScanAt != null) {
      map['last_successful_scan_at'] = Variable<DateTime>(lastSuccessfulScanAt);
    }
    if (!nullToAbsent || importScope != null) {
      map['import_scope'] = Variable<String>(importScope);
    }
    map['scan_version'] = Variable<int>(scanVersion);
    if (!nullToAbsent || lastReconciledAt != null) {
      map['last_reconciled_at'] = Variable<DateTime>(lastReconciledAt);
    }
    return map;
  }

  ScreenshotImportStatesCompanion toCompanion(bool nullToAbsent) {
    return ScreenshotImportStatesCompanion(
      id: Value(id),
      initialImportCompleted: Value(initialImportCompleted),
      lastScanAt: lastScanAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScanAt),
      lastKnownScreenshotCount: Value(lastKnownScreenshotCount),
      lastSuccessfulScanAt: lastSuccessfulScanAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessfulScanAt),
      importScope: importScope == null && nullToAbsent
          ? const Value.absent()
          : Value(importScope),
      scanVersion: Value(scanVersion),
      lastReconciledAt: lastReconciledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReconciledAt),
    );
  }

  factory ScreenshotImportStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreenshotImportStateRow(
      id: serializer.fromJson<String>(json['id']),
      initialImportCompleted: serializer.fromJson<bool>(
        json['initialImportCompleted'],
      ),
      lastScanAt: serializer.fromJson<DateTime?>(json['lastScanAt']),
      lastKnownScreenshotCount: serializer.fromJson<int>(
        json['lastKnownScreenshotCount'],
      ),
      lastSuccessfulScanAt: serializer.fromJson<DateTime?>(
        json['lastSuccessfulScanAt'],
      ),
      importScope: serializer.fromJson<String?>(json['importScope']),
      scanVersion: serializer.fromJson<int>(json['scanVersion']),
      lastReconciledAt: serializer.fromJson<DateTime?>(
        json['lastReconciledAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'initialImportCompleted': serializer.toJson<bool>(initialImportCompleted),
      'lastScanAt': serializer.toJson<DateTime?>(lastScanAt),
      'lastKnownScreenshotCount': serializer.toJson<int>(
        lastKnownScreenshotCount,
      ),
      'lastSuccessfulScanAt': serializer.toJson<DateTime?>(
        lastSuccessfulScanAt,
      ),
      'importScope': serializer.toJson<String?>(importScope),
      'scanVersion': serializer.toJson<int>(scanVersion),
      'lastReconciledAt': serializer.toJson<DateTime?>(lastReconciledAt),
    };
  }

  ScreenshotImportStateRow copyWith({
    String? id,
    bool? initialImportCompleted,
    Value<DateTime?> lastScanAt = const Value.absent(),
    int? lastKnownScreenshotCount,
    Value<DateTime?> lastSuccessfulScanAt = const Value.absent(),
    Value<String?> importScope = const Value.absent(),
    int? scanVersion,
    Value<DateTime?> lastReconciledAt = const Value.absent(),
  }) => ScreenshotImportStateRow(
    id: id ?? this.id,
    initialImportCompleted:
        initialImportCompleted ?? this.initialImportCompleted,
    lastScanAt: lastScanAt.present ? lastScanAt.value : this.lastScanAt,
    lastKnownScreenshotCount:
        lastKnownScreenshotCount ?? this.lastKnownScreenshotCount,
    lastSuccessfulScanAt: lastSuccessfulScanAt.present
        ? lastSuccessfulScanAt.value
        : this.lastSuccessfulScanAt,
    importScope: importScope.present ? importScope.value : this.importScope,
    scanVersion: scanVersion ?? this.scanVersion,
    lastReconciledAt: lastReconciledAt.present
        ? lastReconciledAt.value
        : this.lastReconciledAt,
  );
  ScreenshotImportStateRow copyWithCompanion(
    ScreenshotImportStatesCompanion data,
  ) {
    return ScreenshotImportStateRow(
      id: data.id.present ? data.id.value : this.id,
      initialImportCompleted: data.initialImportCompleted.present
          ? data.initialImportCompleted.value
          : this.initialImportCompleted,
      lastScanAt: data.lastScanAt.present
          ? data.lastScanAt.value
          : this.lastScanAt,
      lastKnownScreenshotCount: data.lastKnownScreenshotCount.present
          ? data.lastKnownScreenshotCount.value
          : this.lastKnownScreenshotCount,
      lastSuccessfulScanAt: data.lastSuccessfulScanAt.present
          ? data.lastSuccessfulScanAt.value
          : this.lastSuccessfulScanAt,
      importScope: data.importScope.present
          ? data.importScope.value
          : this.importScope,
      scanVersion: data.scanVersion.present
          ? data.scanVersion.value
          : this.scanVersion,
      lastReconciledAt: data.lastReconciledAt.present
          ? data.lastReconciledAt.value
          : this.lastReconciledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreenshotImportStateRow(')
          ..write('id: $id, ')
          ..write('initialImportCompleted: $initialImportCompleted, ')
          ..write('lastScanAt: $lastScanAt, ')
          ..write('lastKnownScreenshotCount: $lastKnownScreenshotCount, ')
          ..write('lastSuccessfulScanAt: $lastSuccessfulScanAt, ')
          ..write('importScope: $importScope, ')
          ..write('scanVersion: $scanVersion, ')
          ..write('lastReconciledAt: $lastReconciledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    initialImportCompleted,
    lastScanAt,
    lastKnownScreenshotCount,
    lastSuccessfulScanAt,
    importScope,
    scanVersion,
    lastReconciledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreenshotImportStateRow &&
          other.id == this.id &&
          other.initialImportCompleted == this.initialImportCompleted &&
          other.lastScanAt == this.lastScanAt &&
          other.lastKnownScreenshotCount == this.lastKnownScreenshotCount &&
          other.lastSuccessfulScanAt == this.lastSuccessfulScanAt &&
          other.importScope == this.importScope &&
          other.scanVersion == this.scanVersion &&
          other.lastReconciledAt == this.lastReconciledAt);
}

class ScreenshotImportStatesCompanion
    extends UpdateCompanion<ScreenshotImportStateRow> {
  final Value<String> id;
  final Value<bool> initialImportCompleted;
  final Value<DateTime?> lastScanAt;
  final Value<int> lastKnownScreenshotCount;
  final Value<DateTime?> lastSuccessfulScanAt;
  final Value<String?> importScope;
  final Value<int> scanVersion;
  final Value<DateTime?> lastReconciledAt;
  final Value<int> rowid;
  const ScreenshotImportStatesCompanion({
    this.id = const Value.absent(),
    this.initialImportCompleted = const Value.absent(),
    this.lastScanAt = const Value.absent(),
    this.lastKnownScreenshotCount = const Value.absent(),
    this.lastSuccessfulScanAt = const Value.absent(),
    this.importScope = const Value.absent(),
    this.scanVersion = const Value.absent(),
    this.lastReconciledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScreenshotImportStatesCompanion.insert({
    this.id = const Value.absent(),
    this.initialImportCompleted = const Value.absent(),
    this.lastScanAt = const Value.absent(),
    this.lastKnownScreenshotCount = const Value.absent(),
    this.lastSuccessfulScanAt = const Value.absent(),
    this.importScope = const Value.absent(),
    this.scanVersion = const Value.absent(),
    this.lastReconciledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<ScreenshotImportStateRow> custom({
    Expression<String>? id,
    Expression<bool>? initialImportCompleted,
    Expression<DateTime>? lastScanAt,
    Expression<int>? lastKnownScreenshotCount,
    Expression<DateTime>? lastSuccessfulScanAt,
    Expression<String>? importScope,
    Expression<int>? scanVersion,
    Expression<DateTime>? lastReconciledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (initialImportCompleted != null)
        'initial_import_completed': initialImportCompleted,
      if (lastScanAt != null) 'last_scan_at': lastScanAt,
      if (lastKnownScreenshotCount != null)
        'last_known_screenshot_count': lastKnownScreenshotCount,
      if (lastSuccessfulScanAt != null)
        'last_successful_scan_at': lastSuccessfulScanAt,
      if (importScope != null) 'import_scope': importScope,
      if (scanVersion != null) 'scan_version': scanVersion,
      if (lastReconciledAt != null) 'last_reconciled_at': lastReconciledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScreenshotImportStatesCompanion copyWith({
    Value<String>? id,
    Value<bool>? initialImportCompleted,
    Value<DateTime?>? lastScanAt,
    Value<int>? lastKnownScreenshotCount,
    Value<DateTime?>? lastSuccessfulScanAt,
    Value<String?>? importScope,
    Value<int>? scanVersion,
    Value<DateTime?>? lastReconciledAt,
    Value<int>? rowid,
  }) {
    return ScreenshotImportStatesCompanion(
      id: id ?? this.id,
      initialImportCompleted:
          initialImportCompleted ?? this.initialImportCompleted,
      lastScanAt: lastScanAt ?? this.lastScanAt,
      lastKnownScreenshotCount:
          lastKnownScreenshotCount ?? this.lastKnownScreenshotCount,
      lastSuccessfulScanAt: lastSuccessfulScanAt ?? this.lastSuccessfulScanAt,
      importScope: importScope ?? this.importScope,
      scanVersion: scanVersion ?? this.scanVersion,
      lastReconciledAt: lastReconciledAt ?? this.lastReconciledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (initialImportCompleted.present) {
      map['initial_import_completed'] = Variable<bool>(
        initialImportCompleted.value,
      );
    }
    if (lastScanAt.present) {
      map['last_scan_at'] = Variable<DateTime>(lastScanAt.value);
    }
    if (lastKnownScreenshotCount.present) {
      map['last_known_screenshot_count'] = Variable<int>(
        lastKnownScreenshotCount.value,
      );
    }
    if (lastSuccessfulScanAt.present) {
      map['last_successful_scan_at'] = Variable<DateTime>(
        lastSuccessfulScanAt.value,
      );
    }
    if (importScope.present) {
      map['import_scope'] = Variable<String>(importScope.value);
    }
    if (scanVersion.present) {
      map['scan_version'] = Variable<int>(scanVersion.value);
    }
    if (lastReconciledAt.present) {
      map['last_reconciled_at'] = Variable<DateTime>(lastReconciledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreenshotImportStatesCompanion(')
          ..write('id: $id, ')
          ..write('initialImportCompleted: $initialImportCompleted, ')
          ..write('lastScanAt: $lastScanAt, ')
          ..write('lastKnownScreenshotCount: $lastKnownScreenshotCount, ')
          ..write('lastSuccessfulScanAt: $lastSuccessfulScanAt, ')
          ..write('importScope: $importScope, ')
          ..write('scanVersion: $scanVersion, ')
          ..write('lastReconciledAt: $lastReconciledAt, ')
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
  static const VerificationMeta _lastSavedItemsCursorMeta =
      const VerificationMeta('lastSavedItemsCursor');
  @override
  late final GeneratedColumn<DateTime> lastSavedItemsCursor =
      GeneratedColumn<DateTime>(
        'last_saved_items_cursor',
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
    lastSavedItemsCursor,
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
    if (data.containsKey('last_saved_items_cursor')) {
      context.handle(
        _lastSavedItemsCursorMeta,
        lastSavedItemsCursor.isAcceptableOrUnknown(
          data['last_saved_items_cursor']!,
          _lastSavedItemsCursorMeta,
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
      lastSavedItemsCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_saved_items_cursor'],
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
  final DateTime? lastSavedItemsCursor;
  final DateTime? lastRemindersCursor;
  final DateTime? lastSuccessfulSyncAt;
  final DateTime? lastAttemptAt;
  final String? lastError;
  const CloudSyncStateRow({
    required this.id,
    required this.installationId,
    this.userId,
    this.lastSavedItemsCursor,
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
    if (!nullToAbsent || lastSavedItemsCursor != null) {
      map['last_saved_items_cursor'] = Variable<DateTime>(lastSavedItemsCursor);
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
      lastSavedItemsCursor: lastSavedItemsCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSavedItemsCursor),
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
      lastSavedItemsCursor: serializer.fromJson<DateTime?>(
        json['lastSavedItemsCursor'],
      ),
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
      'lastSavedItemsCursor': serializer.toJson<DateTime?>(
        lastSavedItemsCursor,
      ),
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
    Value<DateTime?> lastSavedItemsCursor = const Value.absent(),
    Value<DateTime?> lastRemindersCursor = const Value.absent(),
    Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => CloudSyncStateRow(
    id: id ?? this.id,
    installationId: installationId ?? this.installationId,
    userId: userId.present ? userId.value : this.userId,
    lastSavedItemsCursor: lastSavedItemsCursor.present
        ? lastSavedItemsCursor.value
        : this.lastSavedItemsCursor,
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
      lastSavedItemsCursor: data.lastSavedItemsCursor.present
          ? data.lastSavedItemsCursor.value
          : this.lastSavedItemsCursor,
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
          ..write('lastSavedItemsCursor: $lastSavedItemsCursor, ')
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
    lastSavedItemsCursor,
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
          other.lastSavedItemsCursor == this.lastSavedItemsCursor &&
          other.lastRemindersCursor == this.lastRemindersCursor &&
          other.lastSuccessfulSyncAt == this.lastSuccessfulSyncAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.lastError == this.lastError);
}

class CloudSyncStatesCompanion extends UpdateCompanion<CloudSyncStateRow> {
  final Value<String> id;
  final Value<String> installationId;
  final Value<String?> userId;
  final Value<DateTime?> lastSavedItemsCursor;
  final Value<DateTime?> lastRemindersCursor;
  final Value<DateTime?> lastSuccessfulSyncAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const CloudSyncStatesCompanion({
    this.id = const Value.absent(),
    this.installationId = const Value.absent(),
    this.userId = const Value.absent(),
    this.lastSavedItemsCursor = const Value.absent(),
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
    this.lastSavedItemsCursor = const Value.absent(),
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
    Expression<DateTime>? lastSavedItemsCursor,
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
      if (lastSavedItemsCursor != null)
        'last_saved_items_cursor': lastSavedItemsCursor,
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
    Value<DateTime?>? lastSavedItemsCursor,
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
      lastSavedItemsCursor: lastSavedItemsCursor ?? this.lastSavedItemsCursor,
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
    if (lastSavedItemsCursor.present) {
      map['last_saved_items_cursor'] = Variable<DateTime>(
        lastSavedItemsCursor.value,
      );
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
          ..write('lastSavedItemsCursor: $lastSavedItemsCursor, ')
          ..write('lastRemindersCursor: $lastRemindersCursor, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreviewTransferJobsTable extends PreviewTransferJobs
    with TableInfo<$PreviewTransferJobsTable, PreviewTransferJobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreviewTransferJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _savedItemIdMeta = const VerificationMeta(
    'savedItemId',
  );
  @override
  late final GeneratedColumn<String> savedItemId = GeneratedColumn<String>(
    'saved_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saved_items (id) ON DELETE CASCADE',
    ),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
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
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    savedItemId,
    operation,
    state,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preview_transfer_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreviewTransferJobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('saved_item_id')) {
      context.handle(
        _savedItemIdMeta,
        savedItemId.isAcceptableOrUnknown(
          data['saved_item_id']!,
          _savedItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savedItemIdMeta);
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
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
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
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {savedItemId};
  @override
  PreviewTransferJobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreviewTransferJobRow(
      savedItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saved_item_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PreviewTransferJobsTable createAlias(String alias) {
    return $PreviewTransferJobsTable(attachedDatabase, alias);
  }
}

class PreviewTransferJobRow extends DataClass
    implements Insertable<PreviewTransferJobRow> {
  final String savedItemId;
  final String operation;
  final String state;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final String? lastErrorCode;
  final DateTime createdAt;
  const PreviewTransferJobRow({
    required this.savedItemId,
    required this.operation,
    required this.state,
    required this.attemptCount,
    this.nextAttemptAt,
    this.lastErrorCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['saved_item_id'] = Variable<String>(savedItemId);
    map['operation'] = Variable<String>(operation);
    map['state'] = Variable<String>(state);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PreviewTransferJobsCompanion toCompanion(bool nullToAbsent) {
    return PreviewTransferJobsCompanion(
      savedItemId: Value(savedItemId),
      operation: Value(operation),
      state: Value(state),
      attemptCount: Value(attemptCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      createdAt: Value(createdAt),
    );
  }

  factory PreviewTransferJobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreviewTransferJobRow(
      savedItemId: serializer.fromJson<String>(json['savedItemId']),
      operation: serializer.fromJson<String>(json['operation']),
      state: serializer.fromJson<String>(json['state']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'savedItemId': serializer.toJson<String>(savedItemId),
      'operation': serializer.toJson<String>(operation),
      'state': serializer.toJson<String>(state),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PreviewTransferJobRow copyWith({
    String? savedItemId,
    String? operation,
    String? state,
    int? attemptCount,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
    DateTime? createdAt,
  }) => PreviewTransferJobRow(
    savedItemId: savedItemId ?? this.savedItemId,
    operation: operation ?? this.operation,
    state: state ?? this.state,
    attemptCount: attemptCount ?? this.attemptCount,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    createdAt: createdAt ?? this.createdAt,
  );
  PreviewTransferJobRow copyWithCompanion(PreviewTransferJobsCompanion data) {
    return PreviewTransferJobRow(
      savedItemId: data.savedItemId.present
          ? data.savedItemId.value
          : this.savedItemId,
      operation: data.operation.present ? data.operation.value : this.operation,
      state: data.state.present ? data.state.value : this.state,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreviewTransferJobRow(')
          ..write('savedItemId: $savedItemId, ')
          ..write('operation: $operation, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    savedItemId,
    operation,
    state,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreviewTransferJobRow &&
          other.savedItemId == this.savedItemId &&
          other.operation == this.operation &&
          other.state == this.state &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastErrorCode == this.lastErrorCode &&
          other.createdAt == this.createdAt);
}

class PreviewTransferJobsCompanion
    extends UpdateCompanion<PreviewTransferJobRow> {
  final Value<String> savedItemId;
  final Value<String> operation;
  final Value<String> state;
  final Value<int> attemptCount;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastErrorCode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PreviewTransferJobsCompanion({
    this.savedItemId = const Value.absent(),
    this.operation = const Value.absent(),
    this.state = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreviewTransferJobsCompanion.insert({
    required String savedItemId,
    required String operation,
    required String state,
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : savedItemId = Value(savedItemId),
       operation = Value(operation),
       state = Value(state),
       createdAt = Value(createdAt);
  static Insertable<PreviewTransferJobRow> custom({
    Expression<String>? savedItemId,
    Expression<String>? operation,
    Expression<String>? state,
    Expression<int>? attemptCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastErrorCode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (savedItemId != null) 'saved_item_id': savedItemId,
      if (operation != null) 'operation': operation,
      if (state != null) 'state': state,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreviewTransferJobsCompanion copyWith({
    Value<String>? savedItemId,
    Value<String>? operation,
    Value<String>? state,
    Value<int>? attemptCount,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastErrorCode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PreviewTransferJobsCompanion(
      savedItemId: savedItemId ?? this.savedItemId,
      operation: operation ?? this.operation,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (savedItemId.present) {
      map['saved_item_id'] = Variable<String>(savedItemId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreviewTransferJobsCompanion(')
          ..write('savedItemId: $savedItemId, ')
          ..write('operation: $operation, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SavedItemsTable savedItems = $SavedItemsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $ScreenshotImportStatesTable screenshotImportStates =
      $ScreenshotImportStatesTable(this);
  late final $CloudSyncStatesTable cloudSyncStates = $CloudSyncStatesTable(
    this,
  );
  late final $PreviewTransferJobsTable previewTransferJobs =
      $PreviewTransferJobsTable(this);
  late final Index savedItemsStatusIdx = Index(
    'saved_items_status_idx',
    'CREATE INDEX saved_items_status_idx ON saved_items (status)',
  );
  late final Index savedItemsCategoryIdx = Index(
    'saved_items_category_idx',
    'CREATE INDEX saved_items_category_idx ON saved_items (category)',
  );
  late final Index savedItemsCapturedAtIdx = Index(
    'saved_items_captured_at_idx',
    'CREATE INDEX saved_items_captured_at_idx ON saved_items (captured_at)',
  );
  late final Index savedItemsUpdatedAtIdx = Index(
    'saved_items_updated_at_idx',
    'CREATE INDEX saved_items_updated_at_idx ON saved_items (updated_at)',
  );
  late final Index savedItemsDeletedAtIdx = Index(
    'saved_items_deleted_at_idx',
    'CREATE INDEX saved_items_deleted_at_idx ON saved_items (deleted_at)',
  );
  late final Index savedItemsLocalAssetIdUniqueIdx = Index(
    'saved_items_local_asset_id_unique_idx',
    'CREATE UNIQUE INDEX saved_items_local_asset_id_unique_idx ON saved_items (local_asset_id)',
  );
  late final Index remindersSavedItemIdx = Index(
    'reminders_saved_item_idx',
    'CREATE INDEX reminders_saved_item_idx ON reminders (saved_item_id)',
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
  late final Index previewTransferJobsDueIdx = Index(
    'preview_transfer_jobs_due_idx',
    'CREATE INDEX preview_transfer_jobs_due_idx ON preview_transfer_jobs (state, next_attempt_at, created_at)',
  );
  late final SavedItemsDao savedItemsDao = SavedItemsDao(this as AppDatabase);
  late final RemindersDao remindersDao = RemindersDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  late final ScreenshotImportStateDao screenshotImportStateDao =
      ScreenshotImportStateDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    savedItems,
    reminders,
    syncQueue,
    screenshotImportStates,
    cloudSyncStates,
    previewTransferJobs,
    savedItemsStatusIdx,
    savedItemsCategoryIdx,
    savedItemsCapturedAtIdx,
    savedItemsUpdatedAtIdx,
    savedItemsDeletedAtIdx,
    savedItemsLocalAssetIdUniqueIdx,
    remindersSavedItemIdx,
    remindersRemindAtIdx,
    remindersDeletedAtIdx,
    syncQueueCreatedAtIdx,
    syncQueueEntityIdx,
    previewTransferJobsDueIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'saved_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('preview_transfer_jobs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SavedItemsTableCreateCompanionBuilder = SavedItemsCompanion Function({
  required String id,
  Value<String?> ownerId,
  required String title,
  Value<String> summary,
  required SavedItemCategory category,
  Value<String?> subtype,
  Value<String?> intent,
  required SavedItemStatus status,
  Value<bool> favorite,
  required DateTime capturedAt,
  Value<DateTime?> eventAt,
  Value<DateTime?> expiresAt,
  Value<DateTime?> snoozedUntil,
  Value<String?> location,
  Value<Map<String, Object?>> entities,
  Value<List<SavedItemActionType>> availableActions,
  Value<String?> cloudPreviewPath,
  Value<String?> imageHash,
  required AnalysisStatus analysisStatus,
  Value<int> analysisVersion,
  Value<double?> confidence,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> localAssetId,
  Value<bool> originalAvailable,
  Value<String?> previewCachePath,
  required SyncStatus syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<int> rowid,
});
typedef $$SavedItemsTableUpdateCompanionBuilder = SavedItemsCompanion Function({
  Value<String> id,
  Value<String?> ownerId,
  Value<String> title,
  Value<String> summary,
  Value<SavedItemCategory> category,
  Value<String?> subtype,
  Value<String?> intent,
  Value<SavedItemStatus> status,
  Value<bool> favorite,
  Value<DateTime> capturedAt,
  Value<DateTime?> eventAt,
  Value<DateTime?> expiresAt,
  Value<DateTime?> snoozedUntil,
  Value<String?> location,
  Value<Map<String, Object?>> entities,
  Value<List<SavedItemActionType>> availableActions,
  Value<String?> cloudPreviewPath,
  Value<String?> imageHash,
  Value<AnalysisStatus> analysisStatus,
  Value<int> analysisVersion,
  Value<double?> confidence,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> localAssetId,
  Value<bool> originalAvailable,
  Value<String?> previewCachePath,
  Value<SyncStatus> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<int> rowid,
});

final class $$SavedItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SavedItemsTable, SavedItemRow> {
  $$SavedItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'saved_items__id__reminders__saved_item_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.savedItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PreviewTransferJobsTable,
    List<PreviewTransferJobRow>
  >
  _previewTransferJobsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.previewTransferJobs,
        aliasName: 'saved_items__id__preview_transfer_jobs__saved_item_id',
      );

  $$PreviewTransferJobsTableProcessedTableManager get previewTransferJobsRefs {
    final manager = $$PreviewTransferJobsTableTableManager(
      $_db,
      $_db.previewTransferJobs,
    ).filter((f) => f.savedItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _previewTransferJobsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SavedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<SavedItemCategory, SavedItemCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intent => $composableBuilder(
    column: $table.intent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SavedItemStatus, SavedItemStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventAt => $composableBuilder(
    column: $table.eventAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, Object?>,
    Map<String, Object>,
    String
  >
  get entities => $composableBuilder(
    column: $table.entities,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<SavedItemActionType>,
    List<SavedItemActionType>,
    String
  >
  get availableActions => $composableBuilder(
    column: $table.availableActions,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get cloudPreviewPath => $composableBuilder(
    column: $table.cloudPreviewPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageHash => $composableBuilder(
    column: $table.imageHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AnalysisStatus, AnalysisStatus, String>
  get analysisStatus => $composableBuilder(
    column: $table.analysisStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get analysisVersion => $composableBuilder(
    column: $table.analysisVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
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

  ColumnFilters<String> get localAssetId => $composableBuilder(
    column: $table.localAssetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get originalAvailable => $composableBuilder(
    column: $table.originalAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previewCachePath => $composableBuilder(
    column: $table.previewCachePath,
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

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.savedItemId,
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

  Expression<bool> previewTransferJobsRefs(
    Expression<bool> Function($$PreviewTransferJobsTableFilterComposer f) f,
  ) {
    final $$PreviewTransferJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.previewTransferJobs,
      getReferencedColumn: (t) => t.savedItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreviewTransferJobsTableFilterComposer(
            $db: $db,
            $table: $db.previewTransferJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SavedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intent => $composableBuilder(
    column: $table.intent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventAt => $composableBuilder(
    column: $table.eventAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entities => $composableBuilder(
    column: $table.entities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get availableActions => $composableBuilder(
    column: $table.availableActions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudPreviewPath => $composableBuilder(
    column: $table.cloudPreviewPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageHash => $composableBuilder(
    column: $table.imageHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisStatus => $composableBuilder(
    column: $table.analysisStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get analysisVersion => $composableBuilder(
    column: $table.analysisVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
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

  ColumnOrderings<String> get localAssetId => $composableBuilder(
    column: $table.localAssetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get originalAvailable => $composableBuilder(
    column: $table.originalAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previewCachePath => $composableBuilder(
    column: $table.previewCachePath,
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
}

class $$SavedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<SavedItemCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subtype =>
      $composableBuilder(column: $table.subtype, builder: (column) => column);

  GeneratedColumn<String> get intent =>
      $composableBuilder(column: $table.intent, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SavedItemStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eventAt =>
      $composableBuilder(column: $table.eventAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, Object?>, String> get entities =>
      $composableBuilder(column: $table.entities, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<SavedItemActionType>, String>
  get availableActions => $composableBuilder(
    column: $table.availableActions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cloudPreviewPath => $composableBuilder(
    column: $table.cloudPreviewPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageHash =>
      $composableBuilder(column: $table.imageHash, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AnalysisStatus, String> get analysisStatus =>
      $composableBuilder(
        column: $table.analysisStatus,
        builder: (column) => column,
      );

  GeneratedColumn<int> get analysisVersion => $composableBuilder(
    column: $table.analysisVersion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get localAssetId => $composableBuilder(
    column: $table.localAssetId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get originalAvailable => $composableBuilder(
    column: $table.originalAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previewCachePath => $composableBuilder(
    column: $table.previewCachePath,
    builder: (column) => column,
  );

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

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.savedItemId,
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

  Expression<T> previewTransferJobsRefs<T extends Object>(
    Expression<T> Function($$PreviewTransferJobsTableAnnotationComposer a) f,
  ) {
    final $$PreviewTransferJobsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.previewTransferJobs,
          getReferencedColumn: (t) => t.savedItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PreviewTransferJobsTableAnnotationComposer(
                $db: $db,
                $table: $db.previewTransferJobs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SavedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedItemsTable,
          SavedItemRow,
          $$SavedItemsTableFilterComposer,
          $$SavedItemsTableOrderingComposer,
          $$SavedItemsTableAnnotationComposer,
          $$SavedItemsTableCreateCompanionBuilder,
          $$SavedItemsTableUpdateCompanionBuilder,
          (SavedItemRow, $$SavedItemsTableReferences),
          SavedItemRow,
          PrefetchHooks Function({
            bool remindersRefs,
            bool previewTransferJobsRefs,
          })
        > {
  $$SavedItemsTableTableManager(_$AppDatabase db, $SavedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<SavedItemCategory> category = const Value.absent(),
                Value<String?> subtype = const Value.absent(),
                Value<String?> intent = const Value.absent(),
                Value<SavedItemStatus> status = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<DateTime?> eventAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<Map<String, Object?>> entities = const Value.absent(),
                Value<List<SavedItemActionType>> availableActions =
                    const Value.absent(),
                Value<String?> cloudPreviewPath = const Value.absent(),
                Value<String?> imageHash = const Value.absent(),
                Value<AnalysisStatus> analysisStatus = const Value.absent(),
                Value<int> analysisVersion = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> localAssetId = const Value.absent(),
                Value<bool> originalAvailable = const Value.absent(),
                Value<String?> previewCachePath = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedItemsCompanion(
                id: id,
                ownerId: ownerId,
                title: title,
                summary: summary,
                category: category,
                subtype: subtype,
                intent: intent,
                status: status,
                favorite: favorite,
                capturedAt: capturedAt,
                eventAt: eventAt,
                expiresAt: expiresAt,
                snoozedUntil: snoozedUntil,
                location: location,
                entities: entities,
                availableActions: availableActions,
                cloudPreviewPath: cloudPreviewPath,
                imageHash: imageHash,
                analysisStatus: analysisStatus,
                analysisVersion: analysisVersion,
                confidence: confidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localAssetId: localAssetId,
                originalAvailable: originalAvailable,
                previewCachePath: previewCachePath,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ownerId = const Value.absent(),
                required String title,
                Value<String> summary = const Value.absent(),
                required SavedItemCategory category,
                Value<String?> subtype = const Value.absent(),
                Value<String?> intent = const Value.absent(),
                required SavedItemStatus status,
                Value<bool> favorite = const Value.absent(),
                required DateTime capturedAt,
                Value<DateTime?> eventAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<Map<String, Object?>> entities = const Value.absent(),
                Value<List<SavedItemActionType>> availableActions =
                    const Value.absent(),
                Value<String?> cloudPreviewPath = const Value.absent(),
                Value<String?> imageHash = const Value.absent(),
                required AnalysisStatus analysisStatus,
                Value<int> analysisVersion = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> localAssetId = const Value.absent(),
                Value<bool> originalAvailable = const Value.absent(),
                Value<String?> previewCachePath = const Value.absent(),
                required SyncStatus syncStatus,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedItemsCompanion.insert(
                id: id,
                ownerId: ownerId,
                title: title,
                summary: summary,
                category: category,
                subtype: subtype,
                intent: intent,
                status: status,
                favorite: favorite,
                capturedAt: capturedAt,
                eventAt: eventAt,
                expiresAt: expiresAt,
                snoozedUntil: snoozedUntil,
                location: location,
                entities: entities,
                availableActions: availableActions,
                cloudPreviewPath: cloudPreviewPath,
                imageHash: imageHash,
                analysisStatus: analysisStatus,
                analysisVersion: analysisVersion,
                confidence: confidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localAssetId: localAssetId,
                originalAvailable: originalAvailable,
                previewCachePath: previewCachePath,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({remindersRefs = false, previewTransferJobsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (remindersRefs) db.reminders,
                    if (previewTransferJobsRefs) db.previewTransferJobs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          SavedItemRow,
                          $SavedItemsTable,
                          ReminderRow
                        >(
                          currentTable: table,
                          referencedTable: $$SavedItemsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavedItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.savedItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (previewTransferJobsRefs)
                        await $_getPrefetchedData<
                          SavedItemRow,
                          $SavedItemsTable,
                          PreviewTransferJobRow
                        >(
                          currentTable: table,
                          referencedTable: $$SavedItemsTableReferences
                              ._previewTransferJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavedItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).previewTransferJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.savedItemId == item.id,
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

typedef $$SavedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedItemsTable,
      SavedItemRow,
      $$SavedItemsTableFilterComposer,
      $$SavedItemsTableOrderingComposer,
      $$SavedItemsTableAnnotationComposer,
      $$SavedItemsTableCreateCompanionBuilder,
      $$SavedItemsTableUpdateCompanionBuilder,
      (SavedItemRow, $$SavedItemsTableReferences),
      SavedItemRow,
      PrefetchHooks Function({bool remindersRefs, bool previewTransferJobsRefs})
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  Value<String?> ownerId,
  required String savedItemId,
  required DateTime remindAt,
  required ReminderKind kind,
  Value<DateTime?> completedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required SyncStatus syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<String?> ownerId,
  Value<String> savedItemId,
  Value<DateTime> remindAt,
  Value<ReminderKind> kind,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<SyncStatus> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> remoteServerUpdatedAt,
  Value<int> rowid,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SavedItemsTable _savedItemIdTable(_$AppDatabase db) =>
      db.savedItems.createAlias('reminders__saved_item_id__saved_items__id');

  $$SavedItemsTableProcessedTableManager get savedItemId {
    final $_column = $_itemColumn<String>('saved_item_id')!;

    final manager = $$SavedItemsTableTableManager(
      $_db,
      $_db.savedItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savedItemIdTable($_db));
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

  ColumnFilters<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderKind, ReminderKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
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

  $$SavedItemsTableFilterComposer get savedItemId {
    final $$SavedItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedItemId,
      referencedTable: $db.savedItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedItemsTableFilterComposer(
            $db: $db,
            $table: $db.savedItems,
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

  ColumnOrderings<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
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

  $$SavedItemsTableOrderingComposer get savedItemId {
    final $$SavedItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedItemId,
      referencedTable: $db.savedItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedItemsTableOrderingComposer(
            $db: $db,
            $table: $db.savedItems,
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

  GeneratedColumn<DateTime> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

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

  $$SavedItemsTableAnnotationComposer get savedItemId {
    final $$SavedItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedItemId,
      referencedTable: $db.savedItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedItems,
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
          PrefetchHooks Function({bool savedItemId})
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
                Value<String> savedItemId = const Value.absent(),
                Value<DateTime> remindAt = const Value.absent(),
                Value<ReminderKind> kind = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                ownerId: ownerId,
                savedItemId: savedItemId,
                remindAt: remindAt,
                kind: kind,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ownerId = const Value.absent(),
                required String savedItemId,
                required DateTime remindAt,
                required ReminderKind kind,
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required SyncStatus syncStatus,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> remoteServerUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                ownerId: ownerId,
                savedItemId: savedItemId,
                remindAt: remindAt,
                kind: kind,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                remoteServerUpdatedAt: remoteServerUpdatedAt,
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
          prefetchHooksCallback: ({savedItemId = false}) {
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
                    if (savedItemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.savedItemId,
                        referencedTable: $$RemindersTableReferences
                            ._savedItemIdTable(db),
                        referencedColumn: $$RemindersTableReferences
                            ._savedItemIdTable(db)
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
      PrefetchHooks Function({bool savedItemId})
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
typedef $$ScreenshotImportStatesTableCreateCompanionBuilder =
    ScreenshotImportStatesCompanion Function({
      Value<String> id,
      Value<bool> initialImportCompleted,
      Value<DateTime?> lastScanAt,
      Value<int> lastKnownScreenshotCount,
      Value<DateTime?> lastSuccessfulScanAt,
      Value<String?> importScope,
      Value<int> scanVersion,
      Value<DateTime?> lastReconciledAt,
      Value<int> rowid,
    });
typedef $$ScreenshotImportStatesTableUpdateCompanionBuilder =
    ScreenshotImportStatesCompanion Function({
      Value<String> id,
      Value<bool> initialImportCompleted,
      Value<DateTime?> lastScanAt,
      Value<int> lastKnownScreenshotCount,
      Value<DateTime?> lastSuccessfulScanAt,
      Value<String?> importScope,
      Value<int> scanVersion,
      Value<DateTime?> lastReconciledAt,
      Value<int> rowid,
    });

class $$ScreenshotImportStatesTableFilterComposer
    extends Composer<_$AppDatabase, $ScreenshotImportStatesTable> {
  $$ScreenshotImportStatesTableFilterComposer({
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

  ColumnFilters<bool> get initialImportCompleted => $composableBuilder(
    column: $table.initialImportCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastScanAt => $composableBuilder(
    column: $table.lastScanAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastKnownScreenshotCount => $composableBuilder(
    column: $table.lastKnownScreenshotCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessfulScanAt => $composableBuilder(
    column: $table.lastSuccessfulScanAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importScope => $composableBuilder(
    column: $table.importScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scanVersion => $composableBuilder(
    column: $table.scanVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReconciledAt => $composableBuilder(
    column: $table.lastReconciledAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScreenshotImportStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScreenshotImportStatesTable> {
  $$ScreenshotImportStatesTableOrderingComposer({
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

  ColumnOrderings<bool> get initialImportCompleted => $composableBuilder(
    column: $table.initialImportCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastScanAt => $composableBuilder(
    column: $table.lastScanAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastKnownScreenshotCount => $composableBuilder(
    column: $table.lastKnownScreenshotCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessfulScanAt => $composableBuilder(
    column: $table.lastSuccessfulScanAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importScope => $composableBuilder(
    column: $table.importScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scanVersion => $composableBuilder(
    column: $table.scanVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReconciledAt => $composableBuilder(
    column: $table.lastReconciledAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScreenshotImportStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScreenshotImportStatesTable> {
  $$ScreenshotImportStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get initialImportCompleted => $composableBuilder(
    column: $table.initialImportCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastScanAt => $composableBuilder(
    column: $table.lastScanAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastKnownScreenshotCount => $composableBuilder(
    column: $table.lastKnownScreenshotCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessfulScanAt => $composableBuilder(
    column: $table.lastSuccessfulScanAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importScope => $composableBuilder(
    column: $table.importScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scanVersion => $composableBuilder(
    column: $table.scanVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReconciledAt => $composableBuilder(
    column: $table.lastReconciledAt,
    builder: (column) => column,
  );
}

class $$ScreenshotImportStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScreenshotImportStatesTable,
          ScreenshotImportStateRow,
          $$ScreenshotImportStatesTableFilterComposer,
          $$ScreenshotImportStatesTableOrderingComposer,
          $$ScreenshotImportStatesTableAnnotationComposer,
          $$ScreenshotImportStatesTableCreateCompanionBuilder,
          $$ScreenshotImportStatesTableUpdateCompanionBuilder,
          (
            ScreenshotImportStateRow,
            BaseReferences<
              _$AppDatabase,
              $ScreenshotImportStatesTable,
              ScreenshotImportStateRow
            >,
          ),
          ScreenshotImportStateRow,
          PrefetchHooks Function()
        > {
  $$ScreenshotImportStatesTableTableManager(
    _$AppDatabase db,
    $ScreenshotImportStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScreenshotImportStatesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScreenshotImportStatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScreenshotImportStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> initialImportCompleted = const Value.absent(),
                Value<DateTime?> lastScanAt = const Value.absent(),
                Value<int> lastKnownScreenshotCount = const Value.absent(),
                Value<DateTime?> lastSuccessfulScanAt = const Value.absent(),
                Value<String?> importScope = const Value.absent(),
                Value<int> scanVersion = const Value.absent(),
                Value<DateTime?> lastReconciledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreenshotImportStatesCompanion(
                id: id,
                initialImportCompleted: initialImportCompleted,
                lastScanAt: lastScanAt,
                lastKnownScreenshotCount: lastKnownScreenshotCount,
                lastSuccessfulScanAt: lastSuccessfulScanAt,
                importScope: importScope,
                scanVersion: scanVersion,
                lastReconciledAt: lastReconciledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> initialImportCompleted = const Value.absent(),
                Value<DateTime?> lastScanAt = const Value.absent(),
                Value<int> lastKnownScreenshotCount = const Value.absent(),
                Value<DateTime?> lastSuccessfulScanAt = const Value.absent(),
                Value<String?> importScope = const Value.absent(),
                Value<int> scanVersion = const Value.absent(),
                Value<DateTime?> lastReconciledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreenshotImportStatesCompanion.insert(
                id: id,
                initialImportCompleted: initialImportCompleted,
                lastScanAt: lastScanAt,
                lastKnownScreenshotCount: lastKnownScreenshotCount,
                lastSuccessfulScanAt: lastSuccessfulScanAt,
                importScope: importScope,
                scanVersion: scanVersion,
                lastReconciledAt: lastReconciledAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScreenshotImportStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScreenshotImportStatesTable,
      ScreenshotImportStateRow,
      $$ScreenshotImportStatesTableFilterComposer,
      $$ScreenshotImportStatesTableOrderingComposer,
      $$ScreenshotImportStatesTableAnnotationComposer,
      $$ScreenshotImportStatesTableCreateCompanionBuilder,
      $$ScreenshotImportStatesTableUpdateCompanionBuilder,
      (
        ScreenshotImportStateRow,
        BaseReferences<
          _$AppDatabase,
          $ScreenshotImportStatesTable,
          ScreenshotImportStateRow
        >,
      ),
      ScreenshotImportStateRow,
      PrefetchHooks Function()
    >;
typedef $$CloudSyncStatesTableCreateCompanionBuilder =
    CloudSyncStatesCompanion Function({
      Value<String> id,
      required String installationId,
      Value<String?> userId,
      Value<DateTime?> lastSavedItemsCursor,
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
      Value<DateTime?> lastSavedItemsCursor,
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

  ColumnFilters<DateTime> get lastSavedItemsCursor => $composableBuilder(
    column: $table.lastSavedItemsCursor,
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

  ColumnOrderings<DateTime> get lastSavedItemsCursor => $composableBuilder(
    column: $table.lastSavedItemsCursor,
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

  GeneratedColumn<DateTime> get lastSavedItemsCursor => $composableBuilder(
    column: $table.lastSavedItemsCursor,
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
                Value<DateTime?> lastSavedItemsCursor = const Value.absent(),
                Value<DateTime?> lastRemindersCursor = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CloudSyncStatesCompanion(
                id: id,
                installationId: installationId,
                userId: userId,
                lastSavedItemsCursor: lastSavedItemsCursor,
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
                Value<DateTime?> lastSavedItemsCursor = const Value.absent(),
                Value<DateTime?> lastRemindersCursor = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CloudSyncStatesCompanion.insert(
                id: id,
                installationId: installationId,
                userId: userId,
                lastSavedItemsCursor: lastSavedItemsCursor,
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
typedef $$PreviewTransferJobsTableCreateCompanionBuilder =
    PreviewTransferJobsCompanion Function({
      required String savedItemId,
      required String operation,
      required String state,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastErrorCode,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PreviewTransferJobsTableUpdateCompanionBuilder =
    PreviewTransferJobsCompanion Function({
      Value<String> savedItemId,
      Value<String> operation,
      Value<String> state,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastErrorCode,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PreviewTransferJobsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PreviewTransferJobsTable,
          PreviewTransferJobRow
        > {
  $$PreviewTransferJobsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavedItemsTable _savedItemIdTable(_$AppDatabase db) => db.savedItems
      .createAlias('preview_transfer_jobs__saved_item_id__saved_items__id');

  $$SavedItemsTableProcessedTableManager get savedItemId {
    final $_column = $_itemColumn<String>('saved_item_id')!;

    final manager = $$SavedItemsTableTableManager(
      $_db,
      $_db.savedItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savedItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PreviewTransferJobsTableFilterComposer
    extends Composer<_$AppDatabase, $PreviewTransferJobsTable> {
  $$PreviewTransferJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SavedItemsTableFilterComposer get savedItemId {
    final $$SavedItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedItemId,
      referencedTable: $db.savedItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedItemsTableFilterComposer(
            $db: $db,
            $table: $db.savedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreviewTransferJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $PreviewTransferJobsTable> {
  $$PreviewTransferJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavedItemsTableOrderingComposer get savedItemId {
    final $$SavedItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedItemId,
      referencedTable: $db.savedItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedItemsTableOrderingComposer(
            $db: $db,
            $table: $db.savedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreviewTransferJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreviewTransferJobsTable> {
  $$PreviewTransferJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SavedItemsTableAnnotationComposer get savedItemId {
    final $$SavedItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedItemId,
      referencedTable: $db.savedItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreviewTransferJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreviewTransferJobsTable,
          PreviewTransferJobRow,
          $$PreviewTransferJobsTableFilterComposer,
          $$PreviewTransferJobsTableOrderingComposer,
          $$PreviewTransferJobsTableAnnotationComposer,
          $$PreviewTransferJobsTableCreateCompanionBuilder,
          $$PreviewTransferJobsTableUpdateCompanionBuilder,
          (PreviewTransferJobRow, $$PreviewTransferJobsTableReferences),
          PreviewTransferJobRow,
          PrefetchHooks Function({bool savedItemId})
        > {
  $$PreviewTransferJobsTableTableManager(
    _$AppDatabase db,
    $PreviewTransferJobsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreviewTransferJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreviewTransferJobsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PreviewTransferJobsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> savedItemId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreviewTransferJobsCompanion(
                savedItemId: savedItemId,
                operation: operation,
                state: state,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String savedItemId,
                required String operation,
                required String state,
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PreviewTransferJobsCompanion.insert(
                savedItemId: savedItemId,
                operation: operation,
                state: state,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PreviewTransferJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({savedItemId = false}) {
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
                    if (savedItemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.savedItemId,
                        referencedTable: $$PreviewTransferJobsTableReferences
                            ._savedItemIdTable(db),
                        referencedColumn: $$PreviewTransferJobsTableReferences
                            ._savedItemIdTable(db)
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

typedef $$PreviewTransferJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreviewTransferJobsTable,
      PreviewTransferJobRow,
      $$PreviewTransferJobsTableFilterComposer,
      $$PreviewTransferJobsTableOrderingComposer,
      $$PreviewTransferJobsTableAnnotationComposer,
      $$PreviewTransferJobsTableCreateCompanionBuilder,
      $$PreviewTransferJobsTableUpdateCompanionBuilder,
      (PreviewTransferJobRow, $$PreviewTransferJobsTableReferences),
      PreviewTransferJobRow,
      PrefetchHooks Function({bool savedItemId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SavedItemsTableTableManager get savedItems =>
      $$SavedItemsTableTableManager(_db, _db.savedItems);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$ScreenshotImportStatesTableTableManager get screenshotImportStates =>
      $$ScreenshotImportStatesTableTableManager(
        _db,
        _db.screenshotImportStates,
      );
  $$CloudSyncStatesTableTableManager get cloudSyncStates =>
      $$CloudSyncStatesTableTableManager(_db, _db.cloudSyncStates);
  $$PreviewTransferJobsTableTableManager get previewTransferJobs =>
      $$PreviewTransferJobsTableTableManager(_db, _db.previewTransferJobs);
}
