import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Uses the capital 'Z' as requested by the package
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // 👇 FIX: The tooltip says the parameter name MUST be 'settings'
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleExpiryNotification({
    required int id,
    required String itemName,
    required DateTime expiryDate,
  }) async {
    final scheduleTime = expiryDate.subtract(const Duration(days: 1));

    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      scheduleTime.year,
      scheduleTime.month,
      scheduleTime.day,
      9, 0,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: 'Food Expiring Soon!',
      body: 'Your $itemName expires tomorrow. Better use it up!',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_channel_id',
          'Expiry Alerts',
          channelDescription: 'Notifications for food expiration',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }
}