// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'RocFit';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get profile => 'Profile';

  @override
  String get home => 'Home';

  @override
  String get exercise => 'Exercise';

  @override
  String get calculator => 'Calculator';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackNav => 'Feedback';

  @override
  String get notifications => 'Notifications';

  @override
  String get shop => 'SHOP';

  @override
  String get mealPlan => 'MEAL PLAN';

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get workouts => 'Workouts';

  @override
  String get daysTrained => 'Days Trained';

  @override
  String get points => 'Points';

  @override
  String get membershipStatus => 'Membership Status';

  @override
  String get active => 'ACTIVE';

  @override
  String get expired => 'EXPIRED';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String daysRemaining(int count) {
    return '$count days remaining';
  }

  @override
  String get membershipExpired => 'Membership expired';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get workout => 'Workout';

  @override
  String get meals => 'Meals';

  @override
  String get progress => 'Progress';

  @override
  String get moreOptions => 'More Options';

  @override
  String get manageNotifications => 'Manage your notifications';

  @override
  String get browseProducts => 'Browse our products';

  @override
  String get shareThoughts => 'Share your thoughts with us';

  @override
  String get logout => 'Logout';

  @override
  String get exitGuestMode => 'Exit Guest Mode';

  @override
  String get logoutConfirm => 'Logout?';

  @override
  String get exitGuestConfirm => 'Exit Guest Mode?';

  @override
  String get logoutMessage => 'Are you sure you want to logout?';

  @override
  String get exitGuestMessage => 'Are you sure you want to exit guest mode?';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get trackProgress => 'Track Your Progress';

  @override
  String get signUpMessage =>
      'Sign up to track workouts, view stats, and see your fitness journey!';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingProfile => 'Loading profile...';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get retry => 'Retry';

  @override
  String get userNotLoggedIn => 'User not logged in';

  @override
  String get guestUser => 'Guest User';

  @override
  String get member => 'Member';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get kurdish => 'کوردی';

  @override
  String dayWorkout(int day) {
    return 'Day $day Workout';
  }

  @override
  String get exercises => 'exercises';

  @override
  String get loadingExercises => 'Loading exercises...';

  @override
  String get participationEnded => 'Participation Period Ended';

  @override
  String get participationDetails => 'Participation Details';

  @override
  String get period => 'Period';

  @override
  String get checkAgain => 'Check Again';

  @override
  String get refresh => 'Refresh';

  @override
  String get startWorkout => 'Start Workout';

  @override
  String get complete => 'Complete';

  @override
  String exerciseCompleted(String exercise) {
    return '$exercise completed!';
  }

  @override
  String get pleaseLoginToStart => 'Please login to start workout';

  @override
  String get pleaseLoginToComplete => 'Please login to complete exercises';

  @override
  String get noWorkoutData => 'No workout data available';

  @override
  String get continueAsGuestButton => 'Continue as Guest';

  @override
  String get loadingFoods => 'Loading foods...';

  @override
  String get noFoodsForMeal => 'No foods for this meal';

  @override
  String foodCompleted(String food) {
    return '$food completed!';
  }

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get workoutAvailable => 'Workout available';

  @override
  String get bmiCalculator => 'BMI Calculator';

  @override
  String get bmiCalculatorTitle => 'BMI CALCULATOR';

  @override
  String get units => 'Units: ';

  @override
  String get metricUnits => 'Metric (cm, kg)';

  @override
  String get imperialUnits => 'Imperial (ft, lbs)';

  @override
  String get metric => 'Metric';

  @override
  String get imperial => 'Imperial';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get heightFt => 'Height (ft)';

  @override
  String get heightHintCm => 'e.g., 175';

  @override
  String get heightHintFt => 'e.g., 5.8';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get weightLbs => 'Weight (lbs)';

  @override
  String get weightHintKg => 'e.g., 70';

  @override
  String get weightHintLbs => 'e.g., 154';

  @override
  String get calculateBMI => 'Calculate BMI';

  @override
  String get clear => 'Clear';

  @override
  String get yourBMIResult => 'Your BMI Result';

  @override
  String get bmi => 'BMI';

  @override
  String get bmiCategories => 'BMI Categories';

  @override
  String get underweight => 'Underweight';

  @override
  String get normalWeight => 'Normal weight';

  @override
  String get overweight => 'Overweight';

  @override
  String get obese => 'Obese';

  @override
  String get pleaseEnterHeight => 'Please enter your height';

  @override
  String get pleaseEnterValidHeight => 'Please enter a valid height';

  @override
  String get heightRangeCm => 'Height should be between 50-300 cm';

  @override
  String get heightRangeFt => 'Height should be between 1-10 feet';

  @override
  String get pleaseEnterWeight => 'Please enter your weight';

  @override
  String get pleaseEnterValidWeight => 'Please enter a valid weight';

  @override
  String get weightRangeKg => 'Weight should be between 20-500 kg';

  @override
  String get weightRangeLbs => 'Weight should be between 44-1100 lbs';

  @override
  String get feedbackTitle => 'FEEDBACK';

  @override
  String get rate => 'RATE';

  @override
  String get feedbackPlaceholder => 'TYPE YOUR FEEDBACK HERE ...';

  @override
  String get submit => 'Submit';

  @override
  String get pleaseEnterFeedback => 'Please enter your feedback';

  @override
  String get pleaseLoginToSubmitFeedback => 'Please login to submit feedback';

  @override
  String get error => 'Error';

  @override
  String get hello => 'Hello';

  @override
  String get homeStartDate => 'START DATE';

  @override
  String get homeExpireDate => 'EXPIRE DATE';

  @override
  String get supplement => 'SUPPLEMENT';

  @override
  String get foodMenu => 'FOOD MENU';

  @override
  String get image => 'Image';

  @override
  String get noBannerImagesAvailable => 'No banner images available';

  @override
  String get noWorkoutItemsAvailable => 'No workout items available';

  @override
  String get star => 'star';

  @override
  String get tapToViewDetails => 'Tap to view details';

  @override
  String get loadingMenuItems => 'Loading menu items...';

  @override
  String get failedToLoadMenuItems => 'Failed to load menu items';

  @override
  String get pleaseTryAgain => 'Please try again.';

  @override
  String get all => 'All';

  @override
  String noItemsFound(String itemType) {
    return 'No $itemType items found';
  }

  @override
  String inCategory(String category) {
    return 'in $category category';
  }

  @override
  String get noImageAvailable => 'No Image Available';

  @override
  String get loadingImage => 'Loading image...';

  @override
  String get unableToLoadImage => 'Unable to load image';

  @override
  String get price => 'Price:';

  @override
  String get description => 'Description';

  @override
  String get noDescriptionAvailable =>
      'No description available for this item.';

  @override
  String get food => 'Food';

  @override
  String get suppliment => 'Supplement';

  @override
  String get mealPlanTitle => 'MEAL PLAN';

  @override
  String get tapToViewMealImage => 'Tap to view meal image';

  @override
  String get foods => 'foods';

  @override
  String serving(String amount) {
    return 'Serving: $amount';
  }

  @override
  String get failedToLoadMealPlan => 'Failed to load meal plan';

  @override
  String get failedToLoadFoods => 'Failed to load foods';

  @override
  String get pinchToZoom => 'Pinch to zoom • Tap outside to close';

  @override
  String get tapOutsideToClose => 'Tap outside to close';

  @override
  String get dailyCreatine => 'Daily Creatine';

  @override
  String get dailyProtein => 'Daily Protein';

  @override
  String gramsPerDay(String amount) {
    return '$amount g/day';
  }

  @override
  String get nutritionalNeeds => 'Daily Nutritional Needs';

  @override
  String get age => 'Age';

  @override
  String get ageHint => 'e.g., 25';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get sedentary => 'Sedentary';

  @override
  String get lightlyActive => 'Lightly Active';

  @override
  String get moderatelyActive => 'Moderately Active';

  @override
  String get veryActive => 'Very Active';

  @override
  String get superActive => 'Super Active';

  @override
  String get bmr => 'BMR (Basal Metabolic Rate)';

  @override
  String get tdee => 'TDEE (Total Daily Energy Expenditure)';

  @override
  String get dailyWater => 'Daily Water Intake';

  @override
  String get bodyFatPercentage => 'Body Fat Percentage';

  @override
  String get idealBodyWeight => 'Ideal Body Weight';

  @override
  String caloriesPerDay(String amount) {
    return '$amount cal/day';
  }

  @override
  String litersPerDay(String amount) {
    return '$amount L/day';
  }

  @override
  String percentage(String amount) {
    return '$amount%';
  }

  @override
  String kilograms(String amount) {
    return '$amount kg';
  }

  @override
  String get macronutrients => 'Daily Macronutrients';

  @override
  String get carbohydrates => 'Carbohydrates';

  @override
  String get fats => 'Fats';

  @override
  String caloriesAndGrams(String calories, String grams) {
    return '$calories cal (${grams}g)';
  }

  @override
  String get pleaseEnterAge => 'Please enter your age';

  @override
  String get pleaseEnterValidAge => 'Please enter a valid age';

  @override
  String get ageRange => 'Age should be between 10-120 years';

  @override
  String get metabolicCalculations => 'Metabolic Calculations';

  @override
  String get bodyComposition => 'Body Composition';

  @override
  String get statistics => 'Statistics';

  @override
  String get exerciseCompletedTitle => '🎉 Exercise Completed!';

  @override
  String get workoutCompletedTitle => '🎉 All Exercises Completed!';

  @override
  String get exerciseCompletedBody => 'Great job! You completed all sets.';

  @override
  String get workoutCompletedBody =>
      'Amazing work! You completed your entire workout. Keep it up! 💪';

  @override
  String get loadingStatistics => 'Loading statistics...';

  @override
  String get somethingWentWrong => 'Oops! Something went wrong';

  @override
  String overviewDays(int days) {
    return 'Overview ($days days)';
  }

  @override
  String get activeDays => 'Active Days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get days => 'Days';

  @override
  String get totalVolume => 'Total Volume';

  @override
  String get totalWeightLifted => 'Total weight lifted';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String get weightLiftedKg => 'Weight Lifted (kg)';

  @override
  String get personalRecord => 'Personal Record';

  @override
  String get personalBest => 'Personal Best';

  @override
  String get continueButton => 'Continue';

  @override
  String get statisticsSubtitle =>
      'View your workout progress and achievements';
}
