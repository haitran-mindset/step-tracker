// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_steps_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyStepsModelAdapter extends TypeAdapter<DailyStepsModel> {
  @override
  final int typeId = 1;

  @override
  DailyStepsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyStepsModel(
      date: fields[0] as DateTime,
      steps: fields[1] as int,
      goal: fields[2] as int,
      caloriesBurned: fields[3] as double,
      distanceKm: fields[4] as double,
      activeMinutes: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyStepsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.steps)
      ..writeByte(2)
      ..write(obj.goal)
      ..writeByte(3)
      ..write(obj.caloriesBurned)
      ..writeByte(4)
      ..write(obj.distanceKm)
      ..writeByte(5)
      ..write(obj.activeMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyStepsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
