class NotificationService {
  // We keep the functions here so your other code doesn't break,
  // but we removed all the complex logic that requires plugins.

  static Future<void> init() async {
    // Does nothing now
    print("Notifications disabled for this build.");
  }

  static Future<void> scheduleExpiryNotification({
    required int id,
    required String itemName,
    required DateTime expiryDate,
  }) async {
    // Does nothing now
  }

  static Future<void> cancelNotification(int id) async {
    // Does nothing now
  }
}