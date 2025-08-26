import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/therocfit_api.dart';

class AuthProvider extends ChangeNotifier {
  final TheRocFitApiClient _apiClient = TheRocFitApiClient();
  
  User? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isGuest = false;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  TheRocFitApiClient get apiClient => _apiClient;
  
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    await _apiClient.initialize();
    await _checkAuthStatus();
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> _checkAuthStatus() async {
    try {
      print('Checking authentication status...');
      // Since the API doesn't have a getCurrentUser endpoint, 
      // we'll check if we have stored login data
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('user_id');
      final storedUsername = prefs.getString('username');
      
      if (storedUserId != null && storedUsername != null) {
        _currentUser = User(
          id: storedUserId,
          name: storedUsername,
          email: null,
          phone: null,
          height: null,
          weight: null,
          cityId: null,
          points: null,
          lastExerciseDate: null,
        );
        _isLoggedIn = true;
        _isGuest = false;
        print('User restored from storage: $storedUsername (ID: $storedUserId)');
        notifyListeners();
      } else {
        print('No stored user found');
        _handleAuthFailure();
      }
    } catch (e) {
      // User not logged in or authentication error
      print('Auth check exception: $e');
      _handleAuthFailure();
    }
  }
  
  void _handleAuthFailure() {
    _currentUser = null;
    _isLoggedIn = false;
    _isGuest = false;
    notifyListeners();
  }
  
  Future<LoginResult> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiClient.login(username, password);
      if (response.success && response.data != null && response.data!.isSuccess) {
        // Create a user object from login response
        _currentUser = User(
          id: response.data!.userId ?? 0,
          name: username,
          email: null,
          phone: null,
          height: null,
          weight: null,
          cityId: null,
          points: null,
          lastExerciseDate: null,
        );
        
        // Store login data for persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', _currentUser!.id);
        await prefs.setString('username', username);
        
        _isLoggedIn = true;
        _isGuest = false;
        _isLoading = false;
        notifyListeners();
        return LoginResult(success: true);
      } else {
        _isLoading = false;
        notifyListeners();
        return LoginResult(
          success: false, 
          message: response.data?.message ?? 'Login failed'
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      
      if (e is ApiException) {
        return LoginResult(success: false, message: e.message);
      }
      return LoginResult(success: false, message: e.toString());
    }
  }
  
  Future<void> continueAsGuest() async {
    _isGuest = true;
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
  
  Future<void> logout() async {
    try {
      if (!_isGuest) {
        await _apiClient.logout();
        
        // Clear stored data
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_id');
        await prefs.remove('username');
      }
    } catch (e) {
      // Handle logout error if needed
    }
    
    _currentUser = null;
    _isLoggedIn = false;
    _isGuest = false;
    notifyListeners();
  }
  
  String get displayName {
    if (_isGuest) return 'Guest User';
    return _currentUser?.name ?? 'User';
  }
}

class LoginResult {
  final bool success;
  final String? message;
  
  LoginResult({required this.success, this.message});
}
