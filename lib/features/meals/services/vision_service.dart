import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_models.dart';

/// Service for Google Vision API food recognition
class VisionService {
  static const String _visionApiUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  final String _apiKey;

  VisionService({required String apiKey}) : _apiKey = apiKey;

  /// Analyze image for food recognition using Google Vision API
  Future<FoodRecognitionResult> analyzeImage(File imageFile) async {
    try {
      // Convert image to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Prepare request
      final requestBody = {
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'LABEL_DETECTION', 'maxResults': 10},
              {'type': 'TEXT_DETECTION', 'maxResults': 5},
            ],
          },
        ],
      };

      // Make API call
      final response = await http.post(
        Uri.parse('$_visionApiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseVisionResponse(data);
      } else {
        print('Vision API error: ${response.statusCode} - ${response.body}');
        return FoodRecognitionResult(
          type: FoodRecognitionType.vision,
          suggestions: [],
          confidence: 0.0,
          error: 'API Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error calling Vision API: $e');
      return FoodRecognitionResult(
        type: FoodRecognitionType.vision,
        suggestions: [],
        confidence: 0.0,
        error: 'Network Error: $e',
      );
    }
  }

  /// Parse Google Vision API response
  FoodRecognitionResult _parseVisionResponse(Map<String, dynamic> data) {
    try {
      final responses = data['responses'] as List? ?? [];
      if (responses.isEmpty) {
        return FoodRecognitionResult(
          type: FoodRecognitionType.vision,
          suggestions: [],
          confidence: 0.0,
          error: 'No response from Vision API',
        );
      }

      final response = responses.first;
      final labelAnnotations = response['labelAnnotations'] as List? ?? [];
      final textAnnotations = response['textAnnotations'] as List? ?? [];

      // Extract food-related labels
      final foodSuggestions = <FoodSuggestion>[];

      for (final label in labelAnnotations) {
        final description = label['description'] as String? ?? '';
        final score = label['score']?.toDouble() ?? 0.0;

        // Filter for food-related labels
        if (_isFoodRelated(description) && score > 0.3) {
          foodSuggestions.add(
            FoodSuggestion(
              name: description,
              confidence: score,
              category: _getFoodCategory(description),
              description: description,
            ),
          );
        }
      }

      // Extract text that might be food names
      for (final text in textAnnotations) {
        final description = text['description'] as String? ?? '';
        if (_isFoodRelated(description) && description.length > 2) {
          foodSuggestions.add(
            FoodSuggestion(
              name: description,
              confidence: 0.6, // Lower confidence for text detection
              category: _getFoodCategory(description),
              description: description,
            ),
          );
        }
      }

      // Remove duplicates and sort by confidence
      final uniqueSuggestions = <String, FoodSuggestion>{};
      for (final suggestion in foodSuggestions) {
        final key = suggestion.name.toLowerCase();
        if (!uniqueSuggestions.containsKey(key) ||
            uniqueSuggestions[key]!.confidence < suggestion.confidence) {
          uniqueSuggestions[key] = suggestion;
        }
      }

      final sortedSuggestions = uniqueSuggestions.values.toList()
        ..sort((a, b) => b.confidence.compareTo(a.confidence));

      return FoodRecognitionResult(
        type: FoodRecognitionType.vision,
        suggestions: sortedSuggestions.take(5).toList(),
        confidence: sortedSuggestions.isNotEmpty
            ? sortedSuggestions.first.confidence
            : 0.0,
      );
    } catch (e) {
      print('Error parsing Vision API response: $e');
      return FoodRecognitionResult(
        type: FoodRecognitionType.vision,
        suggestions: [],
        confidence: 0.0,
        error: 'Parse Error: $e',
      );
    }
  }

  /// Check if a label is food-related
  bool _isFoodRelated(String label) {
    final foodKeywords = [
      'food',
      'meal',
      'dish',
      'cuisine',
      'recipe',
      'cooking',
      'kitchen',
      'restaurant',
      'cafe',
      'bakery',
      'pizza',
      'burger',
      'sandwich',
      'salad',
      'soup',
      'pasta',
      'rice',
      'bread',
      'cake',
      'cookie',
      'fruit',
      'vegetable',
      'meat',
      'chicken',
      'beef',
      'fish',
      'seafood',
      'dairy',
      'milk',
      'cheese',
      'yogurt',
      'egg',
      'breakfast',
      'lunch',
      'dinner',
      'snack',
      'dessert',
      'beverage',
      'drink',
      'coffee',
      'tea',
      'juice',
      'soda',
      'wine',
      'beer',
      'alcohol',
      'spice',
      'herb',
      'sauce',
      'dressing',
      'condiment',
      'ingredient',
      'nut',
      'seed',
      'grain',
      'cereal',
      'pasta',
      'noodle',
      'sushi',
      'taco',
      'burrito',
      'wrap',
      'roll',
      'pie',
      'tart',
      'muffin',
      'donut',
      'bagel',
      'cracker',
      'chip',
      'popcorn',
      'candy',
      'chocolate',
      'ice cream',
      'frozen',
      'fresh',
      'organic',
      'healthy',
      'diet',
      'nutrition',
    ];

    final labelLower = label.toLowerCase();
    return foodKeywords.any((keyword) => labelLower.contains(keyword));
  }

  /// Get food category from label
  String? _getFoodCategory(String label) {
    final labelLower = label.toLowerCase();

    if (labelLower.contains('fruit') ||
        labelLower.contains('apple') ||
        labelLower.contains('banana') ||
        labelLower.contains('orange')) {
      return 'Fruits';
    } else if (labelLower.contains('vegetable') ||
        labelLower.contains('salad') ||
        labelLower.contains('carrot') ||
        labelLower.contains('tomato')) {
      return 'Vegetables';
    } else if (labelLower.contains('meat') ||
        labelLower.contains('chicken') ||
        labelLower.contains('beef') ||
        labelLower.contains('pork')) {
      return 'Meat';
    } else if (labelLower.contains('fish') ||
        labelLower.contains('seafood') ||
        labelLower.contains('salmon') ||
        labelLower.contains('tuna')) {
      return 'Seafood';
    } else if (labelLower.contains('dairy') ||
        labelLower.contains('milk') ||
        labelLower.contains('cheese') ||
        labelLower.contains('yogurt')) {
      return 'Dairy';
    } else if (labelLower.contains('bread') ||
        labelLower.contains('pasta') ||
        labelLower.contains('rice') ||
        labelLower.contains('grain')) {
      return 'Grains';
    } else if (labelLower.contains('dessert') ||
        labelLower.contains('cake') ||
        labelLower.contains('cookie') ||
        labelLower.contains('candy')) {
      return 'Desserts';
    } else if (labelLower.contains('beverage') ||
        labelLower.contains('drink') ||
        labelLower.contains('coffee') ||
        labelLower.contains('tea')) {
      return 'Beverages';
    }

    return 'Other';
  }

  /// Get confidence color based on confidence score
  static int getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return 0xFF4CAF50; // Green
    if (confidence >= 0.6) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  /// Get confidence description
  static String getConfidenceDescription(double confidence) {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Medium';
    return 'Low';
  }
}
