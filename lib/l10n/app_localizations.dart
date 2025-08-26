import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

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
    Locale('ar'),
    Locale('en'),
    Locale('fa'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'RocFit'**
  String get appName;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Continue as guest button
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Exercise screen title
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// Calculator screen title
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// Feedback screen title
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Notifications screen title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Shop action item
  ///
  /// In en, this message translates to:
  /// **'SHOP'**
  String get shop;

  /// Meal plan action item
  ///
  /// In en, this message translates to:
  /// **'MEAL PLAN'**
  String get mealPlan;

  /// Progress section title
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// Workouts counter label
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// Days trained counter label
  ///
  /// In en, this message translates to:
  /// **'Days Trained'**
  String get daysTrained;

  /// Points counter label
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// Membership status section title
  ///
  /// In en, this message translates to:
  /// **'Membership Status'**
  String get membershipStatus;

  /// Active membership status
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// Expired membership status
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get expired;

  /// Membership start date label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// Membership end date label
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// Days remaining in membership
  ///
  /// In en, this message translates to:
  /// **'{count} days remaining'**
  String daysRemaining(int count);

  /// Membership expired message
  ///
  /// In en, this message translates to:
  /// **'Membership expired'**
  String get membershipExpired;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Workout quick action
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// Meals quick action
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// Progress quick action
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// More options section title
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// Notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your notifications'**
  String get manageNotifications;

  /// Shop subtitle
  ///
  /// In en, this message translates to:
  /// **'Browse our products'**
  String get browseProducts;

  /// Feedback subtitle
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts with us'**
  String get shareThoughts;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Exit guest mode button
  ///
  /// In en, this message translates to:
  /// **'Exit Guest Mode'**
  String get exitGuestMode;

  /// Logout confirmation title
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get logoutConfirm;

  /// Exit guest mode confirmation title
  ///
  /// In en, this message translates to:
  /// **'Exit Guest Mode?'**
  String get exitGuestConfirm;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutMessage;

  /// Exit guest mode confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit guest mode?'**
  String get exitGuestMessage;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Exit button
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// Track progress for guest users
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get trackProgress;

  /// Sign up message for guest users
  ///
  /// In en, this message translates to:
  /// **'Sign up to track workouts, view stats, and see your fitness journey!'**
  String get signUpMessage;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Loading profile message
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get loadingProfile;

  /// Failed to load profile error
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// User not logged in error
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// Guest user label
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// Member label
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Select language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Arabic language option
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// Kurdish language option
  ///
  /// In en, this message translates to:
  /// **'کوردی'**
  String get kurdish;

  /// Day workout title
  ///
  /// In en, this message translates to:
  /// **'Day {day} Workout'**
  String dayWorkout(int day);

  /// Exercises count label
  ///
  /// In en, this message translates to:
  /// **'exercises'**
  String get exercises;

  /// Loading exercises message
  ///
  /// In en, this message translates to:
  /// **'Loading exercises...'**
  String get loadingExercises;

  /// Participation period ended title
  ///
  /// In en, this message translates to:
  /// **'Participation Period Ended'**
  String get participationEnded;

  /// Participation details title
  ///
  /// In en, this message translates to:
  /// **'Participation Details'**
  String get participationDetails;

  /// Period label
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// Check again button
  ///
  /// In en, this message translates to:
  /// **'Check Again'**
  String get checkAgain;

  /// Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Start workout button
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// Complete button
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Exercise completed message
  ///
  /// In en, this message translates to:
  /// **'{exercise} completed!'**
  String exerciseCompleted(String exercise);

  /// Please login to start workout message
  ///
  /// In en, this message translates to:
  /// **'Please login to start workout'**
  String get pleaseLoginToStart;

  /// Please login to complete exercises message
  ///
  /// In en, this message translates to:
  /// **'Please login to complete exercises'**
  String get pleaseLoginToComplete;

  /// No workout data message
  ///
  /// In en, this message translates to:
  /// **'No workout data available'**
  String get noWorkoutData;

  /// Continue as guest button in exercise screen
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuestButton;

  /// Loading foods message
  ///
  /// In en, this message translates to:
  /// **'Loading foods...'**
  String get loadingFoods;

  /// No foods for meal message
  ///
  /// In en, this message translates to:
  /// **'No foods for this meal'**
  String get noFoodsForMeal;

  /// Food completed message
  ///
  /// In en, this message translates to:
  /// **'{food} completed!'**
  String foodCompleted(String food);

  /// Breakfast meal type
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// Lunch meal type
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// Dinner meal type
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// Workout available message
  ///
  /// In en, this message translates to:
  /// **'Workout available'**
  String get workoutAvailable;

  /// BMI Calculator screen title
  ///
  /// In en, this message translates to:
  /// **'BMI Calculator'**
  String get bmiCalculator;

  /// BMI Calculator main title
  ///
  /// In en, this message translates to:
  /// **'BMI CALCULATOR'**
  String get bmiCalculatorTitle;

  /// Units selection label
  ///
  /// In en, this message translates to:
  /// **'Units: '**
  String get units;

  /// Metric units option
  ///
  /// In en, this message translates to:
  /// **'Metric (cm, kg)'**
  String get metricUnits;

  /// Imperial units option
  ///
  /// In en, this message translates to:
  /// **'Imperial (ft, lbs)'**
  String get imperialUnits;

  /// Metric unit label
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// Imperial unit label
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperial;

  /// Height input label in centimeters
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// Height input label in feet
  ///
  /// In en, this message translates to:
  /// **'Height (ft)'**
  String get heightFt;

  /// Height input hint in centimeters
  ///
  /// In en, this message translates to:
  /// **'e.g., 175'**
  String get heightHintCm;

  /// Height input hint in feet
  ///
  /// In en, this message translates to:
  /// **'e.g., 5.8'**
  String get heightHintFt;

  /// Weight input label in kilograms
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// Weight input label in pounds
  ///
  /// In en, this message translates to:
  /// **'Weight (lbs)'**
  String get weightLbs;

  /// Weight input hint in kilograms
  ///
  /// In en, this message translates to:
  /// **'e.g., 70'**
  String get weightHintKg;

  /// Weight input hint in pounds
  ///
  /// In en, this message translates to:
  /// **'e.g., 154'**
  String get weightHintLbs;

  /// Calculate BMI button text
  ///
  /// In en, this message translates to:
  /// **'Calculate BMI'**
  String get calculateBMI;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// BMI result section title
  ///
  /// In en, this message translates to:
  /// **'Your BMI Result'**
  String get yourBMIResult;

  /// BMI label
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// BMI categories section title
  ///
  /// In en, this message translates to:
  /// **'BMI Categories'**
  String get bmiCategories;

  /// BMI category: underweight
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get underweight;

  /// BMI category: normal weight
  ///
  /// In en, this message translates to:
  /// **'Normal weight'**
  String get normalWeight;

  /// BMI category: overweight
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get overweight;

  /// BMI category: obese
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get obese;

  /// Height validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your height'**
  String get pleaseEnterHeight;

  /// Valid height validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid height'**
  String get pleaseEnterValidHeight;

  /// Height range validation error for centimeters
  ///
  /// In en, this message translates to:
  /// **'Height should be between 50-300 cm'**
  String get heightRangeCm;

  /// Height range validation error for feet
  ///
  /// In en, this message translates to:
  /// **'Height should be between 1-10 feet'**
  String get heightRangeFt;

  /// Weight validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight'**
  String get pleaseEnterWeight;

  /// Valid weight validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight'**
  String get pleaseEnterValidWeight;

  /// Weight range validation error for kilograms
  ///
  /// In en, this message translates to:
  /// **'Weight should be between 20-500 kg'**
  String get weightRangeKg;

  /// Weight range validation error for pounds
  ///
  /// In en, this message translates to:
  /// **'Weight should be between 44-1100 lbs'**
  String get weightRangeLbs;

  /// Feedback screen title
  ///
  /// In en, this message translates to:
  /// **'FEEDBACK'**
  String get feedbackTitle;

  /// Rate section title
  ///
  /// In en, this message translates to:
  /// **'RATE'**
  String get rate;

  /// Feedback text area placeholder
  ///
  /// In en, this message translates to:
  /// **'TYPE YOUR FEEDBACK HERE ...'**
  String get feedbackPlaceholder;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Please enter feedback error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your feedback'**
  String get pleaseEnterFeedback;

  /// Please login to submit feedback error message
  ///
  /// In en, this message translates to:
  /// **'Please login to submit feedback'**
  String get pleaseLoginToSubmitFeedback;

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Greeting message
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Start date label on home screen
  ///
  /// In en, this message translates to:
  /// **'START DATE'**
  String get homeStartDate;

  /// Expire date label on home screen
  ///
  /// In en, this message translates to:
  /// **'EXPIRE DATE'**
  String get homeExpireDate;

  /// Supplement action item
  ///
  /// In en, this message translates to:
  /// **'SUPPLEMENT'**
  String get supplement;

  /// Food menu action item
  ///
  /// In en, this message translates to:
  /// **'FOOD MENU'**
  String get foodMenu;

  /// Generic image placeholder text
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No banner images available message
  ///
  /// In en, this message translates to:
  /// **'No banner images available'**
  String get noBannerImagesAvailable;

  /// No workout items available message
  ///
  /// In en, this message translates to:
  /// **'No workout items available'**
  String get noWorkoutItemsAvailable;

  /// Star rating label
  ///
  /// In en, this message translates to:
  /// **'star'**
  String get star;

  /// Tap to view details message
  ///
  /// In en, this message translates to:
  /// **'Tap to view details'**
  String get tapToViewDetails;

  /// Loading menu items message
  ///
  /// In en, this message translates to:
  /// **'Loading menu items...'**
  String get loadingMenuItems;

  /// Failed to load menu items error
  ///
  /// In en, this message translates to:
  /// **'Failed to load menu items'**
  String get failedToLoadMenuItems;

  /// Please try again message
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get pleaseTryAgain;

  /// All categories filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No items found message
  ///
  /// In en, this message translates to:
  /// **'No {itemType} items found'**
  String noItemsFound(String itemType);

  /// In specific category message
  ///
  /// In en, this message translates to:
  /// **'in {category} category'**
  String inCategory(String category);

  /// No image available message
  ///
  /// In en, this message translates to:
  /// **'No Image Available'**
  String get noImageAvailable;

  /// Loading image message
  ///
  /// In en, this message translates to:
  /// **'Loading image...'**
  String get loadingImage;

  /// Unable to load image error
  ///
  /// In en, this message translates to:
  /// **'Unable to load image'**
  String get unableToLoadImage;

  /// Price label
  ///
  /// In en, this message translates to:
  /// **'Price:'**
  String get price;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description available message
  ///
  /// In en, this message translates to:
  /// **'No description available for this item.'**
  String get noDescriptionAvailable;

  /// Food item type
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// Supplement item type
  ///
  /// In en, this message translates to:
  /// **'Supplement'**
  String get suppliment;

  /// Meal plan screen title
  ///
  /// In en, this message translates to:
  /// **'MEAL PLAN'**
  String get mealPlanTitle;

  /// Tap to view meal image hint text
  ///
  /// In en, this message translates to:
  /// **'Tap to view meal image'**
  String get tapToViewMealImage;

  /// Foods count label
  ///
  /// In en, this message translates to:
  /// **'foods'**
  String get foods;

  /// Serving size label
  ///
  /// In en, this message translates to:
  /// **'Serving: {amount}'**
  String serving(String amount);

  /// Failed to load meal plan error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load meal plan'**
  String get failedToLoadMealPlan;

  /// Failed to load foods error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load foods'**
  String get failedToLoadFoods;

  /// Image viewer instructions
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom • Tap outside to close'**
  String get pinchToZoom;

  /// Dialog close instructions
  ///
  /// In en, this message translates to:
  /// **'Tap outside to close'**
  String get tapOutsideToClose;
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
      <String>['ar', 'en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
