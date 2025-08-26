// TheRocFit API Integration for Flutter
// This file contains all the necessary code to integrate with TheRocFit APIs
// 
// Dependencies to add in pubspec.yaml:
// dependencies:
//   http: ^1.1.0
//   shared_preferences: ^2.2.2
//   dio: ^5.3.2 (optional, for advanced features)

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// TheRocFit API Client
/// 
/// Usage:
/// ```dart
/// final apiClient = TheRocFitApiClient();
/// await apiClient.login('username', 'password');
/// final exercises = await apiClient.getExercises();
/// ```
class TheRocFitApiClient {
  static const String baseUrl = 'https://therocfit.com';
  static const Duration timeout = Duration(seconds: 30);
  
  // Singleton pattern
  static final TheRocFitApiClient _instance = TheRocFitApiClient._internal();
  factory TheRocFitApiClient() => _instance;
  TheRocFitApiClient._internal();
  
  String? _sessionCookie;
  Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Initialize the API client and load saved session
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionCookie = prefs.getString('session_cookie');
    if (_sessionCookie != null) {
      _defaultHeaders['Cookie'] = _sessionCookie!;
    }
  }
  
  /// Save session cookie
  Future<void> _saveSession(String cookie) async {
    _sessionCookie = cookie;
    _defaultHeaders['Cookie'] = cookie;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_cookie', cookie);
  }
  
  /// Clear session
  Future<void> _clearSession() async {
    _sessionCookie = null;
    _defaultHeaders.remove('Cookie');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');
  }
  
  /// Generic HTTP request method
  Future<ApiResponse<T>> _request<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      // Debug logging (reduced for better performance)
      print('API Request: ${method.toUpperCase()} $uri');
      
      http.Response response;
      
      switch (method.toLowerCase()) {
        case 'get':
          response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
          break;
        case 'post':
          response = await http.post(
            uri,
            headers: _defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(timeout);
          break;
        case 'put':
          response = await http.put(
            uri,
            headers: _defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(timeout);
          break;
        case 'delete':
          response = await http.delete(uri, headers: _defaultHeaders).timeout(timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
      
      // Debug response (reduced for better performance)
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Extract cookies from response
      if (response.headers['set-cookie'] != null) {
        await _saveSession(response.headers['set-cookie']!);
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle both 'success' and 'status' fields for different API responses
        bool isSuccess = jsonResponse['success'] == true || jsonResponse['status'] == 'success';
        
        if (isSuccess) {
          final data = jsonResponse['data'] ?? jsonResponse;
          return ApiResponse<T>(
            success: true,
            message: jsonResponse['message'] ?? 'Success',
            data: fromJson != null && data != null ? fromJson(data) : data,
          );
        } else {
          throw ApiException(
            jsonResponse['message'] ?? 'Unknown error',
            code: jsonResponse['error_code'],
            statusCode: response.statusCode,
          );
        }
      } else {
        // Handle error response structure
        String errorMessage = jsonResponse['message'] ?? 'HTTP ${response.statusCode}';
        if (jsonResponse['error'] == true && jsonResponse['message'] != null) {
          errorMessage = jsonResponse['message'];
        } else if (jsonResponse['status'] == 'error' && jsonResponse['message'] != null) {
          errorMessage = jsonResponse['message'];
        }
        throw ApiException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }
  
  // ==================== AUTHENTICATION APIs ====================
  
  /// Login user
  Future<ApiResponse<LoginResponse>> login(String username, String password) async {
    return await _request<LoginResponse>(
      method: 'POST',
      endpoint: '/panel/api/login.php',
      body: {
        'username': username,
        'password': password,
      },
      fromJson: (json) => LoginResponse.fromJson(json),
    );
  }
  
  /// Logout user
  Future<ApiResponse<void>> logout() async {
    await _clearSession();
    return ApiResponse<void>(success: true, message: 'Logged out successfully');
  }
  
  /// Get current user info (mock implementation since API doesn't have this endpoint)
  Future<ApiResponse<User>> getCurrentUser() async {
    // Since the API doesn't have a "get current user" endpoint, 
    // we'll return a mock response to avoid crashes
    throw ApiException('No current user endpoint available');
  }
  
  // ==================== EXERCISE APIs ====================
  
  /// Get all exercises
  Future<ApiResponse<PaginatedResponse<Exercise>>> getExercises({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    return await _request<PaginatedResponse<Exercise>>(
      method: 'GET',
      endpoint: '/exercises/',
      queryParams: {
        if (category != null) 'category': category,
        'page': page.toString(),
        'limit': limit.toString(),
      },
      fromJson: (json) => PaginatedResponse<Exercise>.fromJson(
        json,
        (item) => Exercise.fromJson(item),
      ),
    );
  }
  
  /// Get exercise details
  Future<ApiResponse<Exercise>> getExerciseDetails(int exerciseId) async {
    return await _request<Exercise>(
      method: 'GET',
      endpoint: '/exercises/detail',
      queryParams: {'id': exerciseId.toString()},
      fromJson: (json) => Exercise.fromJson(json),
    );
  }
  
  /// Get user exercises for specific day (old endpoint - deprecated)
  Future<ApiResponse<UserDayExercises>> getOldUserDayExercises(int userId, int day) async {
    return await _request<UserDayExercises>(
      method: 'GET',
      endpoint: '/exercises/user-day',
      queryParams: {
        'userid': userId.toString(),
        'day': day.toString(),
      },
      fromJson: (json) => UserDayExercises.fromJson(json),
    );
  }
  
  // ==================== DAILY EXERCISE APIs ====================
  
  /// Get daily exercises overview
  Future<ApiResponse<DailyExercisesOverview>> getDailyExercises(int userId) async {
    return await _request<DailyExercisesOverview>(
      method: 'GET',
      endpoint: '/daily-exercises/$userId',
      fromJson: (json) => DailyExercisesOverview.fromJson(json),
    );
  }
  
  /// Get user exercise statistics from the real API
  Future<ApiResponse<RealUserStats>> getRealUserStats(int userId) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/statistics.php');
      
      print('API Request: GET $uri?user_id=$userId');
      
      http.Response response = await http.get(
        uri.replace(queryParameters: {'user_id': userId.toString()}),
        headers: _defaultHeaders,
      ).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['status'] == 'success') {
          final data = RealUserStats.fromJson(jsonResponse['data']);
          return ApiResponse<RealUserStats>(
            success: true,
            message: 'Statistics loaded successfully',
            data: data,
          );
        } else {
          throw ApiException(
            jsonResponse['message'] ?? 'Unknown error',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ApiException(
          jsonResponse['message'] ?? 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in getRealUserStats: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }
  
  /// Get user exercise personal bests
  Future<ApiResponse<List<ExercisePersonalBest>>> getExercisePersonalBests(int userId) async {
    return await _request<List<ExercisePersonalBest>>(
      method: 'GET',
      endpoint: '/user/personal-bests',
      queryParams: {'user_id': userId.toString()},
      fromJson: (json) => (json as List)
          .map((e) => ExercisePersonalBest.fromJson(e))
          .toList(),
    );
  }
  
  /// Get monthly weight progress for user
  Future<ApiResponse<List<MonthlyWeightProgress>>> getMonthlyWeightProgress(int userId, {int? months}) async {
    Map<String, String> params = {'user_id': userId.toString()};
    if (months != null) {
      params['months'] = months.toString();
    }
    
    return await _request<List<MonthlyWeightProgress>>(
      method: 'GET',
      endpoint: '/user/monthly-progress',
      queryParams: params,
      fromJson: (json) => (json as List)
          .map((e) => MonthlyWeightProgress.fromJson(e))
          .toList(),
    );
  }

  /// Mark exercise as completed
  Future<ApiResponse<ExerciseCompletionResponse>> markExerciseComplete({
    required int userId,
    required int userExerciseId,
    String? date,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/mark_exercise_complete.php');
      
      print('API Request: POST $uri');
      
      Map<String, dynamic> body = {
        'user_id': userId,
        'userexercise_id': userExerciseId,
      };
      
      if (date != null) {
        body['date'] = date;
      }
      
      print('Request Body: ${jsonEncode(body)}');
      
      http.Response response = await http.post(
        uri,
        headers: _defaultHeaders,
        body: jsonEncode(body),
      ).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['status'] == 'success') {
          final data = ExerciseCompletionResponse.fromJson(jsonResponse);
          return ApiResponse<ExerciseCompletionResponse>(
            success: true,
            message: jsonResponse['message'] ?? 'Exercise completed successfully',
            data: data,
          );
        } else {
          throw ApiException(
            jsonResponse['message'] ?? 'Unknown error',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ApiException(
          jsonResponse['message'] ?? 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }
  
  /// Get available days for user
  Future<ApiResponse<List<WorkoutDay>>> getWorkoutDays(int userId) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/fetch_days.php');
      uri = uri.replace(queryParameters: {'userid': userId.toString()});
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late List<dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonResponse
            .map((item) => WorkoutDay.fromJson(item))
            .toList();
        return ApiResponse<List<WorkoutDay>>(
          success: true,
          message: 'Success',
          data: data,
        );
      } else {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }



  /// Get meal days (Breakfast, Lunch, Dinner) for user
  Future<ApiResponse<List<MealDay>>> getMealDays(int userId) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/fetch_food_days.php');
      uri = uri.replace(queryParameters: {'userid': userId.toString()});
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late List<dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonResponse
            .map((item) => MealDay.fromJson(item))
            .toList();
        return ApiResponse<List<MealDay>>(
          success: true,
          message: 'Success',
          data: data,
        );
      } else {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Get meal foods for specific meal type (day parameter corresponds to meal type ID)
  Future<ApiResponse<List<MealFood>>> getMealFoods(int userId, int day) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/fetch_foods.php');
      uri = uri.replace(queryParameters: {
        'userid': userId.toString(),
        'day': day.toString(),
      });
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late List<dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonResponse
            .map((item) => MealFood.fromJson(item))
            .toList();
        return ApiResponse<List<MealFood>>(
          success: true,
          message: 'Success',
          data: data,
        );
      } else {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }


  
  /// Get exercises for specific day
  Future<ApiResponse<dynamic>> getWorkoutExercises(int userId, int day) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/fetch_exercises.php');
      uri = uri.replace(queryParameters: {
        'userid': userId.toString(),
        'day': day.toString(),
      });
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late dynamic jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Check if it's an object (participation ended) or array (active exercises)
        if (jsonResponse is Map<String, dynamic>) {
          // This is the participation status object
          final data = WorkoutData.fromJson(jsonResponse);
          return ApiResponse<WorkoutData>(
            success: true,
            message: jsonResponse['message'] ?? 'Success',
            data: data,
          );
        } else if (jsonResponse is List<dynamic>) {
          // This is a direct array of exercises
          final exercises = jsonResponse
              .map((item) => UserDayExercise.fromJson(item))
              .toList();
          return ApiResponse<List<UserDayExercise>>(
            success: true,
            message: 'Success',
            data: exercises,
          );
        } else {
          throw ApiException('Unexpected response format from server');
        }
      } else {
        throw ApiException(
          'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }
  
  // ==================== FOOD APIs ====================
  
  /// Get all foods
  Future<ApiResponse<PaginatedResponse<Food>>> getFoods({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    return await _request<PaginatedResponse<Food>>(
      method: 'GET',
      endpoint: '/foods/',
      queryParams: {
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        'page': page.toString(),
        'limit': limit.toString(),
      },
      fromJson: (json) => PaginatedResponse<Food>.fromJson(
        json,
        (item) => Food.fromJson(item),
      ),
    );
  }
  
  /// Get food details
  Future<ApiResponse<Food>> getFoodDetails(int foodId) async {
    return await _request<Food>(
      method: 'GET',
      endpoint: '/foods/detail',
      queryParams: {'id': foodId.toString()},
      fromJson: (json) => Food.fromJson(json),
    );
  }
  
  /// Get food categories
  Future<ApiResponse<List<FoodCategory>>> getFoodCategories() async {
    return await _request<List<FoodCategory>>(
      method: 'GET',
      endpoint: '/foods/categories',
      fromJson: (json) => (json as List)
          .map((item) => FoodCategory.fromJson(item))
          .toList(),
    );
  }
  
  // ==================== DAILY FOOD APIs ====================
  
  /// Get daily foods overview
  Future<ApiResponse<DailyFoodsOverview>> getDailyFoods(int userId) async {
    return await _request<DailyFoodsOverview>(
      method: 'GET',
      endpoint: '/daily-foods/$userId',
      fromJson: (json) => DailyFoodsOverview.fromJson(json),
    );
  }
  
  /// Get foods in category
  Future<ApiResponse<CategoryFoods>> getCategoryFoods(int userId, int categoryId) async {
    return await _request<CategoryFoods>(
      method: 'GET',
      endpoint: '/daily-foods/category',
      queryParams: {
        'userid': userId.toString(),
        'category_id': categoryId.toString(),
      },
      fromJson: (json) => CategoryFoods.fromJson(json),
    );
  }
  
  /// Add food to daily plan
  Future<ApiResponse<DailyFood>> addFoodToPlan({
    required int foodId,
    required double quantity,
    required int superset,
    String unit = 'g',
    String? mealTime,
    String? notes,
    int? userId,
  }) async {
    return await _request<DailyFood>(
      method: 'POST',
      endpoint: '/daily-foods/add',
      body: {
        'food_id': foodId,
        'quantity': quantity,
        'superset': superset,
        'unit': unit,
        if (mealTime != null) 'meal_time': mealTime,
        if (notes != null) 'notes': notes,
        if (userId != null) 'userid': userId,
      },
      fromJson: (json) => DailyFood.fromJson(json),
    );
  }
  
  // ==================== PROFILE APIs ====================
  
  /// Get user profile
  Future<ApiResponse<UserProfile>> getProfile([int? userId]) async {
    return await _request<UserProfile>(
      method: 'GET',
      endpoint: '/profile/',
      queryParams: userId != null ? {'userid': userId.toString()} : null,
      fromJson: (json) => UserProfile.fromJson(json),
    );
  }
  
  /// Update user profile
  Future<ApiResponse<User>> updateProfile({
    String? name,
    String? email,
    String? phone,
    double? height,
    double? weight,
    int? userId,
  }) async {
    return await _request<User>(
      method: 'PUT',
      endpoint: '/profile/',
      body: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (height != null) 'height': height,
        if (weight != null) 'bodywight': weight,
        if (userId != null) 'userid': userId,
      },
      fromJson: (json) => User.fromJson(json),
    );
  }
  
  /// Get user statistics
  Future<ApiResponse<UserStats>> getUserStats({
    int? userId,
    int days = 30,
  }) async {
    return await _request<UserStats>(
      method: 'GET',
      endpoint: '/profile/stats',
      queryParams: {
        if (userId != null) 'userid': userId.toString(),
        'days': days.toString(),
      },
      fromJson: (json) => UserStats.fromJson(json),
    );
  }

  /// Get shop items
  Future<ApiResponse<List<ShopItem>>> getShopItems() async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/shop.php');
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<ShopItem> data;
        
        // Handle the expected response structure with 'data' key
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          data = (jsonResponse['data'] as List)
              .map((item) => ShopItem.fromJson(item))
              .toList();
        } else {
          throw ApiException('Unexpected response format from server');
        }
        
        return ApiResponse<List<ShopItem>>(
          success: true,
          message: 'Success',
          data: data,
        );
      } else {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Get menu items
  Future<ApiResponse<List<MenuItem>>> getMenuItems() async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/menu.php');
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<MenuItem> data;
        
        // Handle the expected response structure with 'data' key
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          data = (jsonResponse['data'] as List)
              .map((item) => MenuItem.fromJson(item))
              .toList();
        } else {
          throw ApiException('Unexpected response format from server');
        }
        
        return ApiResponse<List<MenuItem>>(
          success: true,
          message: 'Success',
          data: data,
        );
      } else {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Get all suggestions/feedback
  Future<ApiResponse<List<Suggestion>>> getSuggestions() async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/suggestion.php');
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final data = (jsonResponse['data'] as List)
              .map((item) => Suggestion.fromJson(item))
              .toList();
          return ApiResponse<List<Suggestion>>(
            success: true,
            message: 'Success',
            data: data,
          );
        } else {
          throw ApiException('Unexpected response format from server');
        }
      } else {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Submit new suggestion/feedback
  Future<ApiResponse<SuggestionSubmitResponse>> submitSuggestion({
    required String username,
    required String note,
    required int userId,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/suggestion.php');
      
      print('API Request: POST $uri');
      
      Map<String, dynamic> body = {
        'username': username,
        'note': note,
        'userid': userId,
      };
      
      print('Request Body: ${jsonEncode(body)}');
      
      http.Response response = await http.post(
        uri,
        headers: _defaultHeaders,
        body: jsonEncode(body),
      ).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['success'] == true) {
          final data = SuggestionSubmitResponse.fromJson(jsonResponse);
          return ApiResponse<SuggestionSubmitResponse>(
            success: true,
            message: jsonResponse['message'] ?? 'Suggestion submitted successfully',
            data: data,
          );
        } else {
          throw ApiException(
            jsonResponse['error'] ?? 'Unknown error',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ApiException(
          jsonResponse['error'] ?? 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Get game items
  Future<ApiResponse<List<GameItem>>> getGameItems() async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/game.php');
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final data = (jsonResponse['data'] as List)
              .map((item) => GameItem.fromJson(item))
              .toList();
          return ApiResponse<List<GameItem>>(
            success: true,
            message: 'Success',
            data: data,
          );
        } else {
          throw ApiException('Unexpected response format from server');
        }
      } else {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Get notifications for user
  Future<ApiResponse<NotificationResponse>> getNotifications(int playerId) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/notification.php');
      uri = uri.replace(queryParameters: {'playerid': playerId.toString()});
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = NotificationResponse.fromJson(jsonResponse);
        return ApiResponse<NotificationResponse>(
          success: true,
          message: 'Success',
          data: data,
        );
      } else {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Get user profile data
  Future<ApiResponse<ProfileData>> getUserProfileData(int userId) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/get_profile.php');
      
      print('API Request: POST $uri');
      
      Map<String, dynamic> body = {
        'user_id': userId,
      };
      
      print('Request Body: ${jsonEncode(body)}');
      
      http.Response response = await http.post(
        uri,
        headers: _defaultHeaders,
        body: jsonEncode(body),
      ).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          final data = ProfileData.fromJson(jsonResponse['data']);
          return ApiResponse<ProfileData>(
            success: true,
            message: 'Profile loaded successfully',
            data: data,
          );
        } else {
          throw ApiException(
            jsonResponse['message'] ?? 'Unknown error',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ApiException(
          jsonResponse['message'] ?? 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Record exercise set
  Future<ApiResponse<ExerciseSetResponse>> recordExerciseSet({
    required int userExerciseId,
    required int userId,
    required int setNumber,
    required double weightKg,
    required int repetitions,
    String? notes,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/record_exercise_set.php');
      
      print('API Request: POST $uri');
      
      Map<String, dynamic> body = {
        'userexercise_id': userExerciseId,
        'user_id': userId,
        'set_number': setNumber,
        'weight_kg': weightKg,
        'repetitions': repetitions,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      
      print('Request Body: ${jsonEncode(body)}');
      
      http.Response response = await http.post(
        uri,
        headers: _defaultHeaders,
        body: jsonEncode(body),
      ).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['status'] == 'success' || jsonResponse['success'] == true) {
          final data = ExerciseSetResponse.fromJson(jsonResponse);
          return ApiResponse<ExerciseSetResponse>(
            success: true,
            message: jsonResponse['message'] ?? 'Exercise set recorded successfully',
            data: data,
          );
        } else {
          throw ApiException(
            jsonResponse['message'] ?? 'Failed to record exercise set',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ApiException(
          jsonResponse['message'] ?? 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Get last exercise set record
  Future<ApiResponse<List<ExerciseSetRecord>>> getLastExerciseSetRecord({
    required int userExerciseId,
    required int userId,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/get_last_exercise_sets.php');
      uri = uri.replace(queryParameters: {
        'userexercise_id': userExerciseId.toString(),
        'user_id': userId.toString(),
      });
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        return ApiResponse<List<ExerciseSetRecord>>(
          success: true,
          message: 'No previous records found',
          data: [],
        );
      }
      
      late dynamic jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<ExerciseSetRecord> data = [];
        
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['status'] == 'success' && jsonResponse['data'] is List) {
            data = (jsonResponse['data'] as List)
                .map((item) => ExerciseSetRecord.fromJson(item))
                .toList();
          } else if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
            data = (jsonResponse['data'] as List)
                .map((item) => ExerciseSetRecord.fromJson(item))
                .toList();
          }
        } else if (jsonResponse is List) {
          data = jsonResponse
              .map((item) => ExerciseSetRecord.fromJson(item))
              .toList();
        }
        
        return ApiResponse<List<ExerciseSetRecord>>(
          success: true,
          message: 'Success',
          data: data,
        );
      } else {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Get highest weight for exercise
  Future<ApiResponse<double?>> getExerciseHighestWeight({
    required int userExerciseId,
    required int userId,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/get_exercise_stats.php');
      uri = uri.replace(queryParameters: {
        'userexercise_id': userExerciseId.toString(),
        'user_id': userId.toString(),
        'stat_type': 'highest_weight',
      });
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic> && jsonResponse['status'] == 'success') {
          double? weight = jsonResponse['data'] != null ? User._parseDouble(jsonResponse['data']) : null;
          return ApiResponse<double?>(
            success: true,
            message: 'Success',
            data: weight,
          );
        }
      }
      
      return ApiResponse<double?>(
        success: true,
        message: 'No previous records found',
        data: null,
      );
    } catch (e) {
      print('Error getting highest weight: $e');
      return ApiResponse<double?>(
        success: true,
        message: 'No previous records found',
        data: null,
      );
    }
  }

  /// Get last time weight for exercise
  Future<ApiResponse<double?>> getExerciseLastWeight({
    required int userExerciseId,
    required int userId,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/get_exercise_stats.php');
      uri = uri.replace(queryParameters: {
        'userexercise_id': userExerciseId.toString(),
        'user_id': userId.toString(),
        'stat_type': 'last_weight',
      });
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic> && jsonResponse['status'] == 'success') {
          double? weight = jsonResponse['data'] != null ? User._parseDouble(jsonResponse['data']) : null;
          return ApiResponse<double?>(
            success: true,
            message: 'Success',
            data: weight,
          );
        }
      }
      
      return ApiResponse<double?>(
        success: true,
        message: 'No previous records found',
        data: null,
      );
    } catch (e) {
      print('Error getting last weight: $e');
      return ApiResponse<double?>(
        success: true,
        message: 'No previous records found',
        data: null,
      );
    }
  }

  /// Get exercise set information for recording
  Future<ApiResponse<ExerciseSetInfoResponse>> getExerciseSetInfo({
    required int userExerciseId,
    required int userId,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/record_exercise_set.php');
      uri = uri.replace(queryParameters: {
        'userexercise_id': userExerciseId.toString(),
        'user_id': userId.toString(),
      });
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late dynamic jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['status'] == 'success') {
            final data = ExerciseSetInfoResponse.fromJson(jsonResponse);
            return ApiResponse<ExerciseSetInfoResponse>(
              success: true,
              message: jsonResponse['message'] ?? 'Success',
              data: data,
            );
          } else {
            throw ApiException(
              jsonResponse['message'] ?? 'Failed to get exercise set info',
              statusCode: response.statusCode,
            );
          }
        } else {
          throw ApiException('Invalid response format from server', statusCode: response.statusCode);
        }
      } else {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Get carousel images for banner
  Future<ApiResponse<List<String>>> getCarouselImages() async {
    try {
      Uri uri = Uri.parse('$baseUrl/panel/api/get_carousel.php');
      
      print('API Request: GET $uri');
      
      http.Response response = await http.get(uri, headers: _defaultHeaders).timeout(timeout);
      
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error Response Body: ${response.body}');
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        throw ApiException('Empty response from server', statusCode: response.statusCode);
      }
      
      late dynamic jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing failed: $e');
        throw ApiException('Invalid JSON response from server', statusCode: response.statusCode);
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<String> data;
        
        // Handle different response structures
        if (jsonResponse is List) {
          // Direct array of strings
          data = jsonResponse.cast<String>();
        } else if (jsonResponse is Map<String, dynamic>) {
          // Object wrapper - check common keys
          if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
            data = (jsonResponse['data'] as List).cast<String>();
          } else if (jsonResponse.containsKey('images') && jsonResponse['images'] is List) {
            data = (jsonResponse['images'] as List).cast<String>();
          } else if (jsonResponse.containsKey('carousel') && jsonResponse['carousel'] is List) {
            data = (jsonResponse['carousel'] as List).cast<String>();
          } else {
            // If it's a Map but doesn't contain expected array keys, try to extract values
            List<dynamic> values = jsonResponse.values.where((v) => v is List).cast<List>().expand((x) => x).toList();
            if (values.isNotEmpty) {
              data = values.cast<String>();
            } else {
              throw ApiException('No image array found in API response');
            }
          }
        } else {
          throw ApiException('Unexpected response format from server');
        }
        
        return ApiResponse<List<String>>(
          success: true,
          message: 'Success',
          data: data,
        );
      } else {
        throw ApiException('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      print('Unexpected error in API request: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }
}

// ==================== DATA MODELS ====================

/// Generic API Response wrapper
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

/// API Exception
class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  
  ApiException(this.message, {this.code, this.statusCode});
  
  @override
  String toString() => 'ApiException: $message';
}

/// Paginated Response
class PaginatedResponse<T> {
  final List<T> items;
  final Pagination pagination;
  
  PaginatedResponse({
    required this.items,
    required this.pagination,
  });
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final String itemsKey = json.containsKey('exercises') 
        ? 'exercises' 
        : json.containsKey('foods') 
            ? 'foods' 
            : 'items';
    
    return PaginatedResponse<T>(
      items: (json[itemsKey] as List)
          .map((item) => fromJsonT(item))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

/// Pagination info
class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int totalPages;
  
  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });
  
  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
    );
  }
}

/// User model
class User {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final double? height;
  final double? weight;
  final String? cityId;
  final int? points;
  final String? lastExerciseDate;
  
  User({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.height,
    this.weight,
    this.cityId,
    this.points,
    this.lastExerciseDate,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      height: _parseDoubleNullable(json['height']),
      weight: _parseDoubleNullable(json['bodywight']),
      cityId: json['cityid'],
      points: _parseIntNullable(json['points']),
      lastExerciseDate: json['last_exercise_date'],
    );
  }
  
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
  
  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
  
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  
  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Exercise model
class Exercise {
  final int id;
  final String name;
  final String? description;
  final String? instructions;
  final String? category;
  final String? difficulty;
  final String? image;
  final String? videoUrl;
  final String? muscleGroups;
  final String? equipment;
  final String? duration;
  final String? caloriesBurned;
  
  Exercise({
    required this.id,
    required this.name,
    this.description,
    this.instructions,
    this.category,
    this.difficulty,
    this.image,
    this.videoUrl,
    this.muscleGroups,
    this.equipment,
    this.duration,
    this.caloriesBurned,
  });
  
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: User._parseInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'],
      instructions: json['instructions'],
      category: json['category'],
      difficulty: json['difficulty'],
      image: json['image'],
      videoUrl: json['video_url'],
      muscleGroups: json['muscle_groups'],
      equipment: json['equipment'],
      duration: json['duration'],
      caloriesBurned: json['calories_burned'],
    );
  }
}

/// User Exercise model
class UserExercise {
  final int id;
  final int exerciseId;
  final String exerciseName;
  final int? sets;
  final int? reps;
  final String? customSet;
  final String? weight;
  final String? restTime;
  final bool completed;
  final String? completedAt;
  final String? image;
  final String? category;
  final String? difficulty;
  
  UserExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    this.sets,
    this.reps,
    this.customSet,
    this.weight,
    this.restTime,
    required this.completed,
    this.completedAt,
    this.image,
    this.category,
    this.difficulty,
  });
  
  factory UserExercise.fromJson(Map<String, dynamic> json) {
    return UserExercise(
      id: User._parseInt(json['id']),
      exerciseId: User._parseInt(json['exercise_id']),
      exerciseName: json['exercise_name'] ?? '',
      sets: User._parseIntNullable(json['sets']),
      reps: User._parseIntNullable(json['reps']),
      customSet: json['custom_set'],
      weight: json['weight'],
      restTime: json['rest_time'],
      completed: json['completed'] == 1 || json['completed'] == '1' || json['completed'] == true,
      completedAt: json['completed_at'],
      image: json['image'],
      category: json['category'],
      difficulty: json['difficulty'],
    );
  }
}

/// Superset model
class Superset {
  final int id;
  final String name;
  final String type;
  final List<UserExercise> exercises;
  final int totalExercises;
  final int completedExercises;
  
  Superset({
    required this.id,
    required this.name,
    required this.type,
    required this.exercises,
    required this.totalExercises,
    required this.completedExercises,
  });
  
  factory Superset.fromJson(Map<String, dynamic> json) {
    return Superset(
      id: User._parseInt(json['id']),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => UserExercise.fromJson(e))
          .toList(),
      totalExercises: User._parseInt(json['total_exercises']),
      completedExercises: User._parseInt(json['completed_exercises']),
    );
  }
}

