import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('tr'),
    Locale('es'),
    Locale('pt'),
    Locale('pt', 'br'),
    Locale('ar'),
    Locale('de'),
    Locale('fr'),
    Locale('id'),
    Locale('hi'),
    Locale('ru'),
    Locale('it'),
    Locale('pt', 'BR'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Quicko'**
  String get appName;

  /// Title for the Blind Sort game
  ///
  /// In en, this message translates to:
  /// **'Blind Sort'**
  String get blindSort;

  /// Description for the Blind Sort game
  ///
  /// In en, this message translates to:
  /// **'Sort 10 numbers from 1-50. You lose if the new number doesn\'t fit anywhere!'**
  String get blindSortDescription;

  /// Label for the next number in Blind Sort
  ///
  /// In en, this message translates to:
  /// **'Next Number'**
  String get nextNumber;

  /// Message when a new number is about to appear
  ///
  /// In en, this message translates to:
  /// **'New Number Coming...'**
  String get newNumberComing;

  /// Start button text
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Restart button text
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Games navigation label
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// Score label
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// Game over message
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Fullscreen button text
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreen;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Title for the Higher or Lower game
  ///
  /// In en, this message translates to:
  /// **'Higher or Lower'**
  String get higherLower;

  /// Description for the Higher or Lower game
  ///
  /// In en, this message translates to:
  /// **'Guess if the next number will be higher or lower! Numbers are between 1-50.'**
  String get higherLowerDescription;

  /// Higher button text
  ///
  /// In en, this message translates to:
  /// **'Higher'**
  String get higher;

  /// Lower button text
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get lower;

  /// Label for the last number
  ///
  /// In en, this message translates to:
  /// **'Last Number'**
  String get lastNumber;

  /// Message when all targets are completed
  ///
  /// In en, this message translates to:
  /// **'Completed all targets!'**
  String get completedAllTargets;

  /// Label for targets
  ///
  /// In en, this message translates to:
  /// **'Targets'**
  String get targets;

  /// Continue game dialog title
  ///
  /// In en, this message translates to:
  /// **'Continue Game'**
  String get continueGame;

  /// Watch ad to continue button text
  ///
  /// In en, this message translates to:
  /// **'Watch Ad to Continue'**
  String get watchAdToContinue;

  /// Button text for ad-free users to continue game once
  ///
  /// In en, this message translates to:
  /// **'1-Time Continue'**
  String get oneTimeContinue;

  /// Description for continue game option
  ///
  /// In en, this message translates to:
  /// **'Continue your game from where you left off.'**
  String get continueGameDescription;

  /// Message shown when ad-free user has already used their one-time continue
  ///
  /// In en, this message translates to:
  /// **'You have already used your one-time continue for this game session.'**
  String get oneTimeContinueUsed;

  /// Description for watching ad to continue game
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to continue your game from where you left off.'**
  String get watchAdToContinueDescription;

  /// Title for cancel subscription screen
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// Description for cancel subscription screen
  ///
  /// In en, this message translates to:
  /// **'Cancel your ad-free subscription and return to ads'**
  String get cancelSubscriptionDescription;

  /// Title for cancel subscription error
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription Error'**
  String get cancelSubscriptionError;

  /// Description for cancel subscription error
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel your subscription. Please try again or contact support.'**
  String get cancelSubscriptionErrorDescription;

  /// Ad not available dialog title
  ///
  /// In en, this message translates to:
  /// **'Ad Not Available'**
  String get adNotAvailable;

  /// Ad not available message
  ///
  /// In en, this message translates to:
  /// **'No ads are currently available. Please try again later.'**
  String get adNotAvailableMessage;

  /// Ad failed dialog title
  ///
  /// In en, this message translates to:
  /// **'Ad Failed'**
  String get adFailed;

  /// Ad failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to show ad. Please try again.'**
  String get adFailedMessage;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Exit button text
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// Stay button text
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// Text shown when there are more items to display
  ///
  /// In en, this message translates to:
  /// **'and more...'**
  String get andMore;

  /// Mission failed message
  ///
  /// In en, this message translates to:
  /// **'Mission Failed!'**
  String get missionFailed;

  /// Green target hit message
  ///
  /// In en, this message translates to:
  /// **'Green target hit!'**
  String get greenTargetHit;

  /// All targets hit message
  ///
  /// In en, this message translates to:
  /// **'You hit all targets!'**
  String get youHitAllTargets;

  /// Message indicating time ran out
  ///
  /// In en, this message translates to:
  /// **'Time ran out!'**
  String get timeRanOut;

  /// Targets hit label
  ///
  /// In en, this message translates to:
  /// **'Targets Hit'**
  String get targetsHit;

  /// Mistake label
  ///
  /// In en, this message translates to:
  /// **'Mistake'**
  String get mistake;

  /// Civilian hit message
  ///
  /// In en, this message translates to:
  /// **'Civilian Hit'**
  String get civilianHit;

  /// All colors found message
  ///
  /// In en, this message translates to:
  /// **'You found all colors!'**
  String get youFoundAllColors;

  /// Colors found label
  ///
  /// In en, this message translates to:
  /// **'Colors Found'**
  String get colorsFound;

  /// Last mistake label
  ///
  /// In en, this message translates to:
  /// **'Last Mistake'**
  String get lastMistake;

  /// Wrong color message
  ///
  /// In en, this message translates to:
  /// **'Wrong Color'**
  String get wrongColor;

  /// Label for the current number
  ///
  /// In en, this message translates to:
  /// **'Current Number'**
  String get currentNumber;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Message shown when player loses
  ///
  /// In en, this message translates to:
  /// **'Better luck next time!'**
  String get betterLuckNextTime;

  /// Title for losing numbers section
  ///
  /// In en, this message translates to:
  /// **'Numbers That Caused Loss'**
  String get losingNumbers;

  /// Label for the number that caused loss
  ///
  /// In en, this message translates to:
  /// **'Number That Caused Loss'**
  String get losingNumber;

  /// Title for the Color Hunt game
  ///
  /// In en, this message translates to:
  /// **'Color Hunt'**
  String get colorHunt;

  /// Description for the Color Hunt game
  ///
  /// In en, this message translates to:
  /// **'Find the target color! The text color might trick you!'**
  String get colorHuntDescription;

  /// Target label
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Message when wrong color is selected
  ///
  /// In en, this message translates to:
  /// **'Wrong Color Selected'**
  String get wrongColorSelected;

  /// Message when player loses due to wrong color selection
  ///
  /// In en, this message translates to:
  /// **'Wrong Color Selection'**
  String get wrongColorSelection;

  /// Favorites navigation label
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Message when loading favorites
  ///
  /// In en, this message translates to:
  /// **'Loading Favorites...'**
  String get loadingFavorites;

  /// Message when no favorites exist
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get noFavoritesYet;

  /// Instruction to add games to favorites
  ///
  /// In en, this message translates to:
  /// **'Add games to favorites for quick access'**
  String get addGamesToFavorites;

  /// Browse games button text
  ///
  /// In en, this message translates to:
  /// **'Browse Games'**
  String get browseGames;

  /// Title for the Aim Trainer game
  ///
  /// In en, this message translates to:
  /// **'Aim Trainer'**
  String get aimTrainer;

  /// Description for the Aim Trainer game
  ///
  /// In en, this message translates to:
  /// **'Try to shoot the randomly appearing red targets for 20 seconds. Each hit is 1 point!'**
  String get aimTrainerDescription;

  /// Title for the Number Memory game
  ///
  /// In en, this message translates to:
  /// **'Number Memory'**
  String get numberMemory;

  /// Description for the Number Memory game
  ///
  /// In en, this message translates to:
  /// **'Memorize the sequence of numbers and enter it correctly using the keypad. How many digits can you remember?'**
  String get numberMemoryDescription;

  /// Title for the Find the Difference game
  ///
  /// In en, this message translates to:
  /// **'Find the Difference'**
  String get findDifference;

  /// Description for the Find the Difference game
  ///
  /// In en, this message translates to:
  /// **'Find the one square with a different color. It gets harder with each round!'**
  String get findDifferenceDescription;

  /// Title for the Rock-Paper-Scissors game
  ///
  /// In en, this message translates to:
  /// **'Rock-Paper-Scissors'**
  String get rockPaperScissors;

  /// Description for the Rock-Paper-Scissors game
  ///
  /// In en, this message translates to:
  /// **'Play against the computer. First to 5 points wins.'**
  String get rockPaperScissorsDescription;

  /// Title for the 21 (Blackjack) game
  ///
  /// In en, this message translates to:
  /// **'21 (Blackjack)'**
  String get twentyOne;

  /// Description for the 21 (Blackjack) game
  ///
  /// In en, this message translates to:
  /// **'Beat the dealer to 21! Get as close as possible without going over.'**
  String get twentyOneDescription;

  /// Title for the Tic Tac Toe game
  ///
  /// In en, this message translates to:
  /// **'Tic Tac Toe'**
  String get ticTacToe;

  /// Description for the Tic Tac Toe game
  ///
  /// In en, this message translates to:
  /// **'Play against the computer! Get three in a row to win.'**
  String get ticTacToeDescription;

  /// Message indicating it's the player's turn
  ///
  /// In en, this message translates to:
  /// **'Now, your turn!'**
  String get nowYourTurn;

  /// Message when answer is correct
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// Playing status label
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playing;

  /// Instruction to start guessing in Higher or Lower
  ///
  /// In en, this message translates to:
  /// **'Tap Higher or Lower to start guessing! Numbers are between 1-50.'**
  String get tapToStartGuessing;

  /// Information about number range
  ///
  /// In en, this message translates to:
  /// **'Numbers are between 1-50'**
  String get numbersBetween1And50;

  /// Leaderboard navigation label
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// Message when no leaderboard data exists
  ///
  /// In en, this message translates to:
  /// **'No Leaderboard Data'**
  String get noLeaderboardData;

  /// Instruction to play games to see scores
  ///
  /// In en, this message translates to:
  /// **'Play games to see your high scores here!'**
  String get playGamesToSeeScores;

  /// Play games button text
  ///
  /// In en, this message translates to:
  /// **'Play Games'**
  String get playGames;

  /// Hint text for swipe to delete functionality
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete high scores'**
  String get swipeToDeleteHint;

  /// Remove ads subscription option
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get removeAds;

  /// Description for remove ads subscription
  ///
  /// In en, this message translates to:
  /// **'Enjoy an ad-free experience with one-time payment'**
  String get removeAdsDescription;

  /// Monthly subscription text
  ///
  /// In en, this message translates to:
  /// **'Monthly subscription'**
  String get monthlySubscription;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buyNow;

  /// Restore purchases button text
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// Subscription active status
  ///
  /// In en, this message translates to:
  /// **'Subscription Active'**
  String get subscriptionActive;

  /// Subscription expired status
  ///
  /// In en, this message translates to:
  /// **'Subscription Expired'**
  String get subscriptionExpired;

  /// No description provided for @purchasedOn.
  ///
  /// In en, this message translates to:
  /// **'Purchased on: {date}'**
  String purchasedOn(Object date);

  /// Monthly subscription price display
  ///
  /// In en, this message translates to:
  /// **'Monthly subscription - \$2.49'**
  String get monthlySubscriptionPrice;

  /// Warning about subscription loss when app is uninstalled
  ///
  /// In en, this message translates to:
  /// **'Important: Subscription is stored locally. If you uninstall the app, your subscription will be lost and you\'ll need to purchase again.'**
  String get uninstallWarning;

  /// Important notice title for warnings
  ///
  /// In en, this message translates to:
  /// **'Important Notice'**
  String get importantNotice;

  /// Got it button text
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// Purchase success message
  ///
  /// In en, this message translates to:
  /// **'Purchase Successful!'**
  String get purchaseSuccess;

  /// Purchase error message
  ///
  /// In en, this message translates to:
  /// **'Purchase Failed'**
  String get purchaseError;

  /// Restore success message
  ///
  /// In en, this message translates to:
  /// **'Purchases Restored!'**
  String get restoreSuccess;

  /// Restore error message
  ///
  /// In en, this message translates to:
  /// **'Restore Failed'**
  String get restoreError;

  /// Feature description for no banner ads
  ///
  /// In en, this message translates to:
  /// **'No banner ads'**
  String get noBannerAds;

  /// Feature description for no interstitial ads
  ///
  /// In en, this message translates to:
  /// **'No interstitial ads'**
  String get noInterstitialAds;

  /// Feature description for no rewarded ads
  ///
  /// In en, this message translates to:
  /// **'No rewarded ads'**
  String get noRewardedAds;

  /// Feature description for clean experience
  ///
  /// In en, this message translates to:
  /// **'Clean, distraction-free experience'**
  String get cleanExperience;

  /// Feature description for cancel anytime
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancelAnytime;

  /// Warning message when canceling subscription
  ///
  /// In en, this message translates to:
  /// **'Canceling your subscription will remove ad-free access and you will see ads again.'**
  String get cancelSubscriptionWarning;

  /// One-time payment price display
  ///
  /// In en, this message translates to:
  /// **'\$2.99'**
  String get subscriptionPrice;

  /// One-time payment label
  ///
  /// In en, this message translates to:
  /// **'One-time payment'**
  String get oneTimePayment;

  /// Best value label
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// Lifetime access label
  ///
  /// In en, this message translates to:
  /// **'LIFETIME ACCESS'**
  String get lifetimeAccess;

  /// Total games label
  ///
  /// In en, this message translates to:
  /// **'Total Games'**
  String get totalGames;

  /// Highest score label
  ///
  /// In en, this message translates to:
  /// **'Highest Score'**
  String get highestScore;

  /// Average score label
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get averageScore;

  /// High score display with score value
  ///
  /// In en, this message translates to:
  /// **'High Score: {score}'**
  String highScore(int score);

  /// Last played date display
  ///
  /// In en, this message translates to:
  /// **'Last Played: {date}'**
  String lastPlayed(String date);

  /// Sort by label
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// Sort by score option
  ///
  /// In en, this message translates to:
  /// **'Sort by Score'**
  String get sortByScore;

  /// Sort by last played option
  ///
  /// In en, this message translates to:
  /// **'Sort by Last Played'**
  String get sortByLastPlayed;

  /// Share achievements button text
  ///
  /// In en, this message translates to:
  /// **'Share Achievements'**
  String get shareAchievements;

  /// Preview image button text
  ///
  /// In en, this message translates to:
  /// **'Preview Image'**
  String get previewImage;

  /// Share image button text
  ///
  /// In en, this message translates to:
  /// **'Share Image'**
  String get shareImage;

  /// Message when no data is available to share
  ///
  /// In en, this message translates to:
  /// **'No data to share yet. Play some games first!'**
  String get shareNoData;

  /// Error message when sharing fails
  ///
  /// In en, this message translates to:
  /// **'Error sharing achievements. Please try again.'**
  String get shareError;

  /// Message when time runs out
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get timeUp;

  /// Message when time runs out
  ///
  /// In en, this message translates to:
  /// **'You ran out of time!'**
  String get timeUpMessage;

  /// Label for final score in 21 game
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get finalScore;

  /// You won message
  ///
  /// In en, this message translates to:
  /// **'You Won!'**
  String get youWon;

  /// Message when computer wins in TicTacToe game
  ///
  /// In en, this message translates to:
  /// **'Computer Won!'**
  String get computerWon;

  /// Draw game message
  ///
  /// In en, this message translates to:
  /// **'It\'s a Draw!'**
  String get itsADraw;

  /// Good game message
  ///
  /// In en, this message translates to:
  /// **'Good Game!'**
  String get goodGame;

  /// Tap to start message
  ///
  /// In en, this message translates to:
  /// **'Tap to Start'**
  String get tapToStart;

  /// Computer thinking message
  ///
  /// In en, this message translates to:
  /// **'Computer is thinking...'**
  String get computerThinking;

  /// Your turn message
  ///
  /// In en, this message translates to:
  /// **'Your Turn'**
  String get yourTurn;

  /// Computer's turn message
  ///
  /// In en, this message translates to:
  /// **'Computer\'s Turn'**
  String get computerTurn;

  /// Title for rating bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Rate Quicko'**
  String get rateQuicko;

  /// Description text for rating bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve and reach more users!'**
  String get rateQuickoDescription;

  /// Question text for rating
  ///
  /// In en, this message translates to:
  /// **'How would you rate Quicko?'**
  String get howWouldYouRate;

  /// Button text to rate on store
  ///
  /// In en, this message translates to:
  /// **'Rate on Store'**
  String get rateOnStore;

  /// Loading text when opening store
  ///
  /// In en, this message translates to:
  /// **'Opening Store...'**
  String get openingStore;

  /// Rating text for 1 star
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get ratingPoor;

  /// Rating text for 2 stars
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get ratingFair;

  /// Rating text for 3 stars
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// Rating text for 4 stars
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get ratingVeryGood;

  /// Rating text for 5 stars
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get ratingExcellent;

  /// Success message after rating
  ///
  /// In en, this message translates to:
  /// **'Thank you for rating Quicko!'**
  String get thankYouForRating;

  /// Error message when store cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open store. Please try again.'**
  String get couldNotOpenStore;

  /// Congratulations message for winning
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You\'ve completed the challenge!'**
  String get congratulationsMessage;

  /// Message for excellent performance
  ///
  /// In en, this message translates to:
  /// **'Excellent performance!'**
  String get excellentPerformance;

  /// Play again button text
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// Delete high score dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete High Score'**
  String get deleteHighScore;

  /// Delete high score confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the high score for this game?'**
  String get deleteHighScoreMessage;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Language settings title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Select language prompt
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Information about language change
  ///
  /// In en, this message translates to:
  /// **'Language changes will be applied immediately. The app will restart to apply the new language.'**
  String get languageChangeInfo;

  /// Text for language selection prompt
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get choosePreferredLanguage;

  /// Sort by date option
  ///
  /// In en, this message translates to:
  /// **'Sort by Date'**
  String get sort_by_date;

  /// Sort by game option
  ///
  /// In en, this message translates to:
  /// **'Sort by Game'**
  String get sort_by_game;

  /// Theme settings title
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Select theme prompt
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Light theme description
  ///
  /// In en, this message translates to:
  /// **'Light theme for bright environments'**
  String get lightThemeDescription;

  /// Dark theme description
  ///
  /// In en, this message translates to:
  /// **'Dark theme for low-light environments'**
  String get darkThemeDescription;

  /// System theme description
  ///
  /// In en, this message translates to:
  /// **'Follows your device theme setting'**
  String get systemThemeDescription;

  /// Information about theme changes
  ///
  /// In en, this message translates to:
  /// **'Theme changes will be applied immediately throughout the app.'**
  String get themeChangeInfo;

  /// Text for theme selection prompt
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred theme'**
  String get choosePreferredTheme;

  /// Start game button text
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// Restart game button text
  ///
  /// In en, this message translates to:
  /// **'Restart Game'**
  String get restartGame;

  /// Player label
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Computer opponent label
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get cpu;

  /// Dealer label for card games
  ///
  /// In en, this message translates to:
  /// **'Dealer'**
  String get dealer;

  /// Win message
  ///
  /// In en, this message translates to:
  /// **'You Win!'**
  String get youWin;

  /// Lose message
  ///
  /// In en, this message translates to:
  /// **'You Lose!'**
  String get youLose;

  /// Tie message
  ///
  /// In en, this message translates to:
  /// **'Tie!'**
  String get tie;

  /// Total score label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Red color name
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// Green color name
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// Blue color name
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// Purple color name
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// Orange color name
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orange;

  /// Yellow color name
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;

  /// Pink color name
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get pink;

  /// Brown color name
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get brown;

  /// Cyan color name
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get cyan;

  /// Lime color name
  ///
  /// In en, this message translates to:
  /// **'Lime'**
  String get lime;

  /// Magenta color name
  ///
  /// In en, this message translates to:
  /// **'Magenta'**
  String get magenta;

  /// Teal color name
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get teal;

  /// Indigo color name
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get indigo;

  /// Amber color name
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get amber;

  /// Deep purple color name
  ///
  /// In en, this message translates to:
  /// **'Deep Purple'**
  String get deep_purple;

  /// Light blue color name
  ///
  /// In en, this message translates to:
  /// **'Light Blue'**
  String get light_blue;

  /// Play button text
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// App settings title
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// App settings description
  ///
  /// In en, this message translates to:
  /// **'Customize your app experience'**
  String get customizeAppExperience;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Hit button text for 21 game
  ///
  /// In en, this message translates to:
  /// **'Hit'**
  String get hit;

  /// Stand button text for 21 game
  ///
  /// In en, this message translates to:
  /// **'Stand'**
  String get stand;

  /// Title for the Reaction Time game
  ///
  /// In en, this message translates to:
  /// **'Reaction Time'**
  String get reactionTime;

  /// Description for the Reaction Time game
  ///
  /// In en, this message translates to:
  /// **'Click the numbers from 1 to 12 in the correct order as fast as you can. Your time will be measured (lower is better).'**
  String get reactionTimeDescription;

  /// Wrong sequence message for reaction time game
  ///
  /// In en, this message translates to:
  /// **'Wrong sequence!'**
  String get wrongSequence;

  /// Congratulations message
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// Next label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Label for numbers sorted in Blind Sort game
  ///
  /// In en, this message translates to:
  /// **'Numbers Sorted'**
  String get numbersSorted;

  /// Label for numbers remembered in Number Memory game
  ///
  /// In en, this message translates to:
  /// **'Numbers Remembered'**
  String get numbersRemembered;

  /// Label for correct guesses in Higher Lower game
  ///
  /// In en, this message translates to:
  /// **'Correct Guesses'**
  String get correctGuesses;

  /// Label for player's score in TicTacToe game
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// Label for CPU score in RPS game
  ///
  /// In en, this message translates to:
  /// **'CPU Score'**
  String get cpuScore;

  /// Label for result in 21 game
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// Message when player goes over 21
  ///
  /// In en, this message translates to:
  /// **'Bust!'**
  String get bust;

  /// Message for wrong number in Number Memory
  ///
  /// In en, this message translates to:
  /// **'Wrong Number'**
  String get wrongNumber;

  /// Success message for Blind Sort game
  ///
  /// In en, this message translates to:
  /// **'You successfully sorted all numbers!'**
  String get youSuccessfullySortedAllNumbers;

  /// Success message for Number Memory game
  ///
  /// In en, this message translates to:
  /// **'You remembered all numbers!'**
  String get youRememberedAllNumbers;

  /// Success message for Higher Lower game
  ///
  /// In en, this message translates to:
  /// **'You guessed correctly!'**
  String get youGuessedCorrectly;

  /// Success message for RPS game
  ///
  /// In en, this message translates to:
  /// **'You won the game!'**
  String get youWonTheGame;

  /// Success message for 21 game
  ///
  /// In en, this message translates to:
  /// **'You reached 21!'**
  String get youReached21;

  /// Failure message for 21 game
  ///
  /// In en, this message translates to:
  /// **'You went over 21!'**
  String get youWentOver21;

  /// Label for loss reason section
  ///
  /// In en, this message translates to:
  /// **'Why you lost'**
  String get whyYouLost;

  /// Title for sort leaderboard dialog
  ///
  /// In en, this message translates to:
  /// **'Sort Leaderboard'**
  String get sortLeaderboard;

  /// Sort by name option
  ///
  /// In en, this message translates to:
  /// **'Sort by Name'**
  String get sortByName;

  /// Sort by date option
  ///
  /// In en, this message translates to:
  /// **'Sort by Date'**
  String get sortByDate;

  /// Message for perfect completion time
  ///
  /// In en, this message translates to:
  /// **'Perfect Time!'**
  String get perfectTime;

  /// Message for good completion time
  ///
  /// In en, this message translates to:
  /// **'Good Time!'**
  String get goodTime;

  /// Message for average completion time
  ///
  /// In en, this message translates to:
  /// **'Average Time'**
  String get averageTime;

  /// Message for slow completion time
  ///
  /// In en, this message translates to:
  /// **'Slow Time'**
  String get slowTime;

  /// Message for very slow completion time
  ///
  /// In en, this message translates to:
  /// **'Very Slow Time'**
  String get verySlowTime;

  /// Title for the Pattern Memory game
  ///
  /// In en, this message translates to:
  /// **'Pattern Memory'**
  String get patternMemory;

  /// Description for the Pattern Memory game
  ///
  /// In en, this message translates to:
  /// **'Memorize the pattern on the screen and replicate it. The pattern gets more complex with each level.'**
  String get patternMemoryDescription;

  /// Instructions for the Pattern Memory game
  ///
  /// In en, this message translates to:
  /// **'Memorize the pattern on the screen and replicate it. The pattern gets more complex with each level.'**
  String get patternMemoryInstructions;

  /// Message when wrong pattern is selected
  ///
  /// In en, this message translates to:
  /// **'Wrong Pattern'**
  String get wrongPattern;

  /// Wrong message
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get wrong;

  /// Row label for accessibility
  ///
  /// In en, this message translates to:
  /// **'row'**
  String get row;

  /// Column label for accessibility
  ///
  /// In en, this message translates to:
  /// **'column'**
  String get column;

  /// 50% discount text for subscription
  ///
  /// In en, this message translates to:
  /// **'50% OFF'**
  String get fiftyPercentOff;

  /// Game in progress dialog title
  ///
  /// In en, this message translates to:
  /// **'Game in Progress'**
  String get gameInProgress;

  /// Game in progress confirmation message
  ///
  /// In en, this message translates to:
  /// **'A game is currently in progress. Are you sure you want to exit? Your progress will be lost.'**
  String get gameInProgressMessage;

  /// Stay in game button text
  ///
  /// In en, this message translates to:
  /// **'Stay in Game'**
  String get stayInGame;

  /// Exit game button text
  ///
  /// In en, this message translates to:
  /// **'Exit Game'**
  String get exitGame;

  /// Sound settings screen title
  ///
  /// In en, this message translates to:
  /// **'Sound Settings'**
  String get soundSettings;

  /// Subtitle for sound settings in main settings list
  ///
  /// In en, this message translates to:
  /// **'App sounds and effects level'**
  String get soundSettingsMenuSubtitle;

  /// Header title for app sounds card
  ///
  /// In en, this message translates to:
  /// **'App Sounds'**
  String get appSounds;

  /// Description under app sounds header
  ///
  /// In en, this message translates to:
  /// **'Toggle sounds and adjust effect level'**
  String get appSoundsDescription;

  /// Sounds toggle label
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get sounds;

  /// Sounds enabled label
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get soundsOn;

  /// Sounds disabled label
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get soundsOff;

  /// Effects volume label
  ///
  /// In en, this message translates to:
  /// **'Effects Volume'**
  String get effectsVolume;

  /// Sound test section title
  ///
  /// In en, this message translates to:
  /// **'Sound Test'**
  String get soundTest;

  /// Play sample sound button text
  ///
  /// In en, this message translates to:
  /// **'Play Sample Sound'**
  String get playSampleSound;

  /// Detailed message shown when purchase fails
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete your purchase. Please try again or check your payment method.'**
  String get purchaseErrorDescription;

  /// Detailed message shown when restore fails
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t restore your purchases. Please try again.'**
  String get restoreErrorDescription;

  /// Title shown when no purchases are found to restore
  ///
  /// In en, this message translates to:
  /// **'No Previous Purchases Found'**
  String get noPurchasesFound;

  /// Description shown when no purchases are found to restore
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any previous purchases to restore. Make sure you\'re signed in with the same Apple ID you used for the original purchase.'**
  String get noPurchasesFoundDescription;

  /// Title for network connection errors
  ///
  /// In en, this message translates to:
  /// **'Connection Problem'**
  String get connectionProblem;

  /// Description for network connection errors
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again. A stable connection is required for purchases.'**
  String get connectionProblemDescription;

  /// Title for payment method errors
  ///
  /// In en, this message translates to:
  /// **'Payment Method Issue'**
  String get paymentMethodIssue;

  /// Description for payment method errors
  ///
  /// In en, this message translates to:
  /// **'There\'s an issue with your payment method. Please check your card details or try a different payment method.'**
  String get paymentMethodIssueDescription;

  /// Title for insufficient funds errors
  ///
  /// In en, this message translates to:
  /// **'Insufficient Funds'**
  String get insufficientFunds;

  /// Description for insufficient funds errors
  ///
  /// In en, this message translates to:
  /// **'Your payment method doesn\'t have sufficient funds. Please add money to your account or use a different payment method.'**
  String get insufficientFundsDescription;

  /// Title for cancelled purchases
  ///
  /// In en, this message translates to:
  /// **'Purchase Cancelled'**
  String get purchaseCancelled;

  /// Description for cancelled purchases
  ///
  /// In en, this message translates to:
  /// **'You cancelled the purchase. You can try again anytime.'**
  String get purchaseCancelledDescription;

  /// Title for product not found errors
  ///
  /// In en, this message translates to:
  /// **'Product Not Available'**
  String get productNotAvailable;

  /// Description for product not found errors
  ///
  /// In en, this message translates to:
  /// **'This product is temporarily unavailable. Please try again later or contact support if the issue persists.'**
  String get productNotAvailableDescription;

  /// Title for already owned product errors
  ///
  /// In en, this message translates to:
  /// **'Already Purchased'**
  String get alreadyPurchased;

  /// Description for already owned product errors
  ///
  /// In en, this message translates to:
  /// **'You already own this product. Try restoring your purchases if you\'re not seeing the benefits.'**
  String get alreadyPurchasedDescription;

  /// Title for store not available errors
  ///
  /// In en, this message translates to:
  /// **'Store Unavailable'**
  String get storeUnavailable;

  /// Description for store not available errors
  ///
  /// In en, this message translates to:
  /// **'The app store is temporarily unavailable. Please try again in a few minutes.'**
  String get storeUnavailableDescription;

  /// Title for restore failures
  ///
  /// In en, this message translates to:
  /// **'Restore Failed'**
  String get restoreFailed;

  /// Description for restore failures
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t restore your purchases. Please check your internet connection and try again.'**
  String get restoreFailedDescription;

  /// Feedback screen title
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Feedback and suggestions menu item title
  ///
  /// In en, this message translates to:
  /// **'Feedback & Suggestions'**
  String get feedbackAndSuggestions;

  /// Feedback and suggestions menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts and help us improve'**
  String get feedbackAndSuggestionsSubtitle;

  /// Direct contact section title
  ///
  /// In en, this message translates to:
  /// **'Direct Contact'**
  String get directContact;

  /// Description for direct contact section
  ///
  /// In en, this message translates to:
  /// **'If the feedback form doesn\'t work, you can contact us directly at:'**
  String get directContactDescription;

  /// Send feedback button text
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// Sending feedback loading text
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// Success message when feedback is sent
  ///
  /// In en, this message translates to:
  /// **'✅ Feedback sent successfully! Thank you for your input.'**
  String get feedbackSentSuccess;

  /// Description text shown in feedback success bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback! We appreciate your input and will review it carefully.'**
  String get feedbackSuccessDescription;

  /// Button text for closing feedback success bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get feedbackSuccessGotIt;

  /// Title shown in feedback error bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Email Could Not Be Sent'**
  String get feedbackErrorTitle;

  /// Description text shown in feedback error bottom sheet
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send your feedback at this time. Please try again later or contact us directly at quickogamehelp@gmail.com'**
  String get feedbackErrorDescription;

  /// Error message when feedback sending fails
  ///
  /// In en, this message translates to:
  /// **'❌ {errorMessage}. Please try again or use the direct email option above.'**
  String feedbackSentError(String errorMessage);

  /// Bug report category
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get feedbackCategoryBug;

  /// Feature request category
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get feedbackCategoryFeature;

  /// Improvement suggestion category
  ///
  /// In en, this message translates to:
  /// **'Improvement Suggestion'**
  String get feedbackCategoryImprovement;

  /// General feedback category
  ///
  /// In en, this message translates to:
  /// **'General Feedback'**
  String get feedbackCategoryGeneral;

  /// Feedback category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get feedbackCategory;

  /// Feedback title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get feedbackTitle;

  /// Hint text for feedback title field
  ///
  /// In en, this message translates to:
  /// **'Brief description of your feedback'**
  String get feedbackTitleHint;

  /// Feedback description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get feedbackDescription;

  /// Hint text for feedback description field
  ///
  /// In en, this message translates to:
  /// **'Please provide detailed information about your feedback...'**
  String get feedbackDescriptionHint;

  /// Feedback email field label
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get feedbackEmail;

  /// Hint text for feedback email field
  ///
  /// In en, this message translates to:
  /// **'your.email@example.com'**
  String get feedbackEmailHint;

  /// Description for feedback email field
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this to follow up on your feedback if needed.'**
  String get feedbackEmailDescription;

  /// Email subject prefix for feedback
  ///
  /// In en, this message translates to:
  /// **'Feedback from {title}'**
  String feedbackFrom(String title);

  /// Error message when email app cannot be launched
  ///
  /// In en, this message translates to:
  /// **'Could not launch email app. Please try again manually.'**
  String get emailLaunchError;

  /// Error message for invalid feedback data
  ///
  /// In en, this message translates to:
  /// **'Invalid feedback data'**
  String get invalidFeedbackData;

  /// Error message when feedback sending fails
  ///
  /// In en, this message translates to:
  /// **'Failed to send feedback. Please try again.'**
  String get failedToSendFeedback;

  /// Detailed error message for feedback sending
  ///
  /// In en, this message translates to:
  /// **'Error sending feedback: {error}'**
  String errorSendingFeedback(String error);

  /// Maybe later button text
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get maybeLater;

  /// No internet connection screen title
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetTitle;

  /// No internet connection screen description
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get noInternetDescription;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Offline mode information text
  ///
  /// In en, this message translates to:
  /// **'Games work offline, but ads and online features require internet.'**
  String get offlineModeInfo;

  /// Message when there are no leaderboard entries
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntriesYet;

  /// Label for user's ranking in leaderboard
  ///
  /// In en, this message translates to:
  /// **'Your Ranking'**
  String get yourRanking;

  /// Message shown when user's score appears in leaderboard
  ///
  /// In en, this message translates to:
  /// **'This is Your Score!'**
  String get thisIsYourScore;

  /// Message shown when loading user data for leaderboard
  ///
  /// In en, this message translates to:
  /// **'Loading user data...'**
  String get loadingUserData;

  /// Title for leaderboard profile settings
  ///
  /// In en, this message translates to:
  /// **'Leaderboard Profile'**
  String get leaderboardProfile;

  /// Subtitle for leaderboard profile settings
  ///
  /// In en, this message translates to:
  /// **'Edit your name and country flag'**
  String get leaderboardProfileSubtitle;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Validation message for required name
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Validation message for minimum name length
  ///
  /// In en, this message translates to:
  /// **'At least 2 characters'**
  String get minimumTwoCharacters;

  /// Country field label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Country search field label
  ///
  /// In en, this message translates to:
  /// **'Search Country'**
  String get searchCountry;

  /// Confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// Warning message about profile change
  ///
  /// In en, this message translates to:
  /// **'Your progress so far will continue with a different name.'**
  String get profileChangeWarning;

  /// Description of profile change action
  ///
  /// In en, this message translates to:
  /// **'You are about to change your profile information (name and country).'**
  String get profileChangeDescription;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Title for leaderboard registration
  ///
  /// In en, this message translates to:
  /// **'Register for the leaderboard'**
  String get registerForLeaderboard;

  /// Description for leaderboard registration
  ///
  /// In en, this message translates to:
  /// **'Enter your information to add your score to the global ranking.'**
  String get enterInfoForGlobalRanking;

  /// Hint text for name field
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// Hint text for country search
  ///
  /// In en, this message translates to:
  /// **'Write country name...'**
  String get writeCountryName;

  /// Hint text for country field
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get selectYourCountry;

  /// Give up button text
  ///
  /// In en, this message translates to:
  /// **'Give Up'**
  String get giveUp;

  /// Title for leaderboard opt-in dialog
  ///
  /// In en, this message translates to:
  /// **'Add to Leaderboard?'**
  String get addToLeaderboard;

  /// Description for leaderboard opt-in dialog
  ///
  /// In en, this message translates to:
  /// **'Add your score to the global ranking to compete with other players.'**
  String get addToLeaderboardDescription;

  /// Yes button for adding to leaderboard
  ///
  /// In en, this message translates to:
  /// **'Yes, Add'**
  String get yesAdd;

  /// Message shown while generating a random number
  ///
  /// In en, this message translates to:
  /// **'Generating number...'**
  String get generatingNumber;

  /// Message shown while calculating game result
  ///
  /// In en, this message translates to:
  /// **'Calculating result...'**
  String get calculatingResult;

  /// Title for premium features section
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// Description for premium features
  ///
  /// In en, this message translates to:
  /// **'Get a clean, ad-free experience with premium features.'**
  String get getCleanExperience;

  /// Subtitle for game in progress dialog
  ///
  /// In en, this message translates to:
  /// **'You have an active game session'**
  String get gameInProgressSubtitle;

  /// Title for game in progress dialog content
  ///
  /// In en, this message translates to:
  /// **'Game Session Active'**
  String get gameInProgressTitle;

  /// Title for game completed dialog content
  ///
  /// In en, this message translates to:
  /// **'Game Completed!'**
  String get gameCompleted;

  /// Message for game completed dialog
  ///
  /// In en, this message translates to:
  /// **'Congratulations on completing the game! You can restart to play again or exit to return to the main menu.'**
  String get gameCompletedMessage;

  /// Title for unlocked benefits section in ad-free screen
  ///
  /// In en, this message translates to:
  /// **'Unlocked Benefits'**
  String get unlockedBenefits;

  /// Description for no banner ads benefit
  ///
  /// In en, this message translates to:
  /// **'No banner advertisements'**
  String get noBannerAdvertisements;

  /// Description for no interstitial ads benefit
  ///
  /// In en, this message translates to:
  /// **'No full-screen ads'**
  String get noFullScreenAds;

  /// Description for no rewarded ads benefit
  ///
  /// In en, this message translates to:
  /// **'No video ads'**
  String get noVideoAds;

  /// Description for clean experience benefit
  ///
  /// In en, this message translates to:
  /// **'Distraction-free gaming'**
  String get distractionFreeGaming;

  /// Description for lifetime access benefit
  ///
  /// In en, this message translates to:
  /// **'One-time payment, forever access'**
  String get oneTimePaymentForeverAccess;

  /// Skip button text for onboarding
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Get started button text for onboarding
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// First onboarding page title
  ///
  /// In en, this message translates to:
  /// **'Train Your Brain'**
  String get onboardingTitle1;

  /// First onboarding page description
  ///
  /// In en, this message translates to:
  /// **'Challenge your mind with our collection of brain training games designed to improve memory, focus, and cognitive skills.'**
  String get onboardingDescription1;

  /// Second onboarding page title
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get onboardingTitle2;

  /// Second onboarding page description
  ///
  /// In en, this message translates to:
  /// **'Monitor your performance with detailed statistics and compete with players worldwide on our global leaderboards.'**
  String get onboardingDescription2;

  /// Third onboarding page title
  ///
  /// In en, this message translates to:
  /// **'Earn Achievements'**
  String get onboardingTitle3;

  /// Third onboarding page description
  ///
  /// In en, this message translates to:
  /// **'Unlock achievements and rewards as you improve your skills. Share your progress and challenge friends to beat your scores.'**
  String get onboardingDescription3;

  /// Title for uninstall warning dialog
  ///
  /// In en, this message translates to:
  /// **'Important Notice'**
  String get uninstallWarningTitle;

  /// Message for uninstall warning dialog
  ///
  /// In en, this message translates to:
  /// **'If you uninstall the app, all your game scores and subscription rights will be permanently deleted.'**
  String get uninstallWarningMessage;

  /// Title for the Guess the Flag game
  ///
  /// In en, this message translates to:
  /// **'Guess the Flag'**
  String get guessTheFlag;

  /// Description for the Guess the Flag game
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge of world flags! Match the flag emoji to the correct country name.'**
  String get guessTheFlagDescription;

  /// Question asking which country the flag belongs to
  ///
  /// In en, this message translates to:
  /// **'Which country does this flag belong to?'**
  String get whichCountry;

  /// Description when time runs out
  ///
  /// In en, this message translates to:
  /// **'You ran out of time! Try to be faster next time.'**
  String get timeUpDescription;

  /// Message when answer is wrong
  ///
  /// In en, this message translates to:
  /// **'Wrong Answer!'**
  String get wrongAnswer;

  /// Description when answer is wrong
  ///
  /// In en, this message translates to:
  /// **'That\'s not the correct country. Better luck next time!'**
  String get wrongAnswerDescription;

  /// Round label
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// Message when ready to start the game
  ///
  /// In en, this message translates to:
  /// **'Ready to Start?'**
  String get readyToStart;

  /// Label for lives in the game
  ///
  /// In en, this message translates to:
  /// **'Lives'**
  String get lives;

  /// Label for current round in TicTacToe game
  ///
  /// In en, this message translates to:
  /// **'Current Round'**
  String get currentRound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'pt',
    'ru',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
