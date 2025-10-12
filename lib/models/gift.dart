import 'package:hive/hive.dart';

part 'gift.g.dart';

@HiveType(typeId: 1)
class Gift extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? recipientName;

  @HiveField(4)
  double? price;

  @HiveField(5)
  String? imageUrl;

  @HiveField(6)
  bool isPurchased;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? targetDate;

  Gift({
    required this.id,
    required this.title,
    this.description,
    this.recipientName,
    this.price,
    this.imageUrl,
    this.isPurchased = false,
    required this.createdAt,
    this.targetDate,
  });

  factory Gift.create({
    required String title,
    String? description,
    String? recipientName,
    double? price,
    String? imageUrl,
    DateTime? targetDate,
  }) {
    return Gift(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      recipientName: recipientName,
      price: price,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      targetDate: targetDate,
    );
  }

  void markAsPurchased() {
    isPurchased = true;
    save();
  }

  void unmarkPurchased() {
    isPurchased = false;
    save();
  }
}