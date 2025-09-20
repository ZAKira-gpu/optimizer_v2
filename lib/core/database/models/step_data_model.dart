import 'package:hive/hive.dart';

part 'step_data_model.g.dart';

/// Hive model for storing step tracking data locally
@HiveType(typeId: 8)
class StepDataModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final int steps;

  @HiveField(4)
  final double distance;

  @HiveField(5)
  final double calories;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final double userHeight;

  @HiveField(8)
  final double userWeight;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  StepDataModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.steps,
    required this.distance,
    required this.calories,
    required this.status,
    required this.userHeight,
    required this.userWeight,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from step tracking data
  factory StepDataModel.fromStepData({
    required String userId,
    required DateTime date,
    required int steps,
    required double distance,
    required double calories,
    required String status,
    required double userHeight,
    required double userWeight,
  }) {
    return StepDataModel(
      id: '${userId}_${date.millisecondsSinceEpoch}',
      userId: userId,
      date: date,
      steps: steps,
      distance: distance,
      calories: calories,
      status: status,
      userHeight: userHeight,
      userWeight: userWeight,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create empty step data
  factory StepDataModel.empty(String userId, DateTime date) {
    return StepDataModel(
      id: '${userId}_${date.millisecondsSinceEpoch}',
      userId: userId,
      date: date,
      steps: 0,
      distance: 0.0,
      calories: 0.0,
      status: 'Unknown',
      userHeight: 1.75,
      userWeight: 70.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated values
  StepDataModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? steps,
    double? distance,
    double? calories,
    String? status,
    double? userHeight,
    double? userWeight,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StepDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      status: status ?? this.status,
      userHeight: userHeight ?? this.userHeight,
      userWeight: userWeight ?? this.userWeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get progress percentage towards daily goal
  double getProgressPercentage(int dailyGoal) {
    if (dailyGoal == 0) return 0.0;
    return (steps / dailyGoal).clamp(0.0, 1.0);
  }

  /// Check if daily goal is achieved
  bool isDailyGoalAchieved(int dailyGoal) {
    return steps >= dailyGoal;
  }

  /// Get formatted distance string
  String getFormattedDistance() {
    if (distance < 1.0) {
      return '${(distance * 1000).round()} m';
    } else {
      return '${distance.toStringAsFixed(2)} km';
    }
  }

  /// Get formatted calories string
  String getFormattedCalories() {
    return '${calories.toStringAsFixed(0)} kcal';
  }
}
