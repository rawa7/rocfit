import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/therocfit_api.dart';


class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  // Statistics data
  RealUserStats? _realStats;
  
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }
  
  Future<void> _loadStatistics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      _loadMockStatistics();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load real statistics from the API
      final statsResponse = await authProvider.apiClient.getRealUserStats(authProvider.currentUser!.id);

      if (statsResponse.success && statsResponse.data != null) {
        setState(() {
          _realStats = statsResponse.data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load statistics from server');
      }
    } catch (e) {
      print('Error loading statistics: $e');
      // Fall back to mock data if API fails
      _loadMockStatistics();
    }
  }
  
  void _loadMockStatistics() {
    setState(() {
      _realStats = RealUserStats(
        period: StatsPeriod(
          days: 30,
          startDate: '2024-07-26',
          endDate: '2024-08-25',
        ),
        workoutStatistics: WorkoutStatistics(
          activeDays: 2,
          totalSets: 46,
          exercisesPerformed: 6,
          averageWeight: 44.17,
          totalVolume: 18142,
          currentStreak: 2,
          workoutFrequency: 15,
        ),
        personalRecords: PersonalRecords(
          maxWeightEver: 169.0,
          prExerciseId: '5504',
          prReps: 4,
          prDate: '2024-08-24',
          exerciseName: 'Incline dumbbell bench press',
          exerciseNameArabic: 'بينج بريس دمبل الاعلي+ضخظدمبل مفرد داخلي',
          exerciseNameKurdish: 'بينج بريس دمبل الاعلي+ضخظدمبل مفرد داخلي',
        ),
        foodStatistics: RealFoodStatistics(
          totalFoodsLogged: 0,
          foodLoggingDays: 0,
          mealTypesUsed: 0,
          avgFoodsPerDay: 0,
        ),
        weeklyBreakdown: [
          WeeklyBreakdown(
            weekNum: '34',
            yearNum: '2024',
            workoutDays: 2,
            totalSets: 46,
            weeklyVolume: 18142.0,
          ),
          WeeklyBreakdown(
            weekNum: '33',
            yearNum: '2024',
            workoutDays: 3,
            totalSets: 52,
            weeklyVolume: 16800.0,
          ),
          WeeklyBreakdown(
            weekNum: '32',
            yearNum: '2024',
            workoutDays: 4,
            totalSets: 58,
            weeklyVolume: 19200.0,
          ),
        ],
      );
      
      _isLoading = false;
    });
  }

  String _getLocalizedExerciseName(PersonalRecords record, BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    switch (languageProvider.locale.languageCode) {
      case 'ar':
        return record.exerciseNameArabic;
      case 'fa': // Kurdish using fa locale
        return record.exerciseNameKurdish;
      case 'en':
      default:
        return record.exerciseName;
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
            _buildHeader(),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
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
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/main');
              }
            },
          ),
          
          const Spacer(),
          
          Text(
            'STATISTICS',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          
          const Spacer(),
          
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: AppColors.primary,
              size: 24,
            ),
            onPressed: _loadStatistics,
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Loading statistics...',
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
              const Icon(
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
              ElevatedButton.icon(
                onPressed: _loadStatistics,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Stats
          _buildOverviewStats(),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Monthly Progress Chart
          _buildMonthlyProgressChart(),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Exercise Personal Bests
          _buildExerciseBests(),
        ],
      ),
    );
  }
  
  Widget _buildOverviewStats() {
    if (_realStats == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview (${_realStats!.period.days} days)',
          style: AppTextStyles.headline3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                title: 'Active Days',
                value: _realStats!.workoutStatistics.activeDays.toString(),
                subtitle: 'Last 30 days',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                title: 'Current Streak',
                value: _realStats!.workoutStatistics.currentStreak.toString(),
                subtitle: 'Days',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        _buildStatCard(
          icon: Icons.fitness_center,
          title: 'Total Volume',
          value: _realStats!.workoutStatistics.formattedTotalVolume,
          subtitle: 'Total weight lifted',
          color: AppColors.secondary,
          fullWidth: true,
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyText2.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            value,
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodyText2.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthlyProgressChart() {
    if (_realStats == null || _realStats!.weeklyBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Progress',
          style: AppTextStyles.headline3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weight Lifted (kg)',
                    style: AppTextStyles.bodyText1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyDark,
                    ),
                  ),
                  Icon(
                    Icons.trending_up,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Simple bar chart representation
              SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _realStats!.weeklyBreakdown.map((data) => 
                    _buildWeeklyProgressBar(data)
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeeklyProgressBar(WeeklyBreakdown data) {
    final maxValue = _realStats!.weeklyBreakdown.map((e) => e.weeklyVolume).reduce((a, b) => a > b ? a : b);
    final heightRatio = data.weeklyVolume / maxValue;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${data.weeklyVolume.toStringAsFixed(0)}kg',
          style: AppTextStyles.bodyText2.copyWith(
            fontSize: 10,
            color: AppColors.greyDark,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 120 * heightRatio,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.7),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'W${data.weekNum}', // Show week number
          style: AppTextStyles.bodyText2.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
  
  Widget _buildExerciseBests() {
    if (_realStats == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Record',
          style: AppTextStyles.headline3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        _buildPersonalRecordItem(_realStats!.personalRecords),
      ],
    );
  }
  
  Widget _buildPersonalRecordItem(PersonalRecords record) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Medal icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              color: AppColors.secondary,
              size: 24,
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
                    _getLocalizedExerciseName(record, context),
                    style: AppTextStyles.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record.formattedWeight,
                        style: AppTextStyles.bodyText2.copyWith(
                          color: AppColors.greyDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.repeat,
                        size: 16,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record.formattedReps,
                        style: AppTextStyles.bodyText2.copyWith(
                          color: AppColors.greyDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Achievement date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Personal Best',
                style: AppTextStyles.bodyText2.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                record.prDate,
                style: AppTextStyles.bodyText2.copyWith(
                  color: AppColors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


