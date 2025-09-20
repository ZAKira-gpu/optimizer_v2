import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for smart sleep detection using phone sensors
class SleepDetectionService {
  static const String _collection = 'sleepTracking';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream subscriptions
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<double>? _brightnessSubscription;

  // Sleep detection state
  bool _isMonitoring = false;
  bool _isSleeping = false;
  DateTime? _sleepStartTime;
  DateTime? _sleepEndTime;
  List<SleepMovement> _movements = [];
  double _currentBrightness = 1.0;

  // Sleep quality metrics
  int _totalMovements = 0;
  int _restlessPeriods = 0;
  double _sleepEfficiency = 0.0;

  // Configuration
  static const double _movementThreshold =
      0.5; // Threshold for significant movement
  static const int _sleepDetectionMinutes =
      10; // Minutes of stillness to detect sleep
  static const int _wakeDetectionMinutes =
      5; // Minutes of movement to detect wake

  // Getters
  bool get isMonitoring => _isMonitoring;
  bool get isSleeping => _isSleeping;
  DateTime? get sleepStartTime => _sleepStartTime;
  DateTime? get sleepEndTime => _sleepEndTime;
  List<SleepMovement> get movements => List.unmodifiable(_movements);
  double get sleepEfficiency => _sleepEfficiency;

  /// Start sleep monitoring
  Future<bool> startMonitoring() async {
    if (_isMonitoring) return true;

    try {
      // Request permissions
      await _requestPermissions();

      // Start accelerometer monitoring
      _accelerometerSubscription = accelerometerEvents.listen(
        _onAccelerometerEvent,
      );

      // Start brightness monitoring
      _brightnessSubscription = ScreenBrightness().onCurrentBrightnessChanged
          .listen(_onBrightnessChange);

      _isMonitoring = true;
      print('Sleep monitoring started');
      return true;
    } catch (e) {
      print('Error starting sleep monitoring: $e');
      return false;
    }
  }

  /// Stop sleep monitoring
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    _accelerometerSubscription?.cancel();
    _brightnessSubscription?.cancel();
    _isMonitoring = false;
    _isSleeping = false;

