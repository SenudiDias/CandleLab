import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'making_screen.dart';
import 'flame_day_screen.dart';
import 'analysis_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';

class CustomDrawer extends StatefulWidget {
  final String currentRoute;

  const CustomDrawer({super.key, required this.currentRoute});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isContentVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Container(
        color: colorScheme.surface,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(),
                accountName: Text(
                  user?.displayName ?? 'User',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                accountEmail: Text(
                  user?.email ?? 'No email',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: colorScheme.surface,
                  child: Text(
                    user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
                margin: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: AnimatedOpacity(
                opacity: _isContentVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  children: [
                    _buildDrawerItem(
                      context,
                      title: 'Making',
                      route: '/making',
                      isSelected: widget.currentRoute == '/making',
                      icon: Icons.lightbulb,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MakingScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Flame Day',
                      route: '/flame_day',
                      isSelected: widget.currentRoute == '/flame_day',
                      icon: Icons.local_fire_department,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FlameDayScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Analysis Charts',
                      route: '/analysis',
                      isSelected: widget.currentRoute == '/analysis',
                      icon: Icons.bar_chart,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AnalysisScreen(),
                          ),
                        );
                      },
                    ),
                    StreamBuilder<int>(
                      stream: NotificationService.unreadCountStream,
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data ?? 0;
                        return _buildNotificationItem(
                          context,
                          title: 'Notifications',
                          route: '/notifications',
                          isSelected: widget.currentRoute == '/notifications',
                          unreadCount: unreadCount,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 16.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.logout, color: colorScheme.primary, size: 20.0),
                    const SizedBox(width: 8.0),
                    Text(
                      'Logout',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required String route,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.secondary, size: 20.0),
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.secondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? colorScheme.primary.withOpacity(0.1) : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      onTap: onTap,
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String route,
    required bool isSelected,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        Icons.notifications,
        color: colorScheme.secondary,
        size: 20.0,
      ),
      title: Row(
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: colorScheme.error,
                borderRadius: BorderRadius.circular(10.0),
              ),
              constraints: const BoxConstraints(
                minWidth: 20.0,
                minHeight: 20.0,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
      tileColor: isSelected ? colorScheme.primary.withOpacity(0.1) : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      onTap: onTap,
    );
  }
}
