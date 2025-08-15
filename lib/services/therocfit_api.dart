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
  static const String baseUrl = 'https://therocfit.com/new/api';
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
      
      // Extract cookies from response
      if (response.headers['set-cookie'] != null) {
        await _saveSession(response.headers['set-cookie']!);
      }
      
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
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
        throw ApiException(
          jsonResponse['message'] ?? 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Network error occurred');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }
  
  // ==================== AUTHENTICATION APIs ====================
  
  /// Login user
  Future<ApiResponse<User>> login(String username, String password) async {
    return await _request<User>(
      method: 'POST',
      endpoint: '/auth/login',
      body: {
        'username': username,
        'password': password,
      },
      fromJson: (json) => User.fromJson(json),
    );
  }
  
  /// Logout user
  Future<ApiResponse<void>> logout() async {
    final response = await _request<void>(
      method: 'POST',
      endpoint: '/auth/logout',
    );
    await _clearSession();
    return response;
  }
  
  /// Get current user info
  Future<ApiResponse<User>> getCurrentUser() async {
    return await _request<User>(
      method: 'GET',
      endpoint: '/auth/me',
      fromJson: (json) => User.fromJson(json),
    );
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
  
  /// Get user exercises for specific day
  Future<ApiResponse<UserDayExercises>> getUserDayExercises(int userId, int day) async {
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
  
  /// Mark exercise as completed
  Future<ApiResponse<CompletedExercise>> completeExercise({
    required int exerciseId,
    required int day,
    int? userId,
  }) async {
    return await _request<CompletedExercise>(
      method: 'POST',
      endpoint: '/daily-exercises/complete',
      body: {
        'exercise_id': exerciseId,
        'day': day,
        if (userId != null) 'userid': userId,
      },
      fromJson: (json) => CompletedExercise.fromJson(json),
    );
  }
  
  /// Get exercises for specific day
  Future<ApiResponse<DayExercises>> getDayExercises(int userId, int day) async {
    return await _request<DayExercises>(
      method: 'GET',
      endpoint: '/daily-exercises/day',
      queryParams: {
        'userid': userId.toString(),
        'day': day.toString(),
      },
      fromJson: (json) => DayExercises.fromJson(json),
    );
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
      id: json['id'],
      name: json['name'],
      type: json['type'],
      exercises: (json['exercises'] as List)
          .map((e) => UserExercise.fromJson(e))
          .toList(),
      totalExercises: json['total_exercises'] ?? 0,
      completedExercises: json['completed_exercises'] ?? 0,
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
      userId: json['user_id'],
      day: json['day'],
      regularExercises: (json['regular_exercises'] as List)
          .map((e) => UserExercise.fromJson(e))
          .toList(),
      supersets: (json['supersets'] as List)
          .map((s) => Superset.fromJson(s))
          .toList(),
      statistics: ExerciseStatistics.fromJson(json['statistics']),
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
