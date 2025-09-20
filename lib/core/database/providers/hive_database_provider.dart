import 'package:flutter/foundation.dart';
import '../models/health_data_model.dart';
import '../services/hive_database_service.dart';

/// Provider for managing Hive database operations
class HiveDatabaseProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isLoading = false;
  String _error = '';
  HealthDataModel? _todayData;
  List<HealthDataModel> _weeklyData = [];
  List<HealthDataModel> _monthlyData = [];
  Map<String, dynamic> _weeklySummary = {};
  Map<String, dynamic> _monthlySummary = {};

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String get error => _error;
  HealthDataModel? get todayData => _todayData;
  List<HealthDataModel> get weeklyData => _weeklyData;
  List<HealthDataModel> get monthlyData => _monthlyData;
  Map<String, dynamic> get weeklySummary => _weeklySummary;
  Map<String, dynamic> get monthlySummary => _monthlySummary;

  /// Initialize the Hive database
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _clearError();

      await HiveDatabaseService.initialize();
      _isInitialized = true;

      if (kDebugMode) {
        print('✅ HiveDatabaseProvider initialized successfully');
      }
    } catch (e) {
      _setError('Failed to initialize database: $e');
      if (kDebugMode) {
        print('❌ HiveDatabaseProvider initialization failed: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Load today's data for a user
  Future<void> loadTodayData(String userId) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _setLoading(true);
      _clearError();

      _todayData = await HealthDataRepository.getTodayHealthData(userId);
      notifyListeners();

      if (kDebugMode) {
        print('✅ Today\'s data loaded for user: $userId');
      }
    } catch (e) {
      _setError('Failed to load today\'s data: $e');
      if (kDebugMode) {
        print('❌ Failed to load today\'s data: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Load weekly data for a user
  Future<void> loadWeeklyData(String userId) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _setLoading(true);
      _clearError();

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      _weeklyData = HealthDataRepository.getHealthDataRange(
        userId,
        weekStart,
        weekEnd,
      );

      _weeklySummary = HealthDataRepository.getWeeklySummary(userId);
      notifyListeners();

      if (kDebugMode) {
        print('✅ Weekly data loaded for user: $userId');
      }
    } catch (e) {
      _setError('Failed to load weekly data: $e');
      if (kDebugMode) {
        print('❌ Failed to load weekly data: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Load monthly data for a user
  Future<void> loadMonthlyData(String userId) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _setLoading(true);
      _clearError();

      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);

      _monthlyData = HealthDataRepository.getHealthDataRange(
        userId,
        monthStart,
        monthEnd,
      );

      _monthlySummary = HealthDataRepository.getMonthlySummary(userId);
      notifyListeners();

      if (kDebugMode) {
        print('✅ Monthly data loaded for user: $userId');
      }
    } catch (e) {
      _setError('Failed to load monthly data: $e');
      if (kDebugMode) {
        print('❌ Failed to load monthly data: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Update sleep hours for today
  Future<void> updateSleepHours(String userId, double sleepHours) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await HealthDataRepository.updateHealthDataFields(
        userId,
        DateTime.now(),
        sleepHours: sleepHours,
      );

      await loadTodayData(userId);
      await loadWeeklyData(userId);
      await loadMonthlyData(userId);

      if (kDebugMode) {
        print('✅ Sleep hours updated: $sleepHours');
      }
    } catch (e) {
      _setError('Failed to update sleep hours: $e');
      if (kDebugMode) {
        print('❌ Failed to update sleep hours: $e');
      }
    }
  }

  /// Update steps for today
  Future<void> updateSteps(String userId, int steps) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await HealthDataRepository.updateHealthDataFields(
        userId,
        DateTime.now(),
        steps: steps,
      );

      await loadTodayData(userId);
      await loadWeeklyData(userId);
      await loadMonthlyData(userId);

      if (kDebugMode) {
        print('✅ Steps updated: $steps');
      }
    } catch (e) {
      _setError('Failed to update steps: $e');
      if (kDebugMode) {
        print('❌ Failed to update steps: $e');
      }
    }
  }

  /// Update calories in for today
  Future<void> updateCaloriesIn(String userId, double caloriesIn) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await HealthDataRepository.updateHealthDataFields(
        userId,
        DateTime.now(),
        caloriesIn: caloriesIn,
      );

      await loadTodayData(userId);
      await loadWeeklyData(userId);
      await loadMonthlyData(userId);

      if (kDebugMode) {
        print('✅ Calories in updated: $caloriesIn');
      }
    } catch (e) {
      _setError('Failed to update calories in: $e');
      if (kDebugMode) {
        print('❌ Failed to update calories in: $e');
      }
    }
  }

  /// Update calories out for today
  Future<void> updateCaloriesOut(String userId, double caloriesOut) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await HealthDataRepository.updateHealthDataFields(
        userId,
        DateTime.now(),
        caloriesOut: caloriesOut,
      );

      await loadTodayData(userId);
      await loadWeeklyData(userId);
      await loadMonthlyData(userId);

      if (kDebugMode) {
        print('✅ Calories out updated: $caloriesOut');
      }
    } catch (e) {
      _setError('Failed to update calories out: $e');
      if (kDebugMode) {
        print('❌ Failed to update calories out: $e');
      }
    }
  }

  /// Update tasks done for today
  Future<void> updateTasksDone(String userId, int tasksDone) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await HealthDataRepository.updateHealthDataFields(
        userId,
        DateTime.now(),
        tasksDone: tasksDone,
      );

      await loadTodayData(userId);
      await loadWeeklyData(userId);
      await loadMonthlyData(userId);

      if (kDebugMode) {
        print('✅ Tasks done updated: $tasksDone');
      }
    } catch (e) {
      _setError('Failed to update tasks done: $e');
      if (kDebugMode) {
        print('❌ Failed to update tasks done: $e');
      }
    }
  }

  /// Update goal progress for today
  Future<void> updateGoalProgress(String userId, double goalProgress) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await HealthDataRepository.updateHealthDataFields(
        userId,
        DateTime.now(),
        goalProgress: goalProgress,
      );

      await loadTodayData(userId);
      await loadWeeklyData(userId);
      await loadMonthlyData(userId);

      if (kDebugMode) {
        print('✅ Goal progress updated: $goalProgress');
      }
    } catch (e) {
      _setError('Failed to update goal progress: $e');
      if (kDebugMode) {
        print('❌ Failed to update goal progress: $e');
      }
    }
  }

  /// Update efficiency score for today
  Future<void> updateEfficiencyScore(
    String userId,
    double efficiencyScore,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await HealthDataRepository.updateHealthDataFields(
        userId,
        DateTime.now(),
        efficiencyScore: efficiencyScore,
      );

      await loadTodayData(userId);
      await loadWeeklyData(userId);
      await loadMonthlyData(userId);

      if (kDebugMode) {
        print('✅ Efficiency score updated: $efficiencyScore');
      }
    } catch (e) {
      _setError('Failed to update efficiency score: $e');
      if (kDebugMode) {
        print('❌ Failed to update efficiency score: $e');
      }
    }
  }

  /// Update health score for today
  Future<void> updateHealthScore(String userId, double healthScore) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await HealthDataRepository.updateHealthDataFields(
        userId,
        DateTime.now(),
        healthScore: healthScore,
      );

      await loadTodayData(userId);
      await loadWeeklyData(userId);
      await loadMonthlyData(userId);

      if (kDebugMode) {
        print('✅ Health score updated: $healthScore');
      }
    } catch (e) {
      _setError('Failed to update health score: $e');
      if (kDebugMode) {
        print('❌ Failed to update health score: $e');
      }
    }
  }

  /// Update multiple fields at once
  Future<void> updateMultipleFields(
    String userId, {
    double? sleepHours,
    int? steps,
    double? caloriesIn,
    double? caloriesOut,
    int? tasksDone,
    double? goalProgress,
    double? efficiencyScore,
    double? healthScore,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await HealthDataRepository.updateHealthDataFields(
        userId,
        DateTime.now(),
        sleepHours: sleepHours,
        steps: steps,
        caloriesIn: caloriesIn,
        caloriesOut: caloriesOut,
        tasksDone: tasksDone,
        goalProgress: goalProgress,
        efficiencyScore: efficiencyScore,
        healthScore: healthScore,
      );

      await loadTodayData(userId);
      await loadWeeklyData(userId);
      await loadMonthlyData(userId);

      if (kDebugMode) {
        print('✅ Multiple fields updated successfully');
      }
    } catch (e) {
      _setError('Failed to update multiple fields: $e');
      if (kDebugMode) {
        print('❌ Failed to update multiple fields: $e');
      }
    }
  }

  /// Get data for a specific date
  HealthDataModel? getDataForDate(String userId, DateTime date) {
    if (!_isInitialized) return null;

    try {
      return HealthDataRepository.getHealthData(userId, date);
    } catch (e) {
      _setError('Failed to get data for date: $e');
      return null;
    }
  }

  /// Get data range
  List<HealthDataModel> getDataRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (!_isInitialized) return [];

    try {
      return HealthDataRepository.getHealthDataRange(
        userId,
        startDate,
        endDate,
      );
    } catch (e) {
      _setError('Failed to get data range: $e');
      return [];
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    try {
      await HiveDatabaseService.clearAll();
      _todayData = null;
      _weeklyData.clear();
      _monthlyData.clear();
      _weeklySummary.clear();
      _monthlySummary.clear();
      notifyListeners();

      if (kDebugMode) {
        print('✅ All data cleared');
      }
    } catch (e) {
      _setError('Failed to clear all data: $e');
      if (kDebugMode) {
        print('❌ Failed to clear all data: $e');
      }
    }
  }

  /// Get database statistics
  Map<String, int> getDatabaseStats() {
    if (!_isInitialized) return {};
    return HiveDatabaseService.getDatabaseStats();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
  }

  @override
  void dispose() {
    super.dispose();
  }
}
