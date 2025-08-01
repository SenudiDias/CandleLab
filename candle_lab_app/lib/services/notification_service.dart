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

  // Update the getNotifications() method in notification_service.dart
  static Stream<List<NotificationData>> getNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _firestoreService.getAllNotificationsStream().asyncMap((
      notifications,
    ) async {
      final now = DateTime.now();
      for (var notification in notifications) {
        if (notification.burningDay.isBefore(now)) {
          // Only mark as unread if it was never manually read
          if (notification.isRead &&
              (notification.manuallyReadAt == null ||
                  notification.manuallyReadAt!.isBefore(
                    notification.burningDay,
                  ))) {
            await _firestoreService.markNotificationAsUnread(notification.id!);
            notification.isRead = false;
          }
        }
      }
      // Sort with unread first, then by burning date
      notifications.sort((a, b) {
        if (a.isRead != b.isRead) {
          return a.isRead ? 1 : -1;
        }
        return a.burningDay.compareTo(b.burningDay);
      });
      return notifications;
    });
  }
}
