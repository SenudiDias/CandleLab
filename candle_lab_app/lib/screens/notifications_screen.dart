import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:candle_lab_app/models/notification_data.dart';
import 'custom_drawer.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548),
        title: const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'Georgia', color: Colors.white),
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
                            fontSize: 10,
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
        child: FutureBuilder<List<NotificationData>>(
          future: NotificationService.getNotifications(),
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
                    fontSize: 16.0,
                    fontFamily: 'Georgia',
                    color: Color(0xFF5D4037),
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isOverdue = notification.burningDay.isBefore(
                  DateTime.now(),
                );
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      notification.candleName,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Georgia',
                        color: const Color(0xFF5D4037),
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Ready to burn on ${DateFormat('MMM d, yyyy, h:mm a').format(notification.burningDay)}',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Georgia',
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    trailing: isOverdue && !notification.isRead
                        ? IconButton(
                            icon: const Icon(
                              Icons.check,
                              color: Color(0xFF795548),
                            ),
                            onPressed: () async {
                              await NotificationService.markAsRead(
                                notification.id!,
                              );
                              setState(() {}); // Refresh the UI
                            },
                          )
                        : null,
                    tileColor: notification.isRead
                        ? null
                        : const Color(0xFF5D4037).withOpacity(0.1),
                    onTap: () async {
                      if (!notification.isRead) {
                        await NotificationService.markAsRead(notification.id!);
                        setState(() {}); // Refresh the UI
                      }
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
}
