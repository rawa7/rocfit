// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'روك فيت';

  @override
  String get welcome => 'أهلاً وسهلاً';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get profile => 'الصفحة';

  @override
  String get home => 'الصفحة الرئیسیة';

  @override
  String get exercise => 'التدریب';

  @override
  String get calculator => 'الحسبة';

  @override
  String get feedback => 'اتغذیة الراجعة';

  @override
  String get feedbackNav => 'اتغذیة الراجعة';

  @override
  String get notifications => 'الاشعارات';

  @override
  String get shop => 'المتجر';

  @override
  String get mealPlan => 'خطة الوجبات';

  @override
  String get yourProgress => 'تقدمك';

  @override
  String get workouts => 'التمارين';

  @override
  String get daysTrained => 'أيام التدريب';

  @override
  String get points => 'النقاط';

  @override
  String get membershipStatus => 'حالة العضوية';

  @override
  String get active => 'نشط';

  @override
  String get expired => 'منتهي الصلاحية';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String daysRemaining(int count) {
    return 'باقي $count يوم';
  }

  @override
  String get membershipExpired => 'انتهت صلاحية العضوية';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get workout => 'تمرين';

  @override
  String get meals => 'الوجبات';

  @override
  String get progress => 'التقدم';

  @override
  String get moreOptions => 'خيارات أكثر';

  @override
  String get manageNotifications => 'إدارة الإشعارات';

  @override
  String get browseProducts => 'تصفح منتجاتنا';

  @override
  String get shareThoughts => 'شاركنا أفكارك';

  @override
  String get logout => 'الخروج';

  @override
  String get exitGuestMode => 'الخروج من وضع الضيف';

  @override
  String get logoutConfirm => 'تسجيل الخروج؟';

  @override
  String get exitGuestConfirm => 'الخروج من وضع الضيف؟';

  @override
  String get logoutMessage => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get exitGuestMessage => 'هل أنت متأكد من الخروج من وضع الضيف؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get exit => 'خروج';

  @override
  String get comingSoon => 'قريباً!';

  @override
  String get trackProgress => 'تتبع تقدمك';

  @override
  String get signUpMessage =>
      'سجل للحصول على حساب لتتبع التمارين وعرض الإحصائيات ومتابعة رحلة لياقتك!';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get loadingProfile => 'جاري تحميل الملف الشخصي...';

  @override
  String get failedToLoadProfile => 'فشل في تحميل الملف الشخصي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get userNotLoggedIn => 'المستخدم غير مسجل الدخول';

  @override
  String get guestUser => 'مستخدم ضيف';

  @override
  String get member => 'عضو';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get kurdish => 'کوردی';

  @override
  String dayWorkout(int day) {
    return 'تمرين اليوم $day';
  }

  @override
  String get exercises => 'تمارين';

  @override
  String get loadingExercises => 'تحميل التمارين...';

  @override
  String get participationEnded => 'انتهت فترة المشاركة';

  @override
  String get participationDetails => 'تفاصيل المشاركة';

  @override
  String get period => 'الفترة';

  @override
  String get checkAgain => 'تحقق مرة أخرى';

  @override
  String get refresh => 'تحديث';

  @override
  String get startWorkout => 'بدء التمرين';

  @override
  String get complete => 'مكتمل';

  @override
  String exerciseCompleted(String exercise) {
    return 'تم إكمال $exercise!';
  }

  @override
  String get pleaseLoginToStart => 'يرجى تسجيل الدخول لبدء التمرين';

  @override
  String get pleaseLoginToComplete => 'يرجى تسجيل الدخول لإكمال التمارين';

  @override
  String get noWorkoutData => 'لا توجد بيانات تمرين متاحة';

  @override
  String get continueAsGuestButton => 'متابعة كضيف';

  @override
  String get loadingFoods => 'تحميل الأطعمة...';

  @override
  String get noFoodsForMeal => 'لا توجد أطعمة لهذه الوجبة';

  @override
  String foodCompleted(String food) {
    return 'تم إكمال $food!';
  }

  @override
  String get breakfast => 'الفطور';

  @override
  String get lunch => 'الغداء';

  @override
  String get dinner => 'العشاء';

  @override
  String get workoutAvailable => 'تمرين متاح';

  @override
  String get bmiCalculator => 'حاسبة مؤشر كتلة الجسم';

  @override
  String get bmiCalculatorTitle => 'حاسبة مؤشر كتلة الجسم';

  @override
  String get units => 'الوحدات: ';

  @override
  String get metricUnits => 'النظام المتري (سم، كيلو)';

  @override
  String get imperialUnits => 'النظام الإمبراطوري (قدم، باوند)';

  @override
  String get metric => 'متري';

  @override
  String get imperial => 'إمبراطوري';

  @override
  String get heightCm => 'الطول (سم)';

  @override
  String get heightFt => 'الطول (قدم)';

  @override
  String get heightHintCm => 'مثال: 175';

  @override
  String get heightHintFt => 'مثال: 5.8';

  @override
  String get weightKg => 'الوزن (كيلو)';

  @override
  String get weightLbs => 'الوزن (باوند)';

  @override
  String get weightHintKg => 'مثال: 70';

  @override
  String get weightHintLbs => 'مثال: 154';

  @override
  String get calculateBMI => 'احسب مؤشر كتلة الجسم';

  @override
  String get clear => 'مسح';

  @override
  String get yourBMIResult => 'نتيجة مؤشر كتلة جسمك';

  @override
  String get bmi => 'مؤشر كتلة الجسم';

  @override
  String get bmiCategories => 'فئات مؤشر كتلة الجسم';

  @override
  String get underweight => 'نقص في الوزن';

  @override
  String get normalWeight => 'وزن طبيعي';

  @override
  String get overweight => 'زيادة في الوزن';

  @override
  String get obese => 'سمنة';

  @override
  String get pleaseEnterHeight => 'يرجى إدخال طولك';

  @override
  String get pleaseEnterValidHeight => 'يرجى إدخال طول صحيح';

  @override
  String get heightRangeCm => 'يجب أن يكون الطول بين 50-300 سم';

  @override
  String get heightRangeFt => 'يجب أن يكون الطول بين 1-10 قدم';

  @override
  String get pleaseEnterWeight => 'يرجى إدخال وزنك';

  @override
  String get pleaseEnterValidWeight => 'يرجى إدخال وزن صحيح';

  @override
  String get weightRangeKg => 'يجب أن يكون الوزن بين 20-500 كيلو';

  @override
  String get weightRangeLbs => 'يجب أن يكون الوزن بين 44-1100 باوند';

  @override
  String get feedbackTitle => 'الملاحظات';

  @override
  String get rate => 'قيّم';

  @override
  String get feedbackPlaceholder => 'اكتب ملاحظاتك هنا ...';

  @override
  String get submit => 'إرسال';

  @override
  String get pleaseEnterFeedback => 'يرجى إدخال ملاحظاتك';

  @override
  String get pleaseLoginToSubmitFeedback =>
      'يرجى تسجيل الدخول لإرسال الملاحظات';

  @override
  String get error => 'خطأ';

  @override
  String get hello => 'مرحبا';

  @override
  String get homeStartDate => 'تاريخ البداية';

  @override
  String get homeExpireDate => 'تاريخ الانتهاء';

  @override
  String get supplement => 'المكملات الغذائية';

  @override
  String get foodMenu => 'قائمة الطعام';

  @override
  String get image => 'صورة';

  @override
  String get noBannerImagesAvailable => 'لا توجد صور بانر متاحة';

  @override
  String get noWorkoutItemsAvailable => 'لا توجد عناصر تمرين متاحة';

  @override
  String get star => 'نجمة';

  @override
  String get tapToViewDetails => 'اضغط لعرض التفاصيل';

  @override
  String get loadingMenuItems => 'تحميل عناصر القائمة...';

  @override
  String get failedToLoadMenuItems => 'فشل في تحميل عناصر القائمة';

  @override
  String get pleaseTryAgain => 'يرجى المحاولة مرة أخرى.';

  @override
  String get all => 'الكل';

  @override
  String noItemsFound(String itemType) {
    return 'لا توجد عناصر $itemType';
  }

  @override
  String inCategory(String category) {
    return 'في فئة $category';
  }

  @override
  String get noImageAvailable => 'لا توجد صورة متاحة';

  @override
  String get loadingImage => 'تحميل الصورة...';

  @override
  String get unableToLoadImage => 'غير قادر على تحميل الصورة';

  @override
  String get price => 'السعر:';

  @override
  String get description => 'الوصف';

  @override
  String get noDescriptionAvailable => 'لا يوجد وصف متاح لهذا العنصر.';

  @override
  String get food => 'طعام';

  @override
  String get suppliment => 'مكمل غذائي';

  @override
  String get mealPlanTitle => 'خطة الوجبات';

  @override
  String get tapToViewMealImage => 'اضغط لعرض صورة الوجبة';

  @override
  String get foods => 'أطعمة';

  @override
  String serving(String amount) {
    return 'الحصة: $amount';
  }

  @override
  String get failedToLoadMealPlan => 'فشل في تحميل خطة الوجبات';

  @override
  String get failedToLoadFoods => 'فشل في تحميل الأطعمة';

  @override
  String get pinchToZoom => 'اضغط للتكبير • اضغط خارجاً للإغلاق';

  @override
  String get tapOutsideToClose => 'اضغط خارجاً للإغلاق';

  @override
  String get dailyCreatine => 'الكرياتين اليومي';

  @override
  String get dailyProtein => 'البروتين اليومي';

  @override
  String gramsPerDay(String amount) {
    return '$amount غ/يوم';
  }

  @override
  String get nutritionalNeeds => 'الاحتياجات الغذائية اليومية';

  @override
  String get age => 'العمر';

  @override
  String get ageHint => 'مثال: 25';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get activityLevel => 'مستوى النشاط';

  @override
  String get sedentary => 'خامل';

  @override
  String get lightlyActive => 'نشط قليلاً';

  @override
  String get moderatelyActive => 'نشط متوسط';

  @override
  String get veryActive => 'نشط جداً';

  @override
  String get superActive => 'نشط فائق';

  @override
  String get bmr => 'معدل الأيض الأساسي';

  @override
  String get tdee => 'إجمالي إنفاق الطاقة اليومي';

  @override
  String get dailyWater => 'استهلاك الماء اليومي';

  @override
  String get bodyFatPercentage => 'نسبة دهون الجسم';

  @override
  String get idealBodyWeight => 'الوزن المثالي للجسم';

  @override
  String caloriesPerDay(String amount) {
    return '$amount سعرة/يوم';
  }

  @override
  String litersPerDay(String amount) {
    return '$amount لتر/يوم';
  }

  @override
  String percentage(String amount) {
    return '$amount%';
  }

  @override
  String kilograms(String amount) {
    return '$amount كغ';
  }

  @override
  String get macronutrients => 'المغذيات الكبرى اليومية';

  @override
  String get carbohydrates => 'الكربوهيدرات';

  @override
  String get fats => 'الدهون';

  @override
  String caloriesAndGrams(String calories, String grams) {
    return '$calories سعرة ($gramsغ)';
  }

  @override
  String get pleaseEnterAge => 'يرجى إدخال عمرك';

  @override
  String get pleaseEnterValidAge => 'يرجى إدخال عمر صحيح';

  @override
  String get ageRange => 'يجب أن يكون العمر بين 10-120 سنة';

  @override
  String get metabolicCalculations => 'الحسابات الأيضية';

  @override
  String get bodyComposition => 'تكوين الجسم';

  @override
  String get statistics => 'الاحصائیات';

  @override
  String get exerciseCompletedTitle => '🎉 تم الانتهاء من التمرین!';

  @override
  String get workoutCompletedTitle => '🎉 تم إنجاز جمیع التمارین!';

  @override
  String get exerciseCompletedBody => 'عمل رائع! لقد أكملت جمیع المجموعات.';

  @override
  String get workoutCompletedBody =>
      'عمل رائع! لقد أنجزت تدریبك بالكامل. استمر! 💪';

  @override
  String get loadingStatistics => 'تحميل الاحصائيات...';

  @override
  String get somethingWentWrong => 'عذرا! حدث خطأ ما';

  @override
  String overviewDays(int days) {
    return 'نظرة عامة ($days أيام)';
  }

  @override
  String get activeDays => 'الأيام النشطة';

  @override
  String get last30Days => 'آخر ٣٠ يوم';

  @override
  String get currentStreak => 'الشريط الحالي';

  @override
  String get days => 'الأيام';

  @override
  String get totalVolume => 'إجمالي الحجم';

  @override
  String get totalWeightLifted => 'إجمالي الوزن المرفوع';

  @override
  String get weeklyProgress => 'التقدم الأسبوعي';

  @override
  String get weightLiftedKg => 'الوزن المرفوع (كيلو)';

  @override
  String get personalRecord => 'الرقم القياسي الشخصي';

  @override
  String get personalBest => 'أفضل شخصي';

  @override
  String get continueButton => 'متابعة';

  @override
  String get statisticsSubtitle => 'عرض تقدم التمارين والإنجازات';
}
