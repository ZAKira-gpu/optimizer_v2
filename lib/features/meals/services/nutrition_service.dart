import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_models.dart';

/// Service for USDA nutrition database integration
class NutritionService {
  static const String _usdaApiUrl = 'https://api.nal.usda.gov/fdc/v1';
  // static const String _usdaApiKey = 'YOUR_USDA_API_KEY'; // You'll need to get this from USDA

  /// Search for foods in USDA database
  Future<List<FoodSuggestion>> searchFoods(String query) async {
    try {
      final url = '$_usdaApiUrl/foods/search';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'pageSize': 20,
          'dataType': ['Foundation', 'SR Legacy'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods'] as List? ?? [];

        return foods.map((food) {
          final description = food['description'] ?? 'Unknown Food';
          final brandOwner = food['brandOwner'];
          final foodName = brandOwner != null
              ? '$description ($brandOwner)'
              : description;

          return FoodSuggestion(
            name: foodName,
            confidence: 0.9, // USDA data is highly reliable
            category: _getFoodCategory(description),
            description: description,
          );
        }).toList();
      }

      return [];
    } catch (e) {
      print('Error searching USDA foods: $e');
      return [];
    }
  }

  /// Get detailed nutrition information for a specific food
  Future<NutritionInfo?> getFoodNutrition(String foodId) async {
    try {
      final url = '$_usdaApiUrl/food/$foodId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseUSDAFood(data);
      }

      return null;
    } catch (e) {
      print('Error fetching USDA nutrition: $e');
      return null;
    }
  }

  /// Parse USDA food data into NutritionInfo
  NutritionInfo _parseUSDAFood(Map<String, dynamic> food) {
    final description = food['description'] ?? 'Unknown Food';
    final brandOwner = food['brandOwner'];
    final foodName = brandOwner != null
        ? '$description ($brandOwner)'
        : description;

    final foodNutrients = food['foodNutrients'] as List? ?? [];

    // Extract nutrition values (per 100g)
    double calories = 0.0;
    double protein = 0.0;
    double carbs = 0.0;
    double fat = 0.0;
    double fiber = 0.0;
    double sugar = 0.0;
    double sodium = 0.0;

    for (final nutrient in foodNutrients) {
      final nutrientData = nutrient['nutrient'];
      if (nutrientData != null) {
        final nutrientId = nutrientData['id'];
        final amount = nutrientData['amount']?.toDouble() ?? 0.0;

        switch (nutrientId) {
          case 1008: // Energy (kcal)
            calories = amount;
            break;
          case 1003: // Protein
            protein = amount;
            break;
          case 1005: // Carbohydrate, by difference
            carbs = amount;
            break;
          case 1004: // Total lipid (fat)
            fat = amount;
            break;
          case 1079: // Fiber, total dietary
            fiber = amount;
            break;
          case 2000: // Sugars, total including NLEA
            sugar = amount;
            break;
          case 1093: // Sodium, Na
            sodium = amount;
            break;
        }
      }
    }

    return NutritionInfo(
      foodName: foodName,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      servingSize: '100g',
      servingWeight: 100.0,
    );
  }

  /// Get food category from description
  String? _getFoodCategory(String description) {
    final descLower = description.toLowerCase();

    if (descLower.contains('fruit') ||
        descLower.contains('apple') ||
        descLower.contains('banana') ||
        descLower.contains('orange')) {
      return 'Fruits';
    } else if (descLower.contains('vegetable') ||
        descLower.contains('salad') ||
        descLower.contains('carrot') ||
        descLower.contains('tomato')) {
      return 'Vegetables';
    } else if (descLower.contains('meat') ||
        descLower.contains('chicken') ||
        descLower.contains('beef') ||
        descLower.contains('pork')) {
      return 'Meat';
    } else if (descLower.contains('fish') ||
        descLower.contains('seafood') ||
        descLower.contains('salmon') ||
        descLower.contains('tuna')) {
      return 'Seafood';
    } else if (descLower.contains('dairy') ||
        descLower.contains('milk') ||
        descLower.contains('cheese') ||
        descLower.contains('yogurt')) {
      return 'Dairy';
    } else if (descLower.contains('bread') ||
        descLower.contains('pasta') ||
        descLower.contains('rice') ||
        descLower.contains('grain')) {
      return 'Grains';
    } else if (descLower.contains('dessert') ||
        descLower.contains('cake') ||
        descLower.contains('cookie') ||
        descLower.contains('candy')) {
      return 'Desserts';
    } else if (descLower.contains('beverage') ||
        descLower.contains('drink') ||
        descLower.contains('coffee') ||
        descLower.contains('tea')) {
      return 'Beverages';
    }

    return 'Other';
  }

  /// Create a basic nutrition info for manual entry
  static NutritionInfo createBasicNutrition(String foodName) {
    return NutritionInfo(
      foodName: foodName,
      calories: 0.0,
      protein: 0.0,
      carbs: 0.0,
      fat: 0.0,
      fiber: 0.0,
      sugar: 0.0,
      sodium: 0.0,
      servingSize: '100g',
      servingWeight: 100.0,
    );
  }
}
