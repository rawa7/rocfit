import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calculate,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Text(
              'Calculator',
              style: AppTextStyles.headline2,
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              'BMI Calculator and other fitness calculators\nwill be implemented here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText1,
            ),
          ],
        ),
      ),
    );
  }
}
