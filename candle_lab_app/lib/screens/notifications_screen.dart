import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:candle_lab_app/models/notification_data.dart';
import 'custom_drawer.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _MakingScreen8State();
}

class _MakingScreen8State extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548),
        title: const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
        ),
        leading: Builder(
          builder: (context) => StreamBuilder<int>(
            stream: NotificationService.unreadCountStream,
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      drawer: const CustomDrawer(currentRoute: '/notifications'),
      body: SafeArea(
        child: StreamBuilder<List<NotificationData>>(
          stream: NotificationService.getNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
              return const Center(
                child: Text(
                  'No notifications available',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontFamily: 'Poppins',
                    color: Color(0xFF5D4037),
                  ),
                ),
              );
            }
            // Update the ListView.builder in notifications_screen.dart
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      notification.candleName,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF5D4037),
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Ready to burn on ${DateFormat('MMM d, yyyy, h:mm a').format(notification.burningDay)}',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF5D4037),
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    tileColor: notification.isRead
                        ? null
                        : const Color(0xFF5D4037).withOpacity(0.1),
                    onTap: () async {
                      await _showNotificationDetails(context, notification);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Update the _showNotificationDetails method in notifications_screen.dart
  Future<void> _showNotificationDetails(
    BuildContext context,
    NotificationData notification,
  ) async {
    final batchDate = notification.createdAt;
    final batchTime = DateFormat('h:mm a').format(batchDate);
    final burnDate = DateFormat(
      'MMM d, yyyy, h:mm a',
    ).format(notification.burningDay);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sample Name: ${notification.candleName}'),
              Text('Candle Type: ${notification.candleType}'),
              Text(
                'Batch Date: ${DateFormat('MMM d, yyyy').format(batchDate)}',
              ),
              Text('Batch Time: $batchTime'),
              Text('Burn Date: $burnDate'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (!notification.isRead) {
                  await NotificationService.markAsRead(notification.id!);
                  // Update local state immediately
                  notification.isRead = true;
                }
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
