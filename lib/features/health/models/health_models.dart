import 'package:cloud_firestore/cloud_firestore.dart';

/// Comprehensive health data model containing all health metrics
class HealthData {
  final String userId;
  final DateTime date;
  final StepData stepData;
  final SleepData sleepData;
  final HealthMetrics metrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthData({
    required this.userId,
    required this.date,
    required this.stepData,
    required this.sleepData,
    required this.metrics,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'stepData': stepData.toMap(),
      'sleepData': sleepData.toMap(),
      'metrics': metrics.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory HealthData.fromFirestore(Map<String, dynamic> data) {
    return HealthData(
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      stepData: StepData.fromMap(data['stepData'] ?? {}),
      sleepData: SleepData.fromMap(data['sleepData'] ?? {}),
      metrics: HealthMetrics.fromMap(data['metrics'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Create empty health data for a new day
  factory HealthData.empty(String userId, DateTime date) {
    return HealthData(
      userId: userId,
      date: date,
      stepData: StepData.empty(),
      sleepData: SleepData.empty(),
      metrics: HealthMetrics.empty(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Update with new data
  HealthData copyWith({
    StepData? stepData,
    SleepData? sleepData,
    HealthMetrics? metrics,
  }) {
    return HealthData(
      userId: userId,
      date: date,
      stepData: stepData ?? this.stepData,
      sleepData: sleepData ?? this.sleepData,
      metrics: metrics ?? this.metrics,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Step tracking data model
class StepData {
  final int steps;
  final double distance; // in kilometers
  final double calories;
  final String status; // walking, running, stopped
  final int goal;
  final bool goalAchieved;
  final DateTime? lastUpdated;

  StepData({
    required this.steps,
    required this.distance,
    required this.calories,
    required this.status,
    required this.goal,
    required this.goalAchieved,
    this.lastUpdated,
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'steps': steps,
      'distance': distance,
      'calories': calories,
      'status': status,
      'goal': goal,
      'goalAchieved': goalAchieved,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
    };
  }

  /// Create from map
  factory StepData.fromMap(Map<String, dynamic> data) {
    return StepData(
      steps: data['steps'] ?? 0,
      distance: (data['distance'] ?? 0.0).toDouble(),
      calories: (data['calories'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'stopped',
      goal: data['goal'] ?? 10000,
      goalAchieved: data['goalAchieved'] ?? false,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create empty step data
  factory StepData.empty() {
    return StepData(
      steps: 0,
      distance: 0.0,
      calories: 0.0,
      status: 'stopped',
      goal: 10000,
      goalAchieved: false,
      lastUpdated: null,
    );
  }

  /// Update step data
  StepData copyWith({
    int? steps,
    double? distance,
    double? calories,
    String? status,
    int? goal,
    bool? goalAchieved,
  }) {
    return StepData(
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      status: status ?? this.status,
      goal: goal ?? this.goal,
      goalAchieved: goalAchieved ?? this.goalAchieved,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate progress percentage
  double get progressPercentage {
    if (goal == 0) return 0.0;
    return (steps / goal * 100).clamp(0, 100);
  }

  /// Get formatted distance
  String get formattedDistance {
    if (distance < 1.0) {
      return '${(distance * 1000).round()} m';
    }
    return '${distance.toStringAsFixed(2)} km';
  }

  /// Get formatted calories
  String get formattedCalories {
    return '${calories.toStringAsFixed(0)} kcal';
  }
}

/// Sleep tracking data model
class SleepData {
  final DateTime? sleepStart;
  final DateTime? sleepEnd;
  final double duration; // in hours
  final double quality; // 0-100
  final int totalMovements;
  final int restlessPeriods;
  final double goal; // in hours
  final bool goalAchieved;
  final String qualityDescription;
  final DateTime? lastUpdated;

  SleepData({
    this.sleepStart,
    this.sleepEnd,
    required this.duration,
    required this.quality,
    required this.totalMovements,
    required this.restlessPeriods,
    required this.goal,
    required this.goalAchieved,
    required this.qualityDescription,
    this.lastUpdated,
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'sleepStart': sleepStart != null ? Timestamp.fromDate(sleepStart!) : null,
      'sleepEnd': sleepEnd != null ? Timestamp.fromDate(sleepEnd!) : null,
      'duration': duration,
      'quality': quality,
      'totalMovements': totalMovements,
      'restlessPeriods': restlessPeriods,
      'goal': goal,
      'goalAchieved': goalAchieved,
      'qualityDescription': qualityDescription,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
    };
  }

  /// Create from map
  factory SleepData.fromMap(Map<String, dynamic> data) {
    return SleepData(
      sleepStart: data['sleepStart'] != null
          ? (data['sleepStart'] as Timestamp).toDate()
          : null,
      sleepEnd: data['sleepEnd'] != null
          ? (data['sleepEnd'] as Timestamp).toDate()
          : null,
      duration: (data['duration'] ?? 0.0).toDouble(),
      quality: (data['quality'] ?? 0.0).toDouble(),
      totalMovements: data['totalMovements'] ?? 0,
      restlessPeriods: data['restlessPeriods'] ?? 0,
      goal: (data['goal'] ?? 8.0).toDouble(),
      goalAchieved: data['goalAchieved'] ?? false,
      qualityDescription: data['qualityDescription'] ?? 'Not tracked',
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create empty sleep data
  factory SleepData.empty() {
    return SleepData(
      sleepStart: null,
      sleepEnd: null,
      duration: 0.0,
      quality: 0.0,
      totalMovements: 0,
      restlessPeriods: 0,
      goal: 8.0,
      goalAchieved: false,
      qualityDescription: 'Not tracked',
      lastUpdated: null,
    );
  }

  /// Update sleep data
  SleepData copyWith({
    DateTime? sleepStart,
    DateTime? sleepEnd,
    double? duration,
    double? quality,
    int? totalMovements,
    int? restlessPeriods,
    double? goal,
    bool? goalAchieved,
    String? qualityDescription,
  }) {
    return SleepData(
      sleepStart: sleepStart ?? this.sleepStart,
      sleepEnd: sleepEnd ?? this.sleepEnd,
      duration: duration ?? this.duration,
      quality: quality ?? this.quality,
      totalMovements: totalMovements ?? this.totalMovements,
      restlessPeriods: restlessPeriods ?? this.restlessPeriods,
      goal: goal ?? this.goal,
      goalAchieved: goalAchieved ?? this.goalAchieved,
      qualityDescription: qualityDescription ?? this.qualityDescription,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate progress percentage
  double get progressPercentage {
    if (goal == 0) return 0.0;
    return (duration / goal * 100).clamp(0, 100);
  }

  /// Get formatted duration
  String get formattedDuration {
    if (duration == 0) return '0h 0m';
    final hours = duration.floor();
    final minutes = ((duration - hours) * 60).round();
    return '${hours}h ${minutes}m';
  }

  /// Get quality color
  int get qualityColor {
    if (quality >= 80) return 0xFF4CAF50; // Green
    if (quality >= 60) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }
}

/// General health metrics model
class HealthMetrics {
  final int points;
  final int streak;
  final int longestStreak;
  final double weeklyAverageSteps;
  final double weeklyAverageSleep;
  final double goalAchievementRate;
  final String level;
  final DateTime? lastUpdated;

  HealthMetrics({
    required this.points,
    required this.streak,
    required this.longestStreak,
    required this.weeklyAverageSteps,
    required this.weeklyAverageSleep,
    required this.goalAchievementRate,
    required this.level,
    this.lastUpdated,
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'points': points,
      'streak': streak,
      'longestStreak': longestStreak,
      'weeklyAverageSteps': weeklyAverageSteps,
      'weeklyAverageSleep': weeklyAverageSleep,
      'goalAchievementRate': goalAchievementRate,
      'level': level,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
    };
  }

  /// Create from map
  factory HealthMetrics.fromMap(Map<String, dynamic> data) {
    return HealthMetrics(
      points: data['points'] ?? 0,
      streak: data['streak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      weeklyAverageSteps: (data['weeklyAverageSteps'] ?? 0.0).toDouble(),
      weeklyAverageSleep: (data['weeklyAverageSleep'] ?? 0.0).toDouble(),
      goalAchievementRate: (data['goalAchievementRate'] ?? 0.0).toDouble(),
      level: data['level'] ?? 'beginner',
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create empty health metrics
  factory HealthMetrics.empty() {
    return HealthMetrics(
      points: 0,
      streak: 0,
      longestStreak: 0,
      weeklyAverageSteps: 0.0,
      weeklyAverageSleep: 0.0,
      goalAchievementRate: 0.0,
      level: 'beginner',
      lastUpdated: null,
    );
  }

  /// Update health metrics
  HealthMetrics copyWith({
    int? points,
    int? streak,
    int? longestStreak,
    double? weeklyAverageSteps,
    double? weeklyAverageSleep,
    double? goalAchievementRate,
    String? level,
  }) {
    return HealthMetrics(
      points: points ?? this.points,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      weeklyAverageSteps: weeklyAverageSteps ?? this.weeklyAverageSteps,
      weeklyAverageSleep: weeklyAverageSleep ?? this.weeklyAverageSleep,
      goalAchievementRate: goalAchievementRate ?? this.goalAchievementRate,
      level: level ?? this.level,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate overall health score
  int get overallHealthScore {
    final stepScore = (weeklyAverageSteps / 10000 * 100).clamp(0, 100);
    final sleepScore = (weeklyAverageSleep / 8 * 100).clamp(0, 100);
    final goalScore = goalAchievementRate * 100;

    return ((stepScore * 0.4 + sleepScore * 0.4 + goalScore * 0.2)).round();
  }

  /// Get health level based on score
  String get healthLevel {
    final score = overallHealthScore;
    if (score >= 90) return 'Expert';
    if (score >= 80) return 'Advanced';
    if (score >= 70) return 'Intermediate';
    if (score >= 60) return 'Beginner';
    return 'Novice';
  }

  /// Get formatted points
  String get formattedPoints {
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}k';
    }
    return points.toString();
  }
}

/// Weekly health summary model
class WeeklyHealthSummary {
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<HealthData> dailyData;
  final HealthMetrics weeklyMetrics;
  final DateTime createdAt;

  WeeklyHealthSummary({
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.dailyData,
    required this.weeklyMetrics,
    required this.createdAt,
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'weekStart': Timestamp.fromDate(weekStart),
      'weekEnd': Timestamp.fromDate(weekEnd),
      'dailyData': dailyData.map((data) => data.toFirestore()).toList(),
      'weeklyMetrics': weeklyMetrics.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create from map
  factory WeeklyHealthSummary.fromMap(Map<String, dynamic> data) {
    return WeeklyHealthSummary(
      userId: data['userId'] ?? '',
      weekStart: (data['weekStart'] as Timestamp).toDate(),
      weekEnd: (data['weekEnd'] as Timestamp).toDate(),
      dailyData:
          (data['dailyData'] as List<dynamic>?)
              ?.map((item) => HealthData.fromFirestore(item))
              .toList() ??
          [],
      weeklyMetrics: HealthMetrics.fromMap(data['weeklyMetrics'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Calculate weekly totals
  Map<String, dynamic> get weeklyTotals {
    final totalSteps = dailyData.fold<int>(
      0,
      (sum, data) => sum + data.stepData.steps,
    );
    final totalDistance = dailyData.fold<double>(
      0,
      (sum, data) => sum + data.stepData.distance,
    );
    final totalCalories = dailyData.fold<double>(
      0,
      (sum, data) => sum + data.stepData.calories,
    );
    final totalSleep = dailyData.fold<double>(
      0,
      (sum, data) => sum + data.sleepData.duration,
    );
    final averageQuality = dailyData.isNotEmpty
        ? dailyData.fold<double>(
                0,
                (sum, data) => sum + data.sleepData.quality,
              ) /
              dailyData.length
        : 0.0;

    return {
      'totalSteps': totalSteps,
      'totalDistance': totalDistance,
      'totalCalories': totalCalories,
      'totalSleep': totalSleep,
      'averageQuality': averageQuality,
      'activeDays': dailyData.where((data) => data.stepData.steps > 0).length,
      'goodSleepDays': dailyData
          .where((data) => data.sleepData.quality >= 70)
          .length,
    };
  }
}
