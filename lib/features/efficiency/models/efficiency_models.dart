import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Task model for productivity tracking
class Task {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int estimatedMinutes;
  final String? category;
  final bool isTopThree;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.estimatedMinutes,
    this.category,
    this.isTopThree = false,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'estimatedMinutes': estimatedMinutes,
      'category': category,
      'isTopThree': isTopThree,
    };
  }

  /// Create from Firestore document
  factory Task.fromFirestore(Map<String, dynamic> data) {
    return Task(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TaskStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      estimatedMinutes: data['estimatedMinutes'] ?? 30,
      category: data['category'],
      isTopThree: data['isTopThree'] ?? false,
    );
  }

  /// Create empty task
  factory Task.empty() {
    return Task(
      id: '',
      title: '',
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      createdAt: DateTime.now(),
      estimatedMinutes: 30,
    );
  }

  /// Update task
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    int? estimatedMinutes,
    String? category,
    bool? isTopThree,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      category: category ?? this.category,
      isTopThree: isTopThree ?? this.isTopThree,
    );
  }
}

/// Task priority levels
enum TaskPriority { low, medium, high, urgent }

/// Task status
enum TaskStatus { pending, inProgress, completed, cancelled }

/// Pomodoro session model
class PomodoroSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final PomodoroType type;
  final bool isCompleted;
  final String? taskId; // Associated task if any

  PomodoroSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.type,
    required this.isCompleted,
    this.taskId,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMinutes': durationMinutes,
      'type': type.name,
      'isCompleted': isCompleted,
      'taskId': taskId,
    };
  }

  /// Create from Firestore document
  factory PomodoroSession.fromFirestore(Map<String, dynamic> data) {
    return PomodoroSession(
      id: data['id'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      durationMinutes: data['durationMinutes'] ?? 25,
      type: PomodoroType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PomodoroType.work,
      ),
      isCompleted: data['isCompleted'] ?? false,
      taskId: data['taskId'],
    );
  }

  /// Create empty session
  factory PomodoroSession.empty() {
    return PomodoroSession(
      id: '',
      startTime: DateTime.now(),
      durationMinutes: 25,
      type: PomodoroType.work,
      isCompleted: false,
    );
  }
}

/// Pomodoro session types
enum PomodoroType { work, shortBreak, longBreak }

