import 'package:hive/hive.dart';

part 'efficiency_data_model.g.dart';

/// Hive model for storing efficiency/task data locally
@HiveType(typeId: 4)
class EfficiencyDataModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final List<TaskData> tasks;

  @HiveField(4)
  final List<RoutineData> routines;

  @HiveField(5)
  final List<GoalData> goals;

  @HiveField(6)
  final int completedTasks;

  @HiveField(7)
  final int totalTasks;

  @HiveField(8)
  final int completedPomodoros;

  @HiveField(9)
  final int totalFocusMinutes;

  @HiveField(10)
  final double efficiencyScore;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  EfficiencyDataModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.tasks,
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

  /// Create from Firestore data
  factory EfficiencyDataModel.fromFirestore(Map<String, dynamic> data) {
    return EfficiencyDataModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      date: data['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['date'])
          : DateTime.now(),
      tasks: (data['tasks'] as List<dynamic>? ?? [])
          .map((task) => TaskData.fromMap(task))
          .toList(),
      routines: (data['routines'] as List<dynamic>? ?? [])
          .map((routine) => RoutineData.fromMap(routine))
          .toList(),
      goals: (data['goals'] as List<dynamic>? ?? [])
          .map((goal) => GoalData.fromMap(goal))
          .toList(),
      completedTasks: data['completedTasks'] ?? 0,
      totalTasks: data['totalTasks'] ?? 0,
      completedPomodoros: data['completedPomodoros'] ?? 0,
      totalFocusMinutes: data['totalFocusMinutes'] ?? 0,
      efficiencyScore: (data['efficiencyScore'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'date': date.millisecondsSinceEpoch,
      'tasks': tasks.map((task) => task.toMap()).toList(),
      'routines': routines.map((routine) => routine.toMap()).toList(),
      'goals': goals.map((goal) => goal.toMap()).toList(),
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'completedPomodoros': completedPomodoros,
      'totalFocusMinutes': totalFocusMinutes,
      'efficiencyScore': efficiencyScore,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create empty efficiency data
  factory EfficiencyDataModel.empty(String userId, DateTime date) {
    return EfficiencyDataModel(
      id: '${userId}_${date.millisecondsSinceEpoch}',
      userId: userId,
      date: date,
      tasks: [],
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

  /// Create a copy with updated values
  EfficiencyDataModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<TaskData>? tasks,
    List<RoutineData>? routines,
    List<GoalData>? goals,
    int? completedTasks,
    int? totalTasks,
    int? completedPomodoros,
    int? totalFocusMinutes,
    double? efficiencyScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EfficiencyDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
      routines: routines ?? this.routines,
      goals: goals ?? this.goals,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      efficiencyScore: efficiencyScore ?? this.efficiencyScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Hive model for task data
@HiveType(typeId: 5)
class TaskData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String priority;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? completedAt;

  @HiveField(7)
  final int estimatedMinutes;

  @HiveField(8)
  final String? category;

  @HiveField(9)
  final bool isTopThree;

  TaskData({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.estimatedMinutes,
    this.category,
    required this.isTopThree,
  });

  /// Create from map
  factory TaskData.fromMap(Map<String, dynamic> data) {
    return TaskData(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      priority: data['priority'] ?? 'medium',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      completedAt: data['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['completedAt'])
          : null,
      estimatedMinutes: data['estimatedMinutes'] ?? 30,
      category: data['category'],
      isTopThree: data['isTopThree'] ?? false,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'estimatedMinutes': estimatedMinutes,
      'category': category,
      'isTopThree': isTopThree,
    };
  }
}

/// Hive model for routine data
@HiveType(typeId: 6)
class RoutineData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String iconName;

  @HiveField(4)
  final List<String> daysOfWeek;

  @HiveField(5)
  final String? reminderTime;

  @HiveField(6)
  final bool isActive;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  RoutineData({
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

  /// Create from map
  factory RoutineData.fromMap(Map<String, dynamic> data) {
    return RoutineData(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      iconName: data['iconName'] ?? 'routine',
      daysOfWeek: List<String>.from(data['daysOfWeek'] ?? []),
      reminderTime: data['reminderTime'],
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'daysOfWeek': daysOfWeek,
      'reminderTime': reminderTime,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

/// Hive model for goal data
@HiveType(typeId: 7)
class GoalData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final DateTime targetDate;

  @HiveField(6)
  final int targetValue;

  @HiveField(7)
  final int currentValue;

  @HiveField(8)
  final String unit;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  GoalData({
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

  /// Create from map
  factory GoalData.fromMap(Map<String, dynamic> data) {
    return GoalData(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      type: data['type'] ?? 'custom',
      status: data['status'] ?? 'active',
      targetDate: data['targetDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['targetDate'])
          : DateTime.now().add(const Duration(days: 30)),
      targetValue: data['targetValue'] ?? 0,
      currentValue: data['currentValue'] ?? 0,
      unit: data['unit'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}
