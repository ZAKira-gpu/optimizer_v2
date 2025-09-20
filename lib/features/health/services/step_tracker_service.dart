import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for tracking user steps, distance, and calories
class StepTrackerService {
  static const String _collection = 'stepTracking';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  // Current tracking data
  int _currentSteps = 0;
  double _currentDistance = 0.0;
  double _currentCalories = 0.0;
  String _status = 'Unknown';

  // User metrics for calculations
  double _userHeight = 1.75; // meters (default)
  double _userWeight = 70.0; // kg (default)

  // Getters
  int get currentSteps => _currentSteps;
  double get currentDistance => _currentDistance;
  double get currentCalories => _currentCalories;
  String get status => _status;

  /// Initialize step tracking
  Future<bool> initialize() async {
    try {
      // Listen to step count stream
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );

      // Listen to pedestrian status stream
      _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatus,
        onError: _onPedestrianStatusError,
      );

      return true;
    } catch (e) {
      print('Error initializing step tracker: $e');
      // Return false but don't crash the app
      return false;
    }
  }

  /// Set user metrics for accurate calculations
  void setUserMetrics({required double height, required double weight}) {
    _userHeight = height;
    _userWeight = weight;
  }

  /// Handle step count updates
  void _onStepCount(StepCount event) {
    _currentSteps = event.steps;
    _calculateDistanceAndCalories();
  }

  /// Handle step count errors
  void _onStepCountError(error) {
    print('Step count error: $error');
  }

  /// Handle pedestrian status updates
  void _onPedestrianStatus(PedestrianStatus event) {
    _status = event.status;
  }

  /// Handle pedestrian status errors
  void _onPedestrianStatusError(error) {
    print('Pedestrian status error: $error');
  }

  /// Calculate distance and calories based on steps
  void _calculateDistanceAndCalories() {
    // Calculate stride length based on height
    // Average stride length is approximately 0.78 × height
    double strideLength = _userHeight * 0.78;

    // Calculate distance in kilometers
    _currentDistance = (_currentSteps * strideLength) / 1000;

    // Calculate calories burned
    // Formula: Distance (km) × Weight (kg) × 1.036
    _currentCalories = _currentDistance * _userWeight * 1.036;
  }

  /// Save daily step data to Firestore
  Future<bool> saveDailySteps(String userId) async {
    try {
      final today = DateTime.now();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('dailySteps')
          .doc(dateKey)
          .set({
            'steps': _currentSteps,
            'distance': _currentDistance,
            'calories': _currentCalories,
            'date': Timestamp.fromDate(today),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });

      return true;
    } catch (e) {
      print('Error saving daily steps: $e');
      return false;
    }
  }

  /// Get daily step data from Firestore
  Future<Map<String, dynamic>?> getDailySteps(
    String userId,
    DateTime date,
  ) async {
    try {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('dailySteps')
          .doc(dateKey)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting daily steps: $e');
      return null;
    }
  }

  /// Get weekly step data
  Future<List<Map<String, dynamic>>> getWeeklySteps(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      List<Map<String, dynamic>> weeklyData = [];

      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final data = await getDailySteps(userId, date);

        weeklyData.add({
          'date': date,
          'steps': data?['steps'] ?? 0,
          'distance': data?['distance'] ?? 0.0,
          'calories': data?['calories'] ?? 0.0,
        });
      }

      return weeklyData;
    } catch (e) {
      print('Error getting weekly steps: $e');
      return [];
    }
  }

  /// Get monthly step data
  Future<List<Map<String, dynamic>>> getMonthlySteps(String userId) async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);

      List<Map<String, dynamic>> monthlyData = [];

      for (int i = 0; i < monthEnd.day; i++) {
        final date = monthStart.add(Duration(days: i));
        final data = await getDailySteps(userId, date);

        monthlyData.add({
          'date': date,
          'steps': data?['steps'] ?? 0,
          'distance': data?['distance'] ?? 0.0,
          'calories': data?['calories'] ?? 0.0,
        });
      }

      return monthlyData;
    } catch (e) {
      print('Error getting monthly steps: $e');
      return [];
    }
  }

  /// Calculate points based on daily steps
  int calculatePointsFromSteps(int steps) {
    // Points calculation based on step goals
    // 10,000 steps = 100 points (base goal)
    // 15,000 steps = 150 points (advanced goal)
    // 20,000 steps = 200 points (expert goal)

    if (steps >= 20000) {
      return 200;
    } else if (steps >= 15000) {
      return 150;
    } else if (steps >= 10000) {
      return 100;
    } else if (steps >= 5000) {
      return 50;
    } else {
      return (steps / 100).round(); // 1 point per 100 steps
    }
  }

  /// Get step goal based on user level
  int getStepGoal(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 5000;
      case 'intermediate':
        return 10000;
      case 'advanced':
        return 15000;
      case 'expert':
        return 20000;
      default:
        return 10000;
    }
  }

  /// Check if daily goal is achieved
  bool isDailyGoalAchieved(int steps, String level) {
    return steps >= getStepGoal(level);
  }

  /// Dispose resources
  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
  }
}
