import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';

enum InboxSectionKind {
  needsAction,
  expiringSoon,
  comingUp,
  readyToAnalyze,
  recent,
}

final class InboxSection {
  const InboxSection({required this.kind, required this.items});

  final InboxSectionKind kind;
  final List<SavedItem> items;
}

final class InboxOverview {
  const InboxOverview({required this.sections, required this.attentionCount});

  final List<InboxSection> sections;
  final int attentionCount;
}

abstract final class InboxPolicy {
  static const expiringWindow = Duration(days: 7);
  static const comingUpWindow = Duration(days: 14);

  static InboxOverview organize(List<SavedItem> candidates, DateTime now) {
    final utcNow = now.toUtc();
    final assigned = <String>{};

    List<SavedItem> take(bool Function(SavedItem item) predicate) {
      final result = candidates
          .where((item) => !assigned.contains(item.id) && predicate(item))
          .toList(growable: false);
      assigned.addAll(result.map((item) => item.id));
      return result;
    }

    bool within(DateTime value, Duration window) {
      final utc = value.toUtc();
      return !utc.isBefore(utcNow) && !utc.isAfter(utcNow.add(window));
    }

    final sections = <InboxSection>[
      InboxSection(
        kind: InboxSectionKind.needsAction,
        items: take(
          (item) =>
              item.status == SavedItemStatus.needsAction ||
              (item.expiresAt != null && item.expiresAt!.isBefore(utcNow)),
        ),
      ),
      InboxSection(
        kind: InboxSectionKind.expiringSoon,
        items: take(
          (item) =>
              item.expiresAt != null && within(item.expiresAt!, expiringWindow),
        )..sort((a, b) => a.expiresAt!.compareTo(b.expiresAt!)),
      ),
      InboxSection(
        kind: InboxSectionKind.comingUp,
        items: take(
          (item) =>
              (item.eventAt != null && within(item.eventAt!, comingUpWindow)) ||
              (item.status == SavedItemStatus.snoozed &&
                  (item.snoozedUntil == null ||
                      within(item.snoozedUntil!, comingUpWindow))),
        ),
      ),
      InboxSection(
        kind: InboxSectionKind.readyToAnalyze,
        items: take(
          (item) => item.analysisStatus == AnalysisStatus.unprocessed,
        ),
      ),
      InboxSection(kind: InboxSectionKind.recent, items: take((_) => true)),
    ].where((section) => section.items.isNotEmpty).toList(growable: false);

    final attentionCount = sections
        .where(
          (section) =>
              section.kind == InboxSectionKind.needsAction ||
              section.kind == InboxSectionKind.expiringSoon,
        )
        .fold<int>(0, (total, section) => total + section.items.length);
    return InboxOverview(sections: sections, attentionCount: attentionCount);
  }
}
