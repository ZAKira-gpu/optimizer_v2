import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_models.dart';
import '../services/nutrition_service.dart';
import '../../../core/database/providers/hive_sync_provider.dart';

/// Enhanced meal logging provider with automatic Hive synchronization
class EnhancedMealLoggingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NutritionService _nutritionService = NutritionService();
  final HiveSyncProvider _hiveSyncProvider = HiveSyncProvider();

  // State variables
  bool _isLoading = false;
  String _error = '';
  FoodRecognitionResult? _recognitionResult;
  List<MealItem> _currentMealItems = [];
  String _selectedMealType = 'breakfast';
  String _mealNotes = '';
  String? _mealPhotoPath;

  // Nutrition goals
  NutritionGoals _dailyGoals = NutritionGoals(
    calories: 2000,
    protein: 150,
    carbs: 250,
    fat: 65,
  );

  // Daily nutrition tracking
  DailyNutritionSummary? _todayNutrition;

  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  FoodRecognitionResult? get recognitionResult => _recognitionResult;
  List<MealItem> get currentMealItems => _currentMealItems;
  String get selectedMealType => _selectedMealType;
  String get mealNotes => _mealNotes;
  String? get mealPhotoPath => _mealPhotoPath;
  NutritionGoals get dailyGoals => _dailyGoals;
  DailyNutritionSummary? get todayNutrition => _todayNutrition;

  /// Initialize the provider
  Future<void> initialize() async {
    try {
      await _hiveSyncProvider.initialize();
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize provider: $e');
    }
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

  /// Set meal photo path
  void setMealPhoto(String? photoPath) {
    _mealPhotoPath = photoPath;
    notifyListeners();
  }

  /// Remove meal photo
  void removeMealPhoto() {
    _mealPhotoPath = null;
    notifyListeners();
  }

  /// Update nutrition goals
  void updateNutritionGoals(NutritionGoals goals) {
    _dailyGoals = goals;
    notifyListeners();
  }

  /// Load nutrition goals for a user
  Future<void> loadNutritionGoals(String userId) async {
    if (userId.isEmpty) return;

    try {
      final doc = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('settings')
          .doc('nutritionGoals')
          .get();

      if (doc.exists) {
        _dailyGoals = NutritionGoals.fromJson(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading nutrition goals: $e');
    }
  }

  /// Load today's nutrition summary from logged meals
  Future<void> loadTodayNutrition(String userId) async {
    if (userId.isEmpty) return;

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get all meals from today
      final mealsQuery = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('meals')
          .where(
            'loggedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('loggedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      // Calculate total nutrition from all meals
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      double totalFiber = 0;
      double totalSugar = 0;
      double totalSodium = 0;

      for (final mealDoc in mealsQuery.docs) {
        final mealData = mealDoc.data();
        final items = mealData['items'] as List<dynamic>? ?? [];

        for (final itemData in items) {
          final nutrition = itemData['nutrition'] as Map<String, dynamic>?;
          final portionMultiplier =
              (itemData['portionMultiplier'] as num?)?.toDouble() ?? 1.0;

          if (nutrition != null) {
            totalCalories +=
                ((nutrition['calories'] as num?)?.toDouble() ?? 0) *
                portionMultiplier;
            totalProtein +=
                ((nutrition['protein'] as num?)?.toDouble() ?? 0) *
                portionMultiplier;
            totalCarbs +=
                ((nutrition['carbs'] as num?)?.toDouble() ?? 0) *
                portionMultiplier;
            totalFat +=
                ((nutrition['fat'] as num?)?.toDouble() ?? 0) *
                portionMultiplier;
            totalFiber +=
                ((nutrition['fiber'] as num?)?.toDouble() ?? 0) *
                portionMultiplier;
            totalSugar +=
                ((nutrition['sugar'] as num?)?.toDouble() ?? 0) *
                portionMultiplier;
            totalSodium +=
                ((nutrition['sodium'] as num?)?.toDouble() ?? 0) *
                portionMultiplier;
          }
        }
      }

      // Create total nutrition info
      final totalNutrition = NutritionInfo(
        foodName: 'Daily Total',
        calories: totalCalories,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        fiber: totalFiber,
        sugar: totalSugar,
        sodium: totalSodium,
        servingSize: 'Daily',
        servingWeight: 1,
      );

      // Create meal count map
      final mealCounts = <String, int>{};
      for (final mealDoc in mealsQuery.docs) {
        final mealType = mealDoc.data()['mealType'] as String? ?? 'unknown';
        mealCounts[mealType] = (mealCounts[mealType] ?? 0) + 1;
      }

      _todayNutrition = DailyNutritionSummary(
        userId: userId,
        date: startOfDay,
        meals: mealsQuery.docs.map((doc) => Meal.fromJson(doc.data())).toList(),
        totalNutrition: totalNutrition,
        mealCounts: mealCounts,
      );

      notifyListeners();
    } catch (e) {
      print('Error loading today nutrition: $e');
    }
  }

  /// Search for foods manually using OpenFoodFacts and USDA
  Future<void> searchFoods(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Search in USDA database
      final usdaResults = await _nutritionService.searchFoods(query);

      // Create mock suggestions for demonstration
      final mockSuggestions = _createMockSuggestions(query);

      // Combine results
      final allSuggestions = <FoodSuggestion>[];
      allSuggestions.addAll(usdaResults);
      allSuggestions.addAll(mockSuggestions);

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

  /// Create mock food suggestions for demonstration
  List<FoodSuggestion> _createMockSuggestions(String query) {
    final queryLower = query.toLowerCase();
    final suggestions = <FoodSuggestion>[];

    // Common food items with mock nutrition data
    final foodDatabase = {
      'apple': {'category': 'Fruits', 'confidence': 0.95},
      'banana': {'category': 'Fruits', 'confidence': 0.95},
      'orange': {'category': 'Fruits', 'confidence': 0.95},
      'chicken': {'category': 'Meat', 'confidence': 0.90},
      'beef': {'category': 'Meat', 'confidence': 0.90},
      'pork': {'category': 'Meat', 'confidence': 0.90},
      'fish': {'category': 'Seafood', 'confidence': 0.90},
      'salmon': {'category': 'Seafood', 'confidence': 0.95},
      'pizza': {'category': 'Fast Food', 'confidence': 0.85},
      'burger': {'category': 'Fast Food', 'confidence': 0.85},
      'sandwich': {'category': 'Fast Food', 'confidence': 0.80},
      'salad': {'category': 'Vegetables', 'confidence': 0.90},
      'bread': {'category': 'Grains', 'confidence': 0.90},
      'rice': {'category': 'Grains', 'confidence': 0.90},
      'pasta': {'category': 'Grains', 'confidence': 0.90},
      'milk': {'category': 'Dairy', 'confidence': 0.95},
      'cheese': {'category': 'Dairy', 'confidence': 0.90},
      'yogurt': {'category': 'Dairy', 'confidence': 0.90},
      'egg': {'category': 'Protein', 'confidence': 0.95},
      'coffee': {'category': 'Beverages', 'confidence': 0.90},
      'tea': {'category': 'Beverages', 'confidence': 0.90},
      'water': {'category': 'Beverages', 'confidence': 0.95},
    };

    // Find matching foods
    for (final entry in foodDatabase.entries) {
      if (entry.key.contains(queryLower) || queryLower.contains(entry.key)) {
        suggestions.add(
          FoodSuggestion(
            name: entry.key.toUpperCase(),
            confidence: entry.value['confidence'] as double,
            category: entry.value['category'] as String,
            description: 'Fresh ${entry.key}',
          ),
        );
      }
    }

    // If no exact matches, add some generic suggestions
    if (suggestions.isEmpty) {
      suggestions.addAll([
        FoodSuggestion(
          name: 'Fresh $query',
          confidence: 0.70,
          category: 'Food',
          description: 'Fresh food item',
        ),
        FoodSuggestion(
          name: 'Organic $query',
          confidence: 0.65,
          category: 'Food',
          description: 'Organic food item',
        ),
      ]);
    }

    return suggestions;
  }

  /// Add food item to current meal
  Future<void> addFoodItem(
    FoodSuggestion suggestion,
    double portionMultiplier,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create nutrition info with mock data
      final nutrition = _createMockNutrition(suggestion.name);

      // Create meal item
      final mealItem = MealItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        foodName: suggestion.name,
        nutrition: nutrition,
        portionMultiplier: portionMultiplier,
        imageUrl: null,
        barcode: null,
        recognitionType: FoodRecognitionType.manual,
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

  /// Create mock nutrition data for demonstration
  NutritionInfo _createMockNutrition(String foodName) {
    final foodLower = foodName.toLowerCase();

    // Mock nutrition data based on food type
    if (foodLower.contains('apple') ||
        foodLower.contains('banana') ||
        foodLower.contains('orange')) {
      return NutritionInfo(
        foodName: foodName,
        calories: 80.0,
        protein: 1.0,
        carbs: 20.0,
        fat: 0.3,
        fiber: 3.0,
        sugar: 15.0,
        sodium: 1.0,
        servingSize: '100g',
        servingWeight: 100.0,
      );
    } else if (foodLower.contains('chicken') ||
        foodLower.contains('beef') ||
        foodLower.contains('pork')) {
      return NutritionInfo(
        foodName: foodName,
        calories: 250.0,
        protein: 25.0,
        carbs: 0.0,
        fat: 15.0,
        fiber: 0.0,
        sugar: 0.0,
        sodium: 70.0,
        servingSize: '100g',
        servingWeight: 100.0,
      );
    } else if (foodLower.contains('pizza') || foodLower.contains('burger')) {
      return NutritionInfo(
        foodName: foodName,
        calories: 300.0,
        protein: 12.0,
        carbs: 35.0,
        fat: 12.0,
        fiber: 2.0,
        sugar: 5.0,
        sodium: 800.0,
        servingSize: '100g',
        servingWeight: 100.0,
      );
    } else if (foodLower.contains('salad')) {
      return NutritionInfo(
        foodName: foodName,
        calories: 25.0,
        protein: 2.0,
        carbs: 5.0,
        fat: 0.5,
        fiber: 2.0,
        sugar: 3.0,
        sodium: 10.0,
        servingSize: '100g',
        servingWeight: 100.0,
      );
    } else if (foodLower.contains('bread') ||
        foodLower.contains('rice') ||
        foodLower.contains('pasta')) {
      return NutritionInfo(
        foodName: foodName,
        calories: 130.0,
        protein: 4.0,
        carbs: 25.0,
        fat: 1.0,
        fiber: 2.0,
        sugar: 1.0,
        sodium: 200.0,
        servingSize: '100g',
        servingWeight: 100.0,
      );
    } else if (foodLower.contains('milk') ||
        foodLower.contains('cheese') ||
        foodLower.contains('yogurt')) {
      return NutritionInfo(
        foodName: foodName,
        calories: 60.0,
        protein: 3.0,
        carbs: 5.0,
        fat: 3.0,
        fiber: 0.0,
        sugar: 5.0,
        sodium: 50.0,
        servingSize: '100g',
        servingWeight: 100.0,
      );
    } else {
      // Default nutrition for unknown foods
      return NutritionInfo(
        foodName: foodName,
        calories: 100.0,
        protein: 5.0,
        carbs: 15.0,
        fat: 3.0,
        fiber: 2.0,
        sugar: 5.0,
        sodium: 50.0,
        servingSize: '100g',
        servingWeight: 100.0,
      );
    }
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

  /// Save current meal to Firestore and sync to Hive
  Future<bool> saveMeal(String userId) async {
    if (_currentMealItems.isEmpty) {
      _error = 'No food items to save';
      notifyListeners();
      return false;
    }

    if (userId.isEmpty) {
      _error = 'User ID is empty';
      print('❌ User ID is empty!');
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
        imageUrl: _mealPhotoPath,
      );

      print('🍽️ ===== MEAL SAVING DEBUG =====');
      print('🍽️ User ID: $userId');
      print('🍽️ Meal ID: ${meal.id}');
      print('🍽️ Meal items: ${meal.items.length}');
      print('🍽️ Meal type: ${meal.mealType}');
      print('🍽️ ===============================');

      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      print('🔐 Current Firebase user: ${currentUser?.uid}');
      print('🔐 Is authenticated: ${currentUser != null}');

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (currentUser.uid != userId) {
        print('⚠️ User ID mismatch: ${currentUser.uid} vs $userId');
      }

      // Try multiple save strategies
      bool saved = false;

      // Strategy 1: Save to user-specific path
      try {
        print(
          '💾 Attempting to save to: userProfiles/$userId/meals/${meal.id}',
        );

        await _firestore
            .collection('userProfiles')
            .doc(userId)
            .collection('meals')
            .doc(meal.id)
            .set(meal.toJson());

        print('✅ SUCCESS: Meal saved to userProfiles/$userId/meals/${meal.id}');
        saved = true;
      } catch (e) {
        print('❌ FAILED to save to userProfiles path: $e');
        print('❌ Error type: ${e.runtimeType}');

        // Strategy 2: Save to global meals collection with userId filter
        try {
          print('💾 Attempting fallback to: meals/${meal.id}');

          await _firestore.collection('meals').doc(meal.id).set(meal.toJson());

          print('✅ SUCCESS: Meal saved to global meals collection');
          saved = true;
        } catch (e2) {
          print('❌ FAILED fallback save: $e2');
          print('❌ Fallback error type: ${e2.runtimeType}');
          throw e2;
        }
      }

      if (saved) {
        // Sync to Hive database
        try {
          await _hiveSyncProvider.syncMealData(
            userId: userId,
            mealId: meal.id,
            mealType: meal.mealType,
            items: meal.items.map((item) => item.toJson()).toList(),
            loggedAt: meal.loggedAt,
            notes: meal.notes,
            imageUrl: meal.imageUrl,
          );
          print('✅ Meal data synced to Hive');
        } catch (e) {
          print('⚠️ Failed to sync meal to Hive: $e');
          // Don't fail the entire operation if Hive sync fails
        }

        // Clear current meal
        _clearCurrentMeal();
        _error = '';

        // Refresh today's nutrition data
        await loadTodayNutrition(userId);

        print('🎉 Meal saved successfully!');
        return true;
      } else {
        throw Exception('Failed to save meal with any strategy');
      }
    } catch (e) {
      _error = 'Error saving meal: $e';
      print('❌ FINAL ERROR: $e');
      print('❌ Error type: ${e.runtimeType}');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current meal data
  void _clearCurrentMeal() {
    _recognitionResult = null;
    _currentMealItems.clear();
    _selectedMealType = 'breakfast';
    _mealNotes = '';
    _mealPhotoPath = null;
    _error = '';
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

  /// Reset the provider state
  void reset() {
    _clearCurrentMeal();
    _isLoading = false;
    notifyListeners();
  }

  // Private helper methods
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