/// User Day Exercises model
class UserDayExercises {
  final List<UserExercise> regularExercises;
  final List<Superset> supersets;
  final int day;
  final int userId;
  
  UserDayExercises({
    required this.regularExercises,
    required this.supersets,
    required this.day,
    required this.userId,
  });
  
  factory UserDayExercises.fromJson(Map<String, dynamic> json) {
    return UserDayExercises(
      regularExercises: (json['regular_exercises'] as List)
          .map((e) => UserExercise.fromJson(e))
          .toList(),
      supersets: (json['supersets'] as List)
          .map((s) => Superset.fromJson(s))
          .toList(),
      day: json['day'],
      userId: json['user_id'],
    );
  }
}

/// Daily Exercise Day model
class ExerciseDay {
  final int day;
  final String? exerciseDate;
  final int totalExercises;
  final int completedExercises;
  final double completionPercentage;
  final String apiUrl;
  
  ExerciseDay({
    required this.day,
    this.exerciseDate,
    required this.totalExercises,
    required this.completedExercises,
    required this.completionPercentage,
    required this.apiUrl,
  });
  
  factory ExerciseDay.fromJson(Map<String, dynamic> json) {
    return ExerciseDay(
      day: User._parseInt(json['day']),
      exerciseDate: json['exercise_date'],
      totalExercises: User._parseInt(json['total_exercises']),
      completedExercises: User._parseInt(json['completed_exercises']),
      completionPercentage: User._parseDouble(json['completion_percentage']),
      apiUrl: json['api_url'],
    );
  }
}

