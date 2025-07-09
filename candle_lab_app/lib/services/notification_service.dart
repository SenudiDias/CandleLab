// lib/services/notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationItem {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final String candleName;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.candleName,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'scheduledDate': scheduledDate.toIso8601String(),
    'candleName': candleName,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        scheduledDate: DateTime.parse(json['scheduledDate']),
        candleName: json['candleName'],
        isRead: json['isRead'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );

  NotificationItem copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? scheduledDate,
    String? candleName,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      candleName: candleName ?? this.candleName,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final StreamController<List<NotificationItem>>
  _notificationStreamController =
      StreamController<List<NotificationItem>>.broadcast();

  static Stream<List<NotificationItem>> get notificationStream =>
      _notificationStreamController.stream;

  static final StreamController<int> _unreadCountStreamController =
      StreamController<int>.broadcast();

  static Stream<int> get unreadCountStream =>
      _unreadCountStreamController.stream;

  static const String _notificationsKey = 'app_notifications';

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

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Only required for Android 13+
    await requestNotificationPermission();

    await _loadNotifications();
  }

  static Future<void> _onNotificationTapped(
    NotificationResponse response,
  ) async {
    // Handle notification tap
    if (response.payload != null) {
      final Map<String, dynamic> payload = json.decode(response.payload!);
      final int notificationId = payload['id'];
      await markAsRead(notificationId);
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String candleName,
  }) async {
    try {
      final NotificationItem notification = NotificationItem(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        candleName: candleName,
        createdAt: DateTime.now(),
      );

      // Save to local storage
      await _saveNotification(notification);

      // Schedule the local notification
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'curing_channel',
            'Curing Reminders',
            channelDescription: 'Notifications for candle curing completion',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          );

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        notificationDetails,
        payload: json.encode({
          'id': id,
          'candleName': candleName,
          'type': 'curing_reminder',
        }),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Notification scheduled for: $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> _saveNotification(NotificationItem notification) async {
    final prefs = await SharedPreferences.getInstance();
    final List<NotificationItem> notifications = await getNotifications();

    // Remove existing notification with same ID
    notifications.removeWhere((n) => n.id == notification.id);

    // Add new notification
    notifications.add(notification);

    // Sort by scheduled date (newest first)
    notifications.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    final String notificationsJson = json.encode(
      notifications.map((n) => n.toJson()).toList(),
    );

    await prefs.setString(_notificationsKey, notificationsJson);

    // Update streams
    _notificationStreamController.add(notifications);
    _updateUnreadCount(notifications);
  }

  static Future<List<NotificationItem>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);

    if (notificationsJson != null) {
      final List<dynamic> jsonList = json.decode(notificationsJson);
      return jsonList.map((json) => NotificationItem.fromJson(json)).toList();
    }

    return [];
  }

  static Future<void> _loadNotifications() async {
    final notifications = await getNotifications();
    _notificationStreamController.add(notifications);
    _updateUnreadCount(notifications);
  }

  static Future<void> markAsRead(int notificationId) async {
    final List<NotificationItem> notifications = await getNotifications();
    final int index = notifications.indexWhere((n) => n.id == notificationId);

    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);

      final prefs = await SharedPreferences.getInstance();
      final String notificationsJson = json.encode(
        notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_notificationsKey, notificationsJson);

      // Update streams
      _notificationStreamController.add(notifications);
      _updateUnreadCount(notifications);
    }
  }

  static Future<void> markAllAsRead() async {
    final List<NotificationItem> notifications = await getNotifications();

    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }

    final prefs = await SharedPreferences.getInstance();
    final String notificationsJson = json.encode(
      notifications.map((n) => n.toJson()).toList(),
    );
    await prefs.setString(_notificationsKey, notificationsJson);

    // Update streams
    _notificationStreamController.add(notifications);
    _updateUnreadCount(notifications);
  }

  static Future<void> deleteNotification(int notificationId) async {
    final List<NotificationItem> notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == notificationId);

    final prefs = await SharedPreferences.getInstance();
    final String notificationsJson = json.encode(
      notifications.map((n) => n.toJson()).toList(),
    );
    await prefs.setString(_notificationsKey, notificationsJson);

    // Cancel the scheduled notification
    await _flutterLocalNotificationsPlugin.cancel(notificationId);

    // Update streams
    _notificationStreamController.add(notifications);
    _updateUnreadCount(notifications);
  }

  static Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);

    // Cancel all scheduled notifications
    await _flutterLocalNotificationsPlugin.cancelAll();

    // Update streams
    _notificationStreamController.add([]);
    _unreadCountStreamController.add(0);
  }

  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  static void _updateUnreadCount(List<NotificationItem> notifications) {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    _unreadCountStreamController.add(unreadCount);
  }

  static void dispose() {
    _notificationStreamController.close();
    _unreadCountStreamController.close();
  }
}
