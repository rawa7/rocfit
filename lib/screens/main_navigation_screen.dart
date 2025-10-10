import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'exercise_screen.dart';
import 'calculator_screen.dart';
import 'feedback_screen.dart';
import 'profile_screen.dart';


class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2; // Start with Home tab (center button)
  
  final List<Widget> _screens = [
    const ExerciseScreen(),
    const CalculatorScreen(),
    const HomeScreen(), // Index 2 for center home button
    const _FeedbackScreenWrapper(),
    const ProfileScreen(),
  ];

  void _onNavigationTap(int index) {
    setState(() {
      // Map navigation bar indices to screen indices
      if (index >= 2) {
        // Indices 2,3 in nav bar map to 3,4 in screens (skipping home at index 2)
        _currentIndex = index + 1;
      } else {
        // Indices 0,1 remain the same
        _currentIndex = index;
      }
    });
  }

  void _onHomeTap() {
    setState(() {
      _currentIndex = 2; // Home screen index
    });
  }
  
  void _goToHome() {
    setState(() {
      _currentIndex = 2; // Home screen index
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    // Different bottom padding for different screens
    double getBottomPadding() {
      switch (_currentIndex) {
        case 0: // Exercise screen - very minimal padding
          return 0.0;
        case 4: // Profile screen - needs much more space due to complex layout
          return 100.0;
        default: // All other screens (Calculator, Home, Feedback)
          return 23.0;
      }
    }
    
    return Scaffold(
      resizeToAvoidBottomInset: false, // Keep navigation stable when keyboard appears
      body: Padding(
        padding: EdgeInsets.only(bottom: getBottomPadding()), // Dynamic padding per screen
        child: _screens[_currentIndex],
      ),
      extendBody: true, // Extend body behind the bottom navigation
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _onHomeTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          heroTag: "homeButton",
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/navhome.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: AppColors.primary,
          height: 65, // Fixed height
          elevation: 8,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Exercise Tab
                _buildNavItem(
                  icon: Icons.fitness_center,
                  label: localizations.workout.toUpperCase(),
                  index: 0,
                  screenIndex: 0,
                ),
                
                // Calculator Tab  
                _buildNavItem(
                  icon: Icons.calculate,
                  label: localizations.calculator.toUpperCase(),
                  index: 1,
                  screenIndex: 1,
                ),
                
                // Space for floating action button
                const SizedBox(width: 60),
                
                // Feedback Tab
                _buildNavItem(
                  icon: Icons.feedback_outlined,
                  label: localizations.feedbackNav.toUpperCase(),
                  index: 2,
                  screenIndex: 3,
                ),
                
                // Profile Tab
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: localizations.profile.toUpperCase(),
                  index: 3,
                  screenIndex: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int screenIndex,
  }) {
    final bool isSelected = _currentIndex == screenIndex;
    
    return Expanded(
      child: InkWell(
        onTap: () => _onNavigationTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected 
                  ? AppColors.secondary 
                  : AppColors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: isSelected 
                    ? AppColors.secondary 
                    : AppColors.white.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wrapper for FeedbackScreen when accessed via bottom navigation
class _FeedbackScreenWrapper extends StatelessWidget {
  const _FeedbackScreenWrapper();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When accessed via bottom navigation, go back to home screen
        // Find the main navigation screen and set it to home
        final mainNavState = context.findAncestorStateOfType<_MainNavigationScreenState>();
        if (mainNavState != null) {
          mainNavState._goToHome();
          return false; // Prevent default pop
        }
        return true; // Allow pop if no main nav found
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              // Go back to home when back button is pressed
              final mainNavState = context.findAncestorStateOfType<_MainNavigationScreenState>();
              if (mainNavState != null) {
                mainNavState._goToHome();
              }
            },
          ),
          title: Text(
            AppLocalizations.of(context)?.feedback ?? 'Feedback',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
              onPressed: () {
                // TODO: Handle notifications
              },
            ),
          ],
        ),
        body: const _FeedbackScreenBody(),
      ),
    );
  }
}

// The actual feedback screen content
class _FeedbackScreenBody extends StatefulWidget {
  const _FeedbackScreenBody();

  @override
  State<_FeedbackScreenBody> createState() => _FeedbackScreenBodyState();
}

class _FeedbackScreenBodyState extends State<_FeedbackScreenBody> {
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 4; // Default rating
  bool _isSubmitting = false;
  
  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.pleaseEnterFeedback),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.pleaseLoginToSubmitFeedback),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Format the note with star rating
      final formattedNote = '$_rating ${localizations.star} : ${_feedbackController.text.trim()}';
      
      final apiResponse = await authProvider.apiClient.submitSuggestion(
        username: authProvider.currentUser!.name,
        note: formattedNote,
        userId: authProvider.currentUser!.id,
      );

      if (apiResponse.success) {
        _feedbackController.clear();
        setState(() {
          _rating = 4;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiResponse.message),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiResponse.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.error}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: const Color(0xFFFFD700), // Gold color
              size: 40,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Logo
          Container(
            width: 150,
            height: 150,
            child: Image.asset(
              'assets/Feedback_logo.png',
              fit: BoxFit.contain,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Rating Section
          Text(
            localizations.rate,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildStarRating(),
          
          const SizedBox(height: 40),
          
          // Feedback Text Area
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _feedbackController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: localizations.feedbackPlaceholder,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      localizations.submit,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 100), // Extra padding for navigation bar
        ],
      ),
    );
  }
}
