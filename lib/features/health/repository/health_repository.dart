import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_models.dart';

/// Repository for managing health data in Firestore
class HealthRepository {
  static const String _healthDataCollection = 'healthData';
  static const String _weeklySummariesCollection = 'weeklyHealthSummaries';
  static const String _userProfilesCollection = 'userProfiles';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save daily health data
  Future<bool> saveDailyHealthData(HealthData healthData) async {
    try {
      final dateKey = _getDateKey(healthData.date);

      await _firestore
          .collection(_healthDataCollection)
          .doc(healthData.userId)
          .collection('dailyData')
          .doc(dateKey)
          .set(healthData.toFirestore());

      // Update weekly summary
      await _updateWeeklySummary(healthData.userId, healthData.date);

      return true;
    } catch (e) {
      print('Error saving daily health data: $e');
      return false;
    }
  }

  /// Get daily health data
  Future<HealthData?> getDailyHealthData(String userId, DateTime date) async {
    try {
      final dateKey = _getDateKey(date);

      final doc = await _firestore
          .collection(_healthDataCollection)
          .doc(userId)
          .collection('dailyData')
          .doc(dateKey)
          .get();

      if (doc.exists) {
        return HealthData.fromFirestore(doc.data()!);
      }

      // Return empty data if not found
      return HealthData.empty(userId, date);
    } catch (e) {
      print('Error getting daily health data: $e');
      return null;
    }
  }

