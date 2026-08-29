import 'package:clock/clock.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';
import 'package:kipto/core/repositories/drift_reminders_repository.dart';
import 'package:kipto/core/repositories/drift_saved_items_repository.dart';

final class DevelopmentSeed {
  DevelopmentSeed(this._database, {Clock? clock})
    : _clock = clock ?? const Clock();

  static const concertId = '00000000-0000-4000-8000-000000000001';
  static const restaurantId = '00000000-0000-4000-8000-000000000002';
  static const couponId = '00000000-0000-4000-8000-000000000003';
  static const productId = '00000000-0000-4000-8000-000000000004';
  static const orderId = '00000000-0000-4000-8000-000000000005';
  static const recipeId = '00000000-0000-4000-8000-000000000006';
  static const conversationId = '00000000-0000-4000-8000-000000000007';
  static const memeId = '00000000-0000-4000-8000-000000000008';
  static const mediaId = '00000000-0000-4000-8000-000000000009';
  static const informationId = '00000000-0000-4000-8000-000000000010';
  static const reminderId = '10000000-0000-4000-8000-000000000001';
  static const knownItemIds = <String>[
    concertId,
    restaurantId,
    couponId,
    productId,
    orderId,
    recipeId,
    conversationId,
    memeId,
    mediaId,
    informationId,
  ];

  final AppDatabase _database;
  final Clock _clock;

  Future<void> run() async {
    final now = _clock.now().toUtc();
    final items = _items(now);
    final repository = DriftSavedItemsRepository(_database, clock: _clock);

    await _database.transaction(() async {
      for (final item in items) {
        final existing = await _database.savedItemsDao.findById(
          item.id,
          includeDeleted: true,
        );
        if (existing == null) await repository.create(item);
      }
    });

    if (await _database.remindersDao.findById(reminderId) == null) {
      final reminders = DriftRemindersRepository(
        _database,
        clock: _clock,
        idGenerator: () => reminderId,
      );
      await reminders.create(
        savedItemId: conversationId,
        remindAt: now.add(const Duration(days: 1)),
        kind: ReminderKind.followUp,
      );
    }
  }

