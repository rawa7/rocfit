import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_theme.dart';
import '../l10n/app_localizations.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isMetric = true; // true for metric (cm, kg), false for imperial (ft/in, lbs)
  double? _bmi;
  String _bmiCategory = '';
  Color _bmiCategoryColor = AppColors.grey;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    if (!_formKey.currentState!.validate()) return;

    final heightText = _heightController.text;
    final weightText = _weightController.text;

    if (heightText.isEmpty || weightText.isEmpty) return;

    double height = double.tryParse(heightText) ?? 0;
    double weight = double.tryParse(weightText) ?? 0;

    if (height <= 0 || weight <= 0) return;

    // Convert to metric if imperial
    if (!_isMetric) {
      // Convert feet to cm (assuming input is in feet, e.g., 5.8 for 5'8")
      height = height * 30.48; // feet to cm
      weight = weight * 0.453592; // lbs to kg
    }

    // BMI formula: weight (kg) / height (m)²
    height = height / 100; // cm to m
    final bmi = weight / (height * height);

    setState(() {
      _bmi = bmi;
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
    setState(() {
      _bmi = null;
      _bmiCategory = '';
      _bmiCategoryColor = AppColors.grey;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                localizations.bmiCalculatorTitle,
                style: AppTextStyles.headline2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Unit Toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
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
              const SizedBox(height: AppConstants.paddingLarge),

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
                  if (_bmi != null) _calculateBMI();
                },
              ),
              const SizedBox(height: AppConstants.paddingMedium),

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
                  if (_bmi != null) _calculateBMI();
                },
              ),
              const SizedBox(height: AppConstants.paddingLarge),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _calculateBMI();
                        if (_bmi != null) {
                          setState(() {
                            _setBMICategory(_bmi!, localizations);
                          });
                        }
                      },
                      icon: const Icon(Icons.calculate),
                      label: Text(localizations.calculateBMI),
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
              const SizedBox(height: AppConstants.paddingLarge),

              // Results
              if (_bmi != null) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      children: [
                        Text(
                          localizations.yourBMIResult,
                          style: AppTextStyles.headline3,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        
                        // BMI Value
                        Container(
                          padding: const EdgeInsets.all(AppConstants.paddingLarge),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _bmi!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 48,
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
                        const SizedBox(height: AppConstants.paddingMedium),

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
                const SizedBox(height: AppConstants.paddingLarge),

                // BMI Categories Reference
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.bmiCategories,
                          style: AppTextStyles.headline4,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        _buildBMICategory(localizations.underweight, '< 18.5', AppColors.info),
                        _buildBMICategory(localizations.normalWeight, '18.5 - 24.9', AppColors.success),
                        _buildBMICategory(localizations.overweight, '25.0 - 29.9', AppColors.warning),
                        _buildBMICategory(localizations.obese, '≥ 30.0', AppColors.error),
                      ],
                    ),
                  ),
                ),
              ],
            ],
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
}
