import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/therocfit_api.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _selectedDay = 2; // Day 2 is selected by default as shown in design
  DayExercises? _dayExercises;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      // Show mock data for guest users
      _loadMockData();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await authProvider.apiClient.getDayExercises(
        authProvider.currentUser!.id,
        _selectedDay,
      );
      
      if (response.success && response.data != null) {
        setState(() {
          _dayExercises = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load exercises: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _loadMockData() {
    // Mock data for guest users
    setState(() {
      _dayExercises = DayExercises(
        userId: 0,
        day: _selectedDay,
        regularExercises: [
          UserExercise(
            id: 1,
            exerciseId: 1,
            exerciseName: 'Bench Press',
            sets: 1,
            reps: 12,
            completed: true,
          ),
          UserExercise(
            id: 2,
            exerciseId: 2,
            exerciseName: 'Back Squat',
            sets: 1,
            reps: 12,
            completed: false,
          ),
          UserExercise(
            id: 3,
            exerciseId: 3,
            exerciseName: 'Overhead',
            sets: 1,
            reps: 12,
            completed: false,
          ),
        ],
        supersets: [],
        statistics: ExerciseStatistics(
          totalExercises: 3,
          completedExercises: 1,
          completionPercentage: 33.3,
        ),
      );
      _isLoading = false;
    });
  }

  Future<void> _completeExercise(UserExercise exercise) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn) {
      // For guest users, just update locally
      setState(() {
        final exercises = _dayExercises!.regularExercises;
        final index = exercises.indexWhere((e) => e.id == exercise.id);
        if (index != -1) {
          exercises[index] = UserExercise(
            id: exercise.id,
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.exerciseName,
            sets: exercise.sets,
            reps: exercise.reps,
            customSet: exercise.customSet,
            weight: exercise.weight,
            restTime: exercise.restTime,
            completed: !exercise.completed,
            completedAt: exercise.completedAt,
            image: exercise.image,
            category: exercise.category,
            difficulty: exercise.difficulty,
          );
        }
      });
      return;
    }

    try {
      final response = await authProvider.apiClient.completeExercise(
        exerciseId: exercise.id,
        day: _selectedDay,
        userId: authProvider.currentUser!.id,
      );
      
      if (response.success) {
        _loadExercises(); // Reload to get updated status
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise updated!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
                      // Handle back navigation
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
                      // Handle notifications
                    },
                  ),
                ],
              ),
            ),
            
            // Exercise Image
            Container(
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: const Center(
                child: Text(
                  'Image',
                  style: TextStyle(
                    fontSize: 32,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            
            // Day Tabs
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Row(
                children: List.generate(
                  6,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = index + 1;
                        });
                        _loadExercises();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedDay == index + 1
                              ? AppColors.primary
                              : AppColors.greyLight,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                        child: Text(
                          'Day ${index + 1}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedDay == index + 1
                                ? AppColors.white
                                : AppColors.greyDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Exercise List
            Expanded(
              child: _buildExerciseList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText1.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton(
              onPressed: _loadExercises,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_dayExercises == null || _dayExercises!.regularExercises.isEmpty) {
      return const Center(
        child: Text(
          'No exercises found for this day',
          style: AppTextStyles.bodyText1,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      itemCount: _dayExercises!.regularExercises.length,
      itemBuilder: (context, index) {
        final exercise = _dayExercises!.regularExercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(UserExercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: [
          // Exercise completion checkbox
          GestureDetector(
            onTap: () => _completeExercise(exercise),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: exercise.completed ? AppColors.primary : AppColors.white,
                border: Border.all(
                  color: exercise.completed ? AppColors.primary : AppColors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: exercise.completed
                  ? const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: AppConstants.paddingMedium),
          
          // Exercise Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.greyDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: const Center(
              child: Text(
                'Image',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppConstants.paddingMedium),
          
          // Exercise Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: AppTextStyles.bodyText1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.customSet ?? 'Set ${exercise.sets} - ${exercise.reps} Reps',
                  style: AppTextStyles.bodyText2.copyWith(
                    color: AppColors.greyDark,
                  ),
                ),
              ],
            ),
          ),
          
          // Arrow Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
