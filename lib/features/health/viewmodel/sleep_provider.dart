import 'package:flutter/foundation.dart';
import '../services/sleep_detection_service.dart';

/// Provider for managing sleep tracking state and data
class SleepProvider extends ChangeNotifier {
  final SleepDetectionService _sleepService = SleepDetectionService();

  // Sleep tracking state
  bool _isInitialized = false;
  bool _isMonitoring = false;
  bool _isSleeping = false;
  String _error = '';

  // Current sleep session
  DateTime? _currentSleepStart;
  DateTime? _currentSleepEnd;
  double _currentSleepDuration = 0.0;
  double _currentSleepQuality = 0.0;

  // Sleep goals and streaks
  double _sleepGoal = 8.0; // 8 hours default
  int _currentStreak = 0;
  int _longestStreak = 0;

  // Weekly data
  List<Map<String, dynamic>> _weeklyData = [];

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isMonitoring => _isMonitoring;
  bool get isSleeping => _isSleeping;
  String get error => _error;
  DateTime? get currentSleepStart => _currentSleepStart;
  DateTime? get currentSleepEnd => _currentSleepEnd;
  double get currentSleepDuration => _currentSleepDuration;
  double get currentSleepQuality => _currentSleepQuality;
  double get sleepGoal => _sleepGoal;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  List<Map<String, dynamic>> get weeklyData => List.unmodifiable(_weeklyData);

  /// Initialize sleep tracking
  Future<void> initialize() async {
    try {
      _isInitialized = await _sleepService.startMonitoring();
      if (_isInitialized) {
        _isMonitoring = true;
        _error = '';
        print('Sleep tracking initialized successfully');
      } else {
        _error = 'Failed to initialize sleep tracking';
      }
    } catch (e) {
      _error = 'Error initializing sleep tracking: $e';
      print(_error);
    }
    notifyListeners();
  }

