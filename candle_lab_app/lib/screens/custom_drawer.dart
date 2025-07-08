import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'making_screen.dart';
import 'flame_day_screen.dart';
import 'analysis_screen.dart';
import 'login_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String currentRoute;

  const CustomDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: Container(
        color: const Color(0xFFF5F5DC), // Beige background
        child: Column(
          children: [
            // User details header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF795548), // Brown
              ),
              accountName: Text(
                user?.displayName ?? 'User',
                style: const TextStyle(fontFamily: 'Georgia', fontSize: 18.0),
              ),
              accountEmail: Text(
                user?.email ?? 'No email',
                style: const TextStyle(fontSize: 14.0),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 24.0,
                    color: Color(0xFF5D4037),
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
            ),
            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    title: 'Making',
                    route: '/making',
                    isSelected: currentRoute == '/making',
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
                    isSelected: currentRoute == '/flame_day',
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
                    isSelected: currentRoute == '/analysis',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnalysisScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Logout button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D4037), // Deep brown
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontFamily: 'Georgia',
                  ),
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
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          fontFamily: 'Georgia',
          color: const Color(0xFF5D4037),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? const Color(0xFF5D4037).withOpacity(0.1) : null,
      onTap: onTap,
    );
  }
}
