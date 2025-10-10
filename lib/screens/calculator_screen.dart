import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/keyboard_aware_wrapper.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isMetric = true; // true for metric (cm, kg), false for imperial (ft/in, lbs)
  bool _isMale = true; // true for male, false for female
  int _activityLevel = 1; // 0-4 for sedentary to super active
  
  double? _bmi;
  String _bmiCategory = '';
  Color _bmiCategoryColor = AppColors.grey;
  double? _dailyCreatine;
  double? _dailyProtein;
  double? _bmr;
  double? _tdee;
  double? _dailyWater;
  double? _bodyFatPercentage;
  double? _idealBodyWeight;
  double? _dailyCarbs;
  double? _dailyFats;
  double? _dailyProteinMacro;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _calculateAll() {
    if (!_formKey.currentState!.validate()) return;

    final heightText = _heightController.text;
    final weightText = _weightController.text;
    final ageText = _ageController.text;

    if (heightText.isEmpty || weightText.isEmpty || ageText.isEmpty) return;

    double height = double.tryParse(heightText) ?? 0;
    double weight = double.tryParse(weightText) ?? 0;
    double age = double.tryParse(ageText) ?? 0;

    if (height <= 0 || weight <= 0 || age <= 0) return;

    double originalWeight = weight; // Keep original for water calculation
    
    // Convert to metric if imperial
    if (!_isMetric) {
      // Convert feet to cm (assuming input is in feet, e.g., 5.8 for 5'8")
      height = height * 30.48; // feet to cm
      weight = weight * 0.453592; // lbs to kg
    }

    // BMI formula: weight (kg) / height (m)²
    double heightInMeters = height / 100; // cm to m
    final bmi = weight / (heightInMeters * heightInMeters);

    // BMR calculation (Harris-Benedict formula)
    double bmr;
    if (_isMale) {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    // TDEE calculation
    final activityMultipliers = [1.2, 1.375, 1.55, 1.725, 1.9];
    final tdee = bmr * activityMultipliers[_activityLevel];

    // Daily water intake (using original weight for lbs if imperial)
    double waterIntake;
    if (_isMetric) {
      waterIntake = weight * 0.035; // 35ml per kg, converted to liters
    } else {
      waterIntake = (originalWeight * 0.5) * 0.0295735; // 0.5 oz per lb, converted to liters
    }

    // Body fat percentage (BMI-based estimate)
    double bodyFat;
    if (_isMale) {
      bodyFat = 1.20 * bmi + 0.23 * age - 16.2;
    } else {
      bodyFat = 1.20 * bmi + 0.23 * age - 5.4;
    }

    // Ideal body weight
    double idealWeight;
    double heightInInches = height / 2.54; // cm to inches
    if (_isMale) {
      idealWeight = 50 + (2.3 * (heightInInches - 60)); // 60 inches = 5 feet
    } else {
      idealWeight = 45.5 + (2.3 * (heightInInches - 60));
    }

    // Macronutrient distribution (based on TDEE)
    final proteinCals = weight * 1.5 * 4; // 1.5g protein per kg, 4 cal per gram
    final fatCals = tdee * 0.25; // 25% of calories from fat
    final carbCals = tdee - proteinCals - fatCals; // remaining calories

    final proteinGrams = proteinCals / 4;
    final fatGrams = fatCals / 9;
    final carbGrams = carbCals / 4;

    // Daily supplements
    final creatine = weight * 0.05; // 0.05g per kg of body weight
    final protein = weight * 1.5;   // 1.5g per kg of body weight

    setState(() {
      _bmi = bmi;
      _bmr = bmr;
      _tdee = tdee;
      _dailyWater = waterIntake;
      _bodyFatPercentage = bodyFat > 0 ? bodyFat : 0;
      _idealBodyWeight = idealWeight;
      _dailyCarbs = carbGrams;
      _dailyFats = fatGrams;
      _dailyProteinMacro = proteinGrams;
      _dailyCreatine = creatine;
      _dailyProtein = protein;
    });
  }

  void _setBMICategory(double bmi, AppLocalizations localizations) {
    if (bmi < 18.5) {
      _bmiCategory = localizations.underweight;
      _bmiCategoryColor = AppColors.info;
    } else if (bmi < 25) {
      _bmiCategory = localizations.normalWeight;
      _bmiCategoryColor = AppColors.success;
    } else if (bmi < 30) {
      _bmiCategory = localizations.overweight;
      _bmiCategoryColor = AppColors.warning;
    } else {
      _bmiCategory = localizations.obese;
      _bmiCategoryColor = AppColors.error;
    }
  }

  void _clearFields() {
    _heightController.clear();
    _weightController.clear();
    _ageController.clear();
    setState(() {
      _bmi = null;
      _bmiCategory = '';
      _bmiCategoryColor = AppColors.grey;
      _dailyCreatine = null;
      _dailyProtein = null;
      _bmr = null;
      _tdee = null;
      _dailyWater = null;
      _bodyFatPercentage = null;
      _idealBodyWeight = null;
      _dailyCarbs = null;
      _dailyFats = null;
      _dailyProteinMacro = null;
    });
  }

  String? _validateHeight(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.pleaseEnterHeight;
    }
    final height = double.tryParse(value);
    if (height == null || height <= 0) {
      return localizations.pleaseEnterValidHeight;
    }
    if (_isMetric && (height < 50 || height > 300)) {
      return localizations.heightRangeCm;
    }
    if (!_isMetric && (height < 1 || height > 10)) {
      return localizations.heightRangeFt;
    }
    return null;
  }

  String? _validateWeight(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.pleaseEnterWeight;
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return localizations.pleaseEnterValidWeight;
    }
    if (_isMetric && (weight < 20 || weight > 500)) {
      return localizations.weightRangeKg;
    }
    if (!_isMetric && (weight < 44 || weight > 1100)) {
      return localizations.weightRangeLbs;
    }
    return null;
  }

  String? _validateAge(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return localizations.pleaseEnterAge;
    }
    final age = double.tryParse(value);
    if (age == null || age <= 0) {
      return localizations.pleaseEnterValidAge;
    }
    if (age < 10 || age > 120) {
      return localizations.ageRange;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    // Set BMI category using localizations if BMI is calculated
    if (_bmi != null && _bmiCategory.isEmpty) {
      _setBMICategory(_bmi!, localizations);
    }
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(localizations.bmiCalculator),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: KeyboardAwareWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppConstants.paddingMedium,
            right: AppConstants.paddingMedium,
            top: AppConstants.paddingMedium,
            bottom: 100, // Bottom padding for navigation bar
          ),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Unit Toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  child: Row(
                    children: [
                      Text(
                        localizations.units,
                        style: AppTextStyles.headline4,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildUnitOption(localizations.metricUnits, true, localizations),
                            _buildUnitOption(localizations.imperialUnits, false, localizations),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Height Input
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: _isMetric ? localizations.heightCm : localizations.heightFt,
                  hintText: _isMetric ? localizations.heightHintCm : localizations.heightHintFt,
                  prefixIcon: const Icon(Icons.height),
                  suffixText: _isMetric ? 'cm' : 'ft',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) => _validateHeight(value, localizations),
                onChanged: (value) {
                  if (_bmi != null) _calculateAll();
                },
              ),
              const SizedBox(height: AppConstants.paddingSmall),

              // Weight Input
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: _isMetric ? localizations.weightKg : localizations.weightLbs,
                  hintText: _isMetric ? localizations.weightHintKg : localizations.weightHintLbs,
                  prefixIcon: const Icon(Icons.fitness_center),
                  suffixText: _isMetric ? 'kg' : 'lbs',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) => _validateWeight(value, localizations),
                onChanged: (value) {
                  if (_bmi != null) _calculateAll();
                },
              ),
              const SizedBox(height: AppConstants.paddingSmall),

              // Age Input
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: localizations.age,
                  hintText: localizations.ageHint,
                  prefixIcon: const Icon(Icons.cake),
                  suffixText: 'years',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) => _validateAge(value, localizations),
                onChanged: (value) {
                  if (_bmi != null) _calculateAll();
                },
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Gender Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.gender,
                        style: AppTextStyles.headline4,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text(localizations.male),
                              value: true,
                              groupValue: _isMale,
                              onChanged: (value) {
                                setState(() {
                                  _isMale = value!;
                                });
                                if (_bmi != null) _calculateAll();
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text(localizations.female),
                              value: false,
                              groupValue: _isMale,
                              onChanged: (value) {
                                setState(() {
                                  _isMale = value!;
                                });
                                if (_bmi != null) _calculateAll();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),

              // Activity Level Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.activityLevel,
                        style: AppTextStyles.headline4,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      DropdownButtonFormField<int>(
                        value: _activityLevel,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.directions_run),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 0, child: Text(localizations.sedentary)),
                          DropdownMenuItem(value: 1, child: Text(localizations.lightlyActive)),
                          DropdownMenuItem(value: 2, child: Text(localizations.moderatelyActive)),
                          DropdownMenuItem(value: 3, child: Text(localizations.veryActive)),
                          DropdownMenuItem(value: 4, child: Text(localizations.superActive)),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _activityLevel = value!;
                          });
                          if (_bmi != null) _calculateAll();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _calculateAll();
                        if (_bmi != null) {
                          setState(() {
                            _setBMICategory(_bmi!, localizations);
                          });
                        }
                      },
                      icon: const Icon(Icons.calculate),
                      label: Text('Calculate All'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearFields,
                      icon: const Icon(Icons.clear),
                      label: Text(localizations.clear),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Results
              if (_bmi != null) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      children: [
                        Text(
                          localizations.yourBMIResult,
                          style: AppTextStyles.headline4,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        
                        // BMI Value
                        Container(
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _bmi!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                localizations.bmi,
                                style: AppTextStyles.bodyText2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),

                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingLarge,
                            vertical: AppConstants.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: _bmiCategoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                            border: Border.all(color: _bmiCategoryColor, width: 2),
                          ),
                          child: Text(
                            _bmiCategory,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _bmiCategoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),

                // BMI Categories Reference
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingSmall),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.bmiCategories,
                          style: AppTextStyles.headline4,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        _buildBMICategory(localizations.underweight, '< 18.5', AppColors.info),
                        _buildBMICategory(localizations.normalWeight, '18.5 - 24.9', AppColors.success),
                        _buildBMICategory(localizations.overweight, '25.0 - 29.9', AppColors.warning),
                        _buildBMICategory(localizations.obese, '≥ 30.0', AppColors.error),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),

                // Daily Nutritional Needs
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      children: [
                        Text(
                          localizations.nutritionalNeeds,
                          style: AppTextStyles.headline3,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildNutritionalCard(
                                icon: Icons.local_pharmacy,
                                title: localizations.dailyCreatine,
                                value: localizations.gramsPerDay(_dailyCreatine!.toStringAsFixed(1)),
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            Expanded(
                              child: _buildNutritionalCard(
                                icon: Icons.fitness_center,
                                title: localizations.dailyProtein,
                                value: localizations.gramsPerDay(_dailyProtein!.toStringAsFixed(1)),
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),

                // Metabolic Calculations
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      children: [
                        Text(
                          localizations.metabolicCalculations,
                          style: AppTextStyles.headline3,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildNutritionalCard(
                                icon: Icons.local_fire_department,
                                title: localizations.bmr,
                                value: localizations.caloriesPerDay(_bmr!.toStringAsFixed(0)),
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            Expanded(
                              child: _buildNutritionalCard(
                                icon: Icons.flash_on,
                                title: localizations.tdee,
                                value: localizations.caloriesPerDay(_tdee!.toStringAsFixed(0)),
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNutritionalCard(
                                icon: Icons.water_drop,
                                title: localizations.dailyWater,
                                value: localizations.litersPerDay(_dailyWater!.toStringAsFixed(1)),
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),

                // Body Composition
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      children: [
                        Text(
                          localizations.bodyComposition,
                          style: AppTextStyles.headline3,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildNutritionalCard(
                                icon: Icons.percent,
                                title: localizations.bodyFatPercentage,
                                value: localizations.percentage(_bodyFatPercentage!.toStringAsFixed(1)),
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            Expanded(
                              child: _buildNutritionalCard(
                                icon: Icons.balance,
                                title: localizations.idealBodyWeight,
                                value: localizations.kilograms(_idealBodyWeight!.toStringAsFixed(1)),
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),

                // Daily Macronutrients
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      children: [
                        Text(
                          localizations.macronutrients,
                          style: AppTextStyles.headline3,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        
                        Column(
                          children: [
                            _buildMacroCard(
                              icon: Icons.grain,
                              title: localizations.carbohydrates,
                              value: localizations.caloriesAndGrams(
                                (_dailyCarbs! * 4).toStringAsFixed(0),
                                _dailyCarbs!.toStringAsFixed(0),
                              ),
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            _buildMacroCard(
                              icon: Icons.fitness_center,
                              title: 'Protein', // Using direct text since we have daily protein vs macro protein
                              value: localizations.caloriesAndGrams(
                                (_dailyProteinMacro! * 4).toStringAsFixed(0),
                                _dailyProteinMacro!.toStringAsFixed(0),
                              ),
                              color: AppColors.warning,
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            _buildMacroCard(
                              icon: Icons.water_drop_outlined,
                              title: localizations.fats,
                              value: localizations.caloriesAndGrams(
                                (_dailyFats! * 9).toStringAsFixed(0),
                                _dailyFats!.toStringAsFixed(0),
                              ),
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildUnitOption(String label, bool isMetric, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMetric = isMetric;
          _clearFields(); // Clear when switching units
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<bool>(
            value: isMetric,
            groupValue: _isMetric,
            onChanged: (value) {
              setState(() {
                _isMetric = value!;
                _clearFields(); // Clear when switching units
              });
            },
            activeColor: AppColors.primary,
          ),
          Text(
            isMetric ? localizations.metric : localizations.imperial,
            style: AppTextStyles.bodyText1,
          ),
        ],
      ),
    );
  }

  Widget _buildBMICategory(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              category,
              style: AppTextStyles.bodyText1,
            ),
          ),
          Text(
            range,
            style: AppTextStyles.bodyText2,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionalCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            title,
            style: AppTextStyles.bodyText2.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            value,
            style: AppTextStyles.headline4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyText1.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.headline4.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
