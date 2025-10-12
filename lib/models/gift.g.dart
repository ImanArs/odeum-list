// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GiftAdapter extends TypeAdapter<Gift> {
  @override
  final int typeId = 1;

  @override
  Gift read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gift(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      recipientName: fields[3] as String?,
      price: fields[4] as double?,
      imageUrl: fields[5] as String?,
      isPurchased: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      targetDate: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Gift obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.recipientName)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.isPurchased)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.targetDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
