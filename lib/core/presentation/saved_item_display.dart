import 'package:flutter/material.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';
import 'package:kipto/core/domain/models/saved_item.dart';

extension SavedItemCategoryDisplay on SavedItemCategory {
  String get label => switch (this) {
    SavedItemCategory.event => 'Events',
    SavedItemCategory.place => 'Places',
    SavedItemCategory.product => 'Products',
    SavedItemCategory.order => 'Orders',
    SavedItemCategory.recipe => 'Recipes',
    SavedItemCategory.coupon => 'Coupons',
    SavedItemCategory.conversation => 'Conversations',
    SavedItemCategory.media => 'Media',
    SavedItemCategory.meme => 'Memes',
    SavedItemCategory.information => 'Information',
    SavedItemCategory.other => 'Other',
  };

  String get singularLabel => switch (this) {
    SavedItemCategory.event => 'Event',
    SavedItemCategory.place => 'Place',
    SavedItemCategory.product => 'Product',
    SavedItemCategory.order => 'Order',
    SavedItemCategory.recipe => 'Recipe',
    SavedItemCategory.coupon => 'Coupon',
    SavedItemCategory.conversation => 'Conversation',
    SavedItemCategory.media => 'Media',
    SavedItemCategory.meme => 'Meme',
    SavedItemCategory.information => 'Information',
    SavedItemCategory.other => 'Other',
  };

  IconData get icon => switch (this) {
    SavedItemCategory.event => Icons.event_outlined,
    SavedItemCategory.place => Icons.place_outlined,
    SavedItemCategory.product => Icons.shopping_bag_outlined,
    SavedItemCategory.order => Icons.local_shipping_outlined,
    SavedItemCategory.recipe => Icons.restaurant_menu,
    SavedItemCategory.coupon => Icons.sell_outlined,
    SavedItemCategory.conversation => Icons.chat_bubble_outline,
    SavedItemCategory.media => Icons.play_circle_outline,
    SavedItemCategory.meme => Icons.sentiment_very_satisfied_outlined,
    SavedItemCategory.information => Icons.info_outline,
    SavedItemCategory.other => Icons.bookmark_outline,
  };
}

extension SavedItemStatusDisplay on SavedItemStatus {
  String get label => switch (this) {
    SavedItemStatus.newItem => 'New',
    SavedItemStatus.needsAction => 'Needs action',
    SavedItemStatus.snoozed => 'Snoozed',
    SavedItemStatus.done => 'Done',
    SavedItemStatus.archived => 'Archived',
  };
}

extension AnalysisStatusDisplay on AnalysisStatus {
  String get label => switch (this) {
    AnalysisStatus.unprocessed => 'Ready to analyze',
    AnalysisStatus.processing => 'Analyzing…',
    AnalysisStatus.processed => 'Analyzed',
    AnalysisStatus.needsReview => 'Needs review',
    AnalysisStatus.failed => 'Analysis failed',
  };

  IconData get icon => switch (this) {
    AnalysisStatus.unprocessed => Icons.auto_awesome_outlined,
    AnalysisStatus.processing => Icons.hourglass_top_rounded,
    AnalysisStatus.processed => Icons.check_circle_outline,
    AnalysisStatus.needsReview => Icons.rate_review_outlined,
    AnalysisStatus.failed => Icons.error_outline,
  };
}

extension SavedItemActionDisplay on SavedItemActionType {
  String get label => switch (this) {
    SavedItemActionType.addCalendar => 'Add to calendar',
    SavedItemActionType.createReminder => 'Create reminder',
    SavedItemActionType.openMaps => 'Open maps',
    SavedItemActionType.openUrl => 'Open link',
    SavedItemActionType.webSearch => 'Search the web',
    SavedItemActionType.copyCode => 'Copy code',
    SavedItemActionType.trackPackage => 'Track package',
    SavedItemActionType.save => 'Save',
    SavedItemActionType.none => 'No action',
  };

