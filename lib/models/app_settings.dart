import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  String language;

  @HiveField(2)
  bool enableNotifications;

  @HiveField(3)
  int defaultPriority;

  @HiveField(4)
  bool showCompletedItems;

  @HiveField(5)
  String sortBy;

  @HiveField(6)
  DateTime lastUpdated;

  AppSettings({
    this.isDarkMode = false,
    this.language = 'en',
    this.enableNotifications = true,
    this.defaultPriority = 0,
    this.showCompletedItems = true,
    this.sortBy = 'createdAt',
    required this.lastUpdated,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      lastUpdated: DateTime.now(),
    );
  }

  void updateSettings({
    bool? isDarkMode,
    String? language,
    bool? enableNotifications,
    int? defaultPriority,
    bool? showCompletedItems,
    String? sortBy,
  }) {
    if (isDarkMode != null) this.isDarkMode = isDarkMode;
    if (language != null) this.language = language;
    if (enableNotifications != null) this.enableNotifications = enableNotifications;
    if (defaultPriority != null) this.defaultPriority = defaultPriority;
    if (showCompletedItems != null) this.showCompletedItems = showCompletedItems;
    if (sortBy != null) this.sortBy = sortBy;
    lastUpdated = DateTime.now();
    save();
  }
}