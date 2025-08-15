import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.white,
                    size: 50,
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingLarge),
                
                // User Name
                Text(
                  authProvider.displayName,
                  style: AppTextStyles.headline2,
                ),
                
                const SizedBox(height: AppConstants.paddingSmall),
                
                // User Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: authProvider.isGuest 
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    authProvider.isGuest ? 'Guest User' : 'Member',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: authProvider.isGuest 
                          ? AppColors.warning
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // Profile Options
                _buildProfileOption(
                  icon: Icons.fitness_center,
                  title: 'My Workouts',
                  subtitle: 'View your exercise history',
                  onTap: () {},
                ),
                
                _buildProfileOption(
                  icon: Icons.restaurant,
                  title: 'Nutrition Plan',
                  subtitle: 'Track your meals and nutrition',
                  onTap: () {},
                ),
                
                _buildProfileOption(
                  icon: Icons.analytics,
                  title: 'Progress',
                  subtitle: 'View your fitness progress',
                  onTap: () {},
                ),
                
                _buildProfileOption(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage your notifications',
                  onTap: () {},
                ),
                
                _buildProfileOption(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () {},
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/splash',
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      authProvider.isGuest ? 'Exit Guest Mode' : 'Logout',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
  
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
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
          style: AppTextStyles.bodyText2,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.grey,
          size: 16,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        tileColor: AppColors.greyLight.withOpacity(0.5),
      ),
    );
  }
}