  List<SavedItem> _items(DateTime now) => [
    _item(
      id: concertId,
      now: now,
      title: 'The National at Auditorio Central',
      summary: 'Tickets go on sale Friday at 10:00.',
      category: SavedItemCategory.event,
      subtype: 'concert',
      intent: 'Add the date and ticket sale to my calendar',
      status: SavedItemStatus.needsAction,
      capturedDaysAgo: 1,
      eventAt: now.add(const Duration(days: 34)),
      entities: const {'artist': 'The National', 'venue': 'Auditorio Central'},
      actions: const [
        SavedItemActionType.addCalendar,
        SavedItemActionType.createReminder,
      ],
      favorite: true,
    ),
    _item(
      id: restaurantId,
      now: now,
      title: 'Casa Lila',
      summary: 'Small seasonal restaurant saved for the weekend.',
      category: SavedItemCategory.place,
      subtype: 'restaurant',
      intent: 'Save this place for later',
      status: SavedItemStatus.newItem,
      capturedDaysAgo: 2,
      location: 'Calle del Mar 18',
      entities: const {'merchant': 'Casa Lila', 'city': 'Las Palmas'},
      actions: const [SavedItemActionType.openMaps, SavedItemActionType.save],
    ),
    _item(
      id: couponId,
      now: now,
      title: '25% off running gear',
      summary: 'Use KIPTO25 before the offer expires.',
      category: SavedItemCategory.coupon,
      subtype: 'discount code',
      intent: 'Remember before it expires',
      status: SavedItemStatus.newItem,
      capturedDaysAgo: 3,
      expiresAt: now.add(const Duration(days: 2)),
      entities: const {'merchant': 'North Run', 'code': 'KIPTO25'},
      actions: const [
        SavedItemActionType.copyCode,
        SavedItemActionType.createReminder,
      ],
    ),
    _item(
      id: productId,
      now: now,
      title: 'Compact travel charger',
      summary: 'Compare the 65W model before buying.',
      category: SavedItemCategory.product,
      subtype: 'electronics',
      intent: 'Compare prices',
      status: SavedItemStatus.snoozed,
      capturedDaysAgo: 4,
      snoozedUntil: now.add(const Duration(days: 3)),
      entities: const {'productName': '65W travel charger', 'price': '€49'},
      actions: const [SavedItemActionType.webSearch, SavedItemActionType.save],
    ),
    _item(
      id: orderId,
      now: now,
      title: 'Desk lamp delivery',
      summary: 'Shipment is in transit with tracking code LP2048.',
      category: SavedItemCategory.order,
      subtype: 'delivery',
      intent: 'Track package',
      status: SavedItemStatus.needsAction,
      capturedDaysAgo: 1,
      entities: const {'merchant': 'Lumen', 'trackingCode': 'LP2048'},
      actions: const [SavedItemActionType.trackPackage],
    ),
    _item(
      id: recipeId,
      now: now,
      title: 'One-pan lemon orzo',
      summary: 'Weeknight recipe with spinach and feta.',
      category: SavedItemCategory.recipe,
      subtype: 'dinner',
      intent: 'Cook later',
      status: SavedItemStatus.done,
      capturedDaysAgo: 8,
      actions: const [SavedItemActionType.save],
    ),
    _item(
      id: conversationId,
      now: now,
      title: 'Send Maya the project notes',
      summary: 'Follow up after reviewing the meeting outline.',
      category: SavedItemCategory.conversation,
      subtype: 'message',
      intent: 'Reply tomorrow',
      status: SavedItemStatus.needsAction,
      capturedDaysAgo: 0,
      actions: const [SavedItemActionType.createReminder],
      favorite: true,
    ),
    _item(
      id: memeId,
      now: now,
      title: 'Release day energy',
      summary: 'A meme worth keeping, no action required.',
      category: SavedItemCategory.meme,
      subtype: 'meme',
      intent: 'Keep for later',
      status: SavedItemStatus.archived,
      capturedDaysAgo: 10,
      actions: const [SavedItemActionType.save],
    ),
    _item(
      id: mediaId,
      now: now,
      title: 'Night Drive — Chromatics',
      summary: 'Song recommendation from a late-night playlist.',
      category: SavedItemCategory.media,
      subtype: 'song',
      intent: 'Listen later',
      status: SavedItemStatus.newItem,
      capturedDaysAgo: 2,
      entities: const {'artist': 'Chromatics', 'mediaType': 'song'},
      actions: const [SavedItemActionType.webSearch, SavedItemActionType.save],
    ),
    _item(
      id: informationId,
      now: now,
      title: 'Carry-on dimensions',
      summary: 'Airline limit: 55 × 40 × 20 cm.',
      category: SavedItemCategory.information,
      subtype: 'travel reference',
      intent: 'Keep as reference',
      status: SavedItemStatus.newItem,
      capturedDaysAgo: 5,
      actions: const [SavedItemActionType.save],
    ),
  ];

  SavedItem _item({
    required String id,
    required DateTime now,
    required String title,
    required String summary,
    required SavedItemCategory category,
    required String subtype,
    required String intent,
    required SavedItemStatus status,
    required int capturedDaysAgo,
    required List<SavedItemActionType> actions,
    Map<String, Object?> entities = const {},
    DateTime? eventAt,
    DateTime? expiresAt,
    DateTime? snoozedUntil,
    String? location,
    bool favorite = false,
  }) {
    final capturedAt = now.subtract(Duration(days: capturedDaysAgo));
    return SavedItem(
      id: id,
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
      availableActions: actions,
      analysisStatus: AnalysisStatus.processed,
      analysisVersion: 1,
      confidence: 0.92,
      createdAt: capturedAt,
      updatedAt: capturedAt,
      localAssetId: 'demo-$id',
      originalAvailable: true,
      syncStatus: SyncStatus.localOnly,
    );
  }
}
