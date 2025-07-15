import 'package:firebase_auth/firebase_auth.dart';
import 'package:candle_lab_app/models/notification_data.dart';
import 'firestore_service.dart';

class NotificationService {
  static final FirestoreService _firestoreService = FirestoreService();

  // Stream for unread notification count
  static Stream<int> get unreadCountStream =>
      _firestoreService.getUnreadNotificationCount();

  // Schedule an in-app notification for the curing reminder
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String candleName,
    required String candleType, // Already defined as a required parameter
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final notification = NotificationData(
      id: id.toString(),
      userId: user.uid,
      candleId: id.toString(),
      candleName: candleName,
      candleType: candleType, // Pass the candleType parameter
      burningDay: scheduledDate,
      isRead: true,
      createdAt: DateTime.now(),
    );
    await _firestoreService.saveNotification(notification);
  }

  // Mark a notification as read
  static Future<void> markAsRead(String notificationId) async {
    await _firestoreService.markNotificationAsRead(notificationId);
  }

  // Stream of all notifications with unread window logic
  static Stream<List<NotificationData>> getNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _firestoreService.getAllNotificationsStream().map((notifications) {
      final now = DateTime.now();
      for (var notification in notifications) {
        final oneHourBefore = notification.burningDay.subtract(
          const Duration(hours: 1),
        );
        final oneHourAfter = notification.burningDay.add(
          const Duration(hours: 1),
        );
        if (now.isAfter(oneHourBefore) &&
            now.isBefore(oneHourAfter) &&
            notification.isRead) {
          _firestoreService.markNotificationAsRead(notification.id!).then((_) {
            notification.isRead = false;
          });
        } else if (now.isAfter(oneHourAfter) && !notification.isRead) {
          _firestoreService.markNotificationAsRead(notification.id!).then((_) {
            notification.isRead = true;
          });
        }
      }
      return notifications;
    });
  }
}
