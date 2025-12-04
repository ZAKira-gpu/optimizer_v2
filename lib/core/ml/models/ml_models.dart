/// ML Models for score calculation
///
/// This file contains data models for ML input and output

/// Input data for ML model
class MLInputData {
  // Health metrics
  final int steps;
  final double sleepHours;
  final double caloriesIn;
  final double caloriesOut;
  final double waterIntake;
  final double heartRate;
  final double bloodPressure;
  final double weight;
  final double height;
  final int age;
  final String gender;

  // Efficiency metrics
  final int completedTasks;
  final int totalTasks;
  final int completedPomodoros;
  final int totalFocusMinutes;
  final double efficiencyScore;
  final int completedRoutines;
  final int totalRoutines;

  // Lifestyle metrics
  final double screenTime;
  final double exerciseMinutes;
  final int socialInteractions;
  final double stressLevel;
  final String mood;
  final double productivityScore;
  final int mealsLogged;
  final double nutritionScore;

  const MLInputData({
    required this.steps,
    required this.sleepHours,
    required this.caloriesIn,
    required this.caloriesOut,
    required this.waterIntake,
    required this.heartRate,
    required this.bloodPressure,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.completedTasks,
    required this.totalTasks,
    required this.completedPomodoros,
    required this.totalFocusMinutes,
    required this.efficiencyScore,
    required this.completedRoutines,
    required this.totalRoutines,
    required this.screenTime,
    required this.exerciseMinutes,
    required this.socialInteractions,
    required this.stressLevel,
    required this.mood,
    required this.productivityScore,
    required this.mealsLogged,
    required this.nutritionScore,
  });

  /// Convert to list for ML model input
  List<double> toList() {
    return [
      steps.toDouble(),
      sleepHours,
      caloriesIn,
      caloriesOut,
      waterIntake,
      heartRate,
      bloodPressure,
      weight,
      height,
      age.toDouble(),
      _genderToNumber(gender),
      completedTasks.toDouble(),
      totalTasks.toDouble(),
      completedPomodoros.toDouble(),
      totalFocusMinutes.toDouble(),
      efficiencyScore,
      completedRoutines.toDouble(),
      totalRoutines.toDouble(),
      screenTime,
      exerciseMinutes,
      socialInteractions.toDouble(),
      stressLevel,
      _moodToNumber(mood),
      productivityScore,
      mealsLogged.toDouble(),
      nutritionScore,
    ];
  }

  /// Convert gender string to number
  double _genderToNumber(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 1.0;
      case 'female':
        return 0.0;
      default:
        return 0.5; // Other/Prefer not to say
    }
  }

  /// Convert mood string to number
  double _moodToNumber(String mood) {
    switch (mood.toLowerCase()) {
      case 'excellent':
        return 5.0;
      case 'good':
        return 4.0;
      case 'okay':
        return 3.0;
      case 'poor':
        return 2.0;
      case 'terrible':
        return 1.0;
      default:
        return 3.0; // Default to neutral
    }
  }

  /// Create from existing data
  factory MLInputData.fromUserData({
    required int steps,
    required double sleepHours,
    required double caloriesIn,
    required double caloriesOut,
    required double waterIntake,
    required double heartRate,
    required double bloodPressure,
    required double weight,
    required double height,
    required int age,
    required String gender,
    required int completedTasks,
    required int totalTasks,
    required int completedPomodoros,
    required int totalFocusMinutes,
    required double efficiencyScore,
    required int completedRoutines,
    required int totalRoutines,
    required double screenTime,
    required double exerciseMinutes,
    required int socialInteractions,
    required double stressLevel,
    required String mood,
    required double productivityScore,
    required int mealsLogged,
    required double nutritionScore,
  }) {
    return MLInputData(
      steps: steps,
      sleepHours: sleepHours,
      caloriesIn: caloriesIn,
      caloriesOut: caloriesOut,
      waterIntake: waterIntake,
      heartRate: heartRate,
      bloodPressure: bloodPressure,
      weight: weight,
      height: height,
      age: age,
      gender: gender,
      completedTasks: completedTasks,
      totalTasks: totalTasks,
      completedPomodoros: completedPomodoros,
      totalFocusMinutes: totalFocusMinutes,
      efficiencyScore: efficiencyScore,
      completedRoutines: completedRoutines,
      totalRoutines: totalRoutines,
      screenTime: screenTime,
      exerciseMinutes: exerciseMinutes,
      socialInteractions: socialInteractions,
      stressLevel: stressLevel,
      mood: mood,
      productivityScore: productivityScore,
      mealsLogged: mealsLogged,
      nutritionScore: nutritionScore,
    );
  }
}

/// Output data from ML model
class MLOutputData {
  final double healthScore;
  final double efficiencyScore;
  final double lifestyleScore;
  final double overallScore;
  final List<String> recommendations;
  final Map<String, double> scoreBreakdown;

  const MLOutputData({
    required this.healthScore,
    required this.efficiencyScore,
    required this.lifestyleScore,
    required this.overallScore,
    required this.recommendations,
    required this.scoreBreakdown,
  });

