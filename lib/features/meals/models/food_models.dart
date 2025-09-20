import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for different types of food recognition
enum FoodRecognitionType { barcode, vision, manual }

/// Model for food recognition results
class FoodRecognitionResult {
  final FoodRecognitionType type;
  final List<FoodSuggestion> suggestions;
  final double confidence;
  final String? barcode;
  final String? error;

  FoodRecognitionResult({
    required this.type,
    required this.suggestions,
    required this.confidence,
    this.barcode,
    this.error,
  });

  factory FoodRecognitionResult.fromJson(Map<String, dynamic> json) {
    return FoodRecognitionResult(
      type: FoodRecognitionType.values.firstWhere(
        (e) => e.toString() == 'FoodRecognitionType.${json['type']}',
        orElse: () => FoodRecognitionType.manual,
      ),
      suggestions: (json['suggestions'] as List)
          .map((s) => FoodSuggestion.fromJson(s))
          .toList(),
      confidence: json['confidence']?.toDouble() ?? 0.0,
      barcode: json['barcode'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'suggestions': suggestions.map((s) => s.toJson()).toList(),
      'confidence': confidence,
      'barcode': barcode,
      'error': error,
    };
  }
}

/// Model for food suggestions from recognition
class FoodSuggestion {
  final String name;
  final double confidence;
  final String? category;
  final String? description;

  FoodSuggestion({
    required this.name,
    required this.confidence,
    this.category,
    this.description,
  });

  factory FoodSuggestion.fromJson(Map<String, dynamic> json) {
    return FoodSuggestion(
      name: json['name'] ?? '',
      confidence: json['confidence']?.toDouble() ?? 0.0,
      category: json['category'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
      'category': category,
      'description': description,
    };
  }
}

/// Model for nutrition information
class NutritionInfo {
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final String servingSize;
  final double servingWeight; // in grams

  NutritionInfo({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.servingSize,
    required this.servingWeight,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      foodName: json['foodName'] ?? '',
      calories: json['calories']?.toDouble() ?? 0.0,
      protein: json['protein']?.toDouble() ?? 0.0,
      carbs: json['carbs']?.toDouble() ?? 0.0,
      fat: json['fat']?.toDouble() ?? 0.0,
      fiber: json['fiber']?.toDouble() ?? 0.0,
      sugar: json['sugar']?.toDouble() ?? 0.0,
      sodium: json['sodium']?.toDouble() ?? 0.0,
      servingSize: json['servingSize'] ?? '100g',
      servingWeight: json['servingWeight']?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'servingSize': servingSize,
      'servingWeight': servingWeight,
    };
  }

  /// Calculate nutrition for a specific portion size
  NutritionInfo forPortion(double portionMultiplier) {
    return NutritionInfo(
      foodName: foodName,
      calories: calories * portionMultiplier,
      protein: protein * portionMultiplier,
      carbs: carbs * portionMultiplier,
      fat: fat * portionMultiplier,
      fiber: fiber * portionMultiplier,
      sugar: sugar * portionMultiplier,
      sodium: sodium * portionMultiplier,
      servingSize: servingSize,
      servingWeight: servingWeight * portionMultiplier,
    );
  }
}

/// Model for a logged meal item
class MealItem {
  final String id;
  final String foodName;
  final NutritionInfo nutrition;
  final double portionMultiplier;
  final String? imageUrl;
  final String? barcode;
  final FoodRecognitionType recognitionType;
  final DateTime loggedAt;

  MealItem({
    required this.id,
    required this.foodName,
    required this.nutrition,
    required this.portionMultiplier,
    this.imageUrl,
    this.barcode,
    required this.recognitionType,
    required this.loggedAt,
  });

  /// Get the actual nutrition for this portion
  NutritionInfo get actualNutrition => nutrition.forPortion(portionMultiplier);

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['id'] ?? '',
      foodName: json['foodName'] ?? '',
      nutrition: NutritionInfo.fromJson(json['nutrition'] ?? {}),
      portionMultiplier: json['portionMultiplier']?.toDouble() ?? 1.0,
      imageUrl: json['imageUrl'],
      barcode: json['barcode'],
      recognitionType: FoodRecognitionType.values.firstWhere(
        (e) => e.toString() == 'FoodRecognitionType.${json['recognitionType']}',
        orElse: () => FoodRecognitionType.manual,
      ),
      loggedAt: (json['loggedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'nutrition': nutrition.toJson(),
      'portionMultiplier': portionMultiplier,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'recognitionType': recognitionType.toString().split('.').last,
      'loggedAt': Timestamp.fromDate(loggedAt),
    };
  }
}

/// Model for a complete meal
class Meal {
  final String id;
  final String userId;
  final List<MealItem> items;
  final DateTime loggedAt;
  final String mealType; // breakfast, lunch, dinner, snack
  final String? notes;
  final String? imageUrl;

  Meal({
    required this.id,
    required this.userId,
    required this.items,
    required this.loggedAt,
    required this.mealType,
    this.notes,
    this.imageUrl,
  });

  /// Get total nutrition for the entire meal
  NutritionInfo get totalNutrition {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalSugar = 0;
    double totalSodium = 0;
    double totalWeight = 0;

    for (final item in items) {
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
      foodName: 'Total Meal',
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

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List)
          .map((item) => MealItem.fromJson(item))
          .toList(),
      loggedAt: (json['loggedAt'] as Timestamp).toDate(),
      mealType: json['mealType'] ?? 'meal',
      notes: json['notes'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'loggedAt': Timestamp.fromDate(loggedAt),
      'mealType': mealType,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }
}

/// Model for nutrition goals
class NutritionGoals {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  NutritionGoals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionGoals.fromJson(Map<String, dynamic> json) {
    return NutritionGoals(
      calories: json['calories']?.toDouble() ?? 2000.0,
      protein: json['protein']?.toDouble() ?? 150.0,
      carbs: json['carbs']?.toDouble() ?? 250.0,
      fat: json['fat']?.toDouble() ?? 65.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

/// Model for daily nutrition summary
class DailyNutritionSummary {
  final String userId;
  final DateTime date;
  final List<Meal> meals;
  final NutritionInfo totalNutrition;
  final Map<String, int> mealCounts; // mealType -> count

  DailyNutritionSummary({
    required this.userId,
    required this.date,
    required this.meals,
    required this.totalNutrition,
    required this.mealCounts,
  });

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) {
    return DailyNutritionSummary(
      userId: json['userId'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      meals: (json['meals'] as List)
          .map((meal) => Meal.fromJson(meal))
          .toList(),
      totalNutrition: NutritionInfo.fromJson(json['totalNutrition'] ?? {}),
      mealCounts: Map<String, int>.from(json['mealCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'totalNutrition': totalNutrition.toJson(),
      'mealCounts': mealCounts,
    };
  }
}