/// Daily Exercises Overview model
class DailyExercisesOverview {
  final int userId;
  final List<ExerciseDay> days;
  final int totalDays;
  
  DailyExercisesOverview({
    required this.userId,
    required this.days,
    required this.totalDays,
  });
  
  factory DailyExercisesOverview.fromJson(Map<String, dynamic> json) {
    return DailyExercisesOverview(
      userId: json['user_id'],
      days: (json['days'] as List)
          .map((d) => ExerciseDay.fromJson(d))
          .toList(),
      totalDays: json['total_days'],
    );
  }
}

/// Completed Exercise model
class CompletedExercise {
  final int id;
  final int exerciseId;
  final String exerciseName;
  final bool completed;
  final String? completedAt;
  
  CompletedExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.completed,
    this.completedAt,
  });
  
  factory CompletedExercise.fromJson(Map<String, dynamic> json) {
    return CompletedExercise(
      id: json['id'],
      exerciseId: json['exercise_id'],
      exerciseName: json['exercise_name'],
      completed: json['completed'] == 1,
      completedAt: json['completed_at'],
    );
  }
}

/// Day Exercises model
class DayExercises {
  final int userId;
  final int day;
  final List<UserExercise> regularExercises;
  final List<Superset> supersets;
  final ExerciseStatistics statistics;
  
