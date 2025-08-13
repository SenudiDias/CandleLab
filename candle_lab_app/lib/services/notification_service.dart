import 'package:firebase_auth/firebase_auth.dart';
import 'package:candle_lab_app/models/notification_data.dart';
import 'firestore_service.dart';
import 'local_notification_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirestoreService _firestoreService = FirestoreService();
  static final StreamController<void> _notificationTrigger =
      StreamController<void>.broadcast();
  static StreamSubscription<void>? _notificationSubscription;

  static Stream<int> get unreadCountStream =>
      _firestoreService.getUnreadNotificationCount();

  static Stream<void> get notificationTriggerStream =>
      _notificationTrigger.stream;

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String candleName,
    required String candleType,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final notification = NotificationData(
        id: id.toString(),
        userId: user.uid,
        candleId: id.toString(),
        candleName: candleName,
        candleType: candleType,
        burningDay: scheduledDate,
        isRead: true, // Set as read initially
        createdAt: DateTime.now(),
      );
      await _firestoreService.saveNotification(notification);

      // Schedule the local notification
      await LocalNotificationService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );
    } catch (e) {
      print('Error in notification scheduling: $e');
      // Notification will still be saved in Firestore even if local scheduling fails
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    await _firestoreService.markNotificationAsRead(notificationId);
    // No _processedNotificationIds; rely on manuallyReadAt
  }

  static Stream<List<NotificationData>> getNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestoreService.getAllNotificationsStream().map((notifications) {
      notifications.sort((a, b) {
        if (a.isRead != b.isRead) return a.isRead ? 1 : -1;
        return a.burningDay.compareTo(b.burningDay);
      });
      return notifications;
    });
  }

  static void startNotificationWatcher(BuildContext context) {
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      print('Checking notifications at $now');
      final notifications = await _firestoreService.getAllNotificationsOnce();

      for (var notification in notifications) {
        if (notification.burningDay.isBefore(now)) {
          if (notification.manuallyReadAt == null) {
            // Only mark as unread if it's time to notify
            await _firestoreService.markNotificationAsUnread(notification.id!);
            print('Triggering notification for ${notification.candleName}');
            _notificationTrigger.add(null);
          }
        }
      }
    });
  }

  // In notification_service.dart, update the checkAndTriggerInAppNotificationWithContext method:
  static void checkAndTriggerInAppNotificationWithContext(
    BuildContext context,
  ) {
    _notificationSubscription?.cancel();
    print('Setting up in-app notification listener with context');
    _notificationSubscription = notificationTriggerStream.listen(
      (_) async {
        print('In-app notification trigger received');
        if (!context.mounted) {
          print('Context not mounted, skipping dialog');
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final now = DateTime.now();
        final notifications = await _firestoreService.getAllNotificationsOnce();

        for (var notification in notifications) {
          if (notification.burningDay.isBefore(now) &&
              !notification.isRead &&
              notification.manuallyReadAt == null) {
            print('Showing in-app dialog for ${notification.candleName}');
            LocalNotificationService.showInAppNotification(
              context,
              'Candle Ready to Burn',
              '${notification.candleName} is ready for burning!',
              notification.id!,
            );
            break; // Exit after showing one dialog
          }
        }
      },
      onError: (error) {
        print('Error in notification stream: $error');
      },
      cancelOnError: true,
    );
  }

  static void disposeNotificationService() {
    _notificationSubscription?.cancel();
    _notificationTrigger.close();
  }
}
