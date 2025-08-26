// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appName => 'ڕۆک فیت';

  @override
  String get welcome => 'بەخێربێیت';

  @override
  String get login => 'چوونە ژوورەوە';

  @override
  String get username => 'ناوی بەکارهێنەر';

  @override
  String get password => 'وشەی تێپەڕ';

  @override
  String get continueAsGuest => 'وەک میوان بەردەوام بە';

  @override
  String get profile => 'پڕۆفایل';

  @override
  String get home => 'سەرەکی';

  @override
  String get exercise => 'ڕاهێنان';

  @override
  String get calculator => 'ژمێرەر';

  @override
  String get feedback => 'پێشنیار';

  @override
  String get notifications => 'ئاگادارکردنەوەکان';

  @override
  String get shop => 'فرۆشگا';

  @override
  String get mealPlan => 'پلانی خواردن';

  @override
  String get yourProgress => 'پێشکەوتنت';

  @override
  String get workouts => 'ڕاهێنانەکان';

  @override
  String get daysTrained => 'ڕۆژانی ڕاهێنان';

  @override
  String get points => 'خاڵەکان';

  @override
  String get membershipStatus => 'دۆخی ئەندامەتی';

  @override
  String get active => 'چالاک';

  @override
  String get expired => 'بەسەرچووە';

  @override
  String get startDate => 'ڕێکەوتی دەستپێک';

  @override
  String get endDate => 'ڕێکەوتی کۆتایی';

  @override
  String daysRemaining(int count) {
    return '$count ڕۆژ ماوە';
  }

  @override
  String get membershipExpired => 'ئەندامەتی بەسەرچووە';

  @override
  String get quickActions => 'کردارە خێراکان';

  @override
  String get workout => 'ڕاهێنان';

  @override
  String get meals => 'خواردنەکان';

  @override
  String get progress => 'پێشکەوتن';

  @override
  String get moreOptions => 'بژاردەی زیاتر';

  @override
  String get manageNotifications => 'بەڕێوەبردنی ئاگادارکردنەوەکان';

  @override
  String get browseProducts => 'گەڕان بە بەرهەمەکانمان';

  @override
  String get shareThoughts => 'بیرۆکەکانت لەگەڵ ئێمە هاوبەش بکە';

  @override
  String get logout => 'دەرچوون';

  @override
  String get exitGuestMode => 'دەرچوون لە دۆخی میوان';

  @override
  String get logoutConfirm => 'دەرچوون؟';

  @override
  String get exitGuestConfirm => 'دەرچوون لە دۆخی میوان؟';

  @override
  String get logoutMessage => 'دڵنیایت لە دەرچوون؟';

  @override
  String get exitGuestMessage => 'دڵنیایت لە دەرچوون لە دۆخی میوان؟';

  @override
  String get cancel => 'هەڵوەشاندنەوە';

  @override
  String get exit => 'دەرچوون';

  @override
  String get comingSoon => 'بەزووە دێت!';

  @override
  String get trackProgress => 'پێشکەوتنت بشوێنە';

  @override
  String get signUpMessage =>
      'تۆمار بکە بۆ شوێنکەوتنی ڕاهێنان و بینینی ئامارەکان و ڕێگای تەندروستیت!';

  @override
  String get loading => 'بارکردن...';

  @override
  String get loadingProfile => 'بارکردنی پڕۆفایل...';

  @override
  String get failedToLoadProfile => 'سەرکەوتوو نەبوو لە بارکردنی پڕۆفایل';

  @override
  String get retry => 'دووبارە هەوڵدانەوە';

  @override
  String get userNotLoggedIn => 'بەکارهێنەر نەچووەتە ژوورەوە';

  @override
  String get guestUser => 'بەکارهێنەری میوان';

  @override
  String get member => 'ئەندام';

  @override
  String get settings => 'ڕێکخستنەکان';

  @override
  String get language => 'زمان';

  @override
  String get selectLanguage => 'زمان هەڵبژێرە';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get kurdish => 'کوردی';

  @override
  String dayWorkout(int day) {
    return 'ڕاهێنانی ڕۆژی $day';
  }

  @override
  String get exercises => 'ڕاهێنانەکان';

  @override
  String get loadingExercises => 'بارکردنی ڕاهێنانەکان...';

  @override
  String get participationEnded => 'ماوەی بەشداری کۆتایی هات';

  @override
  String get participationDetails => 'وردەکاری بەشداری';

  @override
  String get period => 'ماوە';

  @override
  String get checkAgain => 'دووبارە بپشکنە';

  @override
  String get refresh => 'نوێکردنەوە';

  @override
  String get startWorkout => 'دەستکردن بە ڕاهێنان';

  @override
  String get complete => 'تەواو';

  @override
  String exerciseCompleted(String exercise) {
    return '$exercise تەواو بوو!';
  }

  @override
  String get pleaseLoginToStart => 'تکایە بچۆرە ژوورەوە بۆ دەستکردن بە ڕاهێنان';

  @override
  String get pleaseLoginToComplete =>
      'تکایە بچۆرە ژوورەوە بۆ تەواوکردنی ڕاهێنانەکان';

  @override
  String get noWorkoutData => 'هیچ زانیاریەکی ڕاهێنان بەردەست نییە';

  @override
  String get continueAsGuestButton => 'وەک میوان بەردەوام بە';

  @override
  String get loadingFoods => 'بارکردنی خواردنەکان...';

  @override
  String get noFoodsForMeal => 'هیچ خواردنێک نییە بۆ ئەم ژەمە';

  @override
  String foodCompleted(String food) {
    return '$food تەواو بوو!';
  }

  @override
  String get breakfast => 'بەیانی خوان';

  @override
  String get lunch => 'نیوەڕۆ خوان';

  @override
  String get dinner => 'ئێواره خوان';

  @override
  String get workoutAvailable => 'ڕاهێنان بەردەستە';

  @override
  String get bmiCalculator => 'ژمێرەری BMI';

  @override
  String get bmiCalculatorTitle => 'ژمێرەری BMI';

  @override
  String get units => 'یەکە: ';

  @override
  String get metricUnits => 'مەتری (سم، کیلۆ)';

  @override
  String get imperialUnits => 'ئیمپراتۆری (پێ، پاوند)';

  @override
  String get metric => 'مەتری';

  @override
  String get imperial => 'ئیمپراتۆری';

  @override
  String get heightCm => 'درێژی (سم)';

  @override
  String get heightFt => 'درێژی (پێ)';

  @override
  String get heightHintCm => 'وەک: 175';

  @override
  String get heightHintFt => 'وەک: 5.8';

  @override
  String get weightKg => 'کێش (کیلۆ)';

  @override
  String get weightLbs => 'کێش (پاوند)';

  @override
  String get weightHintKg => 'وەک: 70';

  @override
  String get weightHintLbs => 'وەک: 154';

  @override
  String get calculateBMI => 'ژمێردنی BMI';

  @override
  String get clear => 'پاککردنەوە';

  @override
  String get yourBMIResult => 'ئەنجامی BMI ت';

  @override
  String get bmi => 'BMI';

  @override
  String get bmiCategories => 'جۆرەکانی BMI';

  @override
  String get underweight => 'کەمی کێش';

  @override
  String get normalWeight => 'کێشی ئاسایی';

  @override
  String get overweight => 'زیادەی کێش';

  @override
  String get obese => 'قەڵەوی';

  @override
  String get pleaseEnterHeight => 'تکایە درێژیت بنووسە';

  @override
  String get pleaseEnterValidHeight => 'تکایە درێژییەکی دروست بنووسە';

  @override
  String get heightRangeCm => 'درێژی دەبێت نێوان 50-300 سم بێت';

  @override
  String get heightRangeFt => 'درێژی دەبێت نێوان 1-10 پێ بێت';

  @override
  String get pleaseEnterWeight => 'تکایە کێشت بنووسە';

  @override
  String get pleaseEnterValidWeight => 'تکایە کێشێکی دروست بنووسە';

  @override
  String get weightRangeKg => 'کێش دەبێت نێوان 20-500 کیلۆ بێت';

  @override
  String get weightRangeLbs => 'کێش دەبێت نێوان 44-1100 پاوند بێت';

  @override
  String get feedbackTitle => 'پێشنیار';

  @override
  String get rate => 'هەڵسەنگاندن';

  @override
  String get feedbackPlaceholder => 'پێشنیارەکانت لێرە بنووسە ...';

  @override
  String get submit => 'ناردن';

  @override
  String get pleaseEnterFeedback => 'تکایە پێشنیارەکانت بنووسە';

  @override
  String get pleaseLoginToSubmitFeedback =>
      'تکایە بچۆرە ژوورەوە بۆ ناردنی پێشنیار';

  @override
  String get error => 'هەڵە';

  @override
  String get hello => 'سڵاو';

  @override
  String get homeStartDate => 'ڕێکەوتی دەستپێک';

  @override
  String get homeExpireDate => 'ڕێکەوتی کۆتایی';

  @override
  String get supplement => 'خۆراکی پێکەری';

  @override
  String get foodMenu => 'لیستی خواردن';

  @override
  String get image => 'وێنە';

  @override
  String get noBannerImagesAvailable => 'هیچ وێنەیەکی بانەر بەردەست نییە';

  @override
  String get noWorkoutItemsAvailable => 'هیچ بابەتێکی ڕاهێنان بەردەست نییە';

  @override
  String get star => 'ئەستێرە';

  @override
  String get tapToViewDetails => 'دەستی لێبدە بۆ بینینی وردەکاری';

  @override
  String get loadingMenuItems => 'بارکردنی بابەتەکانی لیست...';

  @override
  String get failedToLoadMenuItems =>
      'سەرکەوتوو نەبوو لە بارکردنی بابەتەکانی لیست';

  @override
  String get pleaseTryAgain => 'تکایە دووبارە هەوڵبدەوە.';

  @override
  String get all => 'هەموو';

  @override
  String noItemsFound(String itemType) {
    return 'هیچ بابەتێکی $itemType نەدۆزرایەوە';
  }

  @override
  String inCategory(String category) {
    return 'لە جۆری $category';
  }

  @override
  String get noImageAvailable => 'هیچ وێنەیەک بەردەست نییە';

  @override
  String get loadingImage => 'بارکردنی وێنە...';

  @override
  String get unableToLoadImage => 'نەتوانرا وێنە بار بکرێت';

  @override
  String get price => 'نرخ:';

  @override
  String get description => 'وەسف';

  @override
  String get noDescriptionAvailable => 'هیچ وەسفێک نییە بۆ ئەم بابەتە.';

  @override
  String get food => 'خواردن';

  @override
  String get suppliment => 'خۆراکی پێکەری';

  @override
  String get mealPlanTitle => 'پلانی خواردن';

  @override
  String get tapToViewMealImage => 'دەستی لێبدە بۆ بینینی وێنەی خواردن';

  @override
  String get foods => 'خواردنەکان';

  @override
  String serving(String amount) {
    return 'بەش: $amount';
  }

  @override
  String get failedToLoadMealPlan => 'سەرکەوتوو نەبوو لە بارکردنی پلانی خواردن';

  @override
  String get failedToLoadFoods => 'سەرکەوتوو نەبوو لە بارکردنی خواردنەکان';

  @override
  String get pinchToZoom =>
      'پەنجە بکە بۆ گەورەکردن • دەرەوە دەست بدە بۆ داخستن';

  @override
  String get tapOutsideToClose => 'دەرەوە دەست بدە بۆ داخستن';
}
