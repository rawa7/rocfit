import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  int _currentIndex = 2; // Start with Home tab (middle)
  
  final List<Widget> _screens = [
    const ExerciseScreen(),
    const CalculatorScreen(),
    const HomeScreen(),
    const FeedbackScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: AppColors.white.withOpacity(0.7),
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            // Exercise Tab
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Icon(Icons.fitness_center, size: 24),
              ),
              label: 'EXERCISE',
            ),
            
            // Calculator Tab
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Icon(Icons.calculate, size: 24),
              ),
              label: 'CALCULATOR',
            ),
            
            // Home Tab (Center)
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SvgPicture.asset(
                  AppConstants.logoPath,
                  height: 32,
                  width: 32,
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 2 ? AppColors.secondary : AppColors.white.withOpacity(0.7),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              label: 'HOME',
            ),
            
            // Feedback Tab
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Icon(Icons.chat_bubble_outline, size: 24),
              ),
              label: 'FEEDBACK',
            ),
            
            // Profile Tab
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Icon(Icons.person_outline, size: 24),
              ),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}
