import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/feedback_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const RocFitApp());
}

class RocFitApp extends StatelessWidget {
  const RocFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [  
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return Directionality(
            textDirection: languageProvider.isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: MaterialApp(
              title: AppConstants.appName,
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              
              // Localization support
              locale: languageProvider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: LanguageProvider.supportedLocales,
              
              home: const AuthWrapper(),
              routes: {
                '/splash': (context) => const SplashScreen(),
                '/login': (context) => const LoginScreen(),
                '/main': (context) => const MainNavigationScreen(),
                '/feedback': (context) => const FeedbackScreen(),
              },
            ),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initialize();
      Provider.of<LanguageProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (authProvider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // You can add your logo here
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  Text(
                    'Loading...',
                    style: AppTextStyles.bodyText1.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Navigate based on auth status
        if (authProvider.isLoggedIn || authProvider.isGuest) {
          return const MainNavigationScreen();
        } else {
          // If there's a persistent auth failure, go to guest mode
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.continueAsGuest();
          });
          return const SplashScreen();
        }
      },
    );
  }
}