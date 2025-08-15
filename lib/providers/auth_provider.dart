import 'package:flutter/foundation.dart';
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
      final response = await _apiClient.getCurrentUser();
      if (response.success && response.data != null) {
        _currentUser = response.data;
        _isLoggedIn = true;
        _isGuest = false;
        notifyListeners();
      }
    } catch (e) {
      // User not logged in
      _isLoggedIn = false;
      _isGuest = false;
      notifyListeners();
    }
  }
  
  Future<LoginResult> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiClient.login(username, password);
      if (response.success && response.data != null) {
        _currentUser = response.data;
        _isLoggedIn = true;
        _isGuest = false;
        _isLoading = false;
        notifyListeners();
        return LoginResult(success: true);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      
      if (e is ApiException) {
        return LoginResult(success: false, message: e.message);
      }
      return LoginResult(success: false, message: e.toString());
    }
    
    _isLoading = false;
    notifyListeners();
    return LoginResult(success: false, message: 'Login failed');
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
