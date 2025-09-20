import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_models.dart';
import '../services/barcode_service.dart';
import '../services/vision_service.dart';
import '../services/nutrition_service.dart';

/// Provider for meal logging functionality
class MealLoggingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BarcodeService _barcodeService = BarcodeService();
  final VisionService _visionService = VisionService(
    apiKey: 'YOUR_GOOGLE_VISION_API_KEY',
  );
  final NutritionService _nutritionService = NutritionService();

  // State variables
  bool _isLoading = false;
  String _error = '';
  File? _capturedImage;
  FoodRecognitionResult? _recognitionResult;
  List<MealItem> _currentMealItems = [];
  String _selectedMealType = 'breakfast';
  String _mealNotes = '';

  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  File? get capturedImage => _capturedImage;
  FoodRecognitionResult? get recognitionResult => _recognitionResult;
  List<MealItem> get currentMealItems => _currentMealItems;
  String get selectedMealType => _selectedMealType;
  String get mealNotes => _mealNotes;

  /// Set captured image
  void setCapturedImage(File image) {
    _capturedImage = image;
    _error = '';
    notifyListeners();
  }

  /// Set meal type
  void setMealType(String mealType) {
    _selectedMealType = mealType;
    notifyListeners();
  }

  /// Set meal notes
  void setMealNotes(String notes) {
    _mealNotes = notes;
    notifyListeners();
  }

  /// Analyze image for food recognition
  Future<void> analyzeImage() async {
    if (_capturedImage == null) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Try barcode scanning first
      final barcodeResult = await _barcodeService.scanBarcode(_capturedImage!);

      if (barcodeResult != null) {
        // Barcode found - create recognition result
        _recognitionResult = FoodRecognitionResult(
          type: FoodRecognitionType.barcode,
          suggestions: [
            FoodSuggestion(
              name: barcodeResult.nutrition.foodName,
              confidence: barcodeResult.confidence,
              category: 'Product',
              description: 'Scanned from barcode',
            ),
          ],
          confidence: barcodeResult.confidence,
          barcode: barcodeResult.code,
        );
      } else {
        // No barcode found - try Google Vision
        _recognitionResult = await _visionService.analyzeImage(_capturedImage!);
      }
    } catch (e) {
      _error = 'Error analyzing image: $e';
      print('Error analyzing image: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search for foods manually
  Future<void> searchFoods(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Search in OpenFoodFacts first
      final openFoodFactsResults = await _barcodeService.searchProducts(query);

      // Search in USDA database
      final usdaResults = await _nutritionService.searchFoods(query);

      // Combine results
      final allSuggestions = <FoodSuggestion>[];
      allSuggestions.addAll(openFoodFactsResults);
      allSuggestions.addAll(usdaResults);

      // Remove duplicates and sort by confidence
      final uniqueSuggestions = <String, FoodSuggestion>{};
      for (final suggestion in allSuggestions) {
        final key = suggestion.name.toLowerCase();
        if (!uniqueSuggestions.containsKey(key) ||
            uniqueSuggestions[key]!.confidence < suggestion.confidence) {
          uniqueSuggestions[key] = suggestion;
        }
      }

      final sortedSuggestions = uniqueSuggestions.values.toList()
        ..sort((a, b) => b.confidence.compareTo(a.confidence));

      _recognitionResult = FoodRecognitionResult(
        type: FoodRecognitionType.manual,
        suggestions: sortedSuggestions.take(10).toList(),
        confidence: sortedSuggestions.isNotEmpty
            ? sortedSuggestions.first.confidence
            : 0.0,
      );
    } catch (e) {
      _error = 'Error searching foods: $e';
      print('Error searching foods: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add food item to current meal
  Future<void> addFoodItem(
    FoodSuggestion suggestion,
    double portionMultiplier,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get nutrition information
      NutritionInfo nutrition;

      if (_recognitionResult?.type == FoodRecognitionType.barcode) {
        // Use barcode nutrition data
        final barcodeResult = await _barcodeService.scanBarcode(
          _capturedImage!,
        );
        nutrition =
            barcodeResult?.nutrition ??
            NutritionService.createBasicNutrition(suggestion.name);
      } else {
        // Try to get nutrition from USDA or create basic
        nutrition = NutritionService.createBasicNutrition(suggestion.name);

        // TODO: Implement getting nutrition from USDA by food name
        // For now, we'll use basic nutrition that user can edit
      }

      // Create meal item
      final mealItem = MealItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        foodName: suggestion.name,
        nutrition: nutrition,
        portionMultiplier: portionMultiplier,
        imageUrl: _capturedImage?.path,
        barcode: _recognitionResult?.barcode,
        recognitionType: _recognitionResult?.type ?? FoodRecognitionType.manual,
        loggedAt: DateTime.now(),
      );

      _currentMealItems.add(mealItem);
      _error = '';
    } catch (e) {
      _error = 'Error adding food item: $e';
      print('Error adding food item: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Remove food item from current meal
  void removeFoodItem(String itemId) {
    _currentMealItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  /// Update portion size for a food item
  void updatePortionSize(String itemId, double newMultiplier) {
    final index = _currentMealItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _currentMealItems[index];
      _currentMealItems[index] = MealItem(
        id: item.id,
        foodName: item.foodName,
        nutrition: item.nutrition,
        portionMultiplier: newMultiplier,
        imageUrl: item.imageUrl,
        barcode: item.barcode,
        recognitionType: item.recognitionType,
        loggedAt: item.loggedAt,
      );
      notifyListeners();
    }
  }

  /// Save current meal to Firestore
  Future<bool> saveMeal(String userId) async {
    if (_currentMealItems.isEmpty) {
      _error = 'No food items to save';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final meal = Meal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        items: List.from(_currentMealItems),
        loggedAt: DateTime.now(),
        mealType: _selectedMealType,
        notes: _mealNotes.isNotEmpty ? _mealNotes : null,
        imageUrl: _capturedImage?.path,
      );

      // Save to Firestore
      await _firestore.collection('meals').doc(meal.id).set(meal.toJson());

      // Clear current meal
      _clearCurrentMeal();

      _error = '';
      return true;
    } catch (e) {
      _error = 'Error saving meal: $e';
      print('Error saving meal: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current meal data
  void _clearCurrentMeal() {
    _capturedImage = null;
    _recognitionResult = null;
    _currentMealItems.clear();
    _selectedMealType = 'breakfast';
    _mealNotes = '';
    _error = '';
  }

  /// Reset the provider state
  void reset() {
    _clearCurrentMeal();
    _isLoading = false;
    notifyListeners();
  }

  /// Get total nutrition for current meal
  NutritionInfo get currentMealNutrition {
    if (_currentMealItems.isEmpty) {
      return NutritionService.createBasicNutrition('Empty Meal');
    }

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalSugar = 0;
    double totalSodium = 0;
    double totalWeight = 0;

    for (final item in _currentMealItems) {
      final nutrition = item.actualNutrition;
      totalCalories += nutrition.calories;
      totalProtein += nutrition.protein;
      totalCarbs += nutrition.carbs;
      totalFat += nutrition.fat;
      totalFiber += nutrition.fiber;
      totalSugar += nutrition.sugar;
      totalSodium += nutrition.sodium;
      totalWeight += nutrition.servingWeight;
    }

    return NutritionInfo(
      foodName: 'Current Meal',
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      fiber: totalFiber,
      sugar: totalSugar,
      sodium: totalSodium,
      servingSize: 'Total',
      servingWeight: totalWeight,
    );
  }

  /// Dispose resources
  @override
  void dispose() {
    _barcodeService.dispose();
    super.dispose();
  }
}