  DayExercises({
    required this.userId,
    required this.day,
    required this.regularExercises,
    required this.supersets,
    required this.statistics,
  });
  
  factory DayExercises.fromJson(Map<String, dynamic> json) {
    return DayExercises(
      userId: User._parseInt(json['user_id']),
      day: User._parseInt(json['day']),
      regularExercises: (json['regular_exercises'] as List? ?? [])
          .map((e) => UserExercise.fromJson(e))
          .toList(),
      supersets: (json['supersets'] as List? ?? [])
          .map((s) => Superset.fromJson(s))
          .toList(),
      statistics: json['statistics'] != null 
          ? ExerciseStatistics.fromJson(json['statistics'])
          : ExerciseStatistics(totalExercises: 0, completedExercises: 0, completionPercentage: 0.0),
    );
  }
}

/// Exercise Statistics model
class ExerciseStatistics {
  final int totalExercises;
  final int completedExercises;
  final double completionPercentage;
  
  ExerciseStatistics({
    required this.totalExercises,
    required this.completedExercises,
    required this.completionPercentage,
  });
  
  factory ExerciseStatistics.fromJson(Map<String, dynamic> json) {
    return ExerciseStatistics(
      totalExercises: User._parseInt(json['total_exercises']),
      completedExercises: User._parseInt(json['completed_exercises']),
      completionPercentage: User._parseDouble(json['completion_percentage']),
    );
  }
}

/// Food model
class Food {
  final int id;
  final String name;
  final String? description;
  final String? category;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double? fiberPer100g;
  final double? sugarPer100g;
  final double? sodiumPer100g;
  final String? image;
  final String? preparationTime;
  final String? servingSize;
  final String? recipe;
  final String? ingredients;
  final String? allergens;
  final DietaryInfo? dietaryInfo;
  
  Food({
    required this.id,
    required this.name,
    this.description,
    this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g,
    this.sugarPer100g,
    this.sodiumPer100g,
    this.image,
    this.preparationTime,
    this.servingSize,
    this.recipe,
    this.ingredients,
    this.allergens,
    this.dietaryInfo,
  });
  
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: User._parseInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'],
      caloriesPer100g: User._parseDouble(json['calories_per_100g']),
      proteinPer100g: User._parseDouble(json['protein_per_100g']),
      carbsPer100g: User._parseDouble(json['carbs_per_100g']),
      fatPer100g: User._parseDouble(json['fat_per_100g']),
      fiberPer100g: User._parseDoubleNullable(json['fiber_per_100g']),
      sugarPer100g: User._parseDoubleNullable(json['sugar_per_100g']),
      sodiumPer100g: User._parseDoubleNullable(json['sodium_per_100g']),
      image: json['image'],
      preparationTime: json['preparation_time'],
      servingSize: json['serving_size'],
      recipe: json['recipe'],
      ingredients: json['ingredients'],
      allergens: json['allergens'],
      dietaryInfo: json['dietary_info'] != null 
          ? DietaryInfo.fromJson(json['dietary_info']) 
          : null,
    );
  }
}

/// Dietary Info model
class DietaryInfo {
  final bool vegetarian;
  final bool vegan;
  final bool glutenFree;
  final bool dairyFree;
  
  DietaryInfo({
    required this.vegetarian,
    required this.vegan,
    required this.glutenFree,
    required this.dairyFree,
  });
  
  factory DietaryInfo.fromJson(Map<String, dynamic> json) {
    return DietaryInfo(
      vegetarian: json['vegetarian'] == 1,
      vegan: json['vegan'] == 1,
      glutenFree: json['gluten_free'] == 1,
      dairyFree: json['dairy_free'] == 1,
    );
  }
}

/// Food Category model
class FoodCategory {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int foodCount;
  
  FoodCategory({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.foodCount,
  });
  
  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      foodCount: json['food_count'],
    );
  }
}

/// Food Category Overview model
class FoodCategoryOverview {
  final int supersetId;
  final String categoryName;
  final String? image;
  final String? completionDate;
  final bool isCompleted;
  final int totalFoods;
  final String apiUrl;
  
  FoodCategoryOverview({
    required this.supersetId,
    required this.categoryName,
    this.image,
    this.completionDate,
    required this.isCompleted,
    required this.totalFoods,
    required this.apiUrl,
  });
  
  factory FoodCategoryOverview.fromJson(Map<String, dynamic> json) {
    return FoodCategoryOverview(
      supersetId: json['superset_id'],
      categoryName: json['category_name'],
      image: json['image'],
      completionDate: json['completion_date'],
      isCompleted: json['is_completed'],
      totalFoods: json['total_foods'],
      apiUrl: json['api_url'],
    );
  }
}

/// Daily Foods Overview model
class DailyFoodsOverview {
  final int userId;
  final List<FoodCategoryOverview> foodCategories;
  final int totalCategories;
  
  DailyFoodsOverview({
    required this.userId,
    required this.foodCategories,
    required this.totalCategories,
  });
  
  factory DailyFoodsOverview.fromJson(Map<String, dynamic> json) {
    return DailyFoodsOverview(
      userId: json['user_id'],
      foodCategories: (json['food_categories'] as List)
          .map((c) => FoodCategoryOverview.fromJson(c))
          .toList(),
      totalCategories: json['total_categories'],
    );
  }
}

/// Daily Food model
class DailyFood {
  final int id;
  final int foodId;
  final String foodName;
  final double quantity;
  final String unit;
  final String? mealTime;
  final String? notes;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? addedDate;
  final String? image;
  
  DailyFood({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.unit,
    this.mealTime,
    this.notes,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.addedDate,
    this.image,
  });
  
  factory DailyFood.fromJson(Map<String, dynamic> json) {
    return DailyFood(
      id: User._parseInt(json['id']),
      foodId: User._parseInt(json['food_id']),
      foodName: json['food_name'] ?? '',
      quantity: User._parseDouble(json['quantity']),
      unit: json['unit'] ?? '',
      mealTime: json['meal_time'],
      notes: json['notes'],
      calories: User._parseDouble(json['calories']),
      protein: User._parseDouble(json['protein']),
      carbs: User._parseDouble(json['carbs']),
      fat: User._parseDouble(json['fat']),
      addedDate: json['added_date'],
      image: json['image'],
    );
  }
}

/// Nutritional Summary model
class NutritionalSummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  
  NutritionalSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });
  
  factory NutritionalSummary.fromJson(Map<String, dynamic> json) {
    return NutritionalSummary(
      totalCalories: User._parseDouble(json['total_calories']),
      totalProtein: User._parseDouble(json['total_protein']),
      totalCarbs: User._parseDouble(json['total_carbs']),
      totalFat: User._parseDouble(json['total_fat']),
    );
  }
}

/// Category Foods model
class CategoryFoods {
  final int userId;
  final int categoryId;
  final String categoryName;
  final String? categoryImage;
  final bool isCompleted;
  final String? completionDate;
  final List<DailyFood> foods;
  final NutritionalSummary nutritionalSummary;
  final int totalFoods;
  
  CategoryFoods({
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    this.categoryImage,
    required this.isCompleted,
    this.completionDate,
    required this.foods,
    required this.nutritionalSummary,
    required this.totalFoods,
  });
  
  factory CategoryFoods.fromJson(Map<String, dynamic> json) {
    return CategoryFoods(
      userId: json['user_id'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryImage: json['category_image'],
      isCompleted: json['is_completed'],
      completionDate: json['completion_date'],
      foods: (json['foods'] as List)
          .map((f) => DailyFood.fromJson(f))
          .toList(),
      nutritionalSummary: NutritionalSummary.fromJson(json['nutritional_summary']),
      totalFoods: json['total_foods'],
    );
  }
}

/// User Profile model
class UserProfile {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final double? height;
  final double? weight;
  final double? bmi;
  final String? cityId;
  final int? points;
  final String? lastExerciseDate;
  final ProfileStatistics statistics;
  
  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.height,
    this.weight,
    this.bmi,
    this.cityId,
    this.points,
    this.lastExerciseDate,
    required this.statistics,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: User._parseInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      height: User._parseDoubleNullable(json['height']),
      weight: User._parseDoubleNullable(json['weight']),
      bmi: User._parseDoubleNullable(json['bmi']),
      cityId: json['cityid'],
      points: User._parseIntNullable(json['points']),
      lastExerciseDate: json['last_exercise_date'],
      statistics: ProfileStatistics.fromJson(json['statistics']),
    );
  }
}

/// Profile Statistics model
class ProfileStatistics {
  final int totalExercises;
  final int completedExercises;
  final double exerciseCompletionRate;
  final int totalFoodsLogged;
  
  ProfileStatistics({
    required this.totalExercises,
    required this.completedExercises,
    required this.exerciseCompletionRate,
    required this.totalFoodsLogged,
  });
  
  factory ProfileStatistics.fromJson(Map<String, dynamic> json) {
    return ProfileStatistics(
      totalExercises: User._parseInt(json['total_exercises']),
      completedExercises: User._parseInt(json['completed_exercises']),
      exerciseCompletionRate: User._parseDouble(json['exercise_completion_rate']),
      totalFoodsLogged: User._parseInt(json['total_foods_logged']),
    );
  }
}

/// User Stats model
class UserStats {
  final int userId;
  final StatsPeriod period;
  final ExerciseStatsDetailed exerciseStatistics;
  final FoodStatistics foodStatistics;
  final HealthMetrics healthMetrics;
  final List<DailyActivity> dailyActivities;
  
  UserStats({
    required this.userId,
    required this.period,
    required this.exerciseStatistics,
    required this.foodStatistics,
    required this.healthMetrics,
    required this.dailyActivities,
  });
  
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['user_id'],
      period: StatsPeriod.fromJson(json['period']),
      exerciseStatistics: ExerciseStatsDetailed.fromJson(json['exercise_statistics']),
      foodStatistics: FoodStatistics.fromJson(json['food_statistics']),
      healthMetrics: HealthMetrics.fromJson(json['health_metrics']),
      dailyActivities: (json['daily_activities'] as List)
          .map((a) => DailyActivity.fromJson(a))
          .toList(),
    );
  }
}

/// Stats Period model
class StatsPeriod {
  final int days;
  final String startDate;
  final String endDate;
  
  StatsPeriod({
    required this.days,
    required this.startDate,
    required this.endDate,
  });
  
