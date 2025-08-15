import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo
              SvgPicture.asset(
                AppConstants.logoPath,
                height: 200,
                width: 200,
              ),
              
              const SizedBox(height: AppConstants.paddingXLarge),
              
              // Welcome Text
              Text(
                'Welcome to The Roc fit',
                style: AppTextStyles.headline2.copyWith(
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Subtitle
              Text(
                'Enjoy your time - Enjoy our Services',
                style: AppTextStyles.bodyText1.copyWith(
                  color: AppColors.greyDark,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                  ),
                  child: const Text(
                    'GET START',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }
}
