import 'package:hive/hive.dart';
import 'holiday.dart';

part 'friend.g.dart';

@HiveType(typeId: 5)
class Friend extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? imagePath;

  @HiveField(3)
  List<Holiday> holidays;

  @HiveField(4)
  String? note;

  @HiveField(5)
  DateTime createdAt;

  Friend({
    required this.id,
    required this.name,
    this.imagePath,
    required this.holidays,
    this.note,
    required this.createdAt,
  });

  factory Friend.create({
    required String name,
    String? imagePath,
    List<Holiday>? holidays,
    String? note,
  }) {
    return Friend(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      imagePath: imagePath,
      holidays: holidays ?? [],
      note: note,
      createdAt: DateTime.now(),
    );
  }

  void addHoliday(Holiday holiday) {
    holidays.add(holiday);
    save();
  }

  void removeHoliday(int index) {
    if (index >= 0 && index < holidays.length) {
      holidays.removeAt(index);
      save();
    }
  }

  void updateName(String newName) {
    name = newName;
    save();
  }

  void updateNote(String? newNote) {
    note = newNote;
    save();
  }

  void updateImagePath(String? newImagePath) {
    imagePath = newImagePath;
    save();
  }

  List<Holiday> get upcomingHolidays {
    // Sort holidays by month and day
    return holidays.toList()
      ..sort((a, b) {
        const months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        int monthComparison = months.indexOf(a.month).compareTo(months.indexOf(b.month));
        if (monthComparison != 0) return monthComparison;
        return a.day.compareTo(b.day);
      });
  }

  @override
  String toString() => 'Friend(id: $id, name: $name, holidays: ${holidays.length})';
}