  factory StatsPeriod.fromJson(Map<String, dynamic> json) {
    return StatsPeriod(
      days: json['days'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}

/// Exercise Stats Detailed model
class ExerciseStatsDetailed {
  final int totalExercises;
  final int completedExercises;
  final double completionRate;
  final int activeDays;
  final int currentStreak;
  
  ExerciseStatsDetailed({
    required this.totalExercises,
    required this.completedExercises,
    required this.completionRate,
    required this.activeDays,
    required this.currentStreak,
  });
  
  factory ExerciseStatsDetailed.fromJson(Map<String, dynamic> json) {
    return ExerciseStatsDetailed(
      totalExercises: User._parseInt(json['total_exercises']),
      completedExercises: User._parseInt(json['completed_exercises']),
      completionRate: User._parseDouble(json['completion_rate']),
      activeDays: User._parseInt(json['active_days']),
      currentStreak: User._parseInt(json['current_streak']),
    );
  }
}

/// Food Statistics model
class FoodStatistics {
  final int totalFoodsLogged;
  final int foodLoggingDays;
  final double averageFoodsPerDay;
  
  FoodStatistics({
    required this.totalFoodsLogged,
    required this.foodLoggingDays,
    required this.averageFoodsPerDay,
  });
  
  factory FoodStatistics.fromJson(Map<String, dynamic> json) {
    return FoodStatistics(
      totalFoodsLogged: User._parseInt(json['total_foods_logged']),
      foodLoggingDays: User._parseInt(json['food_logging_days']),
      averageFoodsPerDay: User._parseDouble(json['average_foods_per_day']),
    );
  }
}

/// Health Metrics model
class HealthMetrics {
  final int currentPoints;
  final double? height;
  final double? weight;
  final double? bmi;
  final String? bmiCategory;
  
  HealthMetrics({
    required this.currentPoints,
    this.height,
    this.weight,
    this.bmi,
    this.bmiCategory,
  });
  
  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      currentPoints: User._parseInt(json['current_points']),
      height: User._parseDoubleNullable(json['height']),
      weight: User._parseDoubleNullable(json['weight']),
      bmi: User._parseDoubleNullable(json['bmi']),
      bmiCategory: json['bmi_category'],
    );
  }
}

/// Daily Activity model
class DailyActivity {
  final String date;
  final int totalExercises;
  final int completedExercises;
  final double completionRate;
  
  DailyActivity({
    required this.date,
    required this.totalExercises,
    required this.completedExercises,
    required this.completionRate,
  });
  
  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      date: json['date'] ?? '',
      totalExercises: User._parseInt(json['total_exercises']),
      completedExercises: User._parseInt(json['completed_exercises']),
      completionRate: User._parseDouble(json['completion_rate']),
    );
  }
}

/// Workout Day model for the new API
class WorkoutDay {
  final int day;
  final int exerciseCount;
  final String dayNameEn;
  final String dayNameAr;
  final String dayNameKu;
  final String dayImage;
  
  WorkoutDay({
    required this.day,
    required this.exerciseCount,
    required this.dayNameEn,
    required this.dayNameAr,
    required this.dayNameKu,
    required this.dayImage,
  });
  
  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      day: User._parseInt(json['day']),
      exerciseCount: User._parseInt(json['exercise_count']),
      dayNameEn: json['daynameen'] ?? '',
      dayNameAr: json['daynamear'] ?? '',
      dayNameKu: json['daynameku'] ?? '',
      dayImage: json['dayimage'] ?? '',
    );
  }
}

/// Workout Data model for exercise response
class WorkoutData {
  final String status;
  final String message;
  final ParticipationData? data;
  
  WorkoutData({
    required this.status,
    required this.message,
    this.data,
  });
  
  factory WorkoutData.fromJson(Map<String, dynamic> json) {
    return WorkoutData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? ParticipationData.fromJson(json['data']) : null,
    );
  }
}

/// Participation Data model
class ParticipationData {
  final int id;
  final int participationId;
  final String startDate;
  final String endDate;
  final int month;
  final int typeId;
  final int playerType;
  final int amount;
  final String note;
  final int course;
  final String realDate;
  final String todayDate;
  final int userId;
  final int captnId;
  
  ParticipationData({
    required this.id,
    required this.participationId,
    required this.startDate,
    required this.endDate,
    required this.month,
    required this.typeId,
    required this.playerType,
    required this.amount,
    required this.note,
    required this.course,
    required this.realDate,
    required this.todayDate,
    required this.userId,
    required this.captnId,
  });
  
  factory ParticipationData.fromJson(Map<String, dynamic> json) {
    return ParticipationData(
      id: User._parseInt(json['id']),
      participationId: User._parseInt(json['participationid']),
      startDate: json['startdate'] ?? '',
      endDate: json['enddate'] ?? '',
      month: User._parseInt(json['month']),
      typeId: User._parseInt(json['typeid']),
      playerType: User._parseInt(json['playertype']),
      amount: User._parseInt(json['amout']), // Note: typo in API (amout vs amount)
      note: json['note'] ?? '',
      course: User._parseInt(json['course']),
      realDate: json['realdate'] ?? '',
      todayDate: json['todaydate'] ?? '',
      userId: User._parseInt(json['userid']),
      captnId: User._parseInt(json['captnid']),
    );
  }
}

/// Login Response model for the new API
class LoginResponse {
  final String status;
  final String? message;
  final int? userId;
  
  LoginResponse({
    required this.status,
    this.message,
    this.userId,
  });
  
  bool get isSuccess => status == 'success';
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? '',
      message: json['message'],
      userId: User._parseIntNullable(json['user_id']),
    );
  }
}

/// Exercise Completion Response model
class ExerciseCompletionResponse {
  final String status;
  final String message;
  final int? id;
  
  ExerciseCompletionResponse({
    required this.status,
    required this.message,
    this.id,
  });
  
  bool get isSuccess => status == 'success';
  
  factory ExerciseCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseCompletionResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      id: User._parseIntNullable(json['id']),
    );
  }
}

/// Meal Day model - represents meal types (Breakfast, Lunch, Dinner)
class MealDay {
  final int id;
  final String day; // "Breakfast", "Lunch", "Dinner"
  final String? dayKurdish;
  final String? dayArabic;
  final int superset;
  final String mealType;
  final String? mealTypeKurdish;
  final String? mealTypeArabic;
  final int mealCount;
  final String dayImage;
  
  MealDay({
    required this.id,
    required this.day,
    this.dayKurdish,
    this.dayArabic,
    required this.superset,
    required this.mealType,
    this.mealTypeKurdish,
    this.mealTypeArabic,
    required this.mealCount,
    required this.dayImage,
  });
  
  // Get localized day name based on language code
  String getLocalizedDay(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return dayArabic?.isNotEmpty == true ? dayArabic! : day;
      case 'fa': // Kurdish
        return dayKurdish?.isNotEmpty == true ? dayKurdish! : day;
      default:
        return day;
    }
  }
  
  // Get localized meal type based on language code
  String getLocalizedMealType(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return mealTypeArabic?.isNotEmpty == true ? mealTypeArabic! : mealType;
      case 'fa': // Kurdish
        return mealTypeKurdish?.isNotEmpty == true ? mealTypeKurdish! : mealType;
      default:
        return mealType;
    }
  }
  
  factory MealDay.fromJson(Map<String, dynamic> json) {
    return MealDay(
      id: User._parseInt(json['id']),
      day: json['day'] ?? '',
      dayKurdish: json['day_kurdish'],
      dayArabic: json['day_arabic'],
      superset: User._parseInt(json['superset']),
      mealType: json['meal_type'] ?? '',
      mealTypeKurdish: json['meal_type_kurdish'],
      mealTypeArabic: json['meal_type_arabic'],
      mealCount: User._parseInt(json['meal_count']),
      dayImage: json['dayimage'] ?? '',
    );
  }
}

/// MealFood model - represents individual food items in meal plans
class MealFood {
  final int foodUsersId; // foodusers_id from API
  final int foodId; // foodid from API
  final String gram; // serving size
  final int done; // 0 or 1
  final String date;
  final int superset;
  final int day;
  final String foodName; // food_name from API
  final String? foodNameKurdish;
  final String? foodNameArabic;
  final String image;
  final bool completed;
  
  MealFood({
    required this.foodUsersId,
    required this.foodId,
    required this.gram,
    required this.done,
    required this.date,
    required this.superset,
    required this.day,
    required this.foodName,
    this.foodNameKurdish,
    this.foodNameArabic,
    required this.image,
    required this.completed,
  });
  
  // Computed properties for compatibility
  bool get isCompleted => completed || done == 1;
  int get id => foodUsersId;
  String get name => foodName;
  
  // Get localized food name based on language code
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return foodNameArabic?.isNotEmpty == true ? foodNameArabic! : foodName;
      case 'fa': // Kurdish
        return foodNameKurdish?.isNotEmpty == true ? foodNameKurdish! : foodName;
      default:
        return foodName;
    }
  }
  
  factory MealFood.fromJson(Map<String, dynamic> json) {
    return MealFood(
      foodUsersId: User._parseInt(json['foodusers_id']),
      foodId: User._parseInt(json['foodid']),
      gram: json['gram'] ?? '',
      done: User._parseInt(json['done']),
      date: json['date'] ?? '',
      superset: User._parseInt(json['superset']),
      day: User._parseInt(json['day']),
      foodName: json['food_name'] ?? '',
      foodNameKurdish: json['food_name_kurdish'],
      foodNameArabic: json['food_name_arabic'],
      image: json['image'] ?? '',
      completed: json['completed'] == true || json['completed'] == 1 || json['done'] == 1,
    );
  }
}

/// ShopItem model - represents shop items from the shop API
class ShopItem {
  final String itemId;
  final String itemName;
  final String? itemNameKurdish;
  final String? itemNameArabic;
  final String itemType;
  final String itemCategory;
  final String? itemCategoryKurdish;
  final String? itemCategoryArabic;
  final String price;
  final String? imageId;
  final String? imageId2;
  final String? imageId3;
  final String? imageId4;
  final String? imagePath;
  final String? filename;
  final String itemDescription;
  final String? itemDescriptionKurdish;
  final String? itemDescriptionArabic;
  
  ShopItem({
    required this.itemId,
    required this.itemName,
    this.itemNameKurdish,
    this.itemNameArabic,
    required this.itemType,
    required this.itemCategory,
    this.itemCategoryKurdish,
    this.itemCategoryArabic,
    required this.price,
    this.imageId,
    this.imageId2,
    this.imageId3,
    this.imageId4,
    this.imagePath,
    this.filename,
    required this.itemDescription,
    this.itemDescriptionKurdish,
    this.itemDescriptionArabic,
  });
  
  // Get all image URLs
  List<String> get allImageUrls {
    List<String> urls = [];
    
    // Add primary image if available
    if (imagePath != null && imagePath!.isNotEmpty) {
      String cleanImageUrl = imagePath!.replaceAll(r'\/', '/');
      if (cleanImageUrl.contains('../uploads/')) {
        final filename = cleanImageUrl.split('/uploads/').last;
        cleanImageUrl = 'https://therocfit.com/uploads/$filename';
      }
      urls.add(cleanImageUrl);
    }
    
    // Add additional images based on imageId2, imageId3, imageId4
    final additionalImageIds = [imageId2, imageId3, imageId4];
    for (String? imageId in additionalImageIds) {
      if (imageId != null && imageId.isNotEmpty) {
        urls.add('https://therocfit.com/uploads/$imageId.png');
      }
    }
    
    return urls;
  }
  