    print('Sleep monitoring stopped');
  }

  /// Handle accelerometer events
  void _onAccelerometerEvent(AccelerometerEvent event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final timestamp = DateTime.now();

    // Record movement
    _movements.add(
      SleepMovement(
        timestamp: timestamp,
        magnitude: magnitude,
        isSignificant: magnitude > _movementThreshold,
      ),
    );

    // Keep only last 2 hours of movements
    final cutoff = timestamp.subtract(const Duration(hours: 2));
    _movements.removeWhere((m) => m.timestamp.isBefore(cutoff));

    // Analyze sleep state
    _analyzeSleepState();
  }

  /// Handle brightness changes
  void _onBrightnessChange(double brightness) {
    _currentBrightness = brightness;

    // If brightness increases significantly, might indicate wake up
    if (brightness > 0.1 && _isSleeping) {
      _checkForWakeUp();
    }
  }

  /// Analyze current sleep state based on movement patterns
  void _analyzeSleepState() {
    if (_movements.length < 10) return; // Need enough data

    final now = DateTime.now();
    final recentMovements = _movements
        .where(
          (m) => m.timestamp.isAfter(
            now.subtract(const Duration(minutes: _sleepDetectionMinutes)),
          ),
        )
        .toList();

    // Check for sleep (low movement + low brightness)
    if (!_isSleeping && _currentBrightness < 0.1) {
      final significantMovements = recentMovements
          .where((m) => m.isSignificant)
          .length;

      if (significantMovements < 2) {
        // Very few significant movements
        _startSleep();
      }
    }
    // Check for wake up (high movement or brightness)
    else if (_isSleeping) {
      _checkForWakeUp();
    }
  }

  /// Start sleep session
  void _startSleep() {
    if (_isSleeping) return;

    _isSleeping = true;
    _sleepStartTime = DateTime.now();
    _totalMovements = 0;
    _restlessPeriods = 0;

    print('Sleep detected at ${_sleepStartTime}');
  }

  /// Check for wake up conditions
  void _checkForWakeUp() {
    if (!_isSleeping) return;

    final now = DateTime.now();
    final recentMovements = _movements
        .where(
          (m) => m.timestamp.isAfter(
            now.subtract(const Duration(minutes: _wakeDetectionMinutes)),
          ),
        )
        .toList();

    final significantMovements = recentMovements
        .where((m) => m.isSignificant)
        .length;

    // Wake up if: high movement OR brightness increase
    if (significantMovements > 3 || _currentBrightness > 0.3) {
      _endSleep();
    }
  }

  /// End sleep session
  void _endSleep() {
    if (!_isSleeping) return;

    _isSleeping = false;
    _sleepEndTime = DateTime.now();

    // Calculate sleep quality
    _calculateSleepQuality();

    print('Wake up detected at ${_sleepEndTime}');
    print('Sleep duration: ${_getSleepDuration()}');
    print('Sleep quality: ${_sleepEfficiency.toStringAsFixed(1)}%');
  }

  /// Calculate sleep quality based on movement patterns
  void _calculateSleepQuality() {
    if (_sleepStartTime == null || _sleepEndTime == null) return;

    final sleepDuration = _sleepEndTime!.difference(_sleepStartTime!);
    final sleepMinutes = sleepDuration.inMinutes;

    if (sleepMinutes < 30) {
      _sleepEfficiency = 0.0; // Too short to be quality sleep
      return;
    }

    // Count movements during sleep
    final sleepMovements = _movements
        .where(
          (m) =>
              m.timestamp.isAfter(_sleepStartTime!) &&
              m.timestamp.isBefore(_sleepEndTime!),
        )
        .toList();

    _totalMovements = sleepMovements.length;
    _restlessPeriods = _countRestlessPeriods(sleepMovements);

    // Calculate efficiency (less movement = better sleep)
    final movementScore = max(
      0,
      100 - (_totalMovements * 0.5) - (_restlessPeriods * 2),
    );
    final durationScore = min(100, (sleepMinutes / 8) * 100); // 8 hours = 100%

    _sleepEfficiency = (movementScore * 0.7 + durationScore * 0.3).clamp(
      0,
      100,
    );
  }

  /// Count restless periods (clusters of movements)
  int _countRestlessPeriods(List<SleepMovement> movements) {
    int restlessPeriods = 0;
    bool inRestlessPeriod = false;

    for (int i = 0; i < movements.length - 1; i++) {
      final current = movements[i];
      final next = movements[i + 1];

      if (current.isSignificant && next.isSignificant) {
        final timeDiff = next.timestamp.difference(current.timestamp).inMinutes;

        if (timeDiff < 5) {
          // Movements within 5 minutes
          if (!inRestlessPeriod) {
            restlessPeriods++;
            inRestlessPeriod = true;
          }
        } else {
          inRestlessPeriod = false;
        }
      }
    }

    return restlessPeriods;
  }

  /// Get sleep duration in hours
  double _getSleepDuration() {
    if (_sleepStartTime == null || _sleepEndTime == null) return 0.0;
    return _sleepEndTime!.difference(_sleepStartTime!).inMinutes / 60.0;
  }

  /// Save sleep session to Firestore
  Future<bool> saveSleepSession(String userId) async {
    if (_sleepStartTime == null || _sleepEndTime == null) return false;

    try {
      final today = DateTime.now();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('sleepSessions')
          .doc(dateKey)
          .set({
            'sleepStart': Timestamp.fromDate(_sleepStartTime!),
            'sleepEnd': Timestamp.fromDate(_sleepEndTime!),
            'duration': _getSleepDuration(),
            'quality': _sleepEfficiency,
            'totalMovements': _totalMovements,
            'restlessPeriods': _restlessPeriods,
            'date': Timestamp.fromDate(today),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });

      print('Sleep session saved to Firestore successfully');
      return true;
    } catch (e) {
      print('Error saving sleep session: $e');
      return false;
    }
  }

  /// Save manual sleep session to Firestore
  Future<bool> saveManualSleepSession(
    String userId,
    DateTime sleepStart,
    DateTime sleepEnd,
    double duration,
    double quality,
  ) async {
    try {
      final today = DateTime.now();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final sleepData = {
        'sleepStart': Timestamp.fromDate(sleepStart),
        'sleepEnd': Timestamp.fromDate(sleepEnd),
        'duration': duration,
        'quality': quality,
        'totalMovements': 0, // Manual sleep doesn't track movements
        'restlessPeriods': 0, // Manual sleep doesn't track restless periods
        'date': Timestamp.fromDate(today),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'isManual': true, // Flag to indicate this was manual sleep
      };

      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('sleepSessions')
          .doc(dateKey)
          .set(sleepData);

      print('Manual sleep session saved to Firestore successfully');
      print(
        'Sleep data: Start=$sleepStart, End=$sleepEnd, Duration=${duration.toStringAsFixed(1)}h, Quality=${quality.toStringAsFixed(0)}%',
      );
      return true;
    } catch (e) {
      print('Error saving manual sleep session: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('permission')) {
        print('This looks like a Firestore permission error');
      }
      if (e.toString().contains('network')) {
        print('This looks like a network connectivity error');
      }
      return false;
    }
  }

  /// Get sleep data for a specific date
  Future<Map<String, dynamic>?> getSleepData(
    String userId,
    DateTime date,
  ) async {
    try {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('sleepSessions')
          .doc(dateKey)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting sleep data: $e');
      return null;
    }
  }

  /// Get weekly sleep data
  Future<List<Map<String, dynamic>>> getWeeklySleepData(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      List<Map<String, dynamic>> weeklyData = [];

      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final data = await getSleepData(userId, date);

        weeklyData.add({
          'date': date,
          'duration': data?['duration'] ?? 0.0,
          'quality': data?['quality'] ?? 0.0,
          'sleepStart': data?['sleepStart'],
          'sleepEnd': data?['sleepEnd'],
        });
      }

      return weeklyData;
    } catch (e) {
      print('Error getting weekly sleep data: $e');
      return [];
    }
  }

  /// Request necessary permissions
  Future<void> _requestPermissions() async {
    // Note: sensors_plus doesn't require explicit permissions on most platforms
    // Screen brightness might need permissions on some devices
    try {
      // Screen brightness permissions are handled automatically
      print('Brightness monitoring available');
    } catch (e) {
      print('Brightness permission not available: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _accelerometerSubscription?.cancel();
    _brightnessSubscription?.cancel();
  }
}

/// Data class for sleep movement events
class SleepMovement {
  final DateTime timestamp;
  final double magnitude;
  final bool isSignificant;

  SleepMovement({
    required this.timestamp,
    required this.magnitude,
    required this.isSignificant,
  });
}
