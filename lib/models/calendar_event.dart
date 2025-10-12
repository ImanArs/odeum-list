import 'package:hive/hive.dart';

part 'calendar_event.g.dart';

@HiveType(typeId: 2)
class CalendarEvent extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  DateTime? startTime;

  @HiveField(5)
  DateTime? endTime;

  @HiveField(6)
  bool isAllDay;

  @HiveField(7)
  String? location;

  @HiveField(8)
  int color;

  @HiveField(9)
  DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.location,
    this.color = 0xFF2196F3,
    required this.createdAt,
  });

  factory CalendarEvent.create({
    required String title,
    String? description,
    required DateTime date,
    DateTime? startTime,
    DateTime? endTime,
    bool isAllDay = false,
    String? location,
    int color = 0xFF2196F3,
  }) {
    return CalendarEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      location: location,
      color: color,
      createdAt: DateTime.now(),
    );
  }
}