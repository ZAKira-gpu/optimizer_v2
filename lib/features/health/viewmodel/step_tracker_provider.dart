import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/step_tracker_service.dart';

/// Provider for managing step tracking state
class StepTrackerProvider extends ChangeNotifier {
  final StepTrackerService _stepTrackerService = StepTrackerService();

  // State variables
  bool _isInitialized = false;
  bool _isTracking = false;
  String _error = '';

  // Current tracking data
  int _currentSteps = 0;
  double _currentDistance = 0.0;
  double _currentCalories = 0.0;
  String _status = 'Unknown';

  // Daily data
  Map<String, dynamic>? _todayData;
  List<Map<String, dynamic>> _weeklyData = [];
  List<Map<String, dynamic>> _monthlyData = [];

  // User metrics
  double _userHeight = 1.75;
  double _userWeight = 70.0;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isTracking => _isTracking;
  String get error => _error;
  int get currentSteps => _currentSteps;
  double get currentDistance => _currentDistance;
  double get currentCalories => _currentCalories;
  String get status => _status;
  Map<String, dynamic>? get todayData => _todayData;
  List<Map<String, dynamic>> get weeklyData => _weeklyData;
  List<Map<String, dynamic>> get monthlyData => _monthlyData;
  double get userHeight => _userHeight;
  double get userWeight => _userWeight;

  /// Initialize step tracking
  Future<bool> initialize() async {
    try {
      _clearError();
      _isInitialized = await _stepTrackerService.initialize();

      if (_isInitialized) {
        _isTracking = true;
        _startPeriodicUpdates();
      } else {
        _setError('Step tracking not available on this device');
      }

      notifyListeners();
      return _isInitialized;
    } catch (e) {
      _setError('Failed to initialize step tracking: $e');
      notifyListeners();
      return false;
    }
  }

  /// Set user metrics
  void setUserMetrics({required double height, required double weight}) {
    _userHeight = height;
    _userWeight = weight;
    _stepTrackerService.setUserMetrics(height: height, weight: weight);
    notifyListeners();
  }

  /// Start periodic updates
  void _startPeriodicUpdates() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isTracking) {
        timer.cancel();
        return;
      }

      _updateCurrentData();
    });
  }

  /// Update current tracking data
  void _updateCurrentData() {
    _currentSteps = _stepTrackerService.currentSteps;
    _currentDistance = _stepTrackerService.currentDistance;
    _currentCalories = _stepTrackerService.currentCalories;
    _status = _stepTrackerService.status;
    notifyListeners();
  }

  /// Save daily steps to Firestore and update points
  Future<bool> saveDailySteps(String userId, String userLevel) async {
    try {
      _clearError();
      final success = await _stepTrackerService.saveDailySteps(userId);

      if (success) {
        await loadTodayData(userId);

        // Update points if daily goal is achieved
        if (isDailyGoalAchieved(userLevel)) {
          // This will be handled by the calling screen with ProfileProvider
          // to avoid circular dependencies
        }
      }

      notifyListeners();
      return success;
    } catch (e) {
      _setError('Failed to save daily steps: $e');
      notifyListeners();
      return false;
    }
  }

  /// Load today's step data
  Future<void> loadTodayData(String userId) async {
    try {
      _clearError();
      _todayData = await _stepTrackerService.getDailySteps(
        userId,
        DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load today\'s data: $e');
      notifyListeners();
    }
  }

  /// Load weekly step data
  Future<void> loadWeeklyData(String userId) async {
    try {
      _clearError();
      _weeklyData = await _stepTrackerService.getWeeklySteps(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load weekly data: $e');
      notifyListeners();
    }
  }

  /// Load monthly step data
  Future<void> loadMonthlyData(String userId) async {
    try {
      _clearError();
      _monthlyData = await _stepTrackerService.getMonthlySteps(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load monthly data: $e');
      notifyListeners();
    }
  }

  /// Calculate points from current steps
  int calculatePointsFromSteps() {
    return _stepTrackerService.calculatePointsFromSteps(_currentSteps);
  }

  /// Get step goal based on user level
  int getStepGoal(String level) {
    return _stepTrackerService.getStepGoal(level);
  }

  /// Check if daily goal is achieved
  bool isDailyGoalAchieved(String level) {
    return _stepTrackerService.isDailyGoalAchieved(_currentSteps, level);
  }

  /// Get progress percentage towards daily goal
  double getDailyGoalProgress(String level) {
    final goal = getStepGoal(level);
    if (goal == 0) return 0.0;
    return (_currentSteps / goal).clamp(0.0, 1.0);
  }

  /// Get formatted distance string
  String getFormattedDistance() {
    if (_currentDistance < 1.0) {
      return '${(_currentDistance * 1000).round()} m';
    } else {
      return '${_currentDistance.toStringAsFixed(2)} km';
    }
  }

  /// Get formatted calories string
  String getFormattedCalories() {
    return '${_currentCalories.toStringAsFixed(0)} kcal';
  }

  /// Get average steps per day for the week
  double getWeeklyAverage() {
    if (_weeklyData.isEmpty) return 0.0;

    final totalSteps = _weeklyData.fold<int>(
      0,
      (sum, day) => sum + (day['steps'] as int),
    );

    return totalSteps / _weeklyData.length;
  }

  /// Get total steps for the week
  int getWeeklyTotal() {
    return _weeklyData.fold<int>(0, (sum, day) => sum + (day['steps'] as int));
  }

  /// Get total steps for the month
  int getMonthlyTotal() {
    return _monthlyData.fold<int>(0, (sum, day) => sum + (day['steps'] as int));
  }

  /// Start tracking
  void startTracking() {
    _isTracking = true;
    _startPeriodicUpdates();
    notifyListeners();
  }

  /// Stop tracking
  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }

  /// Clear error
  void _clearError() {
    _error = '';
  }

  /// Set error
  void _setError(String error) {
    _error = error;
  }

  @override
  void dispose() {
    _stepTrackerService.dispose();
    super.dispose();
  }
}
