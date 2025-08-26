import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/therocfit_api.dart';
import '../l10n/app_localizations.dart';
import 'exercise_set_form_dialog.dart';
import 'exercise_set_recording_screen.dart';
import 'notifications_screen.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _selectedDay = 0; // Start with day 0
  List<WorkoutDay> _workoutDays = [];
  WorkoutData? _workoutData;
  List<UserDayExercise> _exercises = [];
  bool _isLoading = false;
  bool _isLoadingDays = false;
  bool _isLoadingExercises = false;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _loadWorkoutDays();
  }

  // Helper method to get localized day name from API data
  String _getLocalizedDayName(WorkoutDay workoutDay, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    switch (languageProvider.locale.languageCode) {
      case 'ar':
        return workoutDay.dayNameAr;
      case 'fa': // Kurdish using fa locale
        return workoutDay.dayNameKu;
      case 'en':
      default:
        return workoutDay.dayNameEn;
    }
  }

  // Helper method to get localized exercise name from API data
  String _getLocalizedExerciseName(UserDayExercise exercise, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    switch (languageProvider.locale.languageCode) {
      case 'ar':
        return exercise.aname;
      case 'fa': // Kurdish using fa locale
        return exercise.kname;
      case 'en':
      default:
        return exercise.name;
    }
  }

  Future<void> _loadWorkoutDays() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Always use mock data for guest users or when user is null
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      _loadMockData();
      return;
    }

    setState(() {
      _isLoadingDays = true;
      _errorMessage = null;
    });

    try {
      print('Loading workout days for user ${authProvider.currentUser!.id}');
      
      final response = await authProvider.apiClient.getWorkoutDays(
        authProvider.currentUser!.id,
      );
      
      if (response.success && response.data != null) {
        setState(() {
          _workoutDays = response.data!;
          _isLoadingDays = false;
          if (_workoutDays.isNotEmpty) {
            _selectedDay = _workoutDays.first.day;
            _loadUserExercises();
          }
        });
      } else {
        print('Failed to load workout days: ${response.message}');
        setState(() {
          _errorMessage = 'Failed to load workout days: ${response.message}';
          _isLoadingDays = false;
        });
      }
    } catch (e) {
      print('Exception loading workout days: $e');
      setState(() {
        _errorMessage = 'Failed to load workout days. Please try guest mode.';
        _isLoadingDays = false;
      });
    }
  }

  Future<void> _loadExercises([bool isRetry = false]) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Always use mock data for guest users or when user is null
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      _loadMockData();
      return;
    }

    if (!isRetry) {
      _retryCount = 0;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _loadExercisesWithRetry(authProvider);
  }

  Future<void> _loadUserExercises() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      _loadMockExercises();
      return;
    }

    setState(() {
      _isLoadingExercises = true;
      _errorMessage = null;
    });

        try {
      print('Loading exercises for user ${authProvider.currentUser!.id}, day $_selectedDay');

      final response = await authProvider.apiClient.getWorkoutExercises(
        authProvider.currentUser!.id,
        _selectedDay,
      );
      
      if (response.success && response.data != null) {
        // Check the type of response data
        if (response.data is WorkoutData) {
          // This is a participation status response
          final workoutData = response.data as WorkoutData;
        setState(() {
            _workoutData = workoutData;
            _exercises = []; // No exercises when participation ended
            _isLoadingExercises = false;
          });
        } else if (response.data is List<UserDayExercise>) {
          // This is an active exercise list
          final exercises = response.data as List<UserDayExercise>;
          setState(() {
            _exercises = exercises;
            _workoutData = null; // Clear any previous workout data
            _isLoadingExercises = false;
          });
          print('Loaded ${exercises.length} exercises for day $_selectedDay');
      } else {
        setState(() {
            _errorMessage = 'Unexpected response format from server';
            _isLoadingExercises = false;
          });
        }
      } else {
        print('Failed to load exercises: ${response.message}');
        setState(() {
          _errorMessage = 'Failed to load exercises: ${response.message}';
          _isLoadingExercises = false;
        });
      }
    } catch (e) {
      print('Exception loading exercises: $e');
      setState(() {
        _errorMessage = 'Failed to load exercises. Please try again.';
        _isLoadingExercises = false;
      });
    }
  }

  void _loadMockExercises() {
    setState(() {
      _exercises = [
        UserDayExercise(
          userExerciseId: 1,
            exerciseId: 1,
          name: 'Push-ups',
          aname: 'تمرين الضغط',
          kname: 'پاش ئەپ',
          sets: 3,
            reps: 12,
          customSet: '12 10 8',
          day: _selectedDay,
          sequence: 0,
          image: null,
          completed: false,
        ),
        UserDayExercise(
          userExerciseId: 2,
            exerciseId: 2,
          name: 'Squats',
          aname: 'القرفصاء',
          kname: 'سکواتس',
          sets: 3,
          reps: 15,
          customSet: '15 12 10',
          day: _selectedDay,
          sequence: 1,
          image: null,
            completed: false,
          ),
        UserDayExercise(
          userExerciseId: 3,
            exerciseId: 3,
          name: 'Plank',
          aname: 'اللوح الخشبي',
          kname: 'پڵانك',
          sets: 3,
          reps: 1,
          customSet: '30sec 45sec 60sec',
          day: _selectedDay,
          sequence: 2,
          image: null,
          completed: true,
        ),
      ];
      _isLoadingExercises = false;
    });
  }

  Future<void> _loadExercisesWithRetry(AuthProvider authProvider) async {
    // Safety check - if we've exceeded max retries, stop
    if (_retryCount >= _maxRetries) {
      setState(() {
        _errorMessage = 'Server is currently unavailable. Please try guest mode.';
        _isLoading = false;
      });
      return;
    }
    
    try {
      // Safety check for user
      if (authProvider.currentUser == null) {
        print('User is null, switching to guest mode');
        _loadMockData();
        return;
      }
      
      print('Loading exercises for user ${authProvider.currentUser!.id}, day $_selectedDay (attempt ${_retryCount + 1}/$_maxRetries)');
      
      final response = await authProvider.apiClient.getWorkoutExercises(
        authProvider.currentUser!.id,
        _selectedDay,
      );
      
      if (response.success && response.data != null) {
        setState(() {
          _workoutData = response.data;
          _isLoading = false;
          _retryCount = 0; // Reset retry count on success
        });
      } else {
        print('API response failed: ${response.message}');
        await _handleApiError(response.message, authProvider);
      }
    } catch (e) {
      print('Exception loading exercises: $e');
      await _handleException(e, authProvider);
    }
  }

  Future<void> _handleApiError(String message, AuthProvider authProvider) async {
    // Don't retry database errors - they're server-side issues
    if (message.toLowerCase().contains('database query failed')) {
      setState(() {
        _errorMessage = 'Server is experiencing issues. Please try guest mode or check back later.';
        _isLoading = false;
      });
      return;
    }
    
    // Check if we should retry
    if (_retryCount < _maxRetries && _shouldRetry(message)) {
      _retryCount++;
      final delay = Duration(seconds: _retryCount * 2); // Exponential backoff
      print('Retrying in ${delay.inSeconds} seconds (attempt ${_retryCount + 1}/$_maxRetries)...');
      await Future.delayed(delay);
      
      // Important: Check again before retrying
      if (_retryCount <= _maxRetries) {
        await _loadExercisesWithRetry(authProvider);
      } else {
        setState(() {
          _errorMessage = 'Unable to connect to server. Please try guest mode.';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = message.isNotEmpty 
            ? 'Server error: $message' 
            : 'Failed to load exercises. Please try guest mode.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleException(dynamic e, AuthProvider authProvider) async {
    String errorMessage;
    bool shouldRetry = false;
    
    final errorStr = e.toString();
    
    if (errorStr.contains('No internet connection') || 
        errorStr.contains('SocketException')) {
      errorMessage = 'No internet connection. Please check your network.';
      shouldRetry = true;
    } else if (errorStr.contains('Database query failed')) {
      errorMessage = 'Server is experiencing database issues. Please try guest mode.';
      shouldRetry = false; // Don't retry database errors
    } else if (errorStr.contains('timeout') ||
               errorStr.contains('TimeoutException')) {
      errorMessage = 'Request timed out. Please check your connection.';
      shouldRetry = true;
    } else if (errorStr.contains('HTTP 5')) {
      errorMessage = 'Server error occurred. Please try guest mode.';
      shouldRetry = false; // Don't retry 500 errors
    } else if (errorStr.contains('Null check operator') || 
               errorStr.contains('type cast') ||
               errorStr.contains('Null')) {
      errorMessage = 'Data parsing error. Please try guest mode.';
      shouldRetry = false; // Don't retry parsing errors
    } else {
      errorMessage = 'An unexpected error occurred. Please try guest mode.';
      shouldRetry = false;
    }
    
    // Only retry network-related issues, not server or parsing errors
    if (_retryCount < _maxRetries && shouldRetry) {
      _retryCount++;
      final delay = Duration(seconds: _retryCount * 2);
      print('Retrying in ${delay.inSeconds} seconds (attempt ${_retryCount + 1}/$_maxRetries)...');
      await Future.delayed(delay);
      
      // Double-check before retrying
      if (_retryCount <= _maxRetries) {
        await _loadExercisesWithRetry(authProvider);
      } else {
        setState(() {
          _errorMessage = 'Unable to connect after multiple attempts. Please try guest mode.';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  bool _shouldRetry(String errorMessage) {
    // Don't retry authentication errors or permanent failures
    final lowerMessage = errorMessage.toLowerCase();
    return !lowerMessage.contains('unauthorized') &&
           !lowerMessage.contains('forbidden') &&
           !lowerMessage.contains('not found') &&
           // Don't keep retrying database errors after a few attempts
           !lowerMessage.contains('database query failed');
  }

  void _loadMockData() {
    // Mock data for guest users
    setState(() {
      _workoutDays = [
        WorkoutDay(
          day: 0,
          exerciseCount: 5,
          dayNameEn: 'Day 1',
          dayNameAr: 'اليوم الاول',
          dayNameKu: 'ڕۆژی 1',
          dayImage: 'Sat.svg',
        ),
        WorkoutDay(
          day: 1,
          exerciseCount: 4,
          dayNameEn: 'Day 2',
          dayNameAr: 'اليوم الثاني',
          dayNameKu: 'ڕۆژی 2',
          dayImage: 'Sun.svg',
        ),
        WorkoutDay(
          day: 2,
          exerciseCount: 6,
          dayNameEn: 'Day 3',
          dayNameAr: 'اليوم الثالث',
          dayNameKu: 'ڕۆژی 3',
          dayImage: 'Mon.svg',
        ),
      ];
      
      _workoutData = WorkoutData(
        status: 'active',
        message: 'Workout available',
        data: ParticipationData(
          id: 1,
          participationId: 1,
          startDate: '2024-01-01',
          endDate: '2024-12-31',
          month: 1,
          typeId: 1,
          playerType: 1,
          amount: 0,
          note: 'Guest workout',
          course: 0,
          realDate: '2024-01-01',
          todayDate: '2024-01-01',
          userId: 0,
          captnId: 0,
        ),
      );
      
      _isLoading = false;
      _isLoadingDays = false;
      _selectedDay = 0;
    });
  }

  Future<void> _startWorkout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn) {
      // For guest users, just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.pleaseLoginToStart ?? 'Please login to start workout')),
      );
      return;
    }

    if (_workoutData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.noWorkoutData ?? 'No workout data available')),
      );
      return;
    }

    // Show workout started dialog/bottom sheet
    _showWorkoutDialog();
  }

  void _showWorkoutDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppConstants.radiusLarge),
              topRight: Radius.circular(AppConstants.radiusLarge),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Consumer<LanguageProvider>(
                        builder: (context, languageProvider, child) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _workoutDays.isNotEmpty ? 
                                  _getLocalizedDayName(_workoutDays.firstWhere((d) => d.day == _selectedDay), context) :
                                  (AppLocalizations.of(context)?.workoutAvailable ?? 'Workout available'),
                              style: AppTextStyles.headline3.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              _workoutDays.isNotEmpty ? 
                                  '${_workoutDays.firstWhere((d) => d.day == _selectedDay).exerciseCount} ${AppLocalizations.of(context)?.exercises ?? 'exercises'}' : 
                                  (AppLocalizations.of(context)?.workoutAvailable ?? 'Workout available'),
                              style: AppTextStyles.bodyText2.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
              
              // Workout content
              Expanded(
                child: _buildWorkoutContent(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutContent() {
    if (_isLoadingExercises) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              AppLocalizations.of(context)?.loadingExercises ?? 'Loading exercises...',
            ),
          ],
        ),
      );
    }

    // Handle participation ended case
    if (_workoutData != null && _workoutData!.status == 'ended') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              AppLocalizations.of(context)?.participationEnded ?? 'Participation Period Ended',
              style: AppTextStyles.headline3.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              _workoutData!.message,
              style: AppTextStyles.bodyText1.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            if (_workoutData!.data != null) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)?.participationDetails ?? 'Participation Details',
                      style: AppTextStyles.headline4,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      '${AppLocalizations.of(context)?.period ?? 'Period'}: ${_workoutData!.data!.startDate} to ${_workoutData!.data!.endDate}',
                      style: AppTextStyles.bodyText2,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton(
              onPressed: _loadUserExercises,
              child: Text(AppLocalizations.of(context)?.checkAgain ?? 'Check Again'),
            ),
          ],
        ),
      );
    }

    if (_exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'No exercises for this day',
              style: AppTextStyles.headline3.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton(
              onPressed: _loadUserExercises,
              child: Text(AppLocalizations.of(context)?.refresh ?? 'Refresh'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Column(
        children: [
          // Exercise list
          Expanded(
            child: ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return _buildRealExerciseItem(exercise);
              },
            ),
          ),
          
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            margin: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(Icons.fitness_center, color: AppColors.primary),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress: ${_exercises.where((e) => e.isCompleted).length}/${_exercises.length} completed',
                        style: AppTextStyles.bodyText1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: _exercises.isEmpty ? 0.0 : _exercises.where((e) => e.isCompleted).length / _exercises.length,
                        backgroundColor: AppColors.grey.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildRealExerciseItem(UserDayExercise exercise) {
    return GestureDetector(
      onTap: exercise.isCompleted ? null : () => _openSetFormDialog(exercise),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: exercise.isCompleted ? AppColors.primary.withOpacity(0.1) : AppColors.greyLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: exercise.isCompleted ? AppColors.primary : AppColors.grey.withOpacity(0.2),
            width: exercise.isCompleted ? 2 : 1,
          ),
        ),
      child: Row(
        children: [
          // Exercise status indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: exercise.isCompleted ? AppColors.primary : AppColors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              exercise.isCompleted ? Icons.check : Icons.fitness_center,
              color: AppColors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: AppConstants.paddingMedium),

          // Exercise image (clickable)
          GestureDetector(
            onTap: () => _showFullScreenImage(exercise.image),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: exercise.image != null && exercise.image!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            exercise.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.fitness_center,
                                color: AppColors.grey,
                                size: 24,
                              );
                            },
                          ),
                          // Overlay to indicate it's tappable
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fullscreen,
                                color: AppColors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Icon(
                      Icons.fitness_center,
                      color: AppColors.grey,
                      size: 24,
                    ),
            ),
          ),

          const SizedBox(width: AppConstants.paddingMedium),

          // Exercise info
          Expanded(
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedExerciseName(exercise, context),
                    style: AppTextStyles.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      decoration: exercise.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                const SizedBox(height: 4),
                // Show custom sets if available, otherwise show sets x reps
                if (exercise.customSet.isNotEmpty) ...[
                  Text(
                    exercise.setReps.isNotEmpty 
                        ? 'Sets: ${exercise.setReps.join(' - ')} Reps'
                        : 'Custom: ${exercise.customSet}',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: AppColors.greyDark,
                    ),
                  ),
                ] else ...[
                  Text(
                    '${exercise.sets} sets × ${exercise.reps} reps',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: AppColors.greyDark,
                    ),
                  ),
                ],
                ],
              ),
            ),
          ),

          // Complete button or status
          if (!exercise.isCompleted) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Icon(
                Icons.check,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildExerciseItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Exercise number
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTextStyles.bodyText2.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppConstants.paddingMedium),
          
          // Exercise info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercise ${index + 1}',
                  style: AppTextStyles.bodyText1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3 sets × 12 reps',
                  style: AppTextStyles.bodyText2.copyWith(
                    color: AppColors.greyDark,
                  ),
                ),
              ],
            ),
          ),
          
          // Status indicator
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.grey, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSetFormDialog(UserDayExercise exercise) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.pleaseLoginToComplete ?? 'Please login to complete exercises')),
      );
      return;
    }

    // Navigate to the new exercise set recording screen
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ExerciseSetRecordingScreen(exercise: exercise),
      ),
    );

    // If the screen returned true (exercise was completed)
    if (result == true) {
      // Mark the exercise as completed and refresh the UI
      await _markExerciseCompleted(exercise);
    }
  }

  Future<void> _markExerciseCompleted(UserDayExercise exercise) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      return;
    }

    try {
      // Call the API to mark exercise complete
      final response = await authProvider.apiClient.markExerciseComplete(
        userId: authProvider.currentUser!.id,
        userExerciseId: exercise.userExerciseId,
      );

      if (response.success && response.data != null && response.data!.isSuccess) {
        // Update the exercise locally
        setState(() {
          final index = _exercises.indexWhere((e) => e.userExerciseId == exercise.userExerciseId);
          if (index != -1) {
            _exercises[index] = UserDayExercise(
              userExerciseId: exercise.userExerciseId,
              exerciseId: exercise.exerciseId,
              name: exercise.name,
              aname: exercise.aname,
              kname: exercise.kname,
              sets: exercise.sets,
              reps: exercise.reps,
              customSet: exercise.customSet,
              day: exercise.day,
              sequence: exercise.sequence,
              completionId: response.data!.id,
              completionDate: DateTime.now().toIso8601String(),
              image: exercise.image,
              completed: true,
            );
          }
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${(AppLocalizations.of(context)?.exerciseCompleted?.toString() ?? '{exercise} completed!').replaceFirst('{exercise}', _getLocalizedExerciseName(exercise, context))}'),
            backgroundColor: AppColors.primary,
          ),
        );
        
        // Check if all exercises are completed
        if (_exercises.every((e) => e.isCompleted)) {
          _showWorkoutCompletedDialog();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data?.message ?? 'Failed to complete exercise'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      print('Error completing exercise: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showFullScreenImage(String? imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background tap to close
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              
              // Image content
              Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent closing when tapping image
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? InteractiveViewer(
                              panEnabled: true,
                              boundaryMargin: const EdgeInsets.all(20),
                              minScale: 0.5,
                              maxScale: 3.0,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 200,
                                    height: 200,
                                    color: AppColors.greyLight,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 200,
                                    color: AppColors.greyLight,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 64,
                                          color: AppColors.grey,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Unable to load image',
                                          style: AppTextStyles.bodyText1.copyWith(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: AppColors.greyLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: AppColors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No image available',
                                    style: AppTextStyles.bodyText1.copyWith(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              
              // Close button
              Positioned(
                top: 60,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              
              // Instructions text
              Positioned(
                bottom: 100,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    imageUrl != null && imageUrl.isNotEmpty
                        ? 'Pinch to zoom • Tap outside to close'
                        : 'Tap outside to close',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyText2.copyWith(
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWorkoutCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              '🎉 Workout Completed!',
              style: AppTextStyles.headline3.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Congratulations! You completed all exercises for Day ${_selectedDay + 1}.',
              style: AppTextStyles.bodyText1.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Keep up the great work!',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Only close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeWorkout({required int index}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.pleaseLoginToComplete ?? 'Please login to complete exercises')),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      // Call the API to mark exercise complete
      final response = await authProvider.apiClient.markExerciseComplete(
        userId: authProvider.currentUser!.id,
        userExerciseId: index, // Mock userexercise_id for demonstration
      );

      Navigator.pop(context); // Close loading dialog

      if (response.success && response.data != null && response.data!.isSuccess) {
        Navigator.pop(context); // Close workout dialog
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data!.message),
            backgroundColor: AppColors.primary,
          ),
        );
        
        // Reload workout data
        _loadExercises();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data?.message ?? 'Failed to complete exercise'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Error completing exercise: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.black,
                      size: 24,
                    ),
                    onPressed: () {
                      // Check if we can pop (came from profile) or need to navigate to main nav
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        // If we can't pop, we came from bottom navigation
                        // Navigate back to main screen (will show home tab by default)
                        Navigator.of(context).pushReplacementNamed('/main');
                      }
                    },
                  ),
                  
                  const Spacer(),
                  
                  Text(
                    'EXERCISE',
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.black,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Exercise Image
            GestureDetector(
              onTap: () => _showFullScreenImage('assets/exercises_home_button.png'),
              child: Container(
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: Image.asset(
                  'assets/exercises_home_button.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              ),
            ),
            
            // Day Tabs
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: _isLoadingDays
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
              child: Row(
                        children: _workoutDays.map((workoutDay) => GestureDetector(
                      onTap: () {
                        setState(() {
                              _selectedDay = workoutDay.day;
                              _retryCount = 0; // Reset retry count when changing days
                        });
                            _loadUserExercises();
                      },
                      child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                              color: _selectedDay == workoutDay.day
                              ? AppColors.primary
                              : AppColors.greyLight,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                            child: Column(
                              children: [
                                Text(
                                  workoutDay.dayNameEn,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                                    color: _selectedDay == workoutDay.day
                                ? AppColors.white
                                : AppColors.greyDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                                const SizedBox(height: 2),
                                Text(
                                  '${workoutDay.exerciseCount} exercises',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _selectedDay == workoutDay.day
                                        ? AppColors.white.withOpacity(0.8)
                                        : AppColors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Exercise List
            Expanded(
              child: _buildWorkoutContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Loading exercises...',
              style: AppTextStyles.bodyText1,
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
              const SizedBox(height: AppConstants.paddingLarge),
              Text(
                'Oops! Something went wrong',
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
                style: AppTextStyles.bodyText1.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loadWorkoutDays,
                      icon: const Icon(Icons.refresh),
                      label: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        authProvider.continueAsGuest();
                        _loadMockData();
                      },
                      icon: const Icon(Icons.person),
                      label: Text(AppLocalizations.of(context)?.continueAsGuestButton ?? 'Continue as Guest'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ),
          ],
        ),
            ],
          ),
        ),
      );
    }

    if (_workoutData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 64,
                color: AppColors.grey,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'No workout data available',
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'Try selecting a different day or check back later.',
                style: AppTextStyles.bodyText1.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Handle different workout statuses
    if (_workoutData!.status == 'ended') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'Participation Ended',
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                _workoutData!.message,
                style: AppTextStyles.bodyText1.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              if (_workoutData!.data != null) ...[
                const SizedBox(height: AppConstants.paddingMedium),
          Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
                    color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
                  child: Column(
                    children: [
                      Text(
                        'Participation Period',
                        style: AppTextStyles.bodyText2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.greyDark,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        '${_workoutData!.data!.startDate} - ${_workoutData!.data!.endDate}',
                        style: AppTextStyles.bodyText2.copyWith(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // For active workouts, show participation info
    return Column(
      children: [
          Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                Text(
                    'Workout Available',
                    style: AppTextStyles.headline3.copyWith(
                    color: AppColors.black,
                      fontWeight: FontWeight.bold,
                  ),
                    textAlign: TextAlign.center,
                ),
                  const SizedBox(height: AppConstants.paddingSmall),
                Text(
                    _workoutData!.message,
                    style: AppTextStyles.bodyText1.copyWith(color: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
                  if (_workoutData!.data != null) ...[
                    const SizedBox(height: AppConstants.paddingMedium),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Start Date:',
                  style: AppTextStyles.bodyText2.copyWith(
                                  fontWeight: FontWeight.bold,
                    color: AppColors.greyDark,
                  ),
                ),
                              Text(
                                _workoutData!.data!.startDate,
                                style: AppTextStyles.bodyText2.copyWith(color: AppColors.grey),
                ),
              ],
            ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'End Date:',
                                style: AppTextStyles.bodyText2.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.greyDark,
                                ),
                              ),
                              Text(
                                _workoutData!.data!.endDate,
                                style: AppTextStyles.bodyText2.copyWith(color: AppColors.grey),
                              ),
                            ],
          ),
        ],
      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingLarge),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
                                onPressed: _startWorkout,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Workout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
        ),
      ),
    );
  }
}
