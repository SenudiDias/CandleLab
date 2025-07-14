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
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final notification = NotificationData(
      id: id.toString(),
      userId: user.uid, // Set userId
      candleId: id.toString(),
      candleName: candleName,
      burningDay: scheduledDate,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await _firestoreService.saveNotification(notification);
  }

  // Mark a notification as read
  static Future<void> markAsRead(String notificationId) async {
    await _firestoreService.markNotificationAsRead(notificationId);
  }

  // Retrieve all notifications
  static Future<List<NotificationData>> getNotifications() async {
    return await _firestoreService.getAllNotifications();
  }
}
