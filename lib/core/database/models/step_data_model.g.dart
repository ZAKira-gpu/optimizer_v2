// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StepDataModelAdapter extends TypeAdapter<StepDataModel> {
  @override
  final int typeId = 8;

  @override
  StepDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StepDataModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      date: fields[2] as DateTime,
      steps: fields[3] as int,
      distance: fields[4] as double,
      calories: fields[5] as double,
      status: fields[6] as String,
      userHeight: fields[7] as double,
      userWeight: fields[8] as double,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StepDataModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.steps)
      ..writeByte(4)
      ..write(obj.distance)
      ..writeByte(5)
      ..write(obj.calories)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.userHeight)
      ..writeByte(8)
      ..write(obj.userWeight)
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
      other is StepDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
