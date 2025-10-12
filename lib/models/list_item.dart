import 'package:hive/hive.dart';

part 'list_item.g.dart';

@HiveType(typeId: 0)
class ListItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  int priority;

  ListItem({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.priority = 0,
  });

  factory ListItem.create({
    required String title,
    String? description,
    int priority = 0,
  }) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      priority: priority,
    );
  }

  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
    save();
  }

  void uncomplete() {
    isCompleted = false;
    completedAt = null;
    save();
  }
}