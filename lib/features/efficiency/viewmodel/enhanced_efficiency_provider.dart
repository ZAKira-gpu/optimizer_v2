import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/efficiency_models.dart';
import '../services/pomodoro_service.dart';
import '../../../core/database/providers/hive_sync_provider.dart';

/// Enhanced efficiency provider with automatic Hive synchronization
class EnhancedEfficiencyProvider extends ChangeNotifier {
  final PomodoroService _pomodoroService = PomodoroService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HiveSyncProvider _hiveSyncProvider = HiveSyncProvider();

  // State variables
  List<Task> _tasks = [];
  List<Routine> _routines = [];
  List<Goal> _goals = [];
  DailyProductivitySummary? _dailySummary;
  bool _isLoading = false;
  String _error = '';

  // Getters
  PomodoroService get pomodoroService => _pomodoroService;
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Routine> get routines => List.unmodifiable(_routines);
  List<Goal> get goals => List.unmodifiable(_goals);
  DailyProductivitySummary? get dailySummary => _dailySummary;
  bool get isLoading => _isLoading;
  String get error => _error;

  /// Get top three tasks
  List<Task> get topThreeTasks =>
      _tasks.where((task) => task.isTopThree).take(3).toList();

  /// Get task completion progress (0.0 to 1.0)
  double get taskCompletionProgress {
    final totalTasks = _tasks.length;
    final completedTasks = _tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
    return totalTasks > 0 ? completedTasks / totalTasks : 0.0;
  }

  /// Get active routines for today
  List<Routine> get todayRoutines {
    final today = DateTime.now().weekday;
    final dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final todayName = dayNames[today - 1];

    return _routines
        .where(
          (routine) =>
              routine.isActive && routine.daysOfWeek.contains(todayName),
        )
        .toList();
  }

  /// Get active goals
  List<Goal> get activeGoals =>
      _goals.where((goal) => goal.status == GoalStatus.active).toList();

  /// Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Initialize Hive sync provider
      await _hiveSyncProvider.initialize();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _loadUserData(user.uid);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      // Load tasks
      await _loadTasks(userId);

      // Load routines
      await _loadRoutines(userId);

      // Load goals
      await _loadGoals(userId);

