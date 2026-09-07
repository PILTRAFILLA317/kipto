// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get pending => 'Pending';

  @override
  String get archive => 'Archive';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Try again';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get resolve => 'Resolve';

  @override
  String get reopen => 'Reopen';

  @override
  String get all => 'All';

  @override
  String get saved => 'Saved';

  @override
  String get resolved => 'Resolved';

  @override
  String get title => 'Title';

  @override
  String get note => 'Note';

  @override
  String get outOfYourHead => 'Out of your head.';

  @override
  String get emptyPendingTitle => 'A little more headspace.';

  @override
  String get emptyPendingBody =>
      'Save a document or write something you want to remember. It starts here.';

  @override
  String get emptyArchiveTitle => 'A place for what matters.';

  @override
  String get emptyArchiveBody =>
      'Your saved documents and resolved matters will be here, ready when you need them.';

  @override
  String get image => 'Image';

  @override
  String get document => 'Document';

  @override
  String get writeOrPaste => 'Write or paste';

  @override
  String get shareHint =>
      'You can also send a photo, PDF or text to Kipto using Share in another app.';

  @override
  String get notAvailableYet => 'Available in the next implementation phase';

  @override
  String get localError => 'We could not open your saved items. Try again.';

  @override
  String get noResults => 'No matches';

  @override
  String get searchHint => 'Search your matters';

  @override
  String get withoutDate => 'No date';

  @override
  String get localSaved => 'Saved on this device';

  @override
  String get notAnalyzed => 'Not analyzed';

  @override
  String get review => 'Review';

  @override
  String get toReview => 'To review';

  @override
  String get upcoming => 'Coming up';

  @override
  String get appearance => 'Appearance';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get haptics => 'Haptic feedback';

  @override
  String get notifications => 'Notifications';

  @override
  String get account => 'Account';

  @override
  String get syncNow => 'Sync now';

  @override
  String get cloudUnavailable =>
      'Cloud sync is not configured. Your items stay on this device.';

  @override
  String get preview => 'Design preview';

  @override
  String get previewTitle => 'Review your policy renewal';

  @override
  String get previewDate => 'September 16 · date to confirm';

  @override
  String get previewSummary =>
      'Check the notice period in the original document.';

  @override
  String get previewSecondTitle => 'Dentist appointment';

  @override
  String get previewSecondDate => 'September 18 · 09:30';

  @override
  String get previewError =>
      'The document could not be read. The original is still saved.';

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active matters',
      one: '1 active matter',
      zero: 'No active matters',
    );
    return '$_temp0';
  }

  @override
  String get saving => 'Saving…';

  @override
  String get confirmingAction => 'Confirming…';

  @override
  String get calendarPermissionDenied => 'Calendar access was not authorised.';

  @override
  String get evidenceDetails => 'Evidence for this fact';

  @override
  String get captureTooLarge =>
      'The limit is 20 MiB per file and 60,000 characters per note.';

  @override
  String get captureUnsupported =>
      'Choose a JPEG, PNG, WebP, HEIC or PDF file.';

  @override
  String get captureUnreadable =>
      'This file cannot be read. Check that it is complete and not password protected.';

  @override
  String get captureFailed =>
      'Could not save this source. Your existing items are safe. Try again.';

  @override
  String get captureAccountChanged =>
      'Your account changed. Reopen Add before saving to this library.';

  @override
  String get sourceUnavailable =>
      'The original is not available on this device.';

  @override
  String get openOriginal => 'Open original';

  @override
  String get source => 'Source';

  @override
  String get syncConsent => 'Sync my matters';

  @override
  String get syncConsentBody =>
      'Includes titles, notes, source text and extracted information in your private cloud library. Original files need separate backup consent.';

  @override
  String get cloud => 'Cloud and privacy';

  @override
  String get protectLibrary => 'Protect this library';

  @override
  String get protectLibraryBody =>
      'Connect Apple or Google to recover your matters on another device.';

  @override
  String get getStarted => 'Continue with a private account';

  @override
  String get restoreApple => 'Restore with Apple';

  @override
  String get restoreGoogle => 'Restore with Google';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutBody =>
      'Removes this library from this device. Cloud data remains.';

  @override
  String get operationFailed =>
      'This action could not be completed. Try again.';

  @override
  String get notificationEnabled => 'Local reminders are enabled';

  @override
  String get notificationDisabled => 'Notifications are disabled';

  @override
  String get notificationAsk => 'Enable when you create a reminder';

  @override
  String get notificationUnavailable => 'Not available on this device';

  @override
  String get sourceTextHint => 'Write or paste what you want to keep';

  @override
  String get fieldRequired => 'Enter a title and some text.';

  @override
  String get recoveryFailed =>
      'Some pending sources could not be recovered. Their files have been kept.';

  @override
  String get pdfLimit =>
      'Only up to 10 pages can be analyzed. Keep this original or provide a shorter PDF.';

  @override
  String sharedReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shared sources are ready',
      one: '1 shared source is ready',
    );
    return '$_temp0';
  }

  @override
  String sharedAsMatters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'They will be saved as $count separate matters.',
      one: 'It will be saved as one matter.',
    );
    return '$_temp0';
  }

  @override
  String get discardCapture => 'Discard capture';

  @override
  String get discardCaptureBody =>
      'This pending delivery will be deleted. Matters already saved will be kept.';

  @override
  String get detectedDate => 'Detected date';

  @override
  String get detectedFact => 'Detected fact';

  @override
  String get correctedFact => 'Corrected fact';

  @override
  String get originalValue => 'Original value';

  @override
  String get checkOriginal =>
      'Check this fact against the original before using it.';

  @override
  String get proposedReminder => 'Proposed reminder';

  @override
  String calendarMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count calendar months',
      one: '1 calendar month',
    );
    return '$_temp0';
  }

  @override
  String calendarDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String pageNumber(int count) {
    return 'Page $count';
  }

  @override
  String get analyze => 'Analyze source';

  @override
  String get analyzeAgain => 'Analyze again';

  @override
  String get analysisConsentTitle => 'Analyze with AI';

  @override
  String get analysisConsentBody =>
      'A prepared copy of this source will be sent to Supabase and OpenAI to extract facts and suggestions. An anonymous session will be created if needed. Your original stays here. This does not enable sync or backup. You can disable this in Settings.';

  @override
  String get analysisConsent => 'Allow AI analysis';

  @override
  String get analysisConsentShort =>
      'Send only sources you choose. Analysis never creates reminders automatically.';

  @override
  String get analysisQueued => 'Saved · awaiting analysis';

  @override
  String get analysisRunning => 'Analyzing source…';

  @override
  String get analysisRetry => 'Waiting to retry';

  @override
  String get analysisReady => 'Analysis ready · review suggestions';

  @override
  String get analysisPaused => 'Analysis is disabled in Settings.';

  @override
  String get analysisCoverage =>
      'Check coverage and evidence before confirming an action.';

  @override
  String get analysisPartial =>
      'Partial analysis: some pages have not been reviewed.';

  @override
  String get analysisTooLarge =>
      'This source exceeds the analysis limit. The original is saved; import a smaller copy.';

  @override
  String get analysisTooManyPages =>
      'This PDF has more than 10 pages. Import a copy containing the relevant pages for analysis. Your original is kept.';

  @override
  String get analysisUnreadable =>
      'This source cannot be read. Enter details manually or import another copy.';

  @override
  String get analysisNetwork =>
      'The connection could not be completed. Your source is still saved.';

  @override
  String get analysisQuota =>
      'An analysis limit has been reached. Existing documents and reminders remain available.';

  @override
  String get analysisSession =>
      'There is no valid session for analysis. Check your account in Settings.';

  @override
  String get analysisConfiguration =>
      'Analysis is unavailable. You can still save sources and enter details manually.';

  @override
  String get analysisInvalid =>
      'The result could not be validated. No suggestions or reminders were created.';

  @override
  String get analysisIndeterminate =>
      'We cannot confirm whether the provider finished analysis. This request will not be repeated automatically.';

  @override
  String get analysisStale =>
      'This result no longer matches the current account or source.';

  @override
  String get analysisNewRequestTitle => 'Start another analysis?';

  @override
  String get analysisNewRequestBody =>
      'A new request may use another analysis from your quota. Corrected facts and accepted actions will be kept.';

  @override
  String get analysisContextOmitted =>
      'Accompanying text is saved with the matter; this analysis reviews only the file.';

  @override
  String get analysisUncertainty => 'Uncertain fact';

  @override
  String get analysisReviewTitle => 'Suggested title';

  @override
  String get analysisNoActions =>
      'No actions were suggested. Saving without a date is still valid.';

  @override
  String get reviewAction => 'Review suggestion';

  @override
  String get remindAction => 'Remind me';

  @override
  String get eventAction => 'Add to calendar';

  @override
  String get keepAction => 'Just save';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get chooseTime => 'Choose time';

  @override
  String get timeZone => 'Time zone';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get startTime => 'Start time';

  @override
  String get endTime => 'End time';

  @override
  String get allDay => 'All day';

  @override
  String get endDateExclusive => 'The end date is not included.';

  @override
  String get locationOptional => 'Location (optional)';

  @override
  String get confirmTemporal =>
      'Check date, time and zone. A detected date does not create a reminder on its own.';

  @override
  String get invalidTemporal =>
      'Complete the date and time, using a valid zone and interval.';

  @override
  String get nonexistentTime =>
      'This local time does not exist due to a clock change. Choose another time.';

  @override
  String get ambiguousTime =>
      'This time occurs twice. Choose the correct occurrence.';

  @override
  String get sameDate => 'That day';

  @override
  String get dayBefore => 'One day before';

  @override
  String get weekBefore => 'One week before';

  @override
  String get monthBefore => 'One calendar month before';

  @override
  String get monthClamped => 'Adjusted to the last day of the month.';

  @override
  String get reminderScheduled => 'Reminder scheduled on this device.';

  @override
  String get reminderNotScheduled =>
      'Reminder saved, but not scheduled on this device. Check notification permission or capacity.';

  @override
  String get calendarSaved => 'Event saved to your calendar.';

  @override
  String get calendarOpened =>
      'Calendar opened. Kipto cannot confirm whether you saved the event.';

  @override
  String get calendarCancelled => 'No event was saved.';

  @override
  String get calendarUnavailable => 'Calendar is unavailable on this device.';

  @override
  String get keepExplained =>
      'Keep the document without creating dates. If no future reminders exist, other suggestions will be dismissed and the matter will move to Archive.';

  @override
  String get keptResult =>
      'Document kept. Existing reminders have not been cancelled.';

  @override
  String get dismissProposal => 'Dismiss suggestion';

  @override
  String get proposedAction => 'Awaiting confirmation';

  @override
  String get acceptedAction => 'Confirmed';

  @override
  String get reopenCalendar => 'Reopen calendar';

  @override
  String get reopenCalendarBody =>
      'The event may already exist. Check your calendar before creating another copy.';

  @override
  String get resolveMatter => 'Resolve matter';

  @override
  String get reopenMatter => 'Return to Pending';

  @override
  String get archiveMatter => 'Archive matter';

  @override
  String get archiveReminderBody =>
      'Archiving will cancel this matter’s future reminders. Calendar events will remain unchanged.';

  @override
  String get resolveReminderBody =>
      'Resolving will cancel pending reminders and keep the document in Archive. Undo only reschedules valid future reminders.';

  @override
  String get editMatter => 'Edit title and summary';

  @override
  String get matterTitle => 'Title';

  @override
  String get matterSummary => 'Summary';

  @override
  String get actionTitle => 'Action title';

  @override
  String get savedChange => 'Changes saved';

  @override
  String get lifecycleFailed =>
      'The operation did not complete. Check saved state and notification permissions before retrying.';

  @override
  String get undo => 'Undo';

  @override
  String get viewEvidence => 'View source for this fact';

  @override
  String get pendingReminder => 'Pending reminder';

  @override
  String get completedReminder => 'Cancelled or completed reminder';

  @override
  String get cancelReminder => 'Cancel reminder';

  @override
  String get cancelReminderBody =>
      'This reminder will be cancelled. The matter will stay in Pending.';

  @override
  String get noReminderCreated => 'Saving does not create a reminder.';

  @override
  String get factValue => 'Value';

  @override
  String get rawDate => 'Date as written';

  @override
  String get currency => 'Currency (optional)';

  @override
  String get durationCount => 'Count';

  @override
  String get durationUnit => 'Unit';

  @override
  String get calendarDayUnit => 'Calendar days';

  @override
  String get calendarMonthUnit => 'Calendar months';

  @override
  String get clearDate => 'Unconfirmed date';

  @override
  String get clearTime => 'Unconfirmed time';

  @override
  String get factCorrectionBody =>
      'Corrections preserve the original extraction and evidence. Existing confirmed reminders remain unchanged.';

  @override
  String get reviewGroup => 'Needs review';

  @override
  String get datedGroup => 'With a date';

  @override
  String get otherGroup => 'Other matters';

  @override
  String get sourceLocal => 'Original on this device';

  @override
  String get sourceMissing => 'Original unavailable on this device';

  @override
  String get reimportSource => 'Import another copy';

  @override
  String get searchResultCount => 'Results';

  @override
  String get backupConsent => 'Original file backup';

  @override
  String get backupConsentBody =>
      'With Kipto Pro, upload originals to your private backup (up to 1 GiB). Requires metadata sync. Turning this off keeps existing backups.';

  @override
  String backupPending(int count) {
    return '$count files awaiting transfer';
  }

  @override
  String get backupReady => 'Backup confirmed';

  @override
  String backupTransfer(int sent, int total) {
    return '$sent of $total bytes transferred; awaiting confirmation';
  }

  @override
  String get backupProRequired =>
      'New backups require Kipto Pro. Your original is still on this device.';

  @override
  String get downloadBackup => 'Download backup, if available';

  @override
  String signOutWarning(int changes, int originals) {
    return 'This device’s library will be removed. There are $changes matters with pending changes and $originals originals without a backup confirmed here. You can cancel and export them before signing out.';
  }

  @override
  String get proHeadline => 'More help.\nAll at hand.';

  @override
  String get proBody => 'More analyses and a private backup of your originals.';

  @override
  String get proAnalysis => '100 analyses per month';

  @override
  String get proBackup => 'Up to 1 GiB of originals';

  @override
  String get proVerified => 'Kipto Pro verified by the server';

  @override
  String get freePlan => 'Free plan · 5 analyses per month';

  @override
  String get billingUnavailable =>
      'Purchases are not available yet. You can still save items and create manual reminders.';

  @override
  String get paymentPending => 'The store is awaiting payment approval.';

  @override
  String get purchaseVerificationPending =>
      'Purchase received by the store. Your limits will increase when the server verifies your entitlement.';

  @override
  String get monthlyPlan => 'Monthly';

  @override
  String get annualPlan => 'Annual';

  @override
  String get subscriptionTerms =>
      'Automatically renews for the period shown. Review the final price and terms in the store before confirming. Saving, viewing and existing reminders remain available if you cancel.';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get restorePurchaseBody =>
      'Purchases checked. Restoring purchases does not restore documents from another account.';

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get noSubscription => 'There is no active subscription to manage.';

  @override
  String get refreshStatus => 'Refresh status';

  @override
  String get privacy => 'Privacy';

  @override
  String get terms => 'Terms';

  @override
  String get exportData => 'Export';

  @override
  String get exportBody =>
      'Prepare a ZIP with the selected data and available originals. If files are missing, cancel and download them from their details before exporting.';

  @override
  String get exportComplete => 'All selected originals are included.';

  @override
  String exportMissing(int count) {
    return '$count originals are missing. The manifest identifies them.';
  }

  @override
  String get saveExport => 'Save or share ZIP';

  @override
  String get deleteMatter => 'Delete matter';

  @override
  String get deleteMatterBody =>
      'The matter and its sources will be deleted, and its reminders cancelled. Remote file deletion may remain pending until connectivity returns. This cannot be undone.';

  @override
  String get deletePending =>
      'Deletion requested. Some steps remain pending; check transfers in Settings.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountBody =>
      'Your account, Kipto data and original file backups will be deleted. Export anything you want to keep first. This cannot be undone. Store subscriptions are not automatically cancelled: you can manage yours in Kipto Pro before continuing, but cancellation is not required to delete your account.';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get accountDeletionPending => 'Deletion in progress';

  @override
  String get accountDeletionWait =>
      'New transfers are blocked. If an upload was in progress, deletion will wait up to five minutes to avoid leaving files behind. Retry while connected; the request is kept if you close the app.';

  @override
  String get notificationsThisDevice => 'Reminders on this device';

  @override
  String get notificationsDevicesBody =>
      'If reminders are enabled on two devices, both may notify you. System permission must also be enabled.';

  @override
  String get notificationTitles => 'Include titles in notifications';

  @override
  String get notificationTitlesBody =>
      'By default, notifications only say an item needs your attention. Enable this to show the title, including on the lock screen.';

  @override
  String get returnToSource => 'Return to source app';

  @override
  String get deleteSource => 'Delete source';

  @override
  String get deleteSourceBody =>
      'This original and its extracted data will be deleted, and related reminders cancelled. The matter is kept. This cannot be undone.';

  @override
  String get loading => 'Loading…';
}
