import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _locale = const Locale('en'); // Default to English
  
  Locale get locale => _locale;
  
  // Available locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic  
    Locale('fa'), // Persian (used for Kurdish)
  ];
  
  // Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'ar': 'العربية',
    'fa': 'کوردی', // Kurdish displayed as Persian locale
  };
  
  // RTL languages
  static const List<String> rtlLanguages = ['ar', 'fa'];
  
  bool get isRTL => rtlLanguages.contains(_locale.languageCode);
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    if (supportedLocales.any((locale) => locale.languageCode == languageCode)) {
      _locale = Locale(languageCode);
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      notifyListeners();
    }
  }
  
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? 'Unknown';
  }
  
  String getCurrentLanguageName() {
    return getLanguageName(_locale.languageCode);
  }
}