      // Load today's summary
      await _loadTodaySummary(userId);
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }

  /// Load tasks from Firestore
  Future<void> _loadTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('efficiency')
          .doc('tasks')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        final tasksData = data['tasks'] as List<dynamic>? ?? [];
        _tasks = tasksData
            .map((taskData) => Task.fromFirestore(taskData))
            .toList();
      } else {
        _tasks = [];
      }
    } catch (e) {
      print('Error loading tasks: $e');
      _tasks = [];
    }
  }

  /// Load routines from Firestore
  Future<void> _loadRoutines(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('efficiency')
          .doc('routines')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        final routinesData = data['routines'] as List<dynamic>? ?? [];
        _routines = routinesData
            .map((routineData) => Routine.fromFirestore(routineData))
            .toList();
      } else {
        _routines = [];
      }
    } catch (e) {
      print('Error loading routines: $e');
      _routines = [];
    }
  }

  /// Load goals from Firestore
  Future<void> _loadGoals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('efficiency')
          .doc('goals')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        final goalsData = data['goals'] as List<dynamic>? ?? [];
        _goals = goalsData
            .map((goalData) => Goal.fromFirestore(goalData))
            .toList();
      } else {
        _goals = [];
      }
    } catch (e) {
      print('Error loading goals: $e');
      _goals = [];
    }
  }

  /// Load today's summary from Firestore
  Future<void> _loadTodaySummary(String userId) async {
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final snapshot = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('efficiency')
          .doc('dailySummaries')
          .collection('summaries')
          .doc(dateStr)
          .get();

      if (snapshot.exists) {
        _dailySummary = DailyProductivitySummary.fromFirestore(
          snapshot.data()!,
        );
      } else {
        _dailySummary = DailyProductivitySummary.empty(userId, today);
      }
    } catch (e) {
      print('Error loading today summary: $e');
      final user = FirebaseAuth.instance.currentUser;
      _dailySummary = DailyProductivitySummary.empty(
        user?.uid ?? '',
        DateTime.now(),
      );
    }
  }

  /// Save tasks to Firestore
  Future<void> _saveTasks(String userId) async {
    try {
      await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('efficiency')
          .doc('tasks')
          .set({
            'tasks': _tasks.map((task) => task.toFirestore()).toList(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to save tasks: $e');
    }
  }

  /// Save routines to Firestore
  Future<void> _saveRoutines(String userId) async {
    try {
      await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('efficiency')
          .doc('routines')
          .set({
            'routines': _routines
                .map((routine) => routine.toFirestore())
                .toList(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to save routines: $e');
    }
  }

  /// Save goals to Firestore
  Future<void> _saveGoals(String userId) async {
    try {
      await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('efficiency')
          .doc('goals')
          .set({
            'goals': _goals.map((goal) => goal.toFirestore()).toList(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to save goals: $e');
    }
  }

  /// Save today's summary to Firestore
  Future<void> _saveTodaySummary() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _firestore
          .collection('userProfiles')
          .doc(user.uid)
          .collection('efficiency')
          .doc('dailySummaries')
          .collection('summaries')
          .doc(dateStr)
          .set(_dailySummary!.toFirestore());
    } catch (e) {
      print('Error saving today summary: $e');
    }
  }

  // TASK MANAGEMENT

  /// Add a new task
  Future<void> addTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    int estimatedMinutes = 30,
    String? category,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        notifyListeners();
        return;
      }

      final newTask = Task(
        id: _generateId(),
        title: title,
        description: description,
        priority: priority,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        estimatedMinutes: estimatedMinutes,
        category: category,
        isTopThree: topThreeTasks.length < 3,
      );

      _tasks.add(newTask);
      await _saveTasks(user.uid);
      await _updateTodaySummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add task: $e';
      notifyListeners();
    }
  }

  /// Complete a task
  Future<void> completeTask(String taskId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex] = _tasks[taskIndex].copyWith(
          status: TaskStatus.completed,
          completedAt: DateTime.now(),
        );
        await _saveTasks(user.uid);
        await _updateTodaySummary();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to complete task: $e';
      notifyListeners();
    }
  }

  /// Update task
  Future<void> updateTask(Task updatedTask) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (taskIndex != -1) {
        _tasks[taskIndex] = updatedTask;
        await _saveTasks(user.uid);
        await _updateTodaySummary();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update task: $e';
      notifyListeners();
    }
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _tasks.removeWhere((task) => task.id == taskId);
      await _saveTasks(user.uid);
      await _updateTodaySummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete task: $e';
      notifyListeners();
    }
  }

  // ROUTINE MANAGEMENT

  /// Add a new routine
  Future<void> addRoutine({
    required String title,
    String? description,
    required String iconName,
    required List<String> daysOfWeek,
    TimeOfDay? reminderTime,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        notifyListeners();
        return;
      }

      final newRoutine = Routine(
        id: _generateId(),
        title: title,
        description: description,
        iconName: iconName,
        daysOfWeek: daysOfWeek,
        reminderTime: reminderTime,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _routines.add(newRoutine);
      await _saveRoutines(user.uid);
      await _updateTodaySummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add routine: $e';
      notifyListeners();
    }
  }

  /// Update routine
  Future<void> updateRoutine(Routine updatedRoutine) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final routineIndex = _routines.indexWhere(
        (routine) => routine.id == updatedRoutine.id,
      );
      if (routineIndex != -1) {
        _routines[routineIndex] = updatedRoutine.copyWith(
          updatedAt: DateTime.now(),
        );
        await _saveRoutines(user.uid);
        await _updateTodaySummary();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update routine: $e';
      notifyListeners();
    }
  }

  /// Delete routine
  Future<void> deleteRoutine(String routineId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _routines.removeWhere((routine) => routine.id == routineId);
      await _saveRoutines(user.uid);
      await _updateTodaySummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete routine: $e';
      notifyListeners();
    }
  }

  /// Toggle routine active status
  Future<void> toggleRoutineStatus(String routineId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final routineIndex = _routines.indexWhere(
        (routine) => routine.id == routineId,
      );
      if (routineIndex != -1) {
        _routines[routineIndex] = _routines[routineIndex].copyWith(
          isActive: !_routines[routineIndex].isActive,
          updatedAt: DateTime.now(),
        );
        await _saveRoutines(user.uid);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to toggle routine status: $e';
      notifyListeners();
    }
  }

  // GOAL MANAGEMENT

  /// Add a new goal
  Future<void> addGoal({
    required String title,
    String? description,
    required GoalType type,
    required DateTime targetDate,
    required int targetValue,
    required String unit,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        notifyListeners();
        return;
      }

      final newGoal = Goal(
        id: _generateId(),
        title: title,
        description: description,
        type: type,
        status: GoalStatus.active,
        targetDate: targetDate,
        targetValue: targetValue,
        currentValue: 0,
        unit: unit,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _goals.add(newGoal);
      await _saveGoals(user.uid);
      await _updateTodaySummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add goal: $e';
      notifyListeners();
    }
  }

  /// Update goal
  Future<void> updateGoal(Goal updatedGoal) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final goalIndex = _goals.indexWhere((goal) => goal.id == updatedGoal.id);
      if (goalIndex != -1) {
        _goals[goalIndex] = updatedGoal.copyWith(updatedAt: DateTime.now());
        await _saveGoals(user.uid);
        await _updateTodaySummary();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update goal: $e';
      notifyListeners();
    }
  }

  /// Delete goal
  Future<void> deleteGoal(String goalId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _goals.removeWhere((goal) => goal.id == goalId);
      await _saveGoals(user.uid);
      await _updateTodaySummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete goal: $e';
      notifyListeners();
    }
  }

  /// Update goal progress
  Future<void> updateGoalProgress(String goalId, int newValue) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        _goals[goalIndex] = goal.copyWith(
          currentValue: newValue,
          status: newValue >= goal.targetValue
              ? GoalStatus.completed
              : GoalStatus.active,
          updatedAt: DateTime.now(),
        );
        await _saveGoals(user.uid);
        await _updateTodaySummary();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update goal progress: $e';
      notifyListeners();
    }
  }

  /// Update today's summary
  Future<void> _updateTodaySummary() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final today = DateTime.now();
      final completedTasks = _tasks
          .where((task) => task.status == TaskStatus.completed)
          .length;
      final totalTasks = _tasks.length;
      final completedPomodoros = _pomodoroService.completedPomodoros;
      final totalFocusMinutes = _pomodoroService.todayFocusMinutes;

      _dailySummary = DailyProductivitySummary(
        userId: user.uid,
        date: today,
        tasks: _tasks,
        pomodoroSessions: _pomodoroService.todaySessions,
        routines: _routines,
        goals: _goals,
        completedTasks: completedTasks,
        totalTasks: totalTasks,
        completedPomodoros: completedPomodoros,
        totalFocusMinutes: totalFocusMinutes,
        efficiencyScore: _calculateEfficiencyScore(),
        createdAt: _dailySummary?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _saveTodaySummary();

      // Sync to Hive database
      try {
        await _hiveSyncProvider.syncEfficiencyData(
          userId: user.uid,
          date: today,
          tasks: _tasks.map((task) => task.toFirestore()).toList(),
          routines: _routines.map((routine) => routine.toFirestore()).toList(),
          goals: _goals.map((goal) => goal.toFirestore()).toList(),
          completedTasks: completedTasks,
          totalTasks: totalTasks,
          completedPomodoros: completedPomodoros,
          totalFocusMinutes: totalFocusMinutes,
          efficiencyScore: _calculateEfficiencyScore(),
        );
        print('✅ Efficiency data synced to Hive');
      } catch (e) {
        print('⚠️ Failed to sync efficiency data to Hive: $e');
        // Don't fail the entire operation if Hive sync fails
      }
    } catch (e) {
      print('Error updating today summary: $e');
    }
  }

  /// Calculate efficiency score (0.0 to 100.0)
  double _calculateEfficiencyScore() {
    final taskScore = taskCompletionProgress * 40; // 40% weight for tasks
    final pomodoroScore =
        (_pomodoroService.completedPomodoros / 8.0) *
        30; // 30% weight for pomodoros
    final goalScore = _goals.isNotEmpty
        ? (_goals.where((goal) => goal.isCompleted).length / _goals.length) * 30
        : 0; // 30% weight for goals
    return (taskScore + pomodoroScore + goalScore).clamp(0.0, 100.0);
  }

  /// Start Pomodoro for a specific task
  void startPomodoroForTask(String taskId) {
    _pomodoroService.startTimer(taskId: taskId);
  }

  /// Get priority color
  Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Color(0xFF4CAF50); // Green
      case TaskPriority.medium:
        return const Color(0xFF2196F3); // Blue
      case TaskPriority.high:
        return const Color(0xFFFF9800); // Orange
      case TaskPriority.urgent:
        return const Color(0xFFF44336); // Red
    }
  }

  /// Get priority display name
  String getPriorityDisplayName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  /// Get goal type display name
  String getGoalTypeDisplayName(GoalType type) {
    switch (type) {
      case GoalType.task:
        return 'Tasks';
      case GoalType.pomodoro:
        return 'Pomodoros';
      case GoalType.routine:
        return 'Routines';
      case GoalType.custom:
        return 'Custom';
    }
  }

  /// Get goal status display name
  String getGoalStatusDisplayName(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.paused:
        return 'Paused';
      case GoalStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Generate unique ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_tasks.length + _routines.length + _goals.length}';
  }

  @override
  void dispose() {
    _pomodoroService.dispose();
    super.dispose();
  }
}
