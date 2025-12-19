import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/health_data_model.dart';
import '../models/meal_data_model.dart';
import '../models/efficiency_data_model.dart';
import '../models/step_data_model.dart';
import 'hive_database_service.dart';

/// Service for automatic synchronization between providers and Hive database
class HiveSyncService {
  static bool _isInitialized = false;
  static final Map<String, DateTime> _lastSyncTimes = {};

  /// Initialize the sync service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Register all adapters
      // HealthDataModelAdapter is already registered in HiveDatabaseService
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HealthDataModelAdapter());
      }
      Hive.registerAdapter(MealDataModelAdapter());
      Hive.registerAdapter(MealItemDataAdapter());
      Hive.registerAdapter(NutritionInfoDataAdapter());
      Hive.registerAdapter(EfficiencyDataModelAdapter());
      Hive.registerAdapter(TaskDataAdapter());
      Hive.registerAdapter(RoutineDataAdapter());
      Hive.registerAdapter(GoalDataAdapter());
      Hive.registerAdapter(StepDataModelAdapter());

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ HiveSyncService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize HiveSyncService: $e');
      }
      rethrow;
    }
  }

  /// Sync health data to Hive
  static Future<void> syncHealthData({
    required String userId,
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
      if (!_isInitialized) await initialize();

      final today = DateTime.now();
      final existingData = HealthDataRepository.getHealthData(userId, today);

      if (existingData != null) {
        // Update existing data
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
        await HealthDataRepository.saveHealthData(updatedData);
      } else {
        // Create new data
        final newData = HealthDataModel(
          id: '${userId}_${today.millisecondsSinceEpoch}',
          userId: userId,
          date: today,
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
        await HealthDataRepository.saveHealthData(newData);
      }

      _updateLastSyncTime('health_$userId');

      if (kDebugMode) {
        print('✅ Health data synced to Hive for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to sync health data: $e');
      }
    }
  }

  /// Sync meal data to Hive
  static Future<void> syncMealData({
    required String userId,
    required String mealId,
    required String mealType,
    required List<Map<String, dynamic>> items,
    DateTime? loggedAt,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final box = await Hive.openBox<MealDataModel>('meal_data');

      final mealData = MealDataModel(
        id: mealId,
        userId: userId,
        mealType: mealType,
        items: items.map((item) => MealItemData.fromMap(item)).toList(),
        loggedAt: loggedAt ?? DateTime.now(),
        notes: notes,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await box.put(mealId, mealData);
      _updateLastSyncTime('meals_$userId');

      if (kDebugMode) {
        print('✅ Meal data synced to Hive: $mealId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to sync meal data: $e');
      }
    }
  }

  /// Sync efficiency data to Hive
  static Future<void> syncEfficiencyData({
    required String userId,
    required DateTime date,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> routines,
    required List<Map<String, dynamic>> goals,
    required int completedTasks,
    required int totalTasks,
    required int completedPomodoros,
    required int totalFocusMinutes,
    required double efficiencyScore,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final box = await Hive.openBox<EfficiencyDataModel>('efficiency_data');
      final dataId = '${userId}_${date.millisecondsSinceEpoch}';

      final efficiencyData = EfficiencyDataModel(
        id: dataId,
        userId: userId,
        date: date,
        tasks: tasks.map((task) => TaskData.fromMap(task)).toList(),
        routines: routines
            .map((routine) => RoutineData.fromMap(routine))
            .toList(),
        goals: goals.map((goal) => GoalData.fromMap(goal)).toList(),
        completedTasks: completedTasks,
        totalTasks: totalTasks,
        completedPomodoros: completedPomodoros,
        totalFocusMinutes: totalFocusMinutes,
        efficiencyScore: efficiencyScore,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await box.put(dataId, efficiencyData);
      _updateLastSyncTime('efficiency_$userId');

      if (kDebugMode) {
        print('✅ Efficiency data synced to Hive for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to sync efficiency data: $e');
      }
    }
  }

  /// Sync step data to Hive
  static Future<void> syncStepData({
    required String userId,
    required DateTime date,
    required int steps,
    required double distance,
    required double calories,
    required String status,
    required double userHeight,
    required double userWeight,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final box = await Hive.openBox<StepDataModel>('step_data');
      final dataId = '${userId}_${date.millisecondsSinceEpoch}';

      final stepData = StepDataModel.fromStepData(
        userId: userId,
        date: date,
        steps: steps,
        distance: distance,
        calories: calories,
        status: status,
        userHeight: userHeight,
        userWeight: userWeight,
      );

      await box.put(dataId, stepData);
      _updateLastSyncTime('steps_$userId');

      if (kDebugMode) {
        print('✅ Step data synced to Hive for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to sync step data: $e');
      }
    }
  }

  /// Get health data from Hive
  static HealthDataModel? getHealthData(String userId, DateTime date) {
    try {
      return HealthDataRepository.getHealthData(userId, date);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get health data from Hive: $e');
      }
      return null;
    }
  }

  /// Get meal data from Hive
  static Future<List<MealDataModel>> getMealData(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final box = await Hive.openBox<MealDataModel>('meal_data');
      final allMeals = box.values
          .where((meal) => meal.userId == userId)
          .toList();
      allMeals.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
      return allMeals.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get meal data from Hive: $e');
      }
      return [];
    }
  }

  /// Get efficiency data from Hive
  static Future<EfficiencyDataModel?> getEfficiencyData(
    String userId,
    DateTime date,
  ) async {
    try {
      final box = await Hive.openBox<EfficiencyDataModel>('efficiency_data');
      final dataId = '${userId}_${date.millisecondsSinceEpoch}';
      return box.get(dataId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get efficiency data from Hive: $e');
      }
      return null;
    }
  }

  /// Get step data from Hive
  static Future<StepDataModel?> getStepData(
    String userId,
    DateTime date,
  ) async {
    try {
      final box = await Hive.openBox<StepDataModel>('step_data');
      final dataId = '${userId}_${date.millisecondsSinceEpoch}';
      return box.get(dataId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get step data from Hive: $e');
      }
      return null;
    }
  }

  /// Get all data for a user from Hive
  static Future<Map<String, dynamic>> getAllUserData(String userId) async {
    try {
      final today = DateTime.now();

      final healthData = getHealthData(userId, today);
      final mealData = await getMealData(userId, limit: 10);
      final efficiencyData = await getEfficiencyData(userId, today);
      final stepData = await getStepData(userId, today);

      return {
        'health': healthData,
        'meals': mealData,
        'efficiency': efficiencyData,
        'steps': stepData,
        'lastSync': _lastSyncTimes,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get all user data from Hive: $e');
      }
      return {};
    }
  }

  /// Clear all data for a user
  static Future<void> clearUserData(String userId) async {
    try {
      // Clear health data
      final healthBox = HiveDatabaseService.healthDataBox;
      final healthKeys = healthBox.keys.where(
        (key) => key.toString().startsWith('${userId}_'),
      );
      for (final key in healthKeys) {
        await healthBox.delete(key);
      }

      // Clear meal data
      final mealBox = await Hive.openBox<MealDataModel>('meal_data');
      final mealKeys = mealBox.keys.where((key) {
        final meal = mealBox.get(key);
        return meal?.userId == userId;
      });
      for (final key in mealKeys) {
        await mealBox.delete(key);
      }

      // Clear efficiency data
      final efficiencyBox = await Hive.openBox<EfficiencyDataModel>(
        'efficiency_data',
      );
      final efficiencyKeys = efficiencyBox.keys.where((key) {
        final data = efficiencyBox.get(key);
        return data?.userId == userId;
      });
      for (final key in efficiencyKeys) {
        await efficiencyBox.delete(key);
      }

      // Clear step data
      final stepBox = await Hive.openBox<StepDataModel>('step_data');
      final stepKeys = stepBox.keys.where((key) {
        final data = stepBox.get(key);
        return data?.userId == userId;
      });
      for (final key in stepKeys) {
        await stepBox.delete(key);
      }

      // Clear sync times
      _lastSyncTimes.removeWhere((key, value) => key.contains(userId));

      if (kDebugMode) {
        print('✅ All data cleared for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to clear user data: $e');
      }
    }
  }

  /// Get sync statistics
  static Map<String, dynamic> getSyncStats() {
    return {
      'isInitialized': _isInitialized,
      'lastSyncTimes': Map.from(_lastSyncTimes),
      'totalSyncOperations': _lastSyncTimes.length,
    };
  }

  /// Check if data needs syncing
  static bool needsSync(
    String dataType,
    String userId, {
    Duration threshold = const Duration(minutes: 5),
  }) {
    final key = '${dataType}_$userId';
    final lastSync = _lastSyncTimes[key];

    if (lastSync == null) return true;

    return DateTime.now().difference(lastSync) > threshold;
  }

  /// Update last sync time
  static void _updateLastSyncTime(String key) {
    _lastSyncTimes[key] = DateTime.now();
  }

  /// Force sync all data for a user
  static Future<void> forceSyncAll(String userId) async {
    try {
      // This would typically trigger a full sync from Firestore to Hive
      // Implementation depends on your specific sync strategy
      _lastSyncTimes.clear();

      if (kDebugMode) {
        print('✅ Force sync completed for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to force sync: $e');
      }
    }
  }
}
