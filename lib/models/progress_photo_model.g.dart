// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_photo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressPhotoModelAdapter extends TypeAdapter<ProgressPhotoModel> {
  @override
  final int typeId = 6;

  @override
  ProgressPhotoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressPhotoModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      imagePath: fields[2] as String,
      weight: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressPhotoModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.weight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressPhotoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
