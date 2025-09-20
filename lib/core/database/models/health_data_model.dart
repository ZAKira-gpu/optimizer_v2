import 'package:hive/hive.dart';

part 'health_data_model.g.dart';

/// Hive model for storing daily health and productivity data
@HiveType(typeId: 0)
class HealthDataModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final double sleepHours;

  @HiveField(4)
  final int steps;

  @HiveField(5)
  final double caloriesIn;

  @HiveField(6)
  final double caloriesOut;

  @HiveField(7)
  final int tasksDone;

  @HiveField(8)
  final double goalProgress;

  @HiveField(9)
  final double efficiencyScore;

  @HiveField(10)
  final double healthScore;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  HealthDataModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.sleepHours,
    required this.steps,
    required this.caloriesIn,
    required this.caloriesOut,
    required this.tasksDone,
    required this.goalProgress,
    required this.efficiencyScore,
    required this.healthScore,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new HealthDataModel with updated values
  HealthDataModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? sleepHours,
    int? steps,
    double? caloriesIn,
    double? caloriesOut,
    int? tasksDone,
    double? goalProgress,
    double? efficiencyScore,
    double? healthScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      sleepHours: sleepHours ?? this.sleepHours,
      steps: steps ?? this.steps,
      caloriesIn: caloriesIn ?? this.caloriesIn,
      caloriesOut: caloriesOut ?? this.caloriesOut,
      tasksDone: tasksDone ?? this.tasksDone,
      goalProgress: goalProgress ?? this.goalProgress,
      efficiencyScore: efficiencyScore ?? this.efficiencyScore,
      healthScore: healthScore ?? this.healthScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create HealthDataModel from JSON
  factory HealthDataModel.fromJson(Map<String, dynamic> json) {
    return HealthDataModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      sleepHours: (json['sleepHours'] as num).toDouble(),
      steps: json['steps'] as int,
      caloriesIn: (json['caloriesIn'] as num).toDouble(),
      caloriesOut: (json['caloriesOut'] as num).toDouble(),
      tasksDone: json['tasksDone'] as int,
      goalProgress: (json['goalProgress'] as num).toDouble(),
      efficiencyScore: (json['efficiencyScore'] as num).toDouble(),
      healthScore: (json['healthScore'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert HealthDataModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'sleepHours': sleepHours,
      'steps': steps,
      'caloriesIn': caloriesIn,
      'caloriesOut': caloriesOut,
      'tasksDone': tasksDone,
      'goalProgress': goalProgress,
      'efficiencyScore': efficiencyScore,
      'healthScore': healthScore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create empty HealthDataModel for a specific date
  factory HealthDataModel.empty({
    required String userId,
    required DateTime date,
  }) {
    final now = DateTime.now();
    return HealthDataModel(
      id: '${userId}_${date.millisecondsSinceEpoch}',
      userId: userId,
      date: date,
      sleepHours: 0.0,
      steps: 0,
      caloriesIn: 0.0,
      caloriesOut: 0.0,
      tasksDone: 0,
      goalProgress: 0.0,
      efficiencyScore: 0.0,
      healthScore: 0.0,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'HealthDataModel(id: $id, userId: $userId, date: $date, sleepHours: $sleepHours, steps: $steps, caloriesIn: $caloriesIn, caloriesOut: $caloriesOut, tasksDone: $tasksDone, goalProgress: $goalProgress, efficiencyScore: $efficiencyScore, healthScore: $healthScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthDataModel &&
        other.id == id &&
        other.userId == userId &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ date.hashCode;
  }
}
