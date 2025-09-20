// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthDataModelAdapter extends TypeAdapter<HealthDataModel> {
  @override
  final int typeId = 0;

  @override
  HealthDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthDataModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      date: fields[2] as DateTime,
      sleepHours: fields[3] as double,
      steps: fields[4] as int,
      caloriesIn: fields[5] as double,
      caloriesOut: fields[6] as double,
      tasksDone: fields[7] as int,
      goalProgress: fields[8] as double,
      efficiencyScore: fields[9] as double,
      healthScore: fields[10] as double,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HealthDataModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.sleepHours)
      ..writeByte(4)
      ..write(obj.steps)
      ..writeByte(5)
      ..write(obj.caloriesIn)
      ..writeByte(6)
      ..write(obj.caloriesOut)
      ..writeByte(7)
      ..write(obj.tasksDone)
      ..writeByte(8)
      ..write(obj.goalProgress)
      ..writeByte(9)
      ..write(obj.efficiencyScore)
      ..writeByte(10)
      ..write(obj.healthScore)
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
      other is HealthDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
