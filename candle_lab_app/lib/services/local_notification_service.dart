import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:candle_lab_app/services/notification_service.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static OverlayEntry? _overlayEntry; // Track the overlay for cleanup

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'candle_reminders',
      'Candle Reminders',
      importance: Importance.max,
      playSound: true,
    );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _onNotificationResponse(
    NotificationResponse response,
  ) async {
    // Handle notification tap if needed
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'candle_reminders',
          'Candle Reminders',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tz.TZDateTime scheduledTzDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'candle_reminders',
            'Candle Reminders',
            importance: Importance.max,
            priority: Priority.high,
          );

      const DarwinNotificationDetails iOSNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSNotificationDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTzDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode
            .inexactAllowWhileIdle, // Changed from exact to inexact
      );
    } catch (e) {
      print('Error scheduling notification: $e');
      // Fallback to immediate notification if scheduling fails
      await showNotification(title: title, body: body);
    }
  }

  static void showInAppNotification(
    BuildContext context,
    String title,
    String body,
    String notificationId,
  ) {
    print(
      'Attempting to show in-app dialog with context: ${context.toString()}, mounted: ${context.mounted}',
    );
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              if (_overlayEntry != null && _overlayEntry!.mounted) {
                _overlayEntry!.remove();
                _overlayEntry = null;
              }
              await NotificationService.markAsRead(notificationId);
            },
          ),
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () {
              if (_overlayEntry != null && _overlayEntry!.mounted) {
                _overlayEntry!.remove();
                _overlayEntry = null;
              }
            },
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    print(
      'In-app dialog inserted into overlay, entry mounted: ${_overlayEntry!.mounted}',
    );
  }
}
