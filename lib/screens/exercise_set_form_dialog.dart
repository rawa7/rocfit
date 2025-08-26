import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/therocfit_api.dart';
import '../l10n/app_localizations.dart';

class ExerciseSetFormDialog extends StatefulWidget {
  final UserDayExercise exercise;

  const ExerciseSetFormDialog({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseSetFormDialog> createState() => _ExerciseSetFormDialogState();
}

class _ExerciseSetFormDialogState extends State<ExerciseSetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _weightControllers = [];
  List<TextEditingController> _repsControllers = [];
  final _notesController = TextEditingController();
  
  int _currentSetCount = 1;
  bool _isLoading = false;
  bool _isLoadingHistory = true;
  List<ExerciseSetRecord> _lastRecords = [];
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Start with planned number of sets or at least 1
    _currentSetCount = widget.exercise.sets > 0 ? widget.exercise.sets : 1;
    _initializeControllers();
    _loadLastRecords();
  }

  void _initializeControllers() {
    // Clear existing controllers
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    
    // Create new controllers
    _weightControllers = List.generate(
      _currentSetCount, 
      (index) => TextEditingController()
    );
    _repsControllers = List.generate(
      _currentSetCount, 
      (index) => TextEditingController()
    );
  }

  void _addSet() {
    setState(() {
      _currentSetCount++;
      _weightControllers.add(TextEditingController());
      _repsControllers.add(TextEditingController());
    });
  }

