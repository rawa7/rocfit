import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/therocfit_api.dart';
import '../l10n/app_localizations.dart';
import 'meal_plan_screen.dart';
import 'menu_screen.dart';
import 'shop_screen.dart';
import 'game_item_detail_screen.dart';
import 'notifications_screen.dart';
import 'exercise_screen.dart';
import 'calculator_screen.dart';
import 'feedback_screen.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<String> _carouselImages = [];
  List<GameItem> _gameItems = [];
  bool _isLoading = true;
  bool _isLoadingGameItems = true;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _loadCarouselImages();
    _loadGameItems();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_carouselImages.isNotEmpty && mounted) {
        final nextPage = (_currentPage + 1) % _carouselImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _resumeAutoScroll() {
    _stopAutoScroll();
    _startAutoScroll();
  }

  Future<void> _loadCarouselImages() async {
    try {
      final apiClient = TheRocFitApiClient();
      final response = await apiClient.getCarouselImages();
      
      if (response.success && response.data != null) {
        setState(() {
          _carouselImages = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading carousel images: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGameItems() async {
    try {
      final apiClient = TheRocFitApiClient();
      final response = await apiClient.getGameItems();
      
      if (response.success && response.data != null) {
        setState(() {
          _gameItems = response.data!;
          _isLoadingGameItems = false;
        });
      } else {
        setState(() {
          _isLoadingGameItems = false;
        });
      }
    } catch (e) {
      print('Error loading game items: $e');
      setState(() {
        _isLoadingGameItems = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    // Menu Icon
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: AppColors.black,
                          size: 28,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Logo
                    Image.asset(
                      'assets/Homepage_logo.png',
                      height: 40,
                      width: 120,
                    ),
                    
                    const Spacer(),
                    
                    // Notification Icon
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.black,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Banner Carousel
              _buildBannerCarousel(),
              
              // Page Indicators
              if (_carouselImages.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _carouselImages.length,
                      (index) => GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentPage ? AppColors.primary : AppColors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // User Profile Section
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                    ),
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        
                        const SizedBox(width: AppConstants.paddingMedium),
                        
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.hello,
                                style: AppTextStyles.bodyText2.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                ),
                              ),
                              Text(
                                authProvider.displayName,
                                style: AppTextStyles.headline3.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Dates
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              localizations.homeStartDate,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '1-5-2025',
                              style: AppTextStyles.bodyText2.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localizations.homeExpireDate,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '1-5-2025',
                              style: AppTextStyles.bodyText2.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Action Items
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionItem(
                        icon: Icons.restaurant_menu,
                        label: localizations.mealPlan,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MealPlanScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: _buildActionItem(
                        icon: Icons.local_pharmacy,
                        label: localizations.supplement,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MenuScreen(
                                itemType: 'Suppliment',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: _buildActionItem(
                        icon: Icons.menu_book,
                        label: localizations.foodMenu,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MenuScreen(
                                itemType: 'Food',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: _buildActionItem(
                        icon: Icons.shopping_cart,
                        label: localizations.shop,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ShopScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Exercise Section
              _buildExerciseSection(),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Dynamic Game Items
              _buildGameItemsSection(),
              
              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    final localizations = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_carouselImages.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.grey,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.noBannerImagesAvailable,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.grey,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadCarouselImages,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(localizations.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      height: 200,
      child: GestureDetector(
        onTapDown: (_) => _stopAutoScroll(),
        onTapUp: (_) => _resumeAutoScroll(),
        onTapCancel: () => _resumeAutoScroll(),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: _carouselImages.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: _carouselImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppColors.greyLight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.greyLight,
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: AppColors.grey,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay for better text visibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Image counter
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${index + 1}/${_carouselImages.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.greyDark,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.greyDark,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGameItemsSection() {
    final localizations = AppLocalizations.of(context)!;
    
    if (_isLoadingGameItems) {
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
        ),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_gameItems.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
        ),
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.sports_gymnastics,
              color: AppColors.grey,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.noWorkoutItemsAvailable,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.grey,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadGameItems,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(localizations.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _gameItems.asMap().entries.map((entry) {
        final index = entry.key;
        final gameItem = entry.value;
        
        return Column(
          children: [
            _buildGameItemCard(gameItem, localizations),
            if (index < _gameItems.length - 1)
              const SizedBox(height: AppConstants.paddingMedium),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGameItemCard(GameItem gameItem, AppLocalizations localizations) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameItemDetailScreen(gameItem: gameItem),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Row(
              children: [
                // Game item image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    child: gameItem.primaryImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: gameItem.primaryImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.greyLight,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.grey,
                                size: 24,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.grey,
                              size: 24,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: AppConstants.paddingMedium),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gameItem.itemName,
                        style: AppTextStyles.headline4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          gameItem.itemType.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gameItem.itemDescription.isNotEmpty 
                            ? gameItem.itemDescription
                            : localizations.tapToViewDetails,
                        style: AppTextStyles.bodyText2.copyWith(
                          color: AppColors.greyDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildExerciseSection() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExerciseScreen(),
            ),
          );
        },
        child: Container(
          height: 150,
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
              'assets/exercises_home_button.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDrawer(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Drawer(
      backgroundColor: AppColors.white,
      width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
      child: Column(
        children: [
          // Header with player name and profile
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Container(
                width: double.infinity,
                height: 280,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppConstants.paddingLarge,
                      right: AppConstants.paddingLarge,
                      top: AppConstants.paddingMedium,
                      bottom: AppConstants.paddingLarge,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppConstants.paddingMedium),
                        
                        // Profile Avatar
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 45,
                          ),
                        ),
                        
                        const SizedBox(height: AppConstants.paddingLarge),
                        
                        // Player Name
                        Container(
                          width: double.infinity,
                          child: Text(
                            authProvider.displayName,
                            style: AppTextStyles.headline2.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Subtitle
                        Container(
                          width: double.infinity,
                          child: Text(
                            localizations.hello,
                            style: AppTextStyles.bodyText1.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        const SizedBox(height: AppConstants.paddingMedium),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                top: AppConstants.paddingMedium,
                bottom: 0, // Remove bottom padding so footer is always visible
              ),
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: localizations.home,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.fitness_center,
                  title: localizations.workout,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExerciseScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.calculate,
                  title: localizations.calculator,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CalculatorScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.restaurant_menu,
                  title: localizations.mealPlan,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MealPlanScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.menu_book,
                  title: localizations.foodMenu,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MenuScreen(itemType: 'Food')),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.local_pharmacy,
                  title: localizations.supplement,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MenuScreen(itemType: 'Suppliment')),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_cart,
                  title: localizations.shop,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShopScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.bar_chart,
                  title: localizations.statistics,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.feedback_outlined,
                  title: localizations.feedback,
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.pushNamed(context, '/feedback');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: localizations.profile,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications_outlined,
                  title: localizations.notifications,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                  },
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                  child: Divider(color: AppColors.greyLight),
                ),
                
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: localizations.logout,
                  onTap: () {
                    Navigator.pop(context);
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                  textColor: AppColors.error,
                  iconColor: AppColors.error,
                ),
              ],
            ),
          ),
          
          // Footer - Always visible at bottom
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.greyLight,
                    width: 1,
                  ),
                ),
              ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.palette,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Powered by AlignArt',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.greyDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 AlignArt. All rights reserved.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: 2,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? AppColors.greyDark,
          size: AppConstants.iconMedium,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyText2.copyWith(
            color: textColor ?? AppColors.greyDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        hoverColor: AppColors.primary.withOpacity(0.05),
        splashColor: AppColors.primary.withOpacity(0.1),
      ),
    );
  }
}