  /// Create from ML model output
  factory MLOutputData.fromModelOutput(List<double> output) {
    if (output.length < 4) {
      throw ArgumentError('Invalid model output length: ${output.length}');
    }

    final healthScore = (output[0] * 100).clamp(0.0, 100.0);
    final efficiencyScore = (output[1] * 100).clamp(0.0, 100.0);
    final lifestyleScore = (output[2] * 100).clamp(0.0, 100.0);
    final overallScore = (output[3] * 100).clamp(0.0, 100.0);

    // Generate recommendations based on scores
    final recommendations = _generateRecommendations(
      healthScore,
      efficiencyScore,
      lifestyleScore,
    );

    // Create score breakdown
    final scoreBreakdown = {
      'health': healthScore,
      'efficiency': efficiencyScore,
      'lifestyle': lifestyleScore,
      'overall': overallScore,
    };

    return MLOutputData(
      healthScore: healthScore,
      efficiencyScore: efficiencyScore,
      lifestyleScore: lifestyleScore,
      overallScore: overallScore,
      recommendations: recommendations,
      scoreBreakdown: scoreBreakdown,
    );
  }

  /// Generate recommendations based on scores
  static List<String> _generateRecommendations(
    double healthScore,
    double efficiencyScore,
    double lifestyleScore,
  ) {
    final recommendations = <String>[];

    // Health recommendations
    if (healthScore < 60) {
      recommendations.add('Focus on improving your health metrics');
      recommendations.add('Aim for 7-9 hours of sleep daily');
      recommendations.add('Increase daily step count to 10,000+');
    } else if (healthScore < 80) {
      recommendations.add('Good health progress! Keep it up');
      recommendations.add('Consider adding more variety to your exercise');
    } else {
      recommendations.add('Excellent health! Maintain your current routine');
    }

    // Efficiency recommendations
    if (efficiencyScore < 60) {
      recommendations.add('Improve task completion rate');
      recommendations.add('Use Pomodoro technique for better focus');
      recommendations.add('Break down large tasks into smaller ones');
    } else if (efficiencyScore < 80) {
      recommendations.add('Good productivity! Try time-blocking');
      recommendations.add('Consider optimizing your daily routines');
    } else {
      recommendations.add('Great efficiency! You\'re doing amazing');
    }

    // Lifestyle recommendations
    if (lifestyleScore < 60) {
      recommendations.add(
        'Reduce screen time and increase social interactions',
      );
      recommendations.add('Focus on work-life balance');
      recommendations.add('Practice stress management techniques');
    } else if (lifestyleScore < 80) {
      recommendations.add('Good lifestyle balance! Keep it up');
      recommendations.add('Consider adding more outdoor activities');
    } else {
      recommendations.add('Excellent lifestyle! You\'re living well');
    }

    return recommendations;
  }

  /// Get score level description
  String getScoreLevel(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    if (score >= 50) return 'Poor';
    return 'Very Poor';
  }

  /// Get score color
  int getScoreColor(double score) {
    if (score >= 80) return 0xFF4CAF50; // Green
    if (score >= 60) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'healthScore': healthScore,
      'efficiencyScore': efficiencyScore,
      'lifestyleScore': lifestyleScore,
      'overallScore': overallScore,
      'recommendations': recommendations,
      'scoreBreakdown': scoreBreakdown,
    };
  }

  /// Create from JSON
  factory MLOutputData.fromJson(Map<String, dynamic> json) {
    return MLOutputData(
      healthScore: (json['healthScore'] as num).toDouble(),
      efficiencyScore: (json['efficiencyScore'] as num).toDouble(),
      lifestyleScore: (json['lifestyleScore'] as num).toDouble(),
      overallScore: (json['overallScore'] as num).toDouble(),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      scoreBreakdown: Map<String, double>.from(
        (json['scoreBreakdown'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
    );
  }
}

/// Score calculation request
class ScoreCalculationRequest {
  final String userId;
  final DateTime date;
  final MLInputData inputData;
  final String modelVersion;

  const ScoreCalculationRequest({
    required this.userId,
    required this.date,
    required this.inputData,
    this.modelVersion = '1.0',
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'inputData': inputData.toList(),
      'modelVersion': modelVersion,
    };
  }
}

/// Score calculation result
class ScoreCalculationResult {
  final String userId;
  final DateTime date;
  final MLOutputData scores;
  final String modelVersion;
  final DateTime calculatedAt;
  final bool isCached;

  const ScoreCalculationResult({
    required this.userId,
    required this.date,
    required this.scores,
    required this.modelVersion,
    required this.calculatedAt,
    this.isCached = false,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'scores': scores.toJson(),
      'modelVersion': modelVersion,
      'calculatedAt': calculatedAt.toIso8601String(),
      'isCached': isCached,
    };
  }

  /// Create from JSON
  factory ScoreCalculationResult.fromJson(Map<String, dynamic> json) {
    return ScoreCalculationResult(
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      scores: MLOutputData.fromJson(json['scores'] as Map<String, dynamic>),
      modelVersion: json['modelVersion'] as String,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
      isCached: json['isCached'] as bool? ?? false,
    );
  }

  /// Create a copy with updated fields
  ScoreCalculationResult copyWith({
    String? userId,
    DateTime? date,
    MLOutputData? scores,
    String? modelVersion,
    DateTime? calculatedAt,
    bool? isCached,
  }) {
    return ScoreCalculationResult(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      scores: scores ?? this.scores,
      modelVersion: modelVersion ?? this.modelVersion,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      isCached: isCached ?? this.isCached,
    );
  }
}
