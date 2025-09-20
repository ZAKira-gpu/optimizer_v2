import 'package:hive/hive.dart';

part 'meal_data_model.g.dart';

/// Hive model for storing meal data locally
@HiveType(typeId: 1)
class MealDataModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String mealType;

  @HiveField(3)
  final List<MealItemData> items;

  @HiveField(4)
  final DateTime loggedAt;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final String? imageUrl;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  MealDataModel({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.items,
    required this.loggedAt,
    this.notes,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore Meal model
  factory MealDataModel.fromMeal(Map<String, dynamic> mealData) {
    return MealDataModel(
      id: mealData['id'] ?? '',
      userId: mealData['userId'] ?? '',
      mealType: mealData['mealType'] ?? 'breakfast',
      items: (mealData['items'] as List<dynamic>? ?? [])
          .map((item) => MealItemData.fromMap(item))
          .toList(),
      loggedAt: mealData['loggedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(mealData['loggedAt'])
          : DateTime.now(),
      notes: mealData['notes'],
      imageUrl: mealData['imageUrl'],
      createdAt: mealData['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(mealData['createdAt'])
          : DateTime.now(),
      updatedAt: mealData['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(mealData['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'mealType': mealType,
      'items': items.map((item) => item.toMap()).toList(),
      'loggedAt': loggedAt.millisecondsSinceEpoch,
      'notes': notes,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create empty meal data
  factory MealDataModel.empty(String userId, String mealType) {
    return MealDataModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      mealType: mealType,
      items: [],
      loggedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated values
  MealDataModel copyWith({
    String? id,
    String? userId,
    String? mealType,
    List<MealItemData>? items,
    DateTime? loggedAt,
    String? notes,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealType: mealType ?? this.mealType,
      items: items ?? this.items,
      loggedAt: loggedAt ?? this.loggedAt,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Hive model for meal item data
@HiveType(typeId: 2)
class MealItemData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String foodName;

  @HiveField(2)
  final NutritionInfoData nutrition;

  @HiveField(3)
  final double portionMultiplier;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final String? barcode;

  @HiveField(6)
  final String recognitionType;

  @HiveField(7)
  final DateTime loggedAt;

  MealItemData({
    required this.id,
    required this.foodName,
    required this.nutrition,
    required this.portionMultiplier,
    this.imageUrl,
    this.barcode,
    required this.recognitionType,
    required this.loggedAt,
  });

  /// Create from map
  factory MealItemData.fromMap(Map<String, dynamic> data) {
    return MealItemData(
      id: data['id'] ?? '',
      foodName: data['foodName'] ?? '',
      nutrition: NutritionInfoData.fromMap(data['nutrition'] ?? {}),
      portionMultiplier: (data['portionMultiplier'] ?? 1.0).toDouble(),
      imageUrl: data['imageUrl'],
      barcode: data['barcode'],
      recognitionType: data['recognitionType'] ?? 'manual',
      loggedAt: data['loggedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['loggedAt'])
          : DateTime.now(),
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodName': foodName,
      'nutrition': nutrition.toMap(),
      'portionMultiplier': portionMultiplier,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'recognitionType': recognitionType,
      'loggedAt': loggedAt.millisecondsSinceEpoch,
    };
  }
}

/// Hive model for nutrition information
@HiveType(typeId: 3)
class NutritionInfoData extends HiveObject {
  @HiveField(0)
  final String foodName;

  @HiveField(1)
  final double calories;

  @HiveField(2)
  final double protein;

  @HiveField(3)
  final double carbs;

  @HiveField(4)
  final double fat;

  @HiveField(5)
  final double fiber;

  @HiveField(6)
  final double sugar;

  @HiveField(7)
  final double sodium;

  @HiveField(8)
  final String servingSize;

  @HiveField(9)
  final double servingWeight;

  NutritionInfoData({
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

  /// Create from map
  factory NutritionInfoData.fromMap(Map<String, dynamic> data) {
    return NutritionInfoData(
      foodName: data['foodName'] ?? '',
      calories: (data['calories'] ?? 0.0).toDouble(),
      protein: (data['protein'] ?? 0.0).toDouble(),
      carbs: (data['carbs'] ?? 0.0).toDouble(),
      fat: (data['fat'] ?? 0.0).toDouble(),
      fiber: (data['fiber'] ?? 0.0).toDouble(),
      sugar: (data['sugar'] ?? 0.0).toDouble(),
      sodium: (data['sodium'] ?? 0.0).toDouble(),
      servingSize: data['servingSize'] ?? '100g',
      servingWeight: (data['servingWeight'] ?? 100.0).toDouble(),
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
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
}
