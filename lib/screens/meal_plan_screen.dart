import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../constants/app_theme.dart';
import '../services/therocfit_api.dart';
import '../l10n/app_localizations.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  int _selectedMealType = 1; // Start with Breakfast (ID 1)
  List<MealDay> _mealDays = [];
  List<MealFood> _foods = [];
  bool _isLoading = false;
  bool _isLoadingDays = false;
  bool _isLoadingFoods = false;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _loadMealDays();
  }

  Future<void> _loadMealDays() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      _loadMockMealData();
      return;
    }

    setState(() {
      _isLoadingDays = true;
      _errorMessage = null;
    });

    try {
      print('Loading meal days for user ${authProvider.currentUser!.id}');

      final response = await authProvider.apiClient.getMealDays(
        authProvider.currentUser!.id,
      );

      if (response.success && response.data != null) {
        setState(() {
          _mealDays = response.data!;
          _isLoadingDays = false;
          // Set first meal type as selected if available
          if (_mealDays.isNotEmpty) {
            _selectedMealType = _mealDays.first.id;
          }
        });
        
        // Load foods for the first meal type
        _loadFoods();
      } else {
        print('Failed to load meal days: ${response.message}');
        setState(() {
          final localizations = AppLocalizations.of(context);
          _errorMessage = '${localizations?.failedToLoadMealPlan ?? 'Failed to load meal plan'}: ${response.message}';
          _isLoadingDays = false;
        });
      }
    } catch (e) {
      print('Exception loading meal days: $e');
              setState(() {
        final localizations = AppLocalizations.of(context);
        _errorMessage = '${localizations?.failedToLoadMealPlan ?? 'Failed to load meal plan'}. ${localizations?.pleaseTryAgain ?? 'Please try again.'}';
        _isLoadingDays = false;
      });
    }
  }

  Future<void> _loadFoods() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      _loadMockFoods();
      return;
    }

    setState(() {
      _isLoadingFoods = true;
      _errorMessage = null;
    });

    try {
      print('Loading foods for user ${authProvider.currentUser!.id}, meal type $_selectedMealType');

      final response = await authProvider.apiClient.getMealFoods(
        authProvider.currentUser!.id,
        _selectedMealType,
      );

      if (response.success && response.data != null) {
        setState(() {
          _foods = response.data!;
          _isLoadingFoods = false;
        });
        print('Loaded ${response.data!.length} foods for meal type $_selectedMealType');
      } else {
        print('Failed to load foods: ${response.message}');
        setState(() {
          final localizations = AppLocalizations.of(context);
          _errorMessage = '${localizations?.failedToLoadFoods ?? 'Failed to load foods'}: ${response.message}';
          _isLoadingFoods = false;
        });
      }
    } catch (e) {
      print('Exception loading foods: $e');
              setState(() {
        final localizations = AppLocalizations.of(context);
        _errorMessage = '${localizations?.failedToLoadFoods ?? 'Failed to load foods'}. ${localizations?.pleaseTryAgain ?? 'Please try again.'}';
        _isLoadingFoods = false;
      });
    }
  }

  void _loadMockMealData() {
    setState(() {
      _mealDays = [
        MealDay(
          id: 1,
          day: 'Breakfast', // Keep original for API compatibility
          superset: 1,
          mealType: 'Breakfast', // Keep original for API compatibility
          mealCount: 4,
          dayImage: 'breakfast.jpeg',
        ),
        MealDay(
          id: 2,
          day: 'Lunch', // Keep original for API compatibility
          superset: 2,
          mealType: 'Lunch', // Keep original for API compatibility
          mealCount: 3,
          dayImage: 'lunch.jpg',
        ),
        MealDay(
          id: 3,
          day: 'Dinner', // Keep original for API compatibility
          superset: 3,
          mealType: 'Dinner', // Keep original for API compatibility
          mealCount: 2,
          dayImage: 'dinner.jpg',
        ),
      ];
      
      _selectedMealType = _mealDays.first.id;
      _isLoadingDays = false;
    });
    
    _loadMockFoods();
  }

  void _loadMockFoods() {
    setState(() {
      _foods = [
        MealFood(
          foodUsersId: 1,
          foodId: 1,
          gram: '250ml',
          done: 0,
          date: '',
          superset: _selectedMealType,
          day: 0,
          foodName: 'Glass of Milk',
          image: '',
          completed: false,
        ),
        MealFood(
          foodUsersId: 2,
          foodId: 2,
          gram: '2 pieces',
          done: 0,
          date: '',
          superset: _selectedMealType,
          day: 0,
          foodName: 'Dates',
          image: '',
          completed: false,
        ),
        MealFood(
          foodUsersId: 3,
          foodId: 3,
          gram: '100g',
          done: 0,
          date: '',
          superset: _selectedMealType,
          day: 0,
          foodName: 'Oatmeal',
          image: '',
          completed: true,
        ),
      ];
      _isLoadingFoods = false;
    });
  }

  Widget _buildMealContent() {
    if (_isLoadingFoods) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(AppLocalizations.of(context)?.loadingFoods ?? 'Loading foods...'),
          ],
        ),
      );
    }

    if (_foods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              AppLocalizations.of(context)?.noFoodsForMeal ?? 'No foods for this meal',
              style: AppTextStyles.headline3.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton(
              onPressed: _loadFoods,
              child: Text(AppLocalizations.of(context)?.refresh ?? 'Refresh'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Column(
        children: [
          // Food list
          Expanded(
            child: ListView.builder(
              itemCount: _foods.length,
              itemBuilder: (context, index) {
                final food = _foods[index];
                return _buildFoodItem(food);
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildFoodItem(MealFood food) {
    final localizations = AppLocalizations.of(context)!;
    final languageCode = localizations.localeName;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Food icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant,
              color: AppColors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: AppConstants.paddingMedium),

          // Food image (clickable)
          GestureDetector(
            onTap: () => _showFullScreenImage(food.image),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: food.image != null && food.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            food.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.restaurant,
                                color: AppColors.grey,
                                size: 24,
                              );
                            },
                          ),
                          // Overlay to indicate it's tappable
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fullscreen,
                                color: AppColors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Icon(
                      Icons.restaurant,
                      color: AppColors.grey,
                      size: 24,
                    ),
            ),
          ),

          const SizedBox(width: AppConstants.paddingMedium),

          // Food info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.getLocalizedName(languageCode),
                  style: AppTextStyles.bodyText1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localizations.serving(food.gram),
                  style: AppTextStyles.bodyText2.copyWith(
                    color: AppColors.greyDark,
                  ),
                ),
              ],
            ),
          ),

          // Food info icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              Icons.info_outline,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String? imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background tap to close
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              
              // Image content
              Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent closing when tapping image
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? InteractiveViewer(
                              panEnabled: true,
                              boundaryMargin: const EdgeInsets.all(20),
                              minScale: 0.5,
                              maxScale: 3.0,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 200,
                                    height: 200,
                                    color: AppColors.greyLight,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 200,
                                    color: AppColors.greyLight,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 64,
                                          color: AppColors.grey,
                                        ),
                                        const SizedBox(height: 16),
                                                                Text(
                          AppLocalizations.of(context)?.unableToLoadImage ?? 'Unable to load image',
                          style: AppTextStyles.bodyText1.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: AppColors.greyLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: AppColors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No image available',
                                    style: AppTextStyles.bodyText1.copyWith(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              
              // Close button
              Positioned(
                top: 60,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              
              // Instructions text
              Positioned(
                bottom: 100,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    imageUrl != null && imageUrl.isNotEmpty
                        ? (AppLocalizations.of(context)?.pinchToZoom ?? 'Pinch to zoom • Tap outside to close')
                        : (AppLocalizations.of(context)?.tapOutsideToClose ?? 'Tap outside to close'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyText2.copyWith(
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.black,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  
                  const Spacer(),
                  
                  Text(
                    AppLocalizations.of(context)?.mealPlanTitle ?? 'MEAL PLAN',
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.black,
                      size: 24,
                    ),
                    onPressed: () {
                      // Handle notifications
                    },
                  ),
                ],
              ),
            ),
            
            // Meal Image
            GestureDetector(
              onTap: () => _showFullScreenImage('assets/food.jpg'),
              child: Container(
                margin: const EdgeInsets.all(AppConstants.paddingMedium),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  child: Image.asset(
                    'assets/food.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            
            // Meal Type Tabs
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: _isLoadingDays
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _mealDays.map((mealDay) {
                          final localizations = AppLocalizations.of(context)!;
                          final languageCode = localizations.localeName;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMealType = mealDay.id;
                                _retryCount = 0;
                              });
                              _loadFoods();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: _selectedMealType == mealDay.id
                                    ? AppColors.primary
                                    : AppColors.greyLight,
                                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    mealDay.getLocalizedMealType(languageCode),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _selectedMealType == mealDay.id
                                          ? AppColors.white
                                          : AppColors.greyDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${mealDay.mealCount} ${localizations.foods}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _selectedMealType == mealDay.id
                                          ? AppColors.white.withOpacity(0.8)
                                          : AppColors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Food List
            Expanded(
              child: _buildMealContent(),
            ),
          ],
        ),
      ),
    );
  }
}
