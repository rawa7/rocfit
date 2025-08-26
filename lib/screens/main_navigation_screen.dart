import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
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
    const FeedbackScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/welcome_logo.png',
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
          child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Exercise Tab
                _buildNavItem(
                  icon: Icons.fitness_center,
                  label: 'EXERCISE',
                  index: 0,
                  screenIndex: 0,
                ),
                
                // Calculator Tab  
                _buildNavItem(
                  icon: Icons.calculate,
                  label: 'CALCULATOR',
                  index: 1,
                  screenIndex: 1,
                ),
                
                // Space for floating action button
                const SizedBox(width: 60),
                
                // Feedback Tab
                _buildNavItem(
                  icon: Icons.feedback_outlined,
                  label: 'FEEDBACK',
                  index: 2,
                  screenIndex: 3,
                ),
                
                // Profile Tab
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'PROFILE',
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
              size: 24,
              color: isSelected 
                  ? AppColors.secondary 
                  : AppColors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
