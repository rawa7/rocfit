import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Text(
              'Feedback',
              style: AppTextStyles.headline2,
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Send feedback and suggestions\nto improve your experience.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText1,
            ),
          ],
        ),
      ),
    );
  }
}
