import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/health_data_model.dart';

/// Hive database service for managing health and productivity data
class HiveDatabaseService {
  static const String _healthDataBoxName = 'health_data';
  static const String _userSettingsBoxName = 'user_settings';

  static Box<HealthDataModel>? _healthDataBox;
  static Box<Map>? _userSettingsBox;

  static bool _isInitialized = false;

  /// Initialize Hive database
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Register adapters
      Hive.registerAdapter(HealthDataModelAdapter());

      // Open boxes
      _healthDataBox = await Hive.openBox<HealthDataModel>(_healthDataBoxName);
      _userSettingsBox = await Hive.openBox<Map>(_userSettingsBoxName);

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ Hive database initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize Hive database: $e');
      }
      rethrow;
    }
  }

  /// Get health data box
  static Box<HealthDataModel> get healthDataBox {
    if (_healthDataBox == null) {
      throw Exception(
        'Hive database not initialized. Call initialize() first.',
      );
    }
    return _healthDataBox!;
  }

  /// Get user settings box
  static Box<Map> get userSettingsBox {
    if (_userSettingsBox == null) {
      throw Exception(
        'Hive database not initialized. Call initialize() first.',
      );
    }
    return _userSettingsBox!;
  }

  /// Check if database is initialized
  static bool get isInitialized => _isInitialized;

  /// Close all boxes
  static Future<void> close() async {
    await _healthDataBox?.close();
    await _userSettingsBox?.close();
    _isInitialized = false;
  }

  /// Clear all data
  static Future<void> clearAll() async {
    await _healthDataBox?.clear();
    await _userSettingsBox?.clear();
  }

  /// Get database statistics
  static Map<String, int> getDatabaseStats() {
    return {
      'healthDataCount': _healthDataBox?.length ?? 0,
      'userSettingsCount': _userSettingsBox?.length ?? 0,
    };
  }
}

/// Health Data Repository for CRUD operations
class HealthDataRepository {
  /// Save or update health data for a specific date
  static Future<void> saveHealthData(HealthDataModel healthData) async {
    try {
      final box = HiveDatabaseService.healthDataBox;
      await box.put(healthData.id, healthData);

      if (kDebugMode) {
        print('✅ Health data saved: ${healthData.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save health data: $e');
      }
      rethrow;
    }
  }