  /// Get weekly health data
  Future<List<HealthData>> getWeeklyHealthData(
    String userId,
    DateTime weekStart,
  ) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 6));
      final dateKeyStart = _getDateKey(weekStart);
      final dateKeyEnd = _getDateKey(weekEnd);

      final query = await _firestore
          .collection(_healthDataCollection)
          .doc(userId)
          .collection('dailyData')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: dateKeyStart)
          .where(FieldPath.documentId, isLessThanOrEqualTo: dateKeyEnd)
          .orderBy(FieldPath.documentId)
          .get();

      final healthDataList = query.docs
          .map((doc) => HealthData.fromFirestore(doc.data()))
          .toList();

      // Fill in missing days with empty data
      final completeWeek = <HealthData>[];
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final existingData = healthDataList.firstWhere(
          (data) => _isSameDay(data.date, date),
          orElse: () => HealthData.empty(userId, date),
        );
        completeWeek.add(existingData);
      }

      return completeWeek;
    } catch (e) {
      print('Error getting weekly health data: $e');
      return [];
    }
  }

  /// Get monthly health data
  Future<List<HealthData>> getMonthlyHealthData(
    String userId,
    DateTime monthStart,
  ) async {
    try {
      final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
      final dateKeyStart = _getDateKey(monthStart);
      final dateKeyEnd = _getDateKey(monthEnd);

      final query = await _firestore
          .collection(_healthDataCollection)
          .doc(userId)
          .collection('dailyData')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: dateKeyStart)
          .where(FieldPath.documentId, isLessThanOrEqualTo: dateKeyEnd)
          .orderBy(FieldPath.documentId)
          .get();

      return query.docs
          .map((doc) => HealthData.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting monthly health data: $e');
      return [];
    }
  }

  /// Update step data for a specific date
  Future<bool> updateStepData(
    String userId,
    DateTime date,
    StepData stepData,
  ) async {
    try {
      final existingData = await getDailyHealthData(userId, date);
      if (existingData == null) return false;

      final updatedData = existingData.copyWith(stepData: stepData);
      return await saveDailyHealthData(updatedData);
    } catch (e) {
      print('Error updating step data: $e');
      return false;
    }
  }

  /// Update sleep data for a specific date
  Future<bool> updateSleepData(
    String userId,
    DateTime date,
    SleepData sleepData,
  ) async {
    try {
      final existingData = await getDailyHealthData(userId, date);
      if (existingData == null) return false;

      final updatedData = existingData.copyWith(sleepData: sleepData);
      return await saveDailyHealthData(updatedData);
    } catch (e) {
      print('Error updating sleep data: $e');
      return false;
    }
  }

  /// Update health metrics for a specific date
  Future<bool> updateHealthMetrics(
    String userId,
    DateTime date,
    HealthMetrics metrics,
  ) async {
    try {
      final existingData = await getDailyHealthData(userId, date);
      if (existingData == null) return false;

      final updatedData = existingData.copyWith(metrics: metrics);
      return await saveDailyHealthData(updatedData);
    } catch (e) {
      print('Error updating health metrics: $e');
      return false;
    }
  }

  /// Get health statistics for a date range
  Future<Map<String, dynamic>> getHealthStatistics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final dateKeyStart = _getDateKey(startDate);
      final dateKeyEnd = _getDateKey(endDate);

      final query = await _firestore
          .collection(_healthDataCollection)
          .doc(userId)
          .collection('dailyData')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: dateKeyStart)
          .where(FieldPath.documentId, isLessThanOrEqualTo: dateKeyEnd)
          .get();

      final healthDataList = query.docs
          .map((doc) => HealthData.fromFirestore(doc.data()))
          .toList();

      if (healthDataList.isEmpty) {
        return _getEmptyStatistics();
      }

      // Calculate statistics
      final totalSteps = healthDataList.fold<int>(
        0,
        (sum, data) => sum + data.stepData.steps,
      );
      final totalDistance = healthDataList.fold<double>(
        0,
        (sum, data) => sum + data.stepData.distance,
      );
      final totalCalories = healthDataList.fold<double>(
        0,
        (sum, data) => sum + data.stepData.calories,
      );
      final totalSleep = healthDataList.fold<double>(
        0,
        (sum, data) => sum + data.sleepData.duration,
      );
      final totalPoints = healthDataList.fold<int>(
        0,
        (sum, data) => sum + data.metrics.points,
      );

      final averageSteps = totalSteps / healthDataList.length;
      final averageDistance = totalDistance / healthDataList.length;
      final averageCalories = totalCalories / healthDataList.length;
      final averageSleep = totalSleep / healthDataList.length;
      final averageQuality =
          healthDataList.fold<double>(
            0,
            (sum, data) => sum + data.sleepData.quality,
          ) /
          healthDataList.length;

      final activeDays = healthDataList
          .where((data) => data.stepData.steps > 0)
          .length;
      final goodSleepDays = healthDataList
          .where((data) => data.sleepData.quality >= 70)
          .length;
      final goalAchievedDays = healthDataList
          .where(
            (data) => data.stepData.goalAchieved && data.sleepData.goalAchieved,
          )
          .length;

      return {
        'totalSteps': totalSteps,
        'totalDistance': totalDistance,
        'totalCalories': totalCalories,
        'totalSleep': totalSleep,
        'totalPoints': totalPoints,
        'averageSteps': averageSteps,
        'averageDistance': averageDistance,
        'averageCalories': averageCalories,
        'averageSleep': averageSleep,
        'averageQuality': averageQuality,
        'activeDays': activeDays,
        'goodSleepDays': goodSleepDays,
        'goalAchievedDays': goalAchievedDays,
        'totalDays': healthDataList.length,
        'activityRate': activeDays / healthDataList.length,
        'sleepQualityRate': goodSleepDays / healthDataList.length,
        'goalAchievementRate': goalAchievedDays / healthDataList.length,
      };
    } catch (e) {
      print('Error getting health statistics: $e');
      return _getEmptyStatistics();
    }
  }

  /// Get weekly health summary
  Future<WeeklyHealthSummary?> getWeeklySummary(
    String userId,
    DateTime weekStart,
  ) async {
    try {
      final weekKey = _getWeekKey(weekStart);

      final doc = await _firestore
          .collection(_weeklySummariesCollection)
          .doc(userId)
          .collection('summaries')
          .doc(weekKey)
          .get();

      if (doc.exists) {
        return WeeklyHealthSummary.fromMap(doc.data()!);
      }

      // Generate summary from daily data
      final dailyData = await getWeeklyHealthData(userId, weekStart);
      if (dailyData.isEmpty) return null;

      final weeklyMetrics = _calculateWeeklyMetrics(dailyData);
      final weekEnd = weekStart.add(const Duration(days: 6));

      return WeeklyHealthSummary(
        userId: userId,
        weekStart: weekStart,
        weekEnd: weekEnd,
        dailyData: dailyData,
        weeklyMetrics: weeklyMetrics,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error getting weekly summary: $e');
      return null;
    }
  }

  /// Save weekly health summary
  Future<bool> saveWeeklySummary(WeeklyHealthSummary summary) async {
    try {
      final weekKey = _getWeekKey(summary.weekStart);

      await _firestore
          .collection(_weeklySummariesCollection)
          .doc(summary.userId)
          .collection('summaries')
          .doc(weekKey)
          .set(summary.toMap());

      return true;
    } catch (e) {
      print('Error saving weekly summary: $e');
      return false;
    }
  }

  /// Get user's health goals
  Future<Map<String, dynamic>> getHealthGoals(String userId) async {
    try {
      final doc = await _firestore
          .collection(_userProfilesCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'stepGoal': data['stepGoal'] ?? 10000,
          'sleepGoal': data['sleepGoal'] ?? 8.0,
          'level': data['level'] ?? 'beginner',
        };
      }

      return {'stepGoal': 10000, 'sleepGoal': 8.0, 'level': 'beginner'};
    } catch (e) {
      print('Error getting health goals: $e');
      return {'stepGoal': 10000, 'sleepGoal': 8.0, 'level': 'beginner'};
    }
  }

  /// Update user's health goals
  Future<bool> updateHealthGoals(
    String userId,
    Map<String, dynamic> goals,
  ) async {
    try {
      await _firestore.collection(_userProfilesCollection).doc(userId).update({
        'stepGoal': goals['stepGoal'],
        'sleepGoal': goals['sleepGoal'],
        'level': goals['level'],
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error updating health goals: $e');
      return false;
    }
  }

  /// Delete health data for a specific date
  Future<bool> deleteHealthData(String userId, DateTime date) async {
    try {
      final dateKey = _getDateKey(date);

      await _firestore
          .collection(_healthDataCollection)
          .doc(userId)
          .collection('dailyData')
          .doc(dateKey)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting health data: $e');
      return false;
    }
  }

  /// Get date key for Firestore document ID
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get week key for Firestore document ID
  String _getWeekKey(DateTime weekStart) {
    return '${weekStart.year}-W${_getWeekNumber(weekStart).toString().padLeft(2, '0')}';
  }

  /// Get week number of the year
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Update weekly summary
  Future<void> _updateWeeklySummary(String userId, DateTime date) async {
    try {
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final dailyData = await getWeeklyHealthData(userId, weekStart);

      if (dailyData.isNotEmpty) {
        final weeklyMetrics = _calculateWeeklyMetrics(dailyData);
        final weekEnd = weekStart.add(const Duration(days: 6));

        final summary = WeeklyHealthSummary(
          userId: userId,
          weekStart: weekStart,
          weekEnd: weekEnd,
          dailyData: dailyData,
          weeklyMetrics: weeklyMetrics,
          createdAt: DateTime.now(),
        );

        await saveWeeklySummary(summary);
      }
    } catch (e) {
      print('Error updating weekly summary: $e');
    }
  }

  /// Calculate weekly metrics from daily data
  HealthMetrics _calculateWeeklyMetrics(List<HealthData> dailyData) {
    final totalSteps = dailyData.fold<int>(
      0,
      (sum, data) => sum + data.stepData.steps,
    );
    final totalSleep = dailyData.fold<double>(
      0,
      (sum, data) => sum + data.sleepData.duration,
    );
    final totalPoints = dailyData.fold<int>(
      0,
      (sum, data) => sum + data.metrics.points,
    );

    final averageSteps = totalSteps / dailyData.length;
    final averageSleep = totalSleep / dailyData.length;

    final goalAchievedDays = dailyData
        .where(
          (data) => data.stepData.goalAchieved && data.sleepData.goalAchieved,
        )
        .length;
    final goalAchievementRate = goalAchievedDays / dailyData.length;

    // Calculate streak (simplified)
    int streak = 0;
    for (int i = dailyData.length - 1; i >= 0; i--) {
      if (dailyData[i].stepData.goalAchieved &&
          dailyData[i].sleepData.goalAchieved) {
        streak++;
      } else {
        break;
      }
    }

    return HealthMetrics(
      points: totalPoints,
      streak: streak,
      longestStreak: streak, // Simplified
      weeklyAverageSteps: averageSteps,
      weeklyAverageSleep: averageSleep,
      goalAchievementRate: goalAchievementRate,
      level: 'beginner', // This would come from user profile
      lastUpdated: DateTime.now(),
    );
  }

  /// Get empty statistics
  Map<String, dynamic> _getEmptyStatistics() {
    return {
      'totalSteps': 0,
      'totalDistance': 0.0,
      'totalCalories': 0.0,
      'totalSleep': 0.0,
      'totalPoints': 0,
      'averageSteps': 0.0,
      'averageDistance': 0.0,
      'averageCalories': 0.0,
      'averageSleep': 0.0,
      'averageQuality': 0.0,
      'activeDays': 0,
      'goodSleepDays': 0,
      'goalAchievedDays': 0,
      'totalDays': 0,
      'activityRate': 0.0,
      'sleepQualityRate': 0.0,
      'goalAchievementRate': 0.0,
    };
  }
}
