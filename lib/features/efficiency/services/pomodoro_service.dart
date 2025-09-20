import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/efficiency_models.dart';

/// Service for managing Pomodoro timer functionality
class PomodoroService extends ChangeNotifier {
  // Timer configuration
  static const int defaultWorkMinutes = 25;
  static const int defaultShortBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;
  static const int pomodorosUntilLongBreak = 4;

  // Timer state
  Timer? _timer;
  int _remainingSeconds = defaultWorkMinutes * 60;
  PomodoroType _currentType = PomodoroType.work;
  bool _isRunning = false;
  bool _isPaused = false;
  int _completedPomodoros = 0;
  int _completedBreaks = 0;
  String? _currentTaskId;

  // Session tracking
  List<PomodoroSession> _todaySessions = [];
  DateTime? _sessionStartTime;

  // Getters
  int get remainingSeconds => _remainingSeconds;
  PomodoroType get currentType => _currentType;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  int get completedPomodoros => _completedPomodoros;
  int get completedBreaks => _completedBreaks;
  List<PomodoroSession> get todaySessions => List.unmodifiable(_todaySessions);

  /// Get formatted time string (MM:SS)
  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progress {
    final totalSeconds = _getTotalSecondsForType(_currentType);
    return 1.0 - (_remainingSeconds / totalSeconds);
  }

  /// Get current session duration in minutes
  int get currentSessionDuration {
    final totalSeconds = _getTotalSecondsForType(_currentType);
    return totalSeconds ~/ 60;
  }

  /// Start the Pomodoro timer
  void startTimer({String? taskId}) {
    if (_isRunning) return;

    _currentTaskId = taskId;
    _isRunning = true;
    _isPaused = false;
    _sessionStartTime = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _completeSession();
      }
    });

    notifyListeners();
  }

  /// Pause the timer
  void pauseTimer() {
    if (!_isRunning || _isPaused) return;

    _timer?.cancel();
    _isPaused = true;
    notifyListeners();
  }

  /// Resume the timer
  void resumeTimer() {
    if (!_isRunning || !_isPaused) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _completeSession();
      }
    });

    _isPaused = false;
    notifyListeners();
  }

  /// Stop the timer
  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _sessionStartTime = null;
    _currentTaskId = null;
    notifyListeners();
  }

  /// Reset the timer to initial state
  void resetTimer() {
    stopTimer();
    _remainingSeconds = _getTotalSecondsForType(_currentType);
    notifyListeners();
  }

  /// Skip current session and move to next
  void skipSession() {
    _completeSession();
  }

  /// Complete current session and move to next
  void _completeSession() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;

    // Save completed session
    if (_sessionStartTime != null) {
      final session = PomodoroSession(
        id: _generateSessionId(),
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        durationMinutes: currentSessionDuration,
        type: _currentType,
        isCompleted: true,
        taskId: _currentTaskId,
      );
      _todaySessions.add(session);
    }

    // Update counters
    if (_currentType == PomodoroType.work) {
      _completedPomodoros++;
    } else {
      _completedBreaks++;
    }

    // Move to next session type
    _moveToNextSession();
    notifyListeners();
  }

  /// Move to the next session type
  void _moveToNextSession() {
    if (_currentType == PomodoroType.work) {
      // After work session, take a break
      if (_completedPomodoros % pomodorosUntilLongBreak == 0) {
        _currentType = PomodoroType.longBreak;
      } else {
        _currentType = PomodoroType.shortBreak;
      }
    } else {
      // After break, go back to work
      _currentType = PomodoroType.work;
    }

    _remainingSeconds = _getTotalSecondsForType(_currentType);
    _sessionStartTime = null;
    _currentTaskId = null;
  }

  /// Get total seconds for a session type
  int _getTotalSecondsForType(PomodoroType type) {
    switch (type) {
      case PomodoroType.work:
        return defaultWorkMinutes * 60;
      case PomodoroType.shortBreak:
        return defaultShortBreakMinutes * 60;
      case PomodoroType.longBreak:
        return defaultLongBreakMinutes * 60;
    }
  }

  /// Generate unique session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  /// Get today's focus minutes
  int get todayFocusMinutes {
    return _todaySessions
        .where(
          (session) => session.type == PomodoroType.work && session.isCompleted,
        )
        .fold(0, (total, session) => total + session.durationMinutes);
  }

  /// Get today's total sessions
  int get todayTotalSessions {
    return _todaySessions.length;
  }

  /// Get session type display name
  String get sessionTypeDisplayName {
    switch (_currentType) {
      case PomodoroType.work:
        return 'Focus Time';
      case PomodoroType.shortBreak:
        return 'Short Break';
      case PomodoroType.longBreak:
        return 'Long Break';
    }
  }

  /// Get session type emoji
  String get sessionTypeEmoji {
    switch (_currentType) {
      case PomodoroType.work:
        return '🍅';
      case PomodoroType.shortBreak:
        return '☕';
      case PomodoroType.longBreak:
        return '🧘';
    }
  }

  /// Get motivational message based on progress
  String get motivationalMessage {
    if (_completedPomodoros == 0) {
      return "Ready to focus? Start your first Pomodoro! 🍅";
    } else if (_completedPomodoros < 2) {
      return "Great start! Keep building momentum! 💪";
    } else if (_completedPomodoros < 4) {
      return "You're in the zone! Keep going! 🔥";
    } else {
      return "Amazing focus session! You're unstoppable! 🚀";
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
