import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';

class FlameDayScreen extends StatelessWidget {
  const FlameDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('MMM d, yyyy');
    final timeFormatter = DateFormat('HH:mm');
    final formattedDate = dateFormatter.format(now);
    final formattedTime = timeFormatter.format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548), // Brown
        title: const Text(
          'Flame Day',
          style: TextStyle(fontFamily: 'Georgia', color: Colors.white),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                    fontFamily: 'Georgia',
                  ),
                ),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                    fontFamily: 'Georgia',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(currentRoute: '/flame_day'),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Flame Day Section',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                  color: Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'This is a placeholder for the Flame Day section.',
                style: TextStyle(fontSize: 18.0, color: Color(0xFF795548)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
