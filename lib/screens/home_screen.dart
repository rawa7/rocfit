import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: AppColors.black,
                        size: 28,
                      ),
                      onPressed: () {
                        // TODO: Open drawer
                      },
                    ),
                    
                    const Spacer(),
                    
                    // Logo
                    SvgPicture.asset(
                      AppConstants.logoPath,
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
                        // TODO: Open notifications
                      },
                    ),
                  ],
                ),
              ),
              
              // Banner
              Container(
                margin: const EdgeInsets.all(AppConstants.paddingMedium),
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: const Center(
                  child: Text(
                    'Banner',
                    style: TextStyle(
                      fontSize: 32,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              
              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == 1 ? AppColors.primary : AppColors.grey,
                      shape: BoxShape.circle,
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
                                'Hello',
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
                              'START DATE',
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
                              'EXPIRE DATE',
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
                        label: 'MEAL PLAN',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: _buildActionItem(
                        icon: Icons.local_pharmacy,
                        label: 'supplement',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: _buildActionItem(
                        icon: Icons.menu_book,
                        label: 'FOOD MENU',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: _buildActionItem(
                        icon: Icons.shopping_cart,
                        label: 'SHOP',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Banner Image
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                ),
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: const Center(
                  child: Text(
                    'Image',
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Workout Categories
              _buildWorkoutCategory(
                title: 'CROSSFIT',
                description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                onTap: () {
                  // Navigate to CrossFit workouts
                },
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              _buildWorkoutCategory(
                title: 'KICKBOXING',
                description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                onTap: () {
                  // Navigate to Kickboxing workouts
                },
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
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
  
  Widget _buildWorkoutCategory({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Row(
              children: [
                // Image placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: const Center(
                    child: Text(
                      'Image',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
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
                        title,
                        style: AppTextStyles.headline4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: AppTextStyles.bodyText2.copyWith(
                          color: AppColors.greyDark,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
