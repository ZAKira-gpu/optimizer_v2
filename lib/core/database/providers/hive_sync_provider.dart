import 'package:flutter/foundation.dart';
import '../services/hive_sync_service.dart';

/// Provider that manages automatic synchronization between providers and Hive
class HiveSyncProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isSyncing = false;
  String _error = '';
  Map<String, DateTime> _lastSyncTimes = {};

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;
  String get error => _error;
  Map<String, DateTime> get lastSyncTimes => Map.unmodifiable(_lastSyncTimes);

  /// Initialize the sync provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _clearError();

      await HiveSyncService.initialize();
      _isInitialized = true;

      if (kDebugMode) {
        print('✅ HiveSyncProvider initialized successfully');
      }
    } catch (e) {
      _setError('Failed to initialize sync provider: $e');
      if (kDebugMode) {
        print('❌ HiveSyncProvider initialization failed: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Sync health data
  Future<void> syncHealthData({
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
    if (!_isInitialized) await initialize();

    try {
      _setLoading(true);
      _clearError();

      await HiveSyncService.syncHealthData(
        userId: userId,
        sleepHours: sleepHours,
        steps: steps,
        caloriesIn: caloriesIn,
        caloriesOut: caloriesOut,
        tasksDone: tasksDone,
        goalProgress: goalProgress,
        efficiencyScore: efficiencyScore,
        healthScore: healthScore,
      );

      _updateLastSyncTime('health_$userId');
      notifyListeners();

      if (kDebugMode) {
        print('✅ Health data synced for user: $userId');
      }
    } catch (e) {
      _setError('Failed to sync health data: $e');
      if (kDebugMode) {
        print('❌ Failed to sync health data: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Sync meal data
  Future<void> syncMealData({
    required String userId,
    required String mealId,
    required String mealType,
    required List<Map<String, dynamic>> items,
    DateTime? loggedAt,
    String? notes,
    String? imageUrl,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      _setLoading(true);
      _clearError();

      await HiveSyncService.syncMealData(
        userId: userId,
        mealId: mealId,
        mealType: mealType,
        items: items,
        loggedAt: loggedAt,
        notes: notes,
        imageUrl: imageUrl,
      );

      _updateLastSyncTime('meals_$userId');
      notifyListeners();

      if (kDebugMode) {
        print('✅ Meal data synced: $mealId');
      }
    } catch (e) {
      _setError('Failed to sync meal data: $e');
      if (kDebugMode) {
        print('❌ Failed to sync meal data: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Sync efficiency data
  Future<void> syncEfficiencyData({
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
    if (!_isInitialized) await initialize();

    try {
      _setLoading(true);
      _clearError();

      await HiveSyncService.syncEfficiencyData(
        userId: userId,
        date: date,
        tasks: tasks,
        routines: routines,
        goals: goals,
        completedTasks: completedTasks,
        totalTasks: totalTasks,
        completedPomodoros: completedPomodoros,
        totalFocusMinutes: totalFocusMinutes,
        efficiencyScore: efficiencyScore,
      );

      _updateLastSyncTime('efficiency_$userId');
      notifyListeners();

      if (kDebugMode) {
        print('✅ Efficiency data synced for user: $userId');
      }
    } catch (e) {
      _setError('Failed to sync efficiency data: $e');
      if (kDebugMode) {
        print('❌ Failed to sync efficiency data: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Sync step data
  Future<void> syncStepData({
    required String userId,
    required DateTime date,
    required int steps,
    required double distance,
    required double calories,
    required String status,
    required double userHeight,
    required double userWeight,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      _setLoading(true);
      _clearError();

      await HiveSyncService.syncStepData(
        userId: userId,
        date: date,
        steps: steps,
        distance: distance,
        calories: calories,
        status: status,
        userHeight: userHeight,
        userWeight: userWeight,
      );

      _updateLastSyncTime('steps_$userId');
      notifyListeners();

      if (kDebugMode) {
        print('✅ Step data synced for user: $userId');
      }
    } catch (e) {
      _setError('Failed to sync step data: $e');
      if (kDebugMode) {
        print('❌ Failed to sync step data: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Get all user data from Hive
  Future<Map<String, dynamic>> getAllUserData(String userId) async {
    if (!_isInitialized) await initialize();

    try {
      return await HiveSyncService.getAllUserData(userId);
    } catch (e) {
      _setError('Failed to get user data: $e');
      return {};
    }
  }

  /// Clear all data for a user
  Future<void> clearUserData(String userId) async {
    if (!_isInitialized) await initialize();

    try {
      _setLoading(true);
      _clearError();

      await HiveSyncService.clearUserData(userId);
      _lastSyncTimes.removeWhere((key, value) => key.contains(userId));

      notifyListeners();

      if (kDebugMode) {
        print('✅ All data cleared for user: $userId');
      }
    } catch (e) {
      _setError('Failed to clear user data: $e');
      if (kDebugMode) {
        print('❌ Failed to clear user data: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Force sync all data for a user
  Future<void> forceSyncAll(String userId) async {
    if (!_isInitialized) await initialize();

    try {
      _setLoading(true);
      _clearError();

      await HiveSyncService.forceSyncAll(userId);
      _lastSyncTimes.clear();

      notifyListeners();

      if (kDebugMode) {
        print('✅ Force sync completed for user: $userId');
      }
    } catch (e) {
      _setError('Failed to force sync: $e');
      if (kDebugMode) {
        print('❌ Failed to force sync: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Check if data needs syncing
  bool needsSync(
    String dataType,
    String userId, {
    Duration threshold = const Duration(minutes: 5),
  }) {
    return HiveSyncService.needsSync(dataType, userId, threshold: threshold);
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return HiveSyncService.getSyncStats();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isSyncing = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
  }

  void _updateLastSyncTime(String key) {
    _lastSyncTimes[key] = DateTime.now();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
