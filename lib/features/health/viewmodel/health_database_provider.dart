import 'package:flutter/foundation.dart';
import '../models/health_models.dart';
import '../repository/health_repository.dart';

/// Comprehensive health database provider that manages all health data
class HealthDatabaseProvider extends ChangeNotifier {
  final HealthRepository _repository = HealthRepository();

  // Current health data
  HealthData? _currentHealthData;
  List<HealthData> _weeklyData = [];
  List<HealthData> _monthlyData = [];
  WeeklyHealthSummary? _weeklySummary;
  Map<String, dynamic> _healthStatistics = {};
  Map<String, dynamic> _healthGoals = {};

  // Loading states
  bool _isLoading = false;
  bool _isInitialized = false;
  String _error = '';

  // Getters
  HealthData? get currentHealthData => _currentHealthData;
  List<HealthData> get weeklyData => List.unmodifiable(_weeklyData);
  List<HealthData> get monthlyData => List.unmodifiable(_monthlyData);
  WeeklyHealthSummary? get weeklySummary => _weeklySummary;
  Map<String, dynamic> get healthStatistics =>
      Map.unmodifiable(_healthStatistics);
  Map<String, dynamic> get healthGoals => Map.unmodifiable(_healthGoals);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String get error => _error;

  /// Initialize health database
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      // Load current day's data
      await loadCurrentDayData(userId);

      // Load weekly data
      await loadWeeklyData(userId);

      // Load health goals
      await loadHealthGoals(userId);