  void _removeSet() {
    if (_currentSetCount > 1) {
      setState(() {
        // Dispose the last controllers
        _weightControllers.last.dispose();
        _repsControllers.last.dispose();
        
        // Remove them from the lists
        _weightControllers.removeLast();
        _repsControllers.removeLast();
        
        _currentSetCount--;
      });
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadLastRecords() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      setState(() {
        _isLoadingHistory = false;
      });
      return;
    }

    try {
      final response = await authProvider.apiClient.getLastExerciseSetRecord(
        userExerciseId: widget.exercise.userExerciseId,
        userId: authProvider.currentUser!.id,
      );
      
      if (response.success && response.data != null) {
        setState(() {
          _lastRecords = response.data!;
          _isLoadingHistory = false;
        });
        
        // Pre-fill with last recorded values if available
        for (int i = 0; i < _lastRecords.length && i < _currentSetCount; i++) {
          final record = _lastRecords[i];
          if (i < _weightControllers.length && i < _repsControllers.length) {
            _weightControllers[i].text = record.weightKg.toString();
            _repsControllers[i].text = record.repetitions.toString();
          }
        }
      } else {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      print('Error loading last records: $e');
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  bool _hasAtLeastOneSet() {
    for (int i = 0; i < _currentSetCount; i++) {
      if (i < _weightControllers.length && i < _repsControllers.length &&
          _weightControllers[i].text.isNotEmpty && _repsControllers[i].text.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  Future<void> _recordAllSets() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasAtLeastOneSet()) {
      setState(() {
        _errorMessage = 'Please fill in at least one set with weight and repetitions.';
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      setState(() {
        _errorMessage = 'Please login to record exercise sets';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Record all sets one by one
      int successCount = 0;
      
      for (int i = 0; i < _currentSetCount; i++) {
        // Skip empty sets
        if (_weightControllers[i].text.isEmpty || _repsControllers[i].text.isEmpty) {
          continue;
        }
        
        final response = await authProvider.apiClient.recordExerciseSet(
          userExerciseId: widget.exercise.userExerciseId,
          userId: authProvider.currentUser!.id,
          setNumber: i + 1,
          weightKg: double.parse(_weightControllers[i].text),
          repetitions: int.parse(_repsControllers[i].text),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        
        if (response.success && response.data != null && response.data!.isSuccess) {
          successCount++;
        } else {
          throw Exception('Failed to record set ${i + 1}: ${response.data?.message ?? "Unknown error"}');
        }
      }
      
      if (successCount > 0) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('All $successCount sets recorded successfully! 🎉'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        setState(() {
          _isLoading = false;
        });
        
        _showCompletionDialog();
      } else {
        setState(() {
          _errorMessage = 'No sets were recorded. Please fill in at least one set.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error recording sets: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showCompletionDialog() {
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
              'Great job! You completed all sets for ${widget.exercise.name}.',
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
                Navigator.of(context).pop(true); // Close set form with success
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusLarge),
                  topRight: Radius.circular(AppConstants.radiusLarge),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exercise.name,
                          style: AppTextStyles.headline4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '$_currentSetCount sets',
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Last Records Section - only show if loading or if records exist
                      if (_isLoadingHistory) ...[
                        Container(
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          margin: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
                          decoration: BoxDecoration(
                            color: AppColors.greyLight,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          ),
                          child: const Row(
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                              SizedBox(width: AppConstants.paddingMedium),
                              Text('Loading last records...'),
                            ],
                          ),
                        ),
                      ] else if (_lastRecords.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          margin: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
                          decoration: BoxDecoration(
                            color: AppColors.greyLight,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Last Time',
                                    style: AppTextStyles.bodyText1.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.paddingSmall),
                              ...List.generate(
                                _lastRecords.take(3).length,
                                (index) {
                                  final record = _lastRecords[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Set ${record.setNumber}:',
                                          style: AppTextStyles.bodyText2.copyWith(
                                            color: AppColors.greyDark,
                                          ),
                                        ),
                                        Text(
                                          '${record.formattedWeight} × ${record.repetitions} reps',
                                          style: AppTextStyles.bodyText2.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              if (_lastRecords.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _lastRecords.first.formattedDate,
                                  style: AppTextStyles.bodyText2.copyWith(
                                    color: AppColors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      // If no records and not loading, don't show anything
                      
                      // Sets Input Section with Add/Remove buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enter data for each set:',
                            style: AppTextStyles.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              // Remove set button
                              IconButton(
                                onPressed: _currentSetCount > 1 ? _removeSet : null,
                                icon: const Icon(Icons.remove_circle_outline),
                                color: _currentSetCount > 1 ? AppColors.error : AppColors.grey,
                                tooltip: 'Remove set',
                              ),
                              // Add set button
                              IconButton(
                                onPressed: _addSet,
                                icon: const Icon(Icons.add_circle_outline),
                                color: AppColors.primary,
                                tooltip: 'Add set',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      
                      // All Sets Input
                      ...List.generate(_currentSetCount, (index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.greyLight,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                            border: Border.all(
                              color: AppColors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Set header with last record
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Set ${index + 1}',
                                    style: AppTextStyles.bodyText1.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (_lastRecords.isNotEmpty && _lastRecords.length > index)
                                    Text(
                                      'Last: ${_lastRecords[index].formattedWeight} × ${_lastRecords[index].repetitions} reps',
                                      style: AppTextStyles.bodyText2.copyWith(
                                        color: AppColors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.paddingSmall),
                              
                              // Weight and Reps inputs in a row
                              Row(
                                children: [
                                  // Weight input
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Weight (kg)',
                                          style: AppTextStyles.bodyText2.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextFormField(
                                          controller: _weightControllers[index],
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          decoration: InputDecoration(
                                            hintText: '0.0',
                                            suffixText: 'kg',
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                              borderSide: const BorderSide(color: AppColors.grey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                              borderSide: const BorderSide(color: AppColors.primary),
                                            ),
                                          ),
                                          validator: (value) {
                                            // Allow empty for optional sets
                                            if (value == null || value.isEmpty) {
                                              return null;
                                            }
                                            final weight = double.tryParse(value);
                                            if (weight == null || weight <= 0) {
                                              return 'Invalid weight';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.paddingMedium),
                                  
                                  // Reps input
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reps',
                                          style: AppTextStyles.bodyText2.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextFormField(
                                          controller: _repsControllers[index],
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            suffixText: 'reps',
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                              borderSide: const BorderSide(color: AppColors.grey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                              borderSide: const BorderSide(color: AppColors.primary),
                                            ),
                                          ),
                                          validator: (value) {
                                            // Allow empty for optional sets, but if weight is filled, reps must be filled too
                                            if (value == null || value.isEmpty) {
                                              // Check if weight is filled for this set
                                              if (index < _weightControllers.length && _weightControllers[index].text.isNotEmpty) {
                                                return 'Required when weight is entered';
                                              }
                                              return null;
                                            }
                                            final reps = int.tryParse(value);
                                            if (reps == null || reps <= 0) {
                                              return 'Invalid reps';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Notes Input (Optional)
                      Text(
                        'Notes (Optional)',
                        style: AppTextStyles.bodyText1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Add notes about this set...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            borderSide: const BorderSide(color: AppColors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          margin: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: AppTextStyles.bodyText2.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
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
            
            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.radiusLarge),
                  bottomRight: Radius.circular(AppConstants.radiusLarge),
                ),
              ),
              child: Column(
                children: [
                                      SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _recordAllSets,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          ),
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Recording All Sets...'),
                                ],
                              )
                            : Text(
                                'Complete Exercise',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodyText1.copyWith(
                          color: AppColors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
