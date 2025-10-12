import 'package:hive/hive.dart';
import '../models/list_item.dart';
import '../models/gift.dart';
import '../models/calendar_event.dart';
import '../models/app_settings.dart';
import '../models/friend.dart';
import '../models/holiday.dart';

class StorageService {
  static const String _listItemsBoxName = 'listItems';
  static const String _giftsBoxName = 'gifts';
  static const String _eventsBoxName = 'events';
  static const String _settingsBoxName = 'settings';
  static const String _friendsBoxName = 'ol-friend';

  static late Box<ListItem> _listItemsBox;
  static late Box<Gift> _giftsBox;
  static late Box<CalendarEvent> _eventsBox;
  static late Box<AppSettings> _settingsBox;
  static late Box<Friend> _friendsBox;

  static Future<void> init() async {
    Hive.registerAdapter(ListItemAdapter());
    Hive.registerAdapter(GiftAdapter());
    Hive.registerAdapter(CalendarEventAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(HolidayAdapter());
    Hive.registerAdapter(FriendAdapter());

    _listItemsBox = await Hive.openBox<ListItem>(_listItemsBoxName);
    _giftsBox = await Hive.openBox<Gift>(_giftsBoxName);
    _eventsBox = await Hive.openBox<CalendarEvent>(_eventsBoxName);
    _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
    _friendsBox = await Hive.openBox<Friend>(_friendsBoxName);
  }

  // List Items
  static Future<void> addListItem(ListItem item) async {
    await _listItemsBox.put(item.id, item);
  }

  static List<ListItem> getAllListItems() {
    return _listItemsBox.values.toList();
  }

  static List<ListItem> getActiveListItems() {
    return _listItemsBox.values.where((item) => !item.isCompleted).toList();
  }

  static List<ListItem> getCompletedListItems() {
    return _listItemsBox.values.where((item) => item.isCompleted).toList();
  }

  static Future<void> updateListItem(ListItem item) async {
    await _listItemsBox.put(item.id, item);
  }

  static Future<void> deleteListItem(String id) async {
    await _listItemsBox.delete(id);
  }

  // Gifts
  static Future<void> addGift(Gift gift) async {
    await _giftsBox.put(gift.id, gift);
  }

  static List<Gift> getAllGifts() {
    return _giftsBox.values.toList();
  }

  static List<Gift> getPurchasedGifts() {
    return _giftsBox.values.where((gift) => gift.isPurchased).toList();
  }

  static List<Gift> getUnpurchasedGifts() {
    return _giftsBox.values.where((gift) => !gift.isPurchased).toList();
  }

  static Future<void> updateGift(Gift gift) async {
    await _giftsBox.put(gift.id, gift);
  }

  static Future<void> deleteGift(String id) async {
    await _giftsBox.delete(id);
  }

  // Calendar Events
  static Future<void> addEvent(CalendarEvent event) async {
    await _eventsBox.put(event.id, event);
  }

  static List<CalendarEvent> getAllEvents() {
    return _eventsBox.values.toList();
  }

  static List<CalendarEvent> getEventsForDate(DateTime date) {
    return _eventsBox.values
        .where((event) => isSameDay(event.date, date))
        .toList();
  }

  static List<CalendarEvent> getUpcomingEvents() {
    final now = DateTime.now();
    return _eventsBox.values
        .where((event) => event.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static Future<void> updateEvent(CalendarEvent event) async {
    await _eventsBox.put(event.id, event);
  }

  static Future<void> deleteEvent(String id) async {
    await _eventsBox.delete(id);
  }

  // Settings
  static Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('app_settings', settings);
  }

  static AppSettings getSettings() {
    return _settingsBox.get('app_settings') ?? AppSettings.defaultSettings();
  }

  // Friends
  static Future<void> addFriend(Friend friend) async {
    await _friendsBox.put(friend.id, friend);
  }

  static List<Friend> getAllFriends() {
    return _friendsBox.values.toList();
  }

  static Friend? getFriendById(String id) {
    return _friendsBox.get(id);
  }

  static List<Friend> searchFriends(String query) {
    return _friendsBox.values
        .where((friend) =>
            friend.name.toLowerCase().contains(query.toLowerCase()) ||
            (friend.note?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }

  static List<Friend> getFriendsWithUpcomingHolidays() {
    final now = DateTime.now();
    final currentMonth = now.month;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return _friendsBox.values
        .where((friend) => friend.holidays.any((holiday) {
          final holidayMonth = months.indexOf(holiday.month) + 1;
          // Check if holiday is in current month or next month
          return holidayMonth == currentMonth ||
                 holidayMonth == (currentMonth % 12) + 1;
        }))
        .toList();
  }

  static Future<void> updateFriend(Friend friend) async {
    await _friendsBox.put(friend.id, friend);
  }

  static Future<void> deleteFriend(String id) async {
    await _friendsBox.delete(id);
  }

  // Utility methods
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static Future<void> clearAllData() async {
    await _listItemsBox.clear();
    await _giftsBox.clear();
    await _eventsBox.clear();
    await _settingsBox.clear();
    await _friendsBox.clear();
  }

  static Future<void> close() async {
    await _listItemsBox.close();
    await _giftsBox.close();
    await _eventsBox.close();
    await _settingsBox.close();
    await _friendsBox.close();
  }
}