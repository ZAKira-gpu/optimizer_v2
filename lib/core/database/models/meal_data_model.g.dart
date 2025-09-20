// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealDataModelAdapter extends TypeAdapter<MealDataModel> {
  @override
  final int typeId = 1;

  @override
  MealDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealDataModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      mealType: fields[2] as String,
      items: (fields[3] as List).cast<MealItemData>(),
      loggedAt: fields[4] as DateTime,
      notes: fields[5] as String?,
      imageUrl: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MealDataModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.mealType)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.loggedAt)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.imageUrl)
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
      other is MealDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MealItemDataAdapter extends TypeAdapter<MealItemData> {
  @override
  final int typeId = 2;

  @override
  MealItemData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealItemData(
      id: fields[0] as String,
      foodName: fields[1] as String,
      nutrition: fields[2] as NutritionInfoData,
      portionMultiplier: fields[3] as double,
      imageUrl: fields[4] as String?,
      barcode: fields[5] as String?,
      recognitionType: fields[6] as String,
      loggedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MealItemData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.foodName)
      ..writeByte(2)
      ..write(obj.nutrition)
      ..writeByte(3)
      ..write(obj.portionMultiplier)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.barcode)
      ..writeByte(6)
      ..write(obj.recognitionType)
      ..writeByte(7)
      ..write(obj.loggedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealItemDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutritionInfoDataAdapter extends TypeAdapter<NutritionInfoData> {
  @override
  final int typeId = 3;

  @override
  NutritionInfoData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionInfoData(
      foodName: fields[0] as String,
      calories: fields[1] as double,
      protein: fields[2] as double,
      carbs: fields[3] as double,
      fat: fields[4] as double,
      fiber: fields[5] as double,
      sugar: fields[6] as double,
      sodium: fields[7] as double,
      servingSize: fields[8] as String,
      servingWeight: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionInfoData obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.foodName)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.protein)
      ..writeByte(3)
      ..write(obj.carbs)
      ..writeByte(4)
      ..write(obj.fat)
      ..writeByte(5)
      ..write(obj.fiber)
      ..writeByte(6)
      ..write(obj.sugar)
      ..writeByte(7)
      ..write(obj.sodium)
      ..writeByte(8)
      ..write(obj.servingSize)
      ..writeByte(9)
      ..write(obj.servingWeight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionInfoDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
