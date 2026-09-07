import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @resolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolve;

  /// No description provided for @reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @outOfYourHead.
  ///
  /// In en, this message translates to:
  /// **'Out of your head.'**
  String get outOfYourHead;

  /// No description provided for @emptyPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'A little more headspace.'**
  String get emptyPendingTitle;

  /// No description provided for @emptyPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Save a document or write something you want to remember. It starts here.'**
  String get emptyPendingBody;

  /// No description provided for @emptyArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'A place for what matters.'**
  String get emptyArchiveTitle;

  /// No description provided for @emptyArchiveBody.
  ///
  /// In en, this message translates to:
  /// **'Your saved documents and resolved matters will be here, ready when you need them.'**
  String get emptyArchiveBody;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @writeOrPaste.
  ///
  /// In en, this message translates to:
  /// **'Write or paste'**
  String get writeOrPaste;

  /// No description provided for @shareHint.
  ///
  /// In en, this message translates to:
  /// **'You can also send a photo, PDF or text to Kipto using Share in another app.'**
  String get shareHint;

  /// No description provided for @notAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'Available in the next implementation phase'**
  String get notAvailableYet;

  /// No description provided for @localError.
  ///
  /// In en, this message translates to:
  /// **'We could not open your saved items. Try again.'**
  String get localError;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noResults;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your matters'**
  String get searchHint;

  /// No description provided for @withoutDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get withoutDate;

  /// No description provided for @localSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get localSaved;

  /// No description provided for @notAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Not analyzed'**
  String get notAnalyzed;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @toReview.
  ///
  /// In en, this message translates to:
  /// **'To review'**
  String get toReview;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get upcoming;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get haptics;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @cloudUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is not configured. Your items stay on this device.'**
  String get cloudUnavailable;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Design preview'**
  String get preview;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your policy renewal'**
  String get previewTitle;

  /// No description provided for @previewDate.
  ///
  /// In en, this message translates to:
  /// **'September 16 · date to confirm'**
  String get previewDate;

  /// No description provided for @previewSummary.
  ///
  /// In en, this message translates to:
  /// **'Check the notice period in the original document.'**
  String get previewSummary;

  /// No description provided for @previewSecondTitle.
  ///
  /// In en, this message translates to:
  /// **'Dentist appointment'**
  String get previewSecondTitle;

  /// No description provided for @previewSecondDate.
  ///
  /// In en, this message translates to:
  /// **'September 18 · 09:30'**
  String get previewSecondDate;

  /// No description provided for @previewError.
  ///
  /// In en, this message translates to:
  /// **'The document could not be read. The original is still saved.'**
  String get previewError;

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active matters} =1{1 active matter} other{{count} active matters}}'**
  String activeCount(int count);

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @confirmingAction.
  ///
  /// In en, this message translates to:
  /// **'Confirming…'**
  String get confirmingAction;

  /// No description provided for @calendarPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Calendar access was not authorised.'**
  String get calendarPermissionDenied;

  /// No description provided for @evidenceDetails.
  ///
  /// In en, this message translates to:
  /// **'Evidence for this fact'**
  String get evidenceDetails;

  /// No description provided for @captureTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The limit is 20 MiB per file and 60,000 characters per note.'**
  String get captureTooLarge;

  /// No description provided for @captureUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Choose a JPEG, PNG, WebP, HEIC or PDF file.'**
  String get captureUnsupported;

  /// No description provided for @captureUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This file cannot be read. Check that it is complete and not password protected.'**
  String get captureUnreadable;

  /// No description provided for @captureFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this source. Your existing items are safe. Try again.'**
  String get captureFailed;

  /// No description provided for @captureAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'Your account changed. Reopen Add before saving to this library.'**
  String get captureAccountChanged;

  /// No description provided for @sourceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The original is not available on this device.'**
  String get sourceUnavailable;

  /// No description provided for @openOriginal.
  ///
  /// In en, this message translates to:
  /// **'Open original'**
  String get openOriginal;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @syncConsent.
  ///
  /// In en, this message translates to:
  /// **'Sync my matters'**
  String get syncConsent;

  /// No description provided for @syncConsentBody.
  ///
  /// In en, this message translates to:
  /// **'Includes titles, notes, source text and extracted information in your private cloud library. Original files need separate backup consent.'**
  String get syncConsentBody;

  /// No description provided for @cloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud and privacy'**
  String get cloud;

  /// No description provided for @protectLibrary.
  ///
  /// In en, this message translates to:
  /// **'Protect this library'**
  String get protectLibrary;

  /// No description provided for @protectLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'Connect Apple or Google to recover your matters on another device.'**
  String get protectLibraryBody;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Continue with a private account'**
  String get getStarted;

  /// No description provided for @restoreApple.
  ///
  /// In en, this message translates to:
  /// **'Restore with Apple'**
  String get restoreApple;

  /// No description provided for @restoreGoogle.
  ///
  /// In en, this message translates to:
  /// **'Restore with Google'**
  String get restoreGoogle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'Removes this library from this device. Cloud data remains.'**
  String get signOutBody;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'This action could not be completed. Try again.'**
  String get operationFailed;

  /// No description provided for @notificationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Local reminders are enabled'**
  String get notificationEnabled;

  /// No description provided for @notificationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled'**
  String get notificationDisabled;

  /// No description provided for @notificationAsk.
  ///
  /// In en, this message translates to:
  /// **'Enable when you create a reminder'**
  String get notificationAsk;

  /// No description provided for @notificationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get notificationUnavailable;

  /// No description provided for @sourceTextHint.
  ///
  /// In en, this message translates to:
  /// **'Write or paste what you want to keep'**
  String get sourceTextHint;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title and some text.'**
  String get fieldRequired;

  /// No description provided for @recoveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Some pending sources could not be recovered. Their files have been kept.'**
  String get recoveryFailed;

  /// No description provided for @pdfLimit.
  ///
  /// In en, this message translates to:
  /// **'Only up to 10 pages can be analyzed. Keep this original or provide a shorter PDF.'**
  String get pdfLimit;

  /// No description provided for @sharedReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 shared source is ready} other{{count} shared sources are ready}}'**
  String sharedReady(int count);

  /// No description provided for @sharedAsMatters.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{It will be saved as one matter.} other{They will be saved as {count} separate matters.}}'**
  String sharedAsMatters(int count);

  /// No description provided for @discardCapture.
  ///
  /// In en, this message translates to:
  /// **'Discard capture'**
  String get discardCapture;

  /// No description provided for @discardCaptureBody.
  ///
  /// In en, this message translates to:
  /// **'This pending delivery will be deleted. Matters already saved will be kept.'**
  String get discardCaptureBody;

  /// No description provided for @detectedDate.
  ///
  /// In en, this message translates to:
  /// **'Detected date'**
  String get detectedDate;

  /// No description provided for @detectedFact.
  ///
  /// In en, this message translates to:
  /// **'Detected fact'**
  String get detectedFact;

  /// No description provided for @correctedFact.
  ///
  /// In en, this message translates to:
  /// **'Corrected fact'**
  String get correctedFact;

  /// No description provided for @originalValue.
  ///
  /// In en, this message translates to:
  /// **'Original value'**
  String get originalValue;

  /// No description provided for @checkOriginal.
  ///
  /// In en, this message translates to:
  /// **'Check this fact against the original before using it.'**
  String get checkOriginal;

  /// No description provided for @proposedReminder.
  ///
  /// In en, this message translates to:
  /// **'Proposed reminder'**
  String get proposedReminder;

  /// No description provided for @calendarMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 calendar month} other{{count} calendar months}}'**
  String calendarMonths(int count);

  /// No description provided for @calendarDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String calendarDays(int count);

  /// No description provided for @pageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page {count}'**
  String pageNumber(int count);

  /// No description provided for @analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze source'**
  String get analyze;

  /// No description provided for @analyzeAgain.
  ///
  /// In en, this message translates to:
  /// **'Analyze again'**
  String get analyzeAgain;

  /// No description provided for @analysisConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze with AI'**
  String get analysisConsentTitle;

  /// No description provided for @analysisConsentBody.
  ///
  /// In en, this message translates to:
  /// **'A prepared copy of this source will be sent to Supabase and OpenAI to extract facts and suggestions. An anonymous session will be created if needed. Your original stays here. This does not enable sync or backup. You can disable this in Settings.'**
  String get analysisConsentBody;

  /// No description provided for @analysisConsent.
  ///
  /// In en, this message translates to:
  /// **'Allow AI analysis'**
  String get analysisConsent;

  /// No description provided for @analysisConsentShort.
  ///
  /// In en, this message translates to:
  /// **'Send only sources you choose. Analysis never creates reminders automatically.'**
  String get analysisConsentShort;

  /// No description provided for @analysisQueued.
  ///
  /// In en, this message translates to:
  /// **'Saved · awaiting analysis'**
  String get analysisQueued;

  /// No description provided for @analysisRunning.
  ///
  /// In en, this message translates to:
  /// **'Analyzing source…'**
  String get analysisRunning;

  /// No description provided for @analysisRetry.
  ///
  /// In en, this message translates to:
  /// **'Waiting to retry'**
  String get analysisRetry;

  /// No description provided for @analysisReady.
  ///
  /// In en, this message translates to:
  /// **'Analysis ready · review suggestions'**
  String get analysisReady;

  /// No description provided for @analysisPaused.
  ///
  /// In en, this message translates to:
  /// **'Analysis is disabled in Settings.'**
  String get analysisPaused;

  /// No description provided for @analysisCoverage.
  ///
  /// In en, this message translates to:
  /// **'Check coverage and evidence before confirming an action.'**
  String get analysisCoverage;

  /// No description provided for @analysisPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial analysis: some pages have not been reviewed.'**
  String get analysisPartial;

  /// No description provided for @analysisTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This source exceeds the analysis limit. The original is saved; import a smaller copy.'**
  String get analysisTooLarge;

  /// No description provided for @analysisTooManyPages.
  ///
  /// In en, this message translates to:
  /// **'This PDF has more than 10 pages. Import a copy containing the relevant pages for analysis. Your original is kept.'**
  String get analysisTooManyPages;

  /// No description provided for @analysisUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This source cannot be read. Enter details manually or import another copy.'**
  String get analysisUnreadable;

  /// No description provided for @analysisNetwork.
  ///
  /// In en, this message translates to:
  /// **'The connection could not be completed. Your source is still saved.'**
  String get analysisNetwork;

  /// No description provided for @analysisQuota.
  ///
  /// In en, this message translates to:
  /// **'An analysis limit has been reached. Existing documents and reminders remain available.'**
  String get analysisQuota;

  /// No description provided for @analysisSession.
  ///
  /// In en, this message translates to:
  /// **'There is no valid session for analysis. Check your account in Settings.'**
  String get analysisSession;

  /// No description provided for @analysisConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Analysis is unavailable. You can still save sources and enter details manually.'**
  String get analysisConfiguration;

  /// No description provided for @analysisInvalid.
  ///
  /// In en, this message translates to:
  /// **'The result could not be validated. No suggestions or reminders were created.'**
  String get analysisInvalid;

  /// No description provided for @analysisIndeterminate.
  ///
  /// In en, this message translates to:
  /// **'We cannot confirm whether the provider finished analysis. This request will not be repeated automatically.'**
  String get analysisIndeterminate;

  /// No description provided for @analysisStale.
  ///
  /// In en, this message translates to:
  /// **'This result no longer matches the current account or source.'**
  String get analysisStale;

  /// No description provided for @analysisNewRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Start another analysis?'**
  String get analysisNewRequestTitle;

  /// No description provided for @analysisNewRequestBody.
  ///
  /// In en, this message translates to:
  /// **'A new request may use another analysis from your quota. Corrected facts and accepted actions will be kept.'**
  String get analysisNewRequestBody;

  /// No description provided for @analysisContextOmitted.
  ///
  /// In en, this message translates to:
  /// **'Accompanying text is saved with the matter; this analysis reviews only the file.'**
  String get analysisContextOmitted;

  /// No description provided for @analysisUncertainty.
  ///
  /// In en, this message translates to:
  /// **'Uncertain fact'**
  String get analysisUncertainty;

  /// No description provided for @analysisReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested title'**
  String get analysisReviewTitle;

  /// No description provided for @analysisNoActions.
  ///
  /// In en, this message translates to:
  /// **'No actions were suggested. Saving without a date is still valid.'**
  String get analysisNoActions;

  /// No description provided for @reviewAction.
  ///
  /// In en, this message translates to:
  /// **'Review suggestion'**
  String get reviewAction;

  /// No description provided for @remindAction.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindAction;

  /// No description provided for @eventAction.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get eventAction;

  /// No description provided for @keepAction.
  ///
  /// In en, this message translates to:
  /// **'Just save'**
  String get keepAction;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose time'**
  String get chooseTime;

  /// No description provided for @timeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get timeZone;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTime;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @endDateExclusive.
  ///
  /// In en, this message translates to:
  /// **'The end date is not included.'**
  String get endDateExclusive;

  /// No description provided for @locationOptional.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get locationOptional;

  /// No description provided for @confirmTemporal.
  ///
  /// In en, this message translates to:
  /// **'Check date, time and zone. A detected date does not create a reminder on its own.'**
  String get confirmTemporal;

  /// No description provided for @invalidTemporal.
  ///
  /// In en, this message translates to:
  /// **'Complete the date and time, using a valid zone and interval.'**
  String get invalidTemporal;

  /// No description provided for @nonexistentTime.
  ///
  /// In en, this message translates to:
  /// **'This local time does not exist due to a clock change. Choose another time.'**
  String get nonexistentTime;

  /// No description provided for @ambiguousTime.
  ///
  /// In en, this message translates to:
  /// **'This time occurs twice. Choose the correct occurrence.'**
  String get ambiguousTime;

  /// No description provided for @sameDate.
  ///
  /// In en, this message translates to:
  /// **'That day'**
  String get sameDate;

  /// No description provided for @dayBefore.
  ///
  /// In en, this message translates to:
  /// **'One day before'**
  String get dayBefore;

  /// No description provided for @weekBefore.
  ///
  /// In en, this message translates to:
  /// **'One week before'**
  String get weekBefore;

  /// No description provided for @monthBefore.
  ///
  /// In en, this message translates to:
  /// **'One calendar month before'**
  String get monthBefore;

  /// No description provided for @monthClamped.
  ///
  /// In en, this message translates to:
  /// **'Adjusted to the last day of the month.'**
  String get monthClamped;

  /// No description provided for @reminderScheduled.
  ///
  /// In en, this message translates to:
  /// **'Reminder scheduled on this device.'**
  String get reminderScheduled;

  /// No description provided for @reminderNotScheduled.
  ///
  /// In en, this message translates to:
  /// **'Reminder saved, but not scheduled on this device. Check notification permission or capacity.'**
  String get reminderNotScheduled;

  /// No description provided for @calendarSaved.
  ///
  /// In en, this message translates to:
  /// **'Event saved to your calendar.'**
  String get calendarSaved;

  /// No description provided for @calendarOpened.
  ///
  /// In en, this message translates to:
  /// **'Calendar opened. Kipto cannot confirm whether you saved the event.'**
  String get calendarOpened;

  /// No description provided for @calendarCancelled.
  ///
  /// In en, this message translates to:
  /// **'No event was saved.'**
  String get calendarCancelled;

  /// No description provided for @calendarUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Calendar is unavailable on this device.'**
  String get calendarUnavailable;

  /// No description provided for @keepExplained.
  ///
  /// In en, this message translates to:
  /// **'Keep the document without creating dates. If no future reminders exist, other suggestions will be dismissed and the matter will move to Archive.'**
  String get keepExplained;

  /// No description provided for @keptResult.
  ///
  /// In en, this message translates to:
  /// **'Document kept. Existing reminders have not been cancelled.'**
  String get keptResult;

  /// No description provided for @dismissProposal.
  ///
  /// In en, this message translates to:
  /// **'Dismiss suggestion'**
  String get dismissProposal;

  /// No description provided for @proposedAction.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get proposedAction;

  /// No description provided for @acceptedAction.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get acceptedAction;

  /// No description provided for @reopenCalendar.
  ///
  /// In en, this message translates to:
  /// **'Reopen calendar'**
  String get reopenCalendar;

  /// No description provided for @reopenCalendarBody.
  ///
  /// In en, this message translates to:
  /// **'The event may already exist. Check your calendar before creating another copy.'**
  String get reopenCalendarBody;

  /// No description provided for @resolveMatter.
  ///
  /// In en, this message translates to:
  /// **'Resolve matter'**
  String get resolveMatter;

  /// No description provided for @reopenMatter.
  ///
  /// In en, this message translates to:
  /// **'Return to Pending'**
  String get reopenMatter;

  /// No description provided for @archiveMatter.
  ///
  /// In en, this message translates to:
  /// **'Archive matter'**
  String get archiveMatter;

  /// No description provided for @archiveReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Archiving will cancel this matter’s future reminders. Calendar events will remain unchanged.'**
  String get archiveReminderBody;

  /// No description provided for @resolveReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Resolving will cancel pending reminders and keep the document in Archive. Undo only reschedules valid future reminders.'**
  String get resolveReminderBody;

  /// No description provided for @editMatter.
  ///
  /// In en, this message translates to:
  /// **'Edit title and summary'**
  String get editMatter;

  /// No description provided for @matterTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get matterTitle;

  /// No description provided for @matterSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get matterSummary;

  /// No description provided for @actionTitle.
  ///
  /// In en, this message translates to:
  /// **'Action title'**
  String get actionTitle;

  /// No description provided for @savedChange.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get savedChange;

  /// No description provided for @lifecycleFailed.
  ///
  /// In en, this message translates to:
  /// **'The operation did not complete. Check saved state and notification permissions before retrying.'**
  String get lifecycleFailed;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @viewEvidence.
  ///
  /// In en, this message translates to:
  /// **'View source for this fact'**
  String get viewEvidence;

  /// No description provided for @pendingReminder.
  ///
  /// In en, this message translates to:
  /// **'Pending reminder'**
  String get pendingReminder;

  /// No description provided for @completedReminder.
  ///
  /// In en, this message translates to:
  /// **'Cancelled or completed reminder'**
  String get completedReminder;

  /// No description provided for @cancelReminder.
  ///
  /// In en, this message translates to:
  /// **'Cancel reminder'**
  String get cancelReminder;

  /// No description provided for @cancelReminderBody.
  ///
  /// In en, this message translates to:
  /// **'This reminder will be cancelled. The matter will stay in Pending.'**
  String get cancelReminderBody;

  /// No description provided for @noReminderCreated.
  ///
  /// In en, this message translates to:
  /// **'Saving does not create a reminder.'**
  String get noReminderCreated;

  /// No description provided for @factValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get factValue;

  /// No description provided for @rawDate.
  ///
  /// In en, this message translates to:
  /// **'Date as written'**
  String get rawDate;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency (optional)'**
  String get currency;

  /// No description provided for @durationCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get durationCount;

  /// No description provided for @durationUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get durationUnit;

  /// No description provided for @calendarDayUnit.
  ///
  /// In en, this message translates to:
  /// **'Calendar days'**
  String get calendarDayUnit;

  /// No description provided for @calendarMonthUnit.
  ///
  /// In en, this message translates to:
  /// **'Calendar months'**
  String get calendarMonthUnit;

  /// No description provided for @clearDate.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed date'**
  String get clearDate;

  /// No description provided for @clearTime.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed time'**
  String get clearTime;

  /// No description provided for @factCorrectionBody.
  ///
  /// In en, this message translates to:
  /// **'Corrections preserve the original extraction and evidence. Existing confirmed reminders remain unchanged.'**
  String get factCorrectionBody;

  /// No description provided for @reviewGroup.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get reviewGroup;

  /// No description provided for @datedGroup.
  ///
  /// In en, this message translates to:
  /// **'With a date'**
  String get datedGroup;

  /// No description provided for @otherGroup.
  ///
  /// In en, this message translates to:
  /// **'Other matters'**
  String get otherGroup;

  /// No description provided for @sourceLocal.
  ///
  /// In en, this message translates to:
  /// **'Original on this device'**
  String get sourceLocal;

  /// No description provided for @sourceMissing.
  ///
  /// In en, this message translates to:
  /// **'Original unavailable on this device'**
  String get sourceMissing;

  /// No description provided for @reimportSource.
  ///
  /// In en, this message translates to:
  /// **'Import another copy'**
  String get reimportSource;

  /// No description provided for @searchResultCount.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get searchResultCount;

  /// No description provided for @backupConsent.
  ///
  /// In en, this message translates to:
  /// **'Original file backup'**
  String get backupConsent;

  /// No description provided for @backupConsentBody.
  ///
  /// In en, this message translates to:
  /// **'With Kipto Pro, upload originals to your private backup (up to 1 GiB). Requires metadata sync. Turning this off keeps existing backups.'**
  String get backupConsentBody;

  /// No description provided for @backupPending.
  ///
  /// In en, this message translates to:
  /// **'{count} files awaiting transfer'**
  String backupPending(int count);

  /// No description provided for @backupReady.
  ///
  /// In en, this message translates to:
  /// **'Backup confirmed'**
  String get backupReady;

  /// No description provided for @backupTransfer.
  ///
  /// In en, this message translates to:
  /// **'{sent} of {total} bytes transferred; awaiting confirmation'**
  String backupTransfer(int sent, int total);

  /// No description provided for @backupProRequired.
  ///
  /// In en, this message translates to:
  /// **'New backups require Kipto Pro. Your original is still on this device.'**
  String get backupProRequired;

  /// No description provided for @downloadBackup.
  ///
  /// In en, this message translates to:
  /// **'Download backup, if available'**
  String get downloadBackup;

  /// No description provided for @signOutWarning.
  ///
  /// In en, this message translates to:
  /// **'This device’s library will be removed. There are {changes} matters with pending changes and {originals} originals without a backup confirmed here. You can cancel and export them before signing out.'**
  String signOutWarning(int changes, int originals);

  /// No description provided for @proHeadline.
  ///
  /// In en, this message translates to:
  /// **'More help.\nAll at hand.'**
  String get proHeadline;

  /// No description provided for @proBody.
  ///
  /// In en, this message translates to:
  /// **'More analyses and a private backup of your originals.'**
  String get proBody;

  /// No description provided for @proAnalysis.
  ///
  /// In en, this message translates to:
  /// **'100 analyses per month'**
  String get proAnalysis;

  /// No description provided for @proBackup.
  ///
  /// In en, this message translates to:
  /// **'Up to 1 GiB of originals'**
  String get proBackup;

  /// No description provided for @proVerified.
  ///
  /// In en, this message translates to:
  /// **'Kipto Pro verified by the server'**
  String get proVerified;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free plan · 5 analyses per month'**
  String get freePlan;

  /// No description provided for @billingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not available yet. You can still save items and create manual reminders.'**
  String get billingUnavailable;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'The store is awaiting payment approval.'**
  String get paymentPending;

  /// No description provided for @purchaseVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Purchase received by the store. Your limits will increase when the server verifies your entitlement.'**
  String get purchaseVerificationPending;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyPlan;

  /// No description provided for @annualPlan.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annualPlan;

  /// No description provided for @subscriptionTerms.
  ///
  /// In en, this message translates to:
  /// **'Automatically renews for the period shown. Review the final price and terms in the store before confirming. Saving, viewing and existing reminders remain available if you cancel.'**
  String get subscriptionTerms;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @restorePurchaseBody.
  ///
  /// In en, this message translates to:
  /// **'Purchases checked. Restoring purchases does not restore documents from another account.'**
  String get restorePurchaseBody;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// No description provided for @noSubscription.
  ///
  /// In en, this message translates to:
  /// **'There is no active subscription to manage.'**
  String get noSubscription;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get refreshStatus;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportData;

  /// No description provided for @exportBody.
  ///
  /// In en, this message translates to:
  /// **'Prepare a ZIP with the selected data and available originals. If files are missing, cancel and download them from their details before exporting.'**
  String get exportBody;

  /// No description provided for @exportComplete.
  ///
  /// In en, this message translates to:
  /// **'All selected originals are included.'**
  String get exportComplete;

  /// No description provided for @exportMissing.
  ///
  /// In en, this message translates to:
  /// **'{count} originals are missing. The manifest identifies them.'**
  String exportMissing(int count);

  /// No description provided for @saveExport.
  ///
  /// In en, this message translates to:
  /// **'Save or share ZIP'**
  String get saveExport;

  /// No description provided for @deleteMatter.
  ///
  /// In en, this message translates to:
  /// **'Delete matter'**
  String get deleteMatter;

  /// No description provided for @deleteMatterBody.
  ///
  /// In en, this message translates to:
  /// **'The matter and its sources will be deleted, and its reminders cancelled. Remote file deletion may remain pending until connectivity returns. This cannot be undone.'**
  String get deleteMatterBody;

  /// No description provided for @deletePending.
  ///
  /// In en, this message translates to:
  /// **'Deletion requested. Some steps remain pending; check transfers in Settings.'**
  String get deletePending;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Your account, Kipto data and original file backups will be deleted. Export anything you want to keep first. This cannot be undone. Store subscriptions are not automatically cancelled: you can manage yours in Kipto Pro before continuing, but cancellation is not required to delete your account.'**
  String get deleteAccountBody;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @accountDeletionPending.
  ///
  /// In en, this message translates to:
  /// **'Deletion in progress'**
  String get accountDeletionPending;

  /// No description provided for @accountDeletionWait.
  ///
  /// In en, this message translates to:
  /// **'New transfers are blocked. If an upload was in progress, deletion will wait up to five minutes to avoid leaving files behind. Retry while connected; the request is kept if you close the app.'**
  String get accountDeletionWait;

  /// No description provided for @notificationsThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Reminders on this device'**
  String get notificationsThisDevice;

  /// No description provided for @notificationsDevicesBody.
  ///
  /// In en, this message translates to:
  /// **'If reminders are enabled on two devices, both may notify you. System permission must also be enabled.'**
  String get notificationsDevicesBody;

  /// No description provided for @notificationTitles.
  ///
  /// In en, this message translates to:
  /// **'Include titles in notifications'**
  String get notificationTitles;

  /// No description provided for @notificationTitlesBody.
  ///
  /// In en, this message translates to:
  /// **'By default, notifications only say an item needs your attention. Enable this to show the title, including on the lock screen.'**
  String get notificationTitlesBody;

  /// No description provided for @returnToSource.
  ///
  /// In en, this message translates to:
  /// **'Return to source app'**
  String get returnToSource;

  /// No description provided for @deleteSource.
  ///
  /// In en, this message translates to:
  /// **'Delete source'**
  String get deleteSource;

  /// No description provided for @deleteSourceBody.
  ///
  /// In en, this message translates to:
  /// **'This original and its extracted data will be deleted, and related reminders cancelled. The matter is kept. This cannot be undone.'**
  String get deleteSourceBody;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
