import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';

final class InboxSection {
  const InboxSection(this.title, this.items);

  final String title;
  final List<SavedItem> items;
}

List<InboxSection> buildInboxSections(List<SavedItem> items, DateTime now) {
  final assigned = <String>{};

  List<SavedItem> take(bool Function(SavedItem item) predicate) {
    final result = items
        .where((item) => !assigned.contains(item.id) && predicate(item))
        .toList(growable: false);
    assigned.addAll(result.map((item) => item.id));
    return result;
  }

  final utcNow = now.toUtc();
  final sections = [
    InboxSection(
      'Need action',
      take((item) => item.status == SavedItemStatus.needsAction),
    ),
    InboxSection(
      'Expiring soon',
      take(
        (item) =>
            item.expiresAt != null &&
            item.expiresAt!.isAfter(utcNow) &&
            item.expiresAt!.isBefore(utcNow.add(const Duration(days: 7))),
      ),
    ),
    InboxSection(
      'Snoozed · Coming up',
      take((item) => item.status == SavedItemStatus.snoozed),
    ),
    InboxSection('Recent', take((item) => true)),
  ];
  return sections.where((section) => section.items.isNotEmpty).toList();
}
