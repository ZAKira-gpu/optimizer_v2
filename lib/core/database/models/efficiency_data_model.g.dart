// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'efficiency_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EfficiencyDataModelAdapter extends TypeAdapter<EfficiencyDataModel> {
  @override
  final int typeId = 4;

  @override
  EfficiencyDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EfficiencyDataModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      date: fields[2] as DateTime,
      tasks: (fields[3] as List).cast<TaskData>(),
      routines: (fields[4] as List).cast<RoutineData>(),
      goals: (fields[5] as List).cast<GoalData>(),
      completedTasks: fields[6] as int,
      totalTasks: fields[7] as int,
      completedPomodoros: fields[8] as int,
      totalFocusMinutes: fields[9] as int,
      efficiencyScore: fields[10] as double,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, EfficiencyDataModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.tasks)
      ..writeByte(4)
      ..write(obj.routines)
      ..writeByte(5)
      ..write(obj.goals)
      ..writeByte(6)
      ..write(obj.completedTasks)
      ..writeByte(7)
      ..write(obj.totalTasks)
      ..writeByte(8)
      ..write(obj.completedPomodoros)
      ..writeByte(9)
      ..write(obj.totalFocusMinutes)
      ..writeByte(10)
      ..write(obj.efficiencyScore)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EfficiencyDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskDataAdapter extends TypeAdapter<TaskData> {
  @override
  final int typeId = 5;

  @override
  TaskData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskData(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      priority: fields[3] as String,
      status: fields[4] as String,
      createdAt: fields[5] as DateTime,
      completedAt: fields[6] as DateTime?,
      estimatedMinutes: fields[7] as int,
      category: fields[8] as String?,
      isTopThree: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskData obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.priority)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.estimatedMinutes)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.isTopThree);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoutineDataAdapter extends TypeAdapter<RoutineData> {
  @override
  final int typeId = 6;

  @override
  RoutineData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineData(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      iconName: fields[3] as String,
      daysOfWeek: (fields[4] as List).cast<String>(),
      reminderTime: fields[5] as String?,
      isActive: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineData obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconName)
      ..writeByte(4)
      ..write(obj.daysOfWeek)
      ..writeByte(5)
      ..write(obj.reminderTime)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalDataAdapter extends TypeAdapter<GoalData> {
  @override
  final int typeId = 7;

  @override
  GoalData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalData(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      type: fields[3] as String,
      status: fields[4] as String,
      targetDate: fields[5] as DateTime,
      targetValue: fields[6] as int,
      currentValue: fields[7] as int,
      unit: fields[8] as String,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GoalData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.targetDate)
      ..writeByte(6)
      ..write(obj.targetValue)
      ..writeByte(7)
      ..write(obj.currentValue)
      ..writeByte(8)
      ..write(obj.unit)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
