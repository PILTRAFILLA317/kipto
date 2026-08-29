import 'package:drift/native.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';

AppDatabase createTestDatabase() => AppDatabase(NativeDatabase.memory());

SavedItem testSavedItem({
  required String id,
  required DateTime now,
  String title = 'Test item',
  String summary = 'A searchable summary',
  SavedItemCategory category = SavedItemCategory.information,
  SavedItemStatus status = SavedItemStatus.newItem,
  bool favorite = false,
  DateTime? expiresAt,
}) {
  final created = now.subtract(const Duration(days: 1));
  return SavedItem(
    id: id,
    title: title,
    summary: summary,
    category: category,
    subtype: 'reference',
    intent: 'Keep for later',
    status: status,
    favorite: favorite,
    capturedAt: created,
    expiresAt: expiresAt,
    entities: const {'keyword': 'needle'},
    availableActions: const [SavedItemActionType.save],
    analysisStatus: AnalysisStatus.processed,
    analysisVersion: 1,
    confidence: 0.9,
    createdAt: created,
    updatedAt: created,
    originalAvailable: false,
    syncStatus: SyncStatus.localOnly,
  );
}
