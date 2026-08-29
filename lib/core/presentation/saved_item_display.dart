import 'package:flutter/material.dart';
import 'package:kipto/core/domain/enums/saved_item_enums.dart';

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
}