/// Routine/Habit model
class Routine {
  final String id;
  final String title;
  final String? description;
  final String iconName; // Icon identifier
  final List<String> daysOfWeek; // ['monday', 'tuesday', etc.]
  final TimeOfDay? reminderTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Routine({
    required this.id,
    required this.title,
    this.description,
    required this.iconName,
    required this.daysOfWeek,
    this.reminderTime,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'daysOfWeek': daysOfWeek,
      'reminderTime': reminderTime != null
          ? {'hour': reminderTime!.hour, 'minute': reminderTime!.minute}
          : null,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory Routine.fromFirestore(Map<String, dynamic> data) {
    return Routine(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      iconName: data['iconName'] ?? 'wb_sunny_rounded',
      daysOfWeek: List<String>.from(data['daysOfWeek'] ?? []),
      reminderTime: data['reminderTime'] != null
          ? TimeOfDay(
              hour: data['reminderTime']['hour'] ?? 9,
              minute: data['reminderTime']['minute'] ?? 0,
            )
          : null,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Create empty routine
  factory Routine.empty() {
    final now = DateTime.now();
    return Routine(
      id: '',
      title: '',
      iconName: 'wb_sunny_rounded',
      daysOfWeek: [],
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Update routine
  Routine copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    List<String>? daysOfWeek,
    TimeOfDay? reminderTime,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Goal model
class Goal {
  final String id;
  final String title;
  final String? description;
  final GoalType type;
  final GoalStatus status;
  final DateTime targetDate;
  final int targetValue;
  final int currentValue;
  final String unit; // e.g., 'tasks', 'hours', 'days'
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.targetDate,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'targetDate': Timestamp.fromDate(targetDate),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory Goal.fromFirestore(Map<String, dynamic> data) {
    return Goal(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      type: GoalType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => GoalType.task,
      ),
      status: GoalStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => GoalStatus.active,
      ),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      targetValue: data['targetValue'] ?? 1,
      currentValue: data['currentValue'] ?? 0,
      unit: data['unit'] ?? 'tasks',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Create empty goal
  factory Goal.empty() {
    final now = DateTime.now();
    return Goal(
      id: '',
      title: '',
      type: GoalType.task,
      status: GoalStatus.active,
      targetDate: now.add(const Duration(days: 30)),
      targetValue: 1,
      currentValue: 0,
      unit: 'tasks',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Update goal
  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    GoalStatus? status,
    DateTime? targetDate,
    int? targetValue,
    int? currentValue,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      targetDate: targetDate ?? this.targetDate,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get progress percentage
  double get progressPercentage =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  /// Check if goal is completed
  bool get isCompleted => currentValue >= targetValue;
}

/// Goal types
enum GoalType { task, pomodoro, routine, custom }

/// Goal status
enum GoalStatus { active, completed, paused, cancelled }

/// Daily productivity summary
class DailyProductivitySummary {
  final String userId;
  final DateTime date;
  final List<Task> tasks;
  final List<PomodoroSession> pomodoroSessions;
  final List<Routine> routines;
  final List<Goal> goals;
  final int completedTasks;
  final int totalTasks;
  final int completedPomodoros;
  final int totalFocusMinutes;
  final double efficiencyScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyProductivitySummary({
    required this.userId,
    required this.date,
    required this.tasks,
    required this.pomodoroSessions,
    required this.routines,
    required this.goals,
    required this.completedTasks,
    required this.totalTasks,
    required this.completedPomodoros,
    required this.totalFocusMinutes,
    required this.efficiencyScore,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'tasks': tasks.map((task) => task.toFirestore()).toList(),
      'pomodoroSessions': pomodoroSessions
          .map((session) => session.toFirestore())
          .toList(),
      'routines': routines.map((routine) => routine.toFirestore()).toList(),
      'goals': goals.map((goal) => goal.toFirestore()).toList(),
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'completedPomodoros': completedPomodoros,
      'totalFocusMinutes': totalFocusMinutes,
      'efficiencyScore': efficiencyScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory DailyProductivitySummary.fromFirestore(Map<String, dynamic> data) {
    return DailyProductivitySummary(
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      tasks:
          (data['tasks'] as List<dynamic>?)
              ?.map((task) => Task.fromFirestore(task))
              .toList() ??
          [],
      pomodoroSessions:
          (data['pomodoroSessions'] as List<dynamic>?)
              ?.map((session) => PomodoroSession.fromFirestore(session))
              .toList() ??
          [],
      routines:
          (data['routines'] as List<dynamic>?)
              ?.map((routine) => Routine.fromFirestore(routine))
              .toList() ??
          [],
      goals:
          (data['goals'] as List<dynamic>?)
              ?.map((goal) => Goal.fromFirestore(goal))
              .toList() ??
          [],
      completedTasks: data['completedTasks'] ?? 0,
      totalTasks: data['totalTasks'] ?? 0,
      totalFocusMinutes: data['totalFocusMinutes'] ?? 0,
      completedPomodoros: data['completedPomodoros'] ?? 0,
      efficiencyScore: (data['efficiencyScore'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Create empty summary for a new day
  factory DailyProductivitySummary.empty(String userId, DateTime date) {
    return DailyProductivitySummary(
      userId: userId,
      date: date,
      tasks: [],
      pomodoroSessions: [],
      routines: [],
      goals: [],
      completedTasks: 0,
      totalTasks: 0,
      completedPomodoros: 0,
      totalFocusMinutes: 0,
      efficiencyScore: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate efficiency score
  double get taskCompletionRate =>
      totalTasks > 0 ? completedTasks / totalTasks : 0.0;

  /// Get top 3 tasks
  List<Task> get topThreeTasks =>
      tasks.where((task) => task.isTopThree).take(3).toList();

  /// Get motivational message based on progress
  String get motivationalMessage {
    if (completedTasks == 0) {
      return "Ready to tackle today? Start with your top task! 💪";
    } else if (completedTasks < totalTasks / 2) {
      return "Great start! Keep the momentum going! 🚀";
    } else if (completedTasks < totalTasks) {
      return "You're on fire! Almost there! 🔥";
    } else {
      return "Amazing! You've crushed all your tasks! 🎉";
    }
  }
}