  // Get localized item name based on language code
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return itemNameArabic?.isNotEmpty == true ? itemNameArabic! : itemName;
      case 'fa': // Kurdish
        return itemNameKurdish?.isNotEmpty == true ? itemNameKurdish! : itemName;
      default:
        return itemName;
    }
  }
  
  // Get localized category based on language code
  String getLocalizedCategory(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return itemCategoryArabic?.isNotEmpty == true ? itemCategoryArabic! : itemCategory;
      case 'fa': // Kurdish
        return itemCategoryKurdish?.isNotEmpty == true ? itemCategoryKurdish! : itemCategory;
      default:
        return itemCategory;
    }
  }
  
  // Get localized description based on language code
  String getLocalizedDescription(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return itemDescriptionArabic?.isNotEmpty == true ? itemDescriptionArabic! : itemDescription;
      case 'fa': // Kurdish
        return itemDescriptionKurdish?.isNotEmpty == true ? itemDescriptionKurdish! : itemDescription;
      default:
        return itemDescription;
    }
  }
  
  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      itemId: json['item_id']?.toString() ?? '',
      itemName: json['item_name'] ?? '',
      itemNameKurdish: json['item_name_kurdish'],
      itemNameArabic: json['item_name_arabic'],
      itemType: json['item_type'] ?? '',
      itemCategory: json['item_category'] ?? '',
      itemCategoryKurdish: json['item_category_kurdish'],
      itemCategoryArabic: json['item_category_arabic'],
      price: json['price']?.toString() ?? '0',
      imageId: json['imageid']?.toString(),
      imageId2: json['imageid2']?.toString(),
      imageId3: json['imageid3']?.toString(),
      imageId4: json['imageid4']?.toString(),
      imagePath: json['image_path'],
      filename: json['filename'],
      itemDescription: json['item_description'] ?? '',
      itemDescriptionKurdish: json['item_description_kurdish'],
      itemDescriptionArabic: json['item_description_arabic'],
    );
  }
}

/// MenuItem model - represents menu items from the menu API
class MenuItem {
  final String itemId;
  final String itemName;
  final String? itemNameKurdish;
  final String? itemNameArabic;
  final String itemType; // "Food" or "Suppliment"
  final String itemCategory;
  final String? itemCategoryKurdish;
  final String? itemCategoryArabic;
  final String price;
  final String? imageId;
  final String? imagePath;
  final String? filename;
  final String itemDescription;
  final String? itemDescriptionKurdish;
  final String? itemDescriptionArabic;
  
  MenuItem({
    required this.itemId,
    required this.itemName,
    this.itemNameKurdish,
    this.itemNameArabic,
    required this.itemType,
    required this.itemCategory,
    this.itemCategoryKurdish,
    this.itemCategoryArabic,
    required this.price,
    this.imageId,
    this.imagePath,
    this.filename,
    required this.itemDescription,
    this.itemDescriptionKurdish,
    this.itemDescriptionArabic,
  });
  
  // Get localized item name based on language code
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return itemNameArabic?.isNotEmpty == true ? itemNameArabic! : itemName;
      case 'fa': // Kurdish
        return itemNameKurdish?.isNotEmpty == true ? itemNameKurdish! : itemName;
      default:
        return itemName;
    }
  }
  
  // Get localized category based on language code
  String getLocalizedCategory(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return itemCategoryArabic?.isNotEmpty == true ? itemCategoryArabic! : itemCategory;
      case 'fa': // Kurdish
        return itemCategoryKurdish?.isNotEmpty == true ? itemCategoryKurdish! : itemCategory;
      default:
        return itemCategory;
    }
  }
  
  // Get localized description based on language code
  String getLocalizedDescription(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return itemDescriptionArabic?.isNotEmpty == true ? itemDescriptionArabic! : itemDescription;
      case 'fa': // Kurdish
        return itemDescriptionKurdish?.isNotEmpty == true ? itemDescriptionKurdish! : itemDescription;
      default:
        return itemDescription;
    }
  }
  
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemId: json['item_id']?.toString() ?? '',
      itemName: json['item_name'] ?? '',
      itemNameKurdish: json['item_name_kurdish'],
      itemNameArabic: json['item_name_arabic'],
      itemType: json['item_type'] ?? '',
      itemCategory: json['item_category'] ?? '',
      itemCategoryKurdish: json['item_category_kurdish'],
      itemCategoryArabic: json['item_category_arabic'],
      price: json['price']?.toString() ?? '0',
      imageId: json['imageid']?.toString(),
      imagePath: json['image_path'],
      filename: json['filename'],
      itemDescription: json['item_description'] ?? '',
      itemDescriptionKurdish: json['item_description_kurdish'],
      itemDescriptionArabic: json['item_description_arabic'],
    );
  }
}

/// User Day Exercise model - represents exercises assigned to a user for a specific day
class UserDayExercise {
  final int userExerciseId; // userexercise_id from API
  final int exerciseId; // exercise_id from API
  final String name; // English name
  final String aname; // Arabic name
  final String kname; // Kurdish name
  final int sets; // sett from API (number of sets)
  final int reps; // tkrar from API (number of reps)
  final String customSet; // customset from API (like "15 12 12 10")
  final int day;
  final int sequence;
  final int? completionId; // completion_id from API
  final String? completionDate; // completion_date from API
  final String? image;
  final bool completed; // completed from API
  
  UserDayExercise({
    required this.userExerciseId,
    required this.exerciseId,
    required this.name,
    required this.aname,
    required this.kname,
    required this.sets,
    required this.reps,
    required this.customSet,
    required this.day,
    required this.sequence,
    this.completionId,
    this.completionDate,
    this.image,
    required this.completed,
  });
  
  // Computed property for display name (can switch based on language preference)
  String get displayName => name;
  
  // Computed property to get individual set reps from customSet
  List<int> get setReps {
    if (customSet.isEmpty) return [];
    return customSet
        .split(RegExp(r'\s+')) // Split by any whitespace
        .map((s) => int.tryParse(s.trim()) ?? 0)
        .where((rep) => rep > 0) // Filter out zero and negative values
        .toList();
  }
  
  // Computed property for completion status
  bool get isCompleted => completed;
  
  // Compatibility properties for existing UI code
  int get id => userExerciseId;
  String get exerciseName => displayName;
  
  factory UserDayExercise.fromJson(Map<String, dynamic> json) {
    return UserDayExercise(
      userExerciseId: User._parseInt(json['userexercise_id']),
      exerciseId: User._parseInt(json['exercise_id']),
      name: json['name'] ?? '',
      aname: json['aname'] ?? '',
      kname: json['kname'] ?? '',
      sets: User._parseInt(json['sett']),
      reps: User._parseInt(json['tkrar']),
      customSet: json['customset'] ?? '',
      day: User._parseInt(json['day']),
      sequence: User._parseInt(json['sequence']),
      completionId: User._parseIntNullable(json['completion_id']),
      completionDate: json['completion_date'],
      image: json['image'],
      completed: json['completed'] == true || json['completed'] == 1 || json['completed'] == '1',
    );
  }
}

/// Suggestion model - represents feedback/suggestions from users
class Suggestion {
  final String id;
  final String username;
  final String note;
  final String userId;
  final String date;
  
  Suggestion({
    required this.id,
    required this.username,
    required this.note,
    required this.userId,
    required this.date,
  });
  
  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      note: json['note'] ?? '',
      userId: json['userid']?.toString() ?? '',
      date: json['date'] ?? '',
    );
  }
}

/// Suggestion Submit Response model - response when submitting feedback
class SuggestionSubmitResponse {
  final bool success;
  final String message;
  final String? id;
  
  SuggestionSubmitResponse({
    required this.success,
    required this.message,
    this.id,
  });
  
  factory SuggestionSubmitResponse.fromJson(Map<String, dynamic> json) {
    return SuggestionSubmitResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      id: json['id']?.toString(),
    );
  }
}

/// GameItem model - represents game items from the game API
class GameItem {
  final String id;
  final String itemName;
  final String? itemNameKurdish;
  final String? itemNameArabic;
  final String itemType;
  final String itemCategory;
  final String? itemCategoryKurdish;
  final String? itemCategoryArabic;
  final String price;
  final String imageId;
  final String imageId2;
  final String imageId3;
  final String imageId4;
  final String createdAt;
  final String updatedAt;
  final String itemDescription;
  final String? itemDescriptionKurdish;
  final String? itemDescriptionArabic;
  final String longDescription;
  final String? longDescriptionKurdish;
  final String? longDescriptionArabic;
  
  GameItem({
    required this.id,
    required this.itemName,
    this.itemNameKurdish,
    this.itemNameArabic,
    required this.itemType,
    required this.itemCategory,
    this.itemCategoryKurdish,
    this.itemCategoryArabic,
    required this.price,
    required this.imageId,
    required this.imageId2,
    required this.imageId3,
    required this.imageId4,
    required this.createdAt,
    required this.updatedAt,
    required this.itemDescription,
    this.itemDescriptionKurdish,
    this.itemDescriptionArabic,
    required this.longDescription,
    this.longDescriptionKurdish,
    this.longDescriptionArabic,
  });
  
  // Get all image URLs based on the image IDs
  List<String> get allImageUrls {
    List<String> urls = [];
    final imageIds = [imageId, imageId2, imageId3, imageId4];
    
    for (String imageIdValue in imageIds) {
      if (imageIdValue.isNotEmpty && imageIdValue != '0') {
        urls.add('https://therocfit.com/uploads/$imageIdValue.png');
      }
    }
    
    return urls;
  }
  
  // Get the primary image URL
  String? get primaryImageUrl {
    if (imageId.isNotEmpty && imageId != '0') {
      return 'https://therocfit.com/uploads/$imageId.png';
    }
    return null;
  }
  