  /// Start sleep monitoring
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    try {
      final success = await _sleepService.startMonitoring();
      if (success) {
        _isMonitoring = true;
        _error = '';
      } else {
        _error = 'Failed to start sleep monitoring';
      }
    } catch (e) {
      _error = 'Error starting sleep monitoring: $e';
    }
    notifyListeners();
  }

  /// Start manual sleep tracking
  Future<void> startManualSleep() async {
    try {
      // Start monitoring if not already started
      if (!_isMonitoring) {
        await startMonitoring();
      }

      // Manually set sleep state
      _isSleeping = true;
      _currentSleepStart = DateTime.now();
      _currentSleepEnd = null;
      _currentSleepDuration = 0.0;
      _currentSleepQuality = 0.0;
      _error = '';

      print('Manual sleep started at ${_currentSleepStart}');
      notifyListeners();
    } catch (e) {
      _error = 'Error starting manual sleep: $e';
      notifyListeners();
    }
  }

  /// Stop manual sleep tracking
  Future<void> stopManualSleep() async {
    try {
      if (_isSleeping && _currentSleepStart != null) {
        _isSleeping = false;
        _currentSleepEnd = DateTime.now();

        // Calculate duration and quality
        _currentSleepDuration =
            _currentSleepEnd!.difference(_currentSleepStart!).inMinutes / 60.0;
        _currentSleepQuality = _calculateManualSleepQuality();

        print('Manual sleep stopped at ${_currentSleepEnd}');
        print('Sleep duration: ${_currentSleepDuration.toStringAsFixed(1)}h');
        print('Sleep quality: ${_currentSleepQuality.toStringAsFixed(0)}%');

        _error = '';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error stopping manual sleep: $e';
      notifyListeners();
    }
  }

  /// Calculate sleep quality for manual sleep
  double _calculateManualSleepQuality() {
    if (_currentSleepDuration < 0.5) return 0.0; // Less than 30 minutes

    // Simple quality calculation based on duration
    if (_currentSleepDuration >= 8.0) return 100.0; // 8+ hours = perfect
    if (_currentSleepDuration >= 7.0) return 90.0; // 7-8 hours = excellent
    if (_currentSleepDuration >= 6.0) return 80.0; // 6-7 hours = very good
    if (_currentSleepDuration >= 5.0) return 70.0; // 5-6 hours = good
    if (_currentSleepDuration >= 4.0) return 60.0; // 4-5 hours = fair
    return 50.0; // Less than 4 hours = poor
  }

  /// Update current sleep duration (called periodically while sleeping)
  void updateCurrentSleepDuration() {
    if (_isSleeping && _currentSleepStart != null) {
      final now = DateTime.now();
      _currentSleepDuration =
          now.difference(_currentSleepStart!).inMinutes / 60.0;
      _currentSleepQuality = _calculateManualSleepQuality();
      notifyListeners();
    }
  }

  /// Stop sleep monitoring
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    try {
      await _sleepService.stopMonitoring();
      _isMonitoring = false;
      _isSleeping = false;
      _error = '';
    } catch (e) {
      _error = 'Error stopping sleep monitoring: $e';
    }
    notifyListeners();
  }

  /// Update current sleep state
  void updateSleepState() {
    _isSleeping = _sleepService.isSleeping;
    _currentSleepStart = _sleepService.sleepStartTime;
    _currentSleepEnd = _sleepService.sleepEndTime;

    if (_currentSleepStart != null && _currentSleepEnd != null) {
      _currentSleepDuration =
          _currentSleepEnd!.difference(_currentSleepStart!).inMinutes / 60.0;
      _currentSleepQuality = _sleepService.sleepEfficiency;
    }

    notifyListeners();
  }

  /// Set sleep goal
  void setSleepGoal(double hours) {
    _sleepGoal = hours.clamp(4.0, 12.0); // Reasonable range
    notifyListeners();
  }

  /// Calculate sleep streak
  void calculateStreak() {
    // This would typically load from Firestore and calculate based on consecutive days
    // For now, we'll use a simple calculation
    _currentStreak = _calculateCurrentStreak();
    _longestStreak = _calculateLongestStreak();
    notifyListeners();
  }

  /// Load weekly sleep data
  Future<void> loadWeeklyData(String userId) async {
    try {
      _weeklyData = await _sleepService.getWeeklySleepData(userId);
      calculateStreak();
      notifyListeners();
    } catch (e) {
      _error = 'Error loading weekly data: $e';
      notifyListeners();
    }
  }

  /// Save current sleep session
  Future<bool> saveCurrentSession(String userId) async {
    try {
      // Check if we have manual sleep data
      if (_currentSleepStart != null && _currentSleepEnd != null) {
        // Save manual sleep session
        final success = await _sleepService.saveManualSleepSession(
          userId,
          _currentSleepStart!,
          _currentSleepEnd!,
          _currentSleepDuration,
          _currentSleepQuality,
        );

        if (success) {
          print('Manual sleep session saved successfully');
          // Reload weekly data to update streaks
          await loadWeeklyData(userId);
        }
        return success;
      } else {
        // Try to save automatic sleep session
        final success = await _sleepService.saveSleepSession(userId);
        if (success) {
          // Reload weekly data to update streaks
          await loadWeeklyData(userId);
        }
        return success;
      }
    } catch (e) {
      _error = 'Error saving sleep session: $e';
      print('Error saving sleep session: $e');
      notifyListeners();
      return false;
    }
  }

  /// Get sleep score (0-100)
  int getSleepScore() {
    if (_currentSleepDuration == 0) return 0;

    // Calculate score based on duration and quality
    final durationScore = (_currentSleepDuration / _sleepGoal * 100).clamp(
      0,
      100,
    );
    final qualityScore = _currentSleepQuality;

    return ((durationScore * 0.6 + qualityScore * 0.4)).round();
  }

  /// Get sleep status text
  String getSleepStatus() {
    if (_isSleeping) {
      return 'Sleeping';
    } else if (_currentSleepDuration > 0) {
      return 'Awake';
    } else {
      return 'Not tracked';
    }
  }

  /// Get sleep quality description
  String getSleepQualityDescription() {
    if (_currentSleepQuality >= 90) return 'Excellent';
    if (_currentSleepQuality >= 80) return 'Very Good';
    if (_currentSleepQuality >= 70) return 'Good';
    if (_currentSleepQuality >= 60) return 'Fair';
    if (_currentSleepQuality >= 50) return 'Poor';
    return 'Very Poor';
  }

  /// Get sleep quality color
  int getSleepQualityColor() {
    if (_currentSleepQuality >= 80) return 0xFF4CAF50; // Green
    if (_currentSleepQuality >= 60) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  /// Calculate current streak (simplified)
  int _calculateCurrentStreak() {
    if (_weeklyData.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayData = _weeklyData.firstWhere(
        (data) => data['date'].day == date.day,
        orElse: () => {'duration': 0.0},
      );

      if (dayData['duration'] >= _sleepGoal * 0.8) {
        // 80% of goal
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate longest streak (simplified)
  int _calculateLongestStreak() {
    // This would typically be stored in Firestore
    // For now, return current streak as longest
    return _currentStreak;
  }

  /// Get average sleep duration for the week
  double getWeeklyAverage() {
    if (_weeklyData.isEmpty) return 0.0;

    final totalDuration = _weeklyData.fold<double>(
      0.0,
      (sum, data) => sum + (data['duration'] ?? 0.0),
    );

    return totalDuration / _weeklyData.length;
  }

  /// Get sleep goal achievement rate
  double getGoalAchievementRate() {
    if (_weeklyData.isEmpty) return 0.0;

    final achievedDays = _weeklyData
        .where((data) => (data['duration'] ?? 0.0) >= _sleepGoal * 0.8)
        .length;

    return achievedDays / _weeklyData.length;
  }

  /// Dispose resources
  @override
  void dispose() {
    _sleepService.dispose();
    super.dispose();
  }
}
