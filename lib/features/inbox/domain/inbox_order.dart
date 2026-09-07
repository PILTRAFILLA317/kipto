import 'package:kipto/core/domain/enums/item_enums.dart';
import 'package:kipto/core/domain/models/item.dart';
import 'package:kipto/core/repositories/item_queries.dart';

enum InboxGroup { review, dated, other }

class InboxEntry {
  const InboxEntry(this.item, this.signal);
  final Item item;
  final ItemSignal signal;
  InboxGroup get group => signal.needsReview
      ? InboxGroup.review
      : signal.nextReminder != null || signal.explicitDate != null
      ? InboxGroup.dated
      : InboxGroup.other;
  String? get dateOrder {
    final values = [
      if (signal.nextReminder != null)
        signal.nextReminder!.toLocal().toIso8601String(),
      if (signal.explicitDate != null) signal.explicitDate.toString(),
    ]..sort();
    return values.firstOrNull;
  }
}

List<InboxEntry> orderInbox(List<Item> items, Map<String, ItemSignal> signals) {
  final result = items
      .where(
        (item) => item.status == ItemStatus.active && item.deletedAt == null,
      )
      .map((item) => InboxEntry(item, signals[item.id] ?? const ItemSignal()))
      .toList();
  result.sort((a, b) {
    final group = a.group.index.compareTo(b.group.index);
    if (group != 0) return group;
    if (a.group == InboxGroup.dated) {
      final date = a.dateOrder!.compareTo(b.dateOrder!);
      if (date != 0) return date;
    }
    final updated = b.item.updatedAt.compareTo(a.item.updatedAt);
    return updated == 0 ? a.item.id.compareTo(b.item.id) : updated;
  });
  return result;
}