  // Get localized item name based on language code
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return itemNameArabic?.isNotEmpty == true ? itemNameArabic! : itemName;
      case 'fa': // Kurdish
        return itemNameKurdish?.isNotEmpty == true ? itemNameKurdish! : itemName;
      default:
        return itemName;
    }
  }
  
  // Get localized category based on language code
  String getLocalizedCategory(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return itemCategoryArabic?.isNotEmpty == true ? itemCategoryArabic! : itemCategory;
      case 'fa': // Kurdish
        return itemCategoryKurdish?.isNotEmpty == true ? itemCategoryKurdish! : itemCategory;
      default:
        return itemCategory;
    }
  }
  
  // Get localized description based on language code
  String getLocalizedDescription(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return itemDescriptionArabic?.isNotEmpty == true ? itemDescriptionArabic! : itemDescription;
      case 'fa': // Kurdish
        return itemDescriptionKurdish?.isNotEmpty == true ? itemDescriptionKurdish! : itemDescription;
      default:
        return itemDescription;
    }
  }
  
  // Get localized long description based on language code
  String getLocalizedLongDescription(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return longDescriptionArabic?.isNotEmpty == true ? longDescriptionArabic! : longDescription;
      case 'fa': // Kurdish
        return longDescriptionKurdish?.isNotEmpty == true ? longDescriptionKurdish! : longDescription;
      default:
        return longDescription;
    }
  }
  
  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      id: json['id']?.toString() ?? '',
      itemName: json['item_name'] ?? '',
      itemNameKurdish: json['item_name_kurdish'],
      itemNameArabic: json['item_name_arabic'],
      itemType: json['item_type'] ?? '',
      itemCategory: json['item_category'] ?? '',
      itemCategoryKurdish: json['item_category_kurdish'],
      itemCategoryArabic: json['item_category_arabic'],
      price: json['price']?.toString() ?? '0',
      imageId: json['imageid']?.toString() ?? '',
      imageId2: json['imageid2']?.toString() ?? '',
      imageId3: json['imageid3']?.toString() ?? '',
      imageId4: json['imageid4']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      itemDescription: json['item_description'] ?? '',
      itemDescriptionKurdish: json['item_description_kurdish'],
      itemDescriptionArabic: json['item_description_arabic'],
      longDescription: json['longdiscription'] ?? '', // Note: API uses 'longdiscription'
      longDescriptionKurdish: json['longdiscription_kurdish'],
      longDescriptionArabic: json['longdiscription_arabic'],
    );
  }
}

/// NotificationItem model - represents individual notification from the API
class NotificationItem {
  final String id;
  final String title;
  final String atitle; // Arabic title
  final String ktitle; // Kurdish title  
  final String notitype;
  final String playerId;
  final String date;
  final String open; // "1" or "2" indicating read status
  
  NotificationItem({
    required this.id,
    required this.title,
    required this.atitle,
    required this.ktitle,
    required this.notitype,
    required this.playerId,
    required this.date,
    required this.open,
  });
  
  // Computed properties
  bool get isRead => open == "2";
  bool get isUnread => open == "1";
  
  // Get display title based on language preference (defaulting to English)
  String get displayTitle => title;
  
  // Get notification type description
  String get notificationTypeDescription {
    switch (notitype) {
      case "1":
        return "Subscription Alert";
      case "2":
        return "Participation";
      case "3":
        return "Balance Update";
      default:
        return "General";
    }
  }
  
  // Get notification icon based on type
  String get iconType {
    switch (notitype) {
      case "1":
        return "subscription";
      case "2":
        return "participation";
      case "3":
        return "balance";
      default:
        return "general";
    }
  }
  
  // Parse date to DateTime
  DateTime? get parsedDate {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
  
  // Get formatted date string
  String get formattedDate {
    final parsed = parsedDate;
    if (parsed == null) return date;
    
    final now = DateTime.now();
    final difference = now.difference(parsed);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
  
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      atitle: json['atitle'] ?? '',
      ktitle: json['ktitle'] ?? '',
      notitype: json['notitype']?.toString() ?? '',
      playerId: json['playerid']?.toString() ?? '',
      date: json['date'] ?? '',
      open: json['open']?.toString() ?? '1',
    );
  }
}

/// NotificationPagination model - represents pagination info for notifications
class NotificationPagination {
  final int page;
  final int limit;
  final String total;
  final int totalPages;
  
  NotificationPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
  
  // Get total as integer
  int get totalInt => int.tryParse(total) ?? 0;
  
  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      page: User._parseInt(json['page']),
      limit: User._parseInt(json['limit']),
      total: json['total']?.toString() ?? '0',
      totalPages: User._parseInt(json['total_pages']),
    );
  }
}

/// NotificationResponse model - represents the complete notification API response
class NotificationResponse {
  final List<NotificationItem> notifications;
  final NotificationPagination pagination;
  
  NotificationResponse({
    required this.notifications,
    required this.pagination,
  });
  
  // Get unread notifications count
  int get unreadCount => notifications.where((n) => n.isUnread).length;
  
  // Get read notifications count
  int get readCount => notifications.where((n) => n.isRead).length;
  
  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      notifications: (json['notifications'] as List? ?? [])
          .map((item) => NotificationItem.fromJson(item))
          .toList(),
      pagination: NotificationPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

/// ProfileData model - represents user profile data from get_profile.php
class ProfileData {
  final String name;
  final String email;
  final int totalWorkouts;
  final int daysTrained;
  final int totalPoints;
  final String? startDate;
  final String? endDate;

  ProfileData({
    required this.name,
    required this.email,
    required this.totalWorkouts,
    required this.daysTrained,
    required this.totalPoints,
    this.startDate,
    this.endDate,
  });

  // Calculate membership duration in days if dates are available
  int? get membershipDays {
    if (startDate == null || endDate == null) return null;
    try {
      final start = DateTime.parse(startDate!);
      final end = DateTime.parse(endDate!);
      return end.difference(start).inDays;
    } catch (e) {
      return null;
    }
  }

  // Calculate days remaining if end date is available
  int? get daysRemaining {
    if (endDate == null) return null;
    try {
      final end = DateTime.parse(endDate!);
      final now = DateTime.now();
      final remaining = end.difference(now).inDays;
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      return null;
    }
  }

  // Check if membership is active
  bool get isActive {
    if (endDate == null) return true; // If no end date, assume active
    try {
      final end = DateTime.parse(endDate!);
      final now = DateTime.now();
      return now.isBefore(end);
    } catch (e) {
      return true; // If we can't parse, assume active
    }
  }

  // Get formatted start date
  String? get formattedStartDate {
    if (startDate == null) return null;
    try {
      final date = DateTime.parse(startDate!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return startDate;
    }
  }

  // Get formatted end date
  String? get formattedEndDate {
    if (endDate == null) return null;
    try {
      final date = DateTime.parse(endDate!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return endDate;
    }
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      totalWorkouts: User._parseInt(json['total_workouts']),
      daysTrained: User._parseInt(json['days_trained']),
      totalPoints: User._parseInt(json['total_points']),
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}

/// Exercise Set Response model - response when recording an exercise set
class ExerciseSetResponse {
  final String status;
  final String message;
  final int? id;
  final bool success;
  
  ExerciseSetResponse({
    required this.status,
    required this.message,
    this.id,
    required this.success,
  });
  
  bool get isSuccess => status == 'success' || success == true;
  
  factory ExerciseSetResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseSetResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      id: User._parseIntNullable(json['id']),
      success: json['success'] == true || json['status'] == 'success',
    );
  }
}

/// Exercise Set Record model - represents a previously recorded set
class ExerciseSetRecord {
  final int id;
  final int userExerciseId;
  final int userId;
  final int setNumber;
  final double weightKg;
  final int repetitions;
  final String completedAt;
  final String? notes;
  
  ExerciseSetRecord({
    required this.id,
    required this.userExerciseId,
    required this.userId,
    required this.setNumber,
    required this.weightKg,
    required this.repetitions,
    required this.completedAt,
    this.notes,
  });
  
  // Get formatted date
  String get formattedDate {
    try {
      final date = DateTime.parse(completedAt);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return completedAt;
    }
  }
  
  // Get formatted weight display
  String get formattedWeight => '${weightKg.toStringAsFixed(1)}kg';
  
  // Get formatted repetitions display  
  String get formattedReps => '${repetitions} reps';
  
  factory ExerciseSetRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseSetRecord(
      id: User._parseInt(json['id']),
      userExerciseId: User._parseInt(json['userexercise_id']),
      userId: User._parseInt(json['user_id']),
      setNumber: User._parseInt(json['set_number']),
      weightKg: User._parseDouble(json['weight_kg']),
      repetitions: User._parseInt(json['repetitions']),
      completedAt: json['completed_at'] ?? '',
      notes: json['notes'],
    );
  }
}

/// Exercise Set History Record model
class ExerciseSetHistoryRecord {
  final double weightKg;
  final String date;
  
  ExerciseSetHistoryRecord({
    required this.weightKg,
    required this.date,
  });
  
  factory ExerciseSetHistoryRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseSetHistoryRecord(
      weightKg: User._parseDouble(json['weight_kg']),
      date: json['date'] ?? '',
    );
  }
  
  String get formattedWeight => '${weightKg.toStringAsFixed(1)}kg';
  
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(date);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return date;
    }
  }
}

/// Exercise Set Info model - represents set information for recording
class ExerciseSetInfo {
  final int setNumber;
  final int targetRepetitions;
  final bool completed;
  final double? weightKg;
  final int? actualRepetitions;
  final String? completedAt;
  final ExerciseSetHistoryRecord? latestRecord;
  final ExerciseSetHistoryRecord? highestRecord;
  
  ExerciseSetInfo({
    required this.setNumber,
    required this.targetRepetitions,
    required this.completed,
    this.weightKg,
    this.actualRepetitions,
    this.completedAt,
    this.latestRecord,
    this.highestRecord,
  });
  
  factory ExerciseSetInfo.fromJson(Map<String, dynamic> json) {
    ExerciseSetHistoryRecord? latestRecord;
    ExerciseSetHistoryRecord? highestRecord;
    
    if (json['latest_record'] != null) {
      latestRecord = ExerciseSetHistoryRecord.fromJson(json['latest_record']);
    }
    
    if (json['highest_record'] != null) {
      highestRecord = ExerciseSetHistoryRecord.fromJson(json['highest_record']);
    }
    
    return ExerciseSetInfo(
      setNumber: User._parseInt(json['set_number']),
      targetRepetitions: User._parseInt(json['target_repetitions']),
      completed: json['completed'] == true || json['completed'] == 1,
      weightKg: json['weight_kg'] != null ? User._parseDouble(json['weight_kg']) : null,
      actualRepetitions: json['actual_repetitions'] != null ? User._parseInt(json['actual_repetitions']) : null,
      completedAt: json['completed_at'],
      latestRecord: latestRecord,
      highestRecord: highestRecord,
    );
  }
  
  String get formattedWeight => weightKg != null ? '${weightKg!.toStringAsFixed(1)}kg' : '-';
  String get formattedReps => actualRepetitions != null ? '${actualRepetitions} reps' : '-';
}

/// Exercise Set Response model - response when getting exercise set info
class ExerciseSetInfoResponse {
  final String status;
  final int totalSets;
  final int completedSets;
  final int remainingSets;
  final bool exerciseCompleted;
  final bool usingCustomSets;
  final List<ExerciseSetInfo> sets;
  final double? lastTimeWeight;
  final double? highestWeight;
  