      _isInitialized = true;
      _error = '';
    } catch (e) {
      _error = 'Error initializing health database: $e';
      print(_error);
    }
    _setLoading(false);
  }

  /// Load current day's health data
  Future<void> loadCurrentDayData(String userId) async {
    try {
      final today = DateTime.now();
      _currentHealthData = await _repository.getDailyHealthData(userId, today);
      notifyListeners();
    } catch (e) {
      _error = 'Error loading current day data: $e';
      notifyListeners();
    }
  }

  /// Load weekly health data
  Future<void> loadWeeklyData(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      _weeklyData = await _repository.getWeeklyHealthData(userId, weekStart);
      _weeklySummary = await _repository.getWeeklySummary(userId, weekStart);
      notifyListeners();
    } catch (e) {
      _error = 'Error loading weekly data: $e';
      notifyListeners();
    }
  }

  /// Load monthly health data
  Future<void> loadMonthlyData(String userId, DateTime monthStart) async {
    try {
      _monthlyData = await _repository.getMonthlyHealthData(userId, monthStart);
      notifyListeners();
    } catch (e) {
      _error = 'Error loading monthly data: $e';
      notifyListeners();
    }
  }

  /// Load health statistics for a date range
  Future<void> loadHealthStatistics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _healthStatistics = await _repository.getHealthStatistics(
        userId,
        startDate,
        endDate,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Error loading health statistics: $e';
      notifyListeners();
    }
  }

  /// Load health goals
  Future<void> loadHealthGoals(String userId) async {
    try {
      _healthGoals = await _repository.getHealthGoals(userId);
      notifyListeners();
    } catch (e) {
      _error = 'Error loading health goals: $e';
      notifyListeners();
    }
  }

  /// Update step data
  Future<bool> updateStepData(
    String userId,
    DateTime date,
    StepData stepData,
  ) async {
    try {
      final success = await _repository.updateStepData(userId, date, stepData);
      if (success) {
        await loadCurrentDayData(userId);
        await loadWeeklyData(userId);
      }
      return success;
    } catch (e) {
      _error = 'Error updating step data: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update sleep data
  Future<bool> updateSleepData(
    String userId,
    DateTime date,
    SleepData sleepData,
  ) async {
    try {
      final success = await _repository.updateSleepData(
        userId,
        date,
        sleepData,
      );
      if (success) {
        await loadCurrentDayData(userId);
        await loadWeeklyData(userId);
      }
      return success;
    } catch (e) {
      _error = 'Error updating sleep data: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update health metrics
  Future<bool> updateHealthMetrics(
    String userId,
    DateTime date,
    HealthMetrics metrics,
  ) async {
    try {
      final success = await _repository.updateHealthMetrics(
        userId,
        date,
        metrics,
      );
      if (success) {
        await loadCurrentDayData(userId);
        await loadWeeklyData(userId);
      }
      return success;
    } catch (e) {
      _error = 'Error updating health metrics: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update health goals
  Future<bool> updateHealthGoals(
    String userId,
    Map<String, dynamic> goals,
  ) async {
    try {
      final success = await _repository.updateHealthGoals(userId, goals);
      if (success) {
        _healthGoals = goals;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Error updating health goals: $e';
      notifyListeners();
      return false;
    }
  }

  /// Save complete health data for a day
  Future<bool> saveDailyHealthData(String userId, HealthData healthData) async {
    try {
      final success = await _repository.saveDailyHealthData(healthData);
      if (success) {
        await loadCurrentDayData(userId);
        await loadWeeklyData(userId);
      }
      return success;
    } catch (e) {
      _error = 'Error saving daily health data: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get health data for a specific date
  Future<HealthData?> getHealthDataForDate(String userId, DateTime date) async {
    try {
      return await _repository.getDailyHealthData(userId, date);
    } catch (e) {
      _error = 'Error getting health data for date: $e';
      notifyListeners();
      return null;
    }
  }

  /// Get current step data
  StepData get currentStepData {
    return _currentHealthData?.stepData ?? StepData.empty();
  }

  /// Get current sleep data
  SleepData get currentSleepData {
    return _currentHealthData?.sleepData ?? SleepData.empty();
  }

  /// Get current health metrics
  HealthMetrics get currentHealthMetrics {
    return _currentHealthData?.metrics ?? HealthMetrics.empty();
  }

  /// Get step goal
  int get stepGoal {
    return _healthGoals['stepGoal'] ?? 10000;
  }

  /// Get sleep goal
  double get sleepGoal {
    return (_healthGoals['sleepGoal'] ?? 8.0).toDouble();
  }

  /// Get user level
  String get userLevel {
    return _healthGoals['level'] ?? 'beginner';
  }

  /// Calculate daily progress
  Map<String, double> get dailyProgress {
    final stepProgress = currentStepData.progressPercentage;
    final sleepProgress = currentSleepData.progressPercentage;
    final overallProgress = (stepProgress + sleepProgress) / 2;

    return {
      'steps': stepProgress,
      'sleep': sleepProgress,
      'overall': overallProgress,
    };
  }

  /// Get weekly averages
  Map<String, double> get weeklyAverages {
    if (_weeklyData.isEmpty) {
      return {
        'steps': 0.0,
        'distance': 0.0,
        'calories': 0.0,
        'sleep': 0.0,
        'quality': 0.0,
      };
    }

    final totalSteps = _weeklyData.fold<int>(
      0,
      (sum, data) => sum + data.stepData.steps,
    );
    final totalDistance = _weeklyData.fold<double>(
      0,
      (sum, data) => sum + data.stepData.distance,
    );
    final totalCalories = _weeklyData.fold<double>(
      0,
      (sum, data) => sum + data.stepData.calories,
    );
    final totalSleep = _weeklyData.fold<double>(
      0,
      (sum, data) => sum + data.sleepData.duration,
    );
    final totalQuality = _weeklyData.fold<double>(
      0,
      (sum, data) => sum + data.sleepData.quality,
    );

    return {
      'steps': totalSteps / _weeklyData.length,
      'distance': totalDistance / _weeklyData.length,
      'calories': totalCalories / _weeklyData.length,
      'sleep': totalSleep / _weeklyData.length,
      'quality': totalQuality / _weeklyData.length,
    };
  }

  /// Get health insights
  List<String> get healthInsights {
    final insights = <String>[];
    final progress = dailyProgress;
    final averages = weeklyAverages;

    // Step insights
    if (progress['steps']! >= 100) {
      insights.add('🎉 Great job! You\'ve exceeded your step goal today!');
    } else if (progress['steps']! >= 80) {
      insights.add('👍 You\'re close to reaching your step goal!');
    } else if (progress['steps']! < 50) {
      insights.add(
        '🚶‍♂️ Try to be more active today to reach your step goal.',
      );
    }

    // Sleep insights
    if (progress['sleep']! >= 100) {
      insights.add('😴 Excellent! You got enough sleep last night.');
    } else if (progress['sleep']! >= 80) {
      insights.add('😊 Good sleep duration, keep it up!');
    } else if (progress['sleep']! < 50) {
      insights.add('😴 Try to get more sleep tonight for better health.');
    }

    // Weekly insights
    if (averages['steps']! > stepGoal * 1.1) {
      insights.add('🏃‍♂️ You\'ve been very active this week!');
    }
    if (averages['sleep']! > sleepGoal * 1.1) {
      insights.add('😴 You\'ve been getting great sleep this week!');
    }

    // Quality insights
    if (averages['quality']! >= 80) {
      insights.add('⭐ Your sleep quality has been excellent this week!');
    } else if (averages['quality']! < 60) {
      insights.add(
        '💤 Consider improving your sleep environment for better quality.',
      );
    }

    return insights;
  }

  /// Get health score (0-100)
  int get healthScore {
    final progress = dailyProgress;
    final averages = weeklyAverages;

    final dailyScore = (progress['overall']! * 0.6);
    final weeklyScore =
        ((averages['steps']! / stepGoal * 100).clamp(0, 100) * 0.2 +
        (averages['sleep']! / sleepGoal * 100).clamp(0, 100) * 0.2);

    return (dailyScore + weeklyScore).round();
  }

  /// Get health level based on score
  String get healthLevel {
    final score = healthScore;
    if (score >= 90) return 'Expert';
    if (score >= 80) return 'Advanced';
    if (score >= 70) return 'Intermediate';
    if (score >= 60) return 'Beginner';
    return 'Novice';
  }

  /// Refresh all data
  Future<void> refresh(String userId) async {
    await loadCurrentDayData(userId);
    await loadWeeklyData(userId);
    await loadHealthGoals(userId);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    super.dispose();
  }
}