  /// Get health data for a specific date
  static HealthDataModel? getHealthData(String userId, DateTime date) {
    try {
      final box = HiveDatabaseService.healthDataBox;
      final id = '${userId}_${date.millisecondsSinceEpoch}';
      return box.get(id);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get health data: $e');
      }
      return null;
    }
  }

  /// Get health data for a date range
  static List<HealthDataModel> getHealthDataRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      final box = HiveDatabaseService.healthDataBox;
      final allData = box.values.toList();

      return allData.where((data) {
        return data.userId == userId &&
            data.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            data.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList()..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get health data range: $e');
      }
      return [];
    }
  }

  /// Get all health data for a user
  static List<HealthDataModel> getAllHealthData(String userId) {
    try {
      final box = HiveDatabaseService.healthDataBox;
      final allData = box.values.toList();

      return allData.where((data) => data.userId == userId).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get all health data: $e');
      }
      return [];
    }
  }

  /// Get today's health data or create empty one
  static Future<HealthDataModel> getTodayHealthData(String userId) async {
    final today = DateTime.now();
    final todayData = getHealthData(userId, today);

    if (todayData != null) {
      return todayData;
    }

    // Create empty data for today
    final emptyData = HealthDataModel.empty(userId: userId, date: today);
    await saveHealthData(emptyData);
    return emptyData;
  }

  /// Update specific fields of health data
  static Future<void> updateHealthDataFields(
    String userId,
    DateTime date, {
    double? sleepHours,
    int? steps,
    double? caloriesIn,
    double? caloriesOut,
    int? tasksDone,
    double? goalProgress,
    double? efficiencyScore,
    double? healthScore,
  }) async {
    try {
      final existingData = getHealthData(userId, date);

      if (existingData != null) {
        final updatedData = existingData.copyWith(
          sleepHours: sleepHours,
          steps: steps,
          caloriesIn: caloriesIn,
          caloriesOut: caloriesOut,
          tasksDone: tasksDone,
          goalProgress: goalProgress,
          efficiencyScore: efficiencyScore,
          healthScore: healthScore,
          updatedAt: DateTime.now(),
        );
        await saveHealthData(updatedData);
      } else {
        // Create new data with provided values
        final newData = HealthDataModel(
          id: '${userId}_${date.millisecondsSinceEpoch}',
          userId: userId,
          date: date,
          sleepHours: sleepHours ?? 0.0,
          steps: steps ?? 0,
          caloriesIn: caloriesIn ?? 0.0,
          caloriesOut: caloriesOut ?? 0.0,
          tasksDone: tasksDone ?? 0,
          goalProgress: goalProgress ?? 0.0,
          efficiencyScore: efficiencyScore ?? 0.0,
          healthScore: healthScore ?? 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await saveHealthData(newData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update health data fields: $e');
      }
      rethrow;
    }
  }

  /// Delete health data for a specific date
  static Future<void> deleteHealthData(String userId, DateTime date) async {
    try {
      final box = HiveDatabaseService.healthDataBox;
      final id = '${userId}_${date.millisecondsSinceEpoch}';
      await box.delete(id);

      if (kDebugMode) {
        print('✅ Health data deleted: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to delete health data: $e');
      }
      rethrow;
    }
  }

  /// Get weekly summary
  static Map<String, dynamic> getWeeklySummary(String userId) {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final weekData = getHealthDataRange(userId, weekStart, weekEnd);

      if (weekData.isEmpty) {
        return {
          'avgSleepHours': 0.0,
          'totalSteps': 0,
          'avgCaloriesIn': 0.0,
          'avgCaloriesOut': 0.0,
          'totalTasksDone': 0,
          'avgGoalProgress': 0.0,
          'avgEfficiencyScore': 0.0,
          'avgHealthScore': 0.0,
          'daysTracked': 0,
        };
      }

      final totalSleep = weekData.fold(
        0.0,
        (sum, data) => sum + data.sleepHours,
      );
      final totalSteps = weekData.fold(0, (sum, data) => sum + data.steps);
      final totalCaloriesIn = weekData.fold(
        0.0,
        (sum, data) => sum + data.caloriesIn,
      );
      final totalCaloriesOut = weekData.fold(
        0.0,
        (sum, data) => sum + data.caloriesOut,
      );
      final totalTasks = weekData.fold(0, (sum, data) => sum + data.tasksDone);
      final totalGoalProgress = weekData.fold(
        0.0,
        (sum, data) => sum + data.goalProgress,
      );
      final totalEfficiency = weekData.fold(
        0.0,
        (sum, data) => sum + data.efficiencyScore,
      );
      final totalHealth = weekData.fold(
        0.0,
        (sum, data) => sum + data.healthScore,
      );

      final daysCount = weekData.length;

      return {
        'avgSleepHours': totalSleep / daysCount,
        'totalSteps': totalSteps,
        'avgCaloriesIn': totalCaloriesIn / daysCount,
        'avgCaloriesOut': totalCaloriesOut / daysCount,
        'totalTasksDone': totalTasks,
        'avgGoalProgress': totalGoalProgress / daysCount,
        'avgEfficiencyScore': totalEfficiency / daysCount,
        'avgHealthScore': totalHealth / daysCount,
        'daysTracked': daysCount,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get weekly summary: $e');
      }
      return {};
    }
  }

  /// Get monthly summary
  static Map<String, dynamic> getMonthlySummary(String userId) {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);

      final monthData = getHealthDataRange(userId, monthStart, monthEnd);

      if (monthData.isEmpty) {
        return {
          'avgSleepHours': 0.0,
          'totalSteps': 0,
          'avgCaloriesIn': 0.0,
          'avgCaloriesOut': 0.0,
          'totalTasksDone': 0,
          'avgGoalProgress': 0.0,
          'avgEfficiencyScore': 0.0,
          'avgHealthScore': 0.0,
          'daysTracked': 0,
        };
      }

      final totalSleep = monthData.fold(
        0.0,
        (sum, data) => sum + data.sleepHours,
      );
      final totalSteps = monthData.fold(0, (sum, data) => sum + data.steps);
      final totalCaloriesIn = monthData.fold(
        0.0,
        (sum, data) => sum + data.caloriesIn,
      );
      final totalCaloriesOut = monthData.fold(
        0.0,
        (sum, data) => sum + data.caloriesOut,
      );
      final totalTasks = monthData.fold(0, (sum, data) => sum + data.tasksDone);
      final totalGoalProgress = monthData.fold(
        0.0,
        (sum, data) => sum + data.goalProgress,
      );
      final totalEfficiency = monthData.fold(
        0.0,
        (sum, data) => sum + data.efficiencyScore,
      );
      final totalHealth = monthData.fold(
        0.0,
        (sum, data) => sum + data.healthScore,
      );

      final daysCount = monthData.length;

      return {
        'avgSleepHours': totalSleep / daysCount,
        'totalSteps': totalSteps,
        'avgCaloriesIn': totalCaloriesIn / daysCount,
        'avgCaloriesOut': totalCaloriesOut / daysCount,
        'totalTasksDone': totalTasks,
        'avgGoalProgress': totalGoalProgress / daysCount,
        'avgEfficiencyScore': totalEfficiency / daysCount,
        'avgHealthScore': totalHealth / daysCount,
        'daysTracked': daysCount,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get monthly summary: $e');
      }
      return {};
    }
  }
}