  ExerciseSetInfoResponse({
    required this.status,
    required this.totalSets,
    required this.completedSets,
    required this.remainingSets,
    required this.exerciseCompleted,
    required this.usingCustomSets,
    required this.sets,
    this.lastTimeWeight,
    this.highestWeight,
  });
  
  factory ExerciseSetInfoResponse.fromJson(Map<String, dynamic> json) {
    List<ExerciseSetInfo> sets = [];
    if (json['sets'] != null && json['sets'] is List) {
      sets = (json['sets'] as List)
          .map((setJson) => ExerciseSetInfo.fromJson(setJson))
          .where((setInfo) => setInfo.targetRepetitions > 0) // Filter out 0-rep sets
          .toList();
    }
    
    // Recalculate totals based on filtered sets
    int actualTotalSets = sets.length;
    int actualCompletedSets = sets.where((set) => set.completed).length;
    int actualRemainingSets = actualTotalSets - actualCompletedSets;
    
    return ExerciseSetInfoResponse(
      status: json['status'] ?? '',
      totalSets: actualTotalSets, // Use filtered count
      completedSets: actualCompletedSets,
      remainingSets: actualRemainingSets,
      exerciseCompleted: actualRemainingSets == 0 && actualTotalSets > 0,
      usingCustomSets: json['using_custom_sets'] == true || json['using_custom_sets'] == 1,
      sets: sets,
      lastTimeWeight: json['last_time_weight'] != null ? User._parseDouble(json['last_time_weight']) : null,
      highestWeight: json['highest_weight'] != null ? User._parseDouble(json['highest_weight']) : null,
    );
  }
  
  bool get isSuccess => status == 'success';
}

/// User Exercise Statistics model - overall statistics for a user
class UserExerciseStats {
  final int totalWorkoutDays;
  final int currentStreak;
  final int longestStreak;
  final int totalExercisesCompleted;
  final double totalWeightLifted;
  final double monthlyWeightLifted;
  final int activeDaysThisMonth;
  final String? lastWorkoutDate;
  
  UserExerciseStats({
    required this.totalWorkoutDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalExercisesCompleted,
    required this.totalWeightLifted,
    required this.monthlyWeightLifted,
    required this.activeDaysThisMonth,
    this.lastWorkoutDate,
  });
  
  factory UserExerciseStats.fromJson(Map<String, dynamic> json) {
    return UserExerciseStats(
      totalWorkoutDays: User._parseInt(json['total_workout_days']),
      currentStreak: User._parseInt(json['current_streak']),
      longestStreak: User._parseInt(json['longest_streak']),
      totalExercisesCompleted: User._parseInt(json['total_exercises_completed']),
      totalWeightLifted: User._parseDouble(json['total_weight_lifted']),
      monthlyWeightLifted: User._parseDouble(json['monthly_weight_lifted']),
      activeDaysThisMonth: User._parseInt(json['active_days_this_month']),
      lastWorkoutDate: json['last_workout_date'],
    );
  }
}

/// Exercise Personal Best model - represents the best performance for an exercise
class ExercisePersonalBest {
  final int exerciseId;
  final String exerciseName;
  final String exerciseNameAr;
  final String exerciseNameKu;
  final double bestWeight;
  final int bestReps;
  final double? bestVolume; // weight * reps
  final String achievedDate;
  final String? image;
  final String? category;
  
  ExercisePersonalBest({
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseNameAr,
    required this.exerciseNameKu,
    required this.bestWeight,
    required this.bestReps,
    this.bestVolume,
    required this.achievedDate,
    this.image,
    this.category,
  });
  
  factory ExercisePersonalBest.fromJson(Map<String, dynamic> json) {
    return ExercisePersonalBest(
      exerciseId: User._parseInt(json['exercise_id']),
      exerciseName: json['exercise_name'] ?? '',
      exerciseNameAr: json['exercise_name_ar'] ?? '',
      exerciseNameKu: json['exercise_name_ku'] ?? '',
      bestWeight: User._parseDouble(json['best_weight']),
      bestReps: User._parseInt(json['best_reps']),
      bestVolume: User._parseDoubleNullable(json['best_volume']),
      achievedDate: json['achieved_date'] ?? '',
      image: json['image'],
      category: json['category'],
    );
  }
  
  String get formattedWeight => bestWeight > 0 ? '${bestWeight.toStringAsFixed(1)}kg' : 'Bodyweight';
  String get formattedReps => '$bestReps reps';
}

/// Monthly Weight Progress model - represents weight progress for a specific month
class MonthlyWeightProgress {
  final String monthYear; // e.g., "2024-01"
  final String monthName; // e.g., "January"
  final double totalWeightLifted;
  final int workoutDays;
  final double averageWeightPerDay;
  final int totalSets;
  final int totalReps;
  
  MonthlyWeightProgress({
    required this.monthYear,
    required this.monthName,
    required this.totalWeightLifted,
    required this.workoutDays,
    required this.averageWeightPerDay,
    required this.totalSets,
    required this.totalReps,
  });
  
  factory MonthlyWeightProgress.fromJson(Map<String, dynamic> json) {
    return MonthlyWeightProgress(
      monthYear: json['month_year'] ?? '',
      monthName: json['month_name'] ?? '',
      totalWeightLifted: User._parseDouble(json['total_weight_lifted']),
      workoutDays: User._parseInt(json['workout_days']),
      averageWeightPerDay: User._parseDouble(json['average_weight_per_day']),
      totalSets: User._parseInt(json['total_sets']),
      totalReps: User._parseInt(json['total_reps']),
    );
  }
  
  String get formattedTotalWeight => '${totalWeightLifted.toStringAsFixed(0)}kg';
}

/// Real User Statistics - matches the actual API response structure
class RealUserStats {
  final StatsPeriod period;
  final WorkoutStatistics workoutStatistics;
  final PersonalRecords personalRecords;
  final RealFoodStatistics foodStatistics;
  final List<WeeklyBreakdown> weeklyBreakdown;
  
  RealUserStats({
    required this.period,
    required this.workoutStatistics,
    required this.personalRecords,
    required this.foodStatistics,
    required this.weeklyBreakdown,
  });
  
  factory RealUserStats.fromJson(Map<String, dynamic> json) {
    return RealUserStats(
      period: StatsPeriod.fromJson(json['period']),
      workoutStatistics: WorkoutStatistics.fromJson(json['workout_statistics']),
      personalRecords: PersonalRecords.fromJson(json['personal_records']),
      foodStatistics: RealFoodStatistics.fromJson(json['food_statistics']),
      weeklyBreakdown: (json['weekly_breakdown'] as List)
          .map((w) => WeeklyBreakdown.fromJson(w))
          .toList(),
    );
  }
}



/// Workout Statistics model
class WorkoutStatistics {
  final int activeDays;
  final int totalSets;
  final int exercisesPerformed;
  final double averageWeight;
  final double totalVolume;
  final int currentStreak;
  final int workoutFrequency;
  
  WorkoutStatistics({
    required this.activeDays,
    required this.totalSets,
    required this.exercisesPerformed,
    required this.averageWeight,
    required this.totalVolume,
    required this.currentStreak,
    required this.workoutFrequency,
  });
  
  factory WorkoutStatistics.fromJson(Map<String, dynamic> json) {
    return WorkoutStatistics(
      activeDays: User._parseInt(json['active_days']),
      totalSets: User._parseInt(json['total_sets']),
      exercisesPerformed: User._parseInt(json['exercises_performed']),
      averageWeight: User._parseDouble(json['average_weight']),
      totalVolume: User._parseDouble(json['total_volume']),
      currentStreak: User._parseInt(json['current_streak']),
      workoutFrequency: User._parseInt(json['workout_frequency']),
    );
  }
  
  String get formattedTotalVolume => '${totalVolume.toStringAsFixed(0)}kg';
  String get formattedAverageWeight => '${averageWeight.toStringAsFixed(1)}kg';
}

/// Personal Records model
class PersonalRecords {
  final double maxWeightEver;
  final String prExerciseId;
  final int prReps;
  final String prDate;
  final String exerciseName;
  final String exerciseNameArabic;
  final String exerciseNameKurdish;
  
  PersonalRecords({
    required this.maxWeightEver,
    required this.prExerciseId,
    required this.prReps,
    required this.prDate,
    required this.exerciseName,
    required this.exerciseNameArabic,
    required this.exerciseNameKurdish,
  });
  
  factory PersonalRecords.fromJson(Map<String, dynamic> json) {
    return PersonalRecords(
      maxWeightEver: User._parseDouble(json['max_weight_ever']),
      prExerciseId: json['pr_exercise_id'] ?? '',
      prReps: User._parseInt(json['pr_reps']),
      prDate: json['pr_date'] ?? '',
      exerciseName: json['exercise_name'] ?? '',
      exerciseNameArabic: json['exercise_name_arabic'] ?? '',
      exerciseNameKurdish: json['exercise_name_kurdish'] ?? '',
    );
  }
  
  String get formattedWeight => '${maxWeightEver.toStringAsFixed(1)}kg';
  String get formattedReps => '$prReps reps';
}

/// Food Statistics model (updated)
class RealFoodStatistics {
  final int totalFoodsLogged;
  final int foodLoggingDays;
  final int mealTypesUsed;
  final double avgFoodsPerDay;
  
  RealFoodStatistics({
    required this.totalFoodsLogged,
    required this.foodLoggingDays,
    required this.mealTypesUsed,
    required this.avgFoodsPerDay,
  });
  
  factory RealFoodStatistics.fromJson(Map<String, dynamic> json) {
    return RealFoodStatistics(
      totalFoodsLogged: User._parseInt(json['total_foods_logged']),
      foodLoggingDays: User._parseInt(json['food_logging_days']),
      mealTypesUsed: User._parseInt(json['meal_types_used']),
      avgFoodsPerDay: User._parseDouble(json['avg_foods_per_day']),
    );
  }
}

/// Weekly Breakdown model
class WeeklyBreakdown {
  final String weekNum;
  final String yearNum;
  final int workoutDays;
  final int totalSets;
  final double weeklyVolume;
  
  WeeklyBreakdown({
    required this.weekNum,
    required this.yearNum,
    required this.workoutDays,
    required this.totalSets,
    required this.weeklyVolume,
  });
  
  factory WeeklyBreakdown.fromJson(Map<String, dynamic> json) {
    return WeeklyBreakdown(
      weekNum: json['week_num'] ?? '',
      yearNum: json['year_num'] ?? '',
      workoutDays: User._parseInt(json['workout_days']),
      totalSets: User._parseInt(json['total_sets']),
      weeklyVolume: User._parseDouble(json['weekly_volume']),
    );
  }
  
  String get formattedVolume => '${weeklyVolume.toStringAsFixed(0)}kg';
  String get weekLabel => 'Week $weekNum';
}
