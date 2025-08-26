import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/therocfit_api.dart';
import '../l10n/app_localizations.dart';
import 'full_screen_image_viewer.dart';

class ExerciseSetRecordingScreen extends StatefulWidget {
  final UserDayExercise exercise;

  const ExerciseSetRecordingScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseSetRecordingScreen> createState() => _ExerciseSetRecordingScreenState();
}

class _ExerciseSetRecordingScreenState extends State<ExerciseSetRecordingScreen> {
  ExerciseSetInfoResponse? _setInfo;
  List<TextEditingController> _weightControllers = [];
  bool _isLoading = true;
  bool _isRecording = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExerciseSetInfo();
  }

  @override
  void dispose() {
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExerciseSetInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      setState(() {
        _errorMessage = 'Please login to record exercise sets';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await authProvider.apiClient.getExerciseSetInfo(
        userExerciseId: widget.exercise.userExerciseId,
        userId: authProvider.currentUser!.id,
      );

      if (response.success && response.data != null) {
        // Debug: Check if historical data is being received
        print('=== DEBUG: Checking Historical Data ===');
        for (int i = 0; i < response.data!.sets.length; i++) {
          final setInfo = response.data!.sets[i];
          print('Set ${setInfo.setNumber}:');
          print('  - Latest Record: ${setInfo.latestRecord?.formattedWeight ?? 'NULL'}');
          print('  - Highest Record: ${setInfo.highestRecord?.formattedWeight ?? 'NULL'}');
          print('  - Has Historical Data: ${setInfo.latestRecord != null || setInfo.highestRecord != null}');
        }
        print('=======================================');
        
        setState(() {
          _setInfo = response.data!;
          _initializeWeightControllers();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load exercise set information';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading exercise set information: $e';
        _isLoading = false;
      });
    }
  }

  void _initializeWeightControllers() {
    if (_setInfo == null) return;
    
    _weightControllers.clear();
    for (int i = 0; i < _setInfo!.sets.length; i++) {
      final controller = TextEditingController();
      // Pre-fill with existing weight if completed
      if (_setInfo!.sets[i].completed && _setInfo!.sets[i].weightKg != null) {
        controller.text = _setInfo!.sets[i].weightKg!.toStringAsFixed(1);
      }
      _weightControllers.add(controller);
    }
  }

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

  Future<void> _recordSet(int setIndex) async {
    if (setIndex >= _weightControllers.length || _setInfo == null) return;
    
    final weightText = _weightControllers[setIndex].text.trim();
    if (weightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter weight for set ${setIndex + 1}'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final weight = double.tryParse(weightText);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid weight'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to record sets'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isRecording = true;
      _errorMessage = null;
    });

    try {
      final setInfo = _setInfo!.sets[setIndex];
      final response = await authProvider.apiClient.recordExerciseSet(
        userExerciseId: widget.exercise.userExerciseId,
        userId: authProvider.currentUser!.id,
        setNumber: setInfo.setNumber,
        weightKg: weight,
        repetitions: setInfo.targetRepetitions,
        notes: null,
      );

      if (response.success && response.data != null && response.data!.isSuccess) {
        // Reload the set info to get updated completion status
        await _loadExerciseSetInfo();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Set ${setIndex + 1} recorded successfully! 🎉'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );

        // Check if all sets are completed
        if (_setInfo?.exerciseCompleted == true) {
          _showExerciseCompletedDialog();
        }
      } else {
        throw Exception(response.data?.message ?? 'Failed to record set');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording set: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isRecording = false;
      });
    }
  }

  void _showExerciseCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              '🎉 Exercise Completed!',
              style: AppTextStyles.headline3.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Great job! You completed all sets for ${_getLocalizedExerciseName(widget.exercise, context)}.',
              style: AppTextStyles.bodyText1.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close completion dialog
                Navigator.of(context).pop(true); // Return to exercise screen with success
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

  Widget _buildSetRow(int index, ExerciseSetInfo setInfo) {
    final isCompleted = setInfo.completed;
    final weightController = index < _weightControllers.length ? _weightControllers[index] : null;
    final hasHistoricalData = setInfo.latestRecord != null || setInfo.highestRecord != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.primary.withOpacity(0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? AppColors.primary : AppColors.grey.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Main row with set info
          Row(
            children: [
              // Set number
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '${setInfo.setNumber}',
                  style: AppTextStyles.bodyText1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppColors.primary : AppColors.black,
                  ),
                ),
              ),
              
              // Target reps
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '${setInfo.targetRepetitions}',
                  style: AppTextStyles.bodyText1.copyWith(
                    color: isCompleted ? AppColors.primary : AppColors.black,
                  ),
                ),
              ),
              
              // Weight input
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: isCompleted
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${setInfo.weightKg?.toStringAsFixed(1) ?? '-'} kg',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : TextField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: setInfo.latestRecord?.formattedWeight ?? '0.0',
                            suffixText: 'kg',
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: AppColors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                          style: AppTextStyles.bodyText1,
                        ),
                ),
              ),
              
              // Record/Status
              Container(
                width: 80,
                alignment: Alignment.center,
                child: isCompleted
                    ? Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 24,
                      )
                    : ElevatedButton(
                        onPressed: _isRecording ? null : () => _recordSet(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          minimumSize: const Size(60, 32),
                        ),
                        child: _isRecording
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Record',
                                style: AppTextStyles.bodyText2.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                      ),
              ),
            ],
          ),
          
          // Historical data row  
          if (!isCompleted) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: hasHistoricalData 
                ? Row(
                    children: [
                      if (setInfo.latestRecord != null)
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Last: ${setInfo.latestRecord!.formattedWeight}',
                                style: AppTextStyles.bodyText2.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greyDark,
                                ),
                              ),
                              Text(
                                setInfo.latestRecord!.formattedDate,
                                style: AppTextStyles.bodyText2.copyWith(
                                  fontSize: 10,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (setInfo.latestRecord != null && setInfo.highestRecord != null)
                        Container(
                          width: 1,
                          height: 30,
                          color: AppColors.grey.withOpacity(0.3),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      if (setInfo.highestRecord != null)
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Best: ${setInfo.highestRecord!.formattedWeight}',
                                style: AppTextStyles.bodyText2.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                setInfo.highestRecord!.formattedDate,
                                style: AppTextStyles.bodyText2.copyWith(
                                  fontSize: 10,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                : Text(
                    'No previous records',
                    style: AppTextStyles.bodyText2.copyWith(
                      fontSize: 11,
                      color: AppColors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Banner Image Section
          if (widget.exercise.image != null && widget.exercise.image!.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(
                      imageUrls: [widget.exercise.image!],
                      initialIndex: 0,
                      heroTag: 'exercise_image_${widget.exercise.userExerciseId}',
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border.all(color: AppColors.grey.withOpacity(0.2)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        widget.exercise.image!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.greyLight,
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: AppColors.grey,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                      // Overlay gradient for better text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Tap to expand hint
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.zoom_out_map,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Exercise Info Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getLocalizedExerciseName(widget.exercise, context),
                            style: AppTextStyles.headline4.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          if (_setInfo != null) ...[
                            Text(
                              '${_setInfo!.completedSets}/${_setInfo!.totalSets} sets completed',
                              style: AppTextStyles.bodyText2.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            if (_setInfo!.usingCustomSets)
                              Text(
                                'Using custom sets',
                                style: AppTextStyles.bodyText2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Progress bar
                if (_setInfo != null) ...[
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: AppTextStyles.bodyText2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${((_setInfo!.completedSets / _setInfo!.totalSets) * 100).toInt()}%',
                            style: AppTextStyles.bodyText2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: _setInfo!.totalSets > 0 ? _setInfo!.completedSets / _setInfo!.totalSets : 0,
                        backgroundColor: AppColors.grey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              'Set',
              style: AppTextStyles.bodyText1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          Container(
            width: 60,
            alignment: Alignment.center,
            child: Text(
              'Reps',
              style: AppTextStyles.bodyText1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              child: Text(
                'Weight (kg)',
                style: AppTextStyles.bodyText1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          Container(
            width: 80,
            alignment: Alignment.center,
            child: Text(
              'Record',
              style: AppTextStyles.bodyText1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
          color: AppColors.black,
        ),
        title: Text(
          'Record Sets',
          style: AppTextStyles.headline4.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: AppTextStyles.bodyText1.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadExerciseSetInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _setInfo == null
                  ? const Center(
                      child: Text('No data available'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Exercise header
                          _buildHeader(),
                          
                          const SizedBox(height: 24),
                          
                          // Sets table
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.grey.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildTableHeader(),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: _setInfo!.sets
                                        .asMap()
                                        .entries
                                        .map((entry) => _buildSetRow(entry.key, entry.value))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Action buttons
                          if (_setInfo!.exerciseCompleted) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Exercise Completed! 🎉',
                                    style: AppTextStyles.bodyText1.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Text(
                              '${_setInfo!.remainingSets} sets remaining',
                              style: AppTextStyles.bodyText1.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
    );
  }
}
