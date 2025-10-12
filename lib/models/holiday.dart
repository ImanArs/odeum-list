import 'package:hive/hive.dart';

part 'holiday.g.dart';

@HiveType(typeId: 4)
class Holiday extends HiveObject {
  @HiveField(0)
  String type;

  @HiveField(1)
  int day;

  @HiveField(2)
  String month;

  Holiday({
    required this.type,
    required this.day,
    required this.month,
  });

  factory Holiday.create({
    required String type,
    required int day,
    required String month,
  }) {
    return Holiday(
      type: type,
      day: day,
      month: month,
    );
  }

  String get formattedDate => '$day ${month.substring(0, 3)}';

  @override
  String toString() => '$type - $formattedDate';
}