  IconData get icon => switch (this) {
    SavedItemActionType.addCalendar => Icons.event_available_outlined,
    SavedItemActionType.createReminder => Icons.add_alert_outlined,
    SavedItemActionType.openMaps => Icons.map_outlined,
    SavedItemActionType.openUrl => Icons.open_in_new,
    SavedItemActionType.webSearch => Icons.manage_search,
    SavedItemActionType.copyCode => Icons.content_copy,
    SavedItemActionType.trackPackage => Icons.local_shipping_outlined,
    SavedItemActionType.save => Icons.bookmark_add_outlined,
    SavedItemActionType.none => Icons.block,
  };

  String get completedLabel => switch (this) {
    SavedItemActionType.addCalendar => 'Added to calendar',
    SavedItemActionType.createReminder => 'Reminder created',
    SavedItemActionType.save => 'Saved',
    _ => label,
  };

  String get description => switch (this) {
    SavedItemActionType.addCalendar =>
      'Review the event, then confirm it in the system Calendar editor.',
    SavedItemActionType.createReminder =>
      'Choose when Kipto should send a local notification.',
    SavedItemActionType.openMaps => 'Open this place in a maps app.',
    SavedItemActionType.openUrl => 'Open the detected link in your browser.',
    SavedItemActionType.webSearch =>
      'Search using the useful detected details.',
    SavedItemActionType.copyCode => 'Copy an explicitly detected code.',
    SavedItemActionType.trackPackage => 'Open tracking or a safe web search.',
    SavedItemActionType.save => 'Keep this item as a favorite in Kipto.',
    SavedItemActionType.none => 'No action is available.',
  };

  bool get requiresConfirmation => switch (this) {
    SavedItemActionType.addCalendar ||
    SavedItemActionType.createReminder => true,
    _ => false,
  };
}

final class SavedItemActionPresentationPolicy {
  const SavedItemActionPresentationPolicy();

  List<SavedItemActionType> orderedFor(SavedItem item) {
    final actions = item.availableActions
        .where((action) => action != SavedItemActionType.none)
        .toSet()
        .toList();
    actions.sort((left, right) {
      final byPriority = _priority(
        item.category,
        left,
      ).compareTo(_priority(item.category, right));
      return byPriority != 0 ? byPriority : left.index.compareTo(right.index);
    });
    return List.unmodifiable(actions);
  }

  SavedItemActionType? primaryFor(SavedItem item) =>
      orderedFor(item).firstOrNull;

  int _priority(SavedItemCategory category, SavedItemActionType action) {
    final categoryPriority = switch (category) {
      SavedItemCategory.event => const [
        SavedItemActionType.addCalendar,
        SavedItemActionType.createReminder,
        SavedItemActionType.openMaps,
      ],
      SavedItemCategory.place => const [
        SavedItemActionType.openMaps,
        SavedItemActionType.openUrl,
      ],
      SavedItemCategory.order => const [
        SavedItemActionType.trackPackage,
        SavedItemActionType.copyCode,
      ],
      SavedItemCategory.coupon => const [
        SavedItemActionType.copyCode,
        SavedItemActionType.createReminder,
      ],
      SavedItemCategory.product => const [
        SavedItemActionType.openUrl,
        SavedItemActionType.webSearch,
      ],
      _ => const <SavedItemActionType>[],
    };
    final categoryIndex = categoryPriority.indexOf(action);
    if (categoryIndex >= 0) return categoryIndex;
    return 10 +
        switch (action) {
          SavedItemActionType.addCalendar => 0,
          SavedItemActionType.createReminder => 1,
          SavedItemActionType.openMaps => 2,
          SavedItemActionType.trackPackage => 3,
          SavedItemActionType.openUrl => 4,
          SavedItemActionType.webSearch => 5,
          SavedItemActionType.copyCode => 6,
          SavedItemActionType.save => 7,
          SavedItemActionType.none => 99,
        };
  }
}
