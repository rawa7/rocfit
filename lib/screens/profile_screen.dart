import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/therocfit_api.dart';
import 'meal_plan_screen.dart';
import 'shop_screen.dart';
import 'notifications_screen.dart';
import 'exercise_screen.dart';
import 'feedback_screen.dart';
import 'statistics_screen.dart';

import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TheRocFitApiClient _apiClient = TheRocFitApiClient();
  ProfileData? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Navigation helper methods
  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
  
  void _showComingSoon() {
    final localizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations?.comingSoon ?? 'Coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _showProgressDialog() {
    final localizations = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isGuest || _profileData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations?.pleaseLoginToStart ?? 'Please login to view progress'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.analytics, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(localizations?.progress ?? 'Progress'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProgressItem(
                icon: Icons.fitness_center,
                title: localizations?.workouts ?? 'Total Workouts',
                value: '${_profileData!.totalWorkouts}',
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              _buildProgressItem(
                icon: Icons.calendar_today,
                title: localizations?.daysTrained ?? 'Days Trained',
                value: '${_profileData!.daysTrained}',
                color: AppColors.success,
              ),
              const SizedBox(height: 16),
              _buildProgressItem(
                icon: Icons.emoji_events,
                title: localizations?.points ?? 'Total Points',
                value: '${_profileData!.totalPoints}',
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _profileData!.daysTrained / 30, // 30 days goal
                backgroundColor: AppColors.greyLight,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'Monthly Goal: ${_profileData!.daysTrained}/30 days',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations?.cancel ?? 'Close'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildProgressItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyText2),
              Text(value, style: AppTextStyles.headline4.copyWith(color: color)),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showLanguageDialog() {
    final localizations = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.selectLanguage ?? 'Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: LanguageProvider.supportedLocales.map((locale) {
              final languageName = LanguageProvider.languageNames[locale.languageCode] ?? locale.languageCode;
              final isSelected = languageProvider.locale.languageCode == locale.languageCode;
              
              return ListTile(
                title: Text(languageName),
                leading: Radio<String>(
                  value: locale.languageCode,
                  groupValue: languageProvider.locale.languageCode,
                  onChanged: (String? value) {
                    if (value != null) {
                      languageProvider.setLanguage(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  languageProvider.setLanguage(locale.languageCode);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations?.cancel ?? 'Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Check if user is logged in (not guest) and has a valid user ID
      if (authProvider.isLoggedIn && authProvider.currentUser?.id != null) {
        final response = await _apiClient.getUserProfileData(authProvider.currentUser!.id);
        if (response.success && response.data != null) {
          setState(() {
            _profileData = response.data!;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = response.message;
            _isLoading = false;
          });
        }
      } else if (authProvider.isGuest) {
        // Guest users don't have profile data, so just stop loading
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight.withOpacity(0.5),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (_isLoading) {
            return _buildLoadingState();
          }

          if (_error != null) {
            return _buildErrorState(authProvider);
          }

          return RefreshIndicator(
            onRefresh: _loadProfile,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(authProvider),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      children: [
                        _buildStatsSection(),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildMembershipSection(),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildQuickActions(),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildProfileOptions(),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildLogoutButton(authProvider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: AppColors.greyLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Loading profile...',
              style: AppTextStyles.bodyText1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AuthProvider authProvider) {
    return Scaffold(
      backgroundColor: AppColors.greyLight.withOpacity(0.5),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.profile ?? 'Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                AppLocalizations.of(context)?.failedToLoadProfile ?? 'Failed to load profile',
                style: AppTextStyles.headline3,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                _error ?? 'Unknown error occurred',
                style: AppTextStyles.bodyText2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              ElevatedButton(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(AuthProvider authProvider) {
    final displayName = _profileData?.name ?? authProvider.displayName;
    final email = _profileData?.email ?? '';
    
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40), // Account for app bar
                Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  displayName,
                  style: AppTextStyles.headline2.copyWith(
                    color: AppColors.white,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    email,
                    style: AppTextStyles.bodyText2.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    // For guests, show a sign-up prompt
    if (_profileData == null) {
      return Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isGuest) {
            return Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    AppLocalizations.of(context)?.trackProgress ?? 'Track Your Progress',
                    style: AppTextStyles.headline3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    AppLocalizations.of(context)?.signUpMessage ?? 'Sign up to track workouts, view stats, and see your fitness journey!',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                Text(
            AppLocalizations.of(context)?.yourProgress ?? 'Your Progress',
            style: AppTextStyles.headline3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.fitness_center,
                  title: AppLocalizations.of(context)?.workouts ?? 'Workouts',
                  value: '${_profileData!.totalWorkouts}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_today,
                  title: AppLocalizations.of(context)?.daysTrained ?? 'Days Trained',
                  value: '${_profileData!.daysTrained}',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events,
                  title: AppLocalizations.of(context)?.points ?? 'Points',
                  value: '${_profileData!.totalPoints}',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
                const SizedBox(height: AppConstants.paddingSmall),
          Text(
            value,
            style: AppTextStyles.headline3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.bodyText2.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipSection() {
    if (_profileData == null) return const SizedBox.shrink();

    final isActive = _profileData!.isActive;
    final daysRemaining = _profileData!.daysRemaining;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.verified : Icons.error,
                color: isActive ? AppColors.success : AppColors.error,
                size: 24,
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                AppLocalizations.of(context)?.membershipStatus ?? 'Membership Status',
                style: AppTextStyles.headline3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
                Container(
            width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                  decoration: BoxDecoration(
              color: isActive 
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
              isActive 
                  ? (AppLocalizations.of(context)?.active ?? 'ACTIVE')
                  : (AppLocalizations.of(context)?.expired ?? 'EXPIRED'),
              style: AppTextStyles.bodyText1.copyWith(
                color: isActive ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_profileData!.formattedStartDate != null && _profileData!.formattedEndDate != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.startDate ?? 'Start Date',
                      style: AppTextStyles.bodyText2.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    Text(
                      _profileData!.formattedStartDate!,
                      style: AppTextStyles.bodyText1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                                        Text(
                      AppLocalizations.of(context)?.endDate ?? 'End Date',
                    style: AppTextStyles.bodyText2.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    Text(
                      _profileData!.formattedEndDate!,
                      style: AppTextStyles.bodyText1.copyWith(
                      fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          if (daysRemaining != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.grey,
                  size: 16,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  daysRemaining > 0 
                      ? '$daysRemaining days remaining'
                      : (AppLocalizations.of(context)?.membershipExpired ?? 'Membership expired'),
                  style: AppTextStyles.bodyText2.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.quickActions ?? 'Quick Actions',
            style: AppTextStyles.headline3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.fitness_center,
                  label: AppLocalizations.of(context)?.workout ?? 'Workout',
                  color: AppColors.primary,
                  onTap: () {
                    _navigateToScreen(const ExerciseScreen());
                  },
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.restaurant,
                  label: AppLocalizations.of(context)?.meals ?? 'Meals',
                  color: AppColors.success,
                  onTap: () {
                    _navigateToScreen(const MealPlanScreen());
                  },
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.analytics,
                  label: AppLocalizations.of(context)?.progress ?? 'Progress',
                  color: AppColors.warning,
                  onTap: _showProgressDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              label,
              style: AppTextStyles.bodyText2.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                  ),
                ),
              ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.moreOptions ?? 'More Options',
            style: AppTextStyles.headline3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildProfileOption(
            icon: Icons.bar_chart,
            title: 'Statistics',
            subtitle: 'View your workout progress and achievements',
            onTap: () {
              _navigateToScreen(const StatisticsScreen());
            },
          ),
          _buildProfileOption(
            icon: Icons.notifications,
            title: AppLocalizations.of(context)?.notifications ?? 'Notifications',
            subtitle: AppLocalizations.of(context)?.manageNotifications ?? 'Manage your notifications',
            onTap: () {
              _navigateToScreen(const NotificationsScreen());
            },
          ),
                _buildProfileOption(
            icon: Icons.shopping_bag,
            title: AppLocalizations.of(context)?.shop ?? 'Shop',
            subtitle: AppLocalizations.of(context)?.browseProducts ?? 'Browse our products',
            onTap: () {
              _navigateToScreen(const ShopScreen());
            },
          ),
          _buildProfileOption(
            icon: Icons.feedback,
            title: AppLocalizations.of(context)?.feedback ?? 'Feedback',
            subtitle: AppLocalizations.of(context)?.shareThoughts ?? 'Share your thoughts with us',
            onTap: () {
              _navigateToScreen(const FeedbackScreen());
            },
          ),
          _buildProfileOption(
            icon: Icons.language,
            title: AppLocalizations.of(context)?.language ?? 'Language',
            subtitle: Provider.of<LanguageProvider>(context).getCurrentLanguageName(),
            onTap: _showLanguageDialog,
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
        leading: Container(
        width: 40,
        height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyText1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
        style: AppTextStyles.bodyText2.copyWith(
          color: AppColors.grey,
        ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.grey,
          size: 16,
        ),
        onTap: onTap,
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppConstants.paddingMedium),
      child: ElevatedButton(
        onPressed: () async {
          // Show confirmation dialog
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                authProvider.isGuest 
                    ? (AppLocalizations.of(context)?.exitGuestConfirm ?? 'Exit Guest Mode?')
                    : (AppLocalizations.of(context)?.logoutConfirm ?? 'Logout?'),
              ),
              content: Text(
                authProvider.isGuest 
                    ? (AppLocalizations.of(context)?.exitGuestMessage ?? 'Are you sure you want to exit guest mode?')
                    : (AppLocalizations.of(context)?.logoutMessage ?? 'Are you sure you want to logout?'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    authProvider.isGuest 
                        ? (AppLocalizations.of(context)?.exit ?? 'Exit')
                        : (AppLocalizations.of(context)?.logout ?? 'Logout'),
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            await authProvider.logout();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/splash',
                (route) => false,
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
        child: Text(
          authProvider.isGuest 
              ? (AppLocalizations.of(context)?.exitGuestMode ?? 'Exit Guest Mode')
              : (AppLocalizations.of(context)?.logout ?? 'Logout'),